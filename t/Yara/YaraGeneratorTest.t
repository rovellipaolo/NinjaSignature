#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::MockObject;
use Test::MockModule;
use Test::More;

use lib './lib';
use Signature::Yara::YaraGenerator;


# MOCK: Signature::Utils::File
my $file_mock = Test::MockModule->new('File');
$file_mock->mock('open', sub { return 0; });
my $read_calls = 0;
$file_mock->mock('read', sub {
    my $byte;
    if ($read_calls >= 0 && $read_calls < 4) {
        $byte = "A";
    } elsif ($read_calls >= 4 && $read_calls < 8) {
        $byte = "B";
    } else {
        $byte = undef;
    }
    $read_calls++;
    return $byte;
});
$file_mock->mock('close', sub { });

my $name = "TestYaraSignature";
my @files = ("./t/data/sample1", "./t/data/sample2");
my $min_string_bytes = 4;

my $sut = YaraGenerator->new(min_string_bytes => $min_string_bytes);

# TEST: min_string_bytes happy case
ok($sut->min_string_bytes eq $min_string_bytes, "YaraGenerator min_string_bytes is correct");

# TEST: generate happy case
my $signature = $sut->generate($name, @files);
my @expected_strings = ("41 41 42 42");
is_deeply($signature->strings, \@expected_strings, "YaraGenerator signature->strings is correct");

# TEST: empty file
$file_mock->mock('read', sub { return undef; });
my $empty_signature = $sut->generate($name, @files);
ok($empty_signature->is_empty(),        "YaraGenerator signature->is_empty is true when file is empty");
ok(@{ $empty_signature->strings } == 0, "YaraGenerator signature->strings is empty when file is empty");

# TEST: match smaller than min_string_bytes
my $big_min_string_bytes = 8;
$sut = YaraGenerator->new(min_string_bytes => $big_min_string_bytes);
$signature = $sut->generate($name, @files);
ok($empty_signature->is_empty(),        "YaraGenerator signature->is_empty is true when min_string_bytes is bigger than match");
ok(@{ $empty_signature->strings } == 0, "YaraGenerator signature->strings is empty when min_string_bytes is bigger than match");

# TEST: _should_add_string
$sut = YaraGenerator->new(min_string_bytes => $min_string_bytes);
ok(!$sut->_should_add_string("41", ()),                       "YaraGenerator _should_add_string is false when string is smaller than min_string_bytes");
ok(!$sut->_should_add_string("4141", ()),                     "YaraGenerator _should_add_string is false when string is equal to min_string_bytes");
ok(!$sut->_should_add_string("41414242", ()),                 "YaraGenerator _should_add_string is false when string is greater than min_string_bytes but not enough");
ok($sut->_should_add_string("41 41 42 42", ()),               "YaraGenerator _should_add_string is true when string is equal to (min_string_bytes * 2) + (min_string_bytes -1) and there is no previous string");
ok($sut->_should_add_string("41 41 42 42", ("43 43 44 44")),  "YaraGenerator _should_add_string is true when string is equal to (min_string_bytes * 2) + (min_string_bytes -1) and string is not duplicated");
ok(!$sut->_should_add_string("41 41 42 42", ("41 41 42 42")), "YaraGenerator _should_add_string is false when string is equal to (min_string_bytes * 2) + (min_string_bytes -1) but is duplicated");
ok($sut->_should_add_string("41 41 42 42 43 43", ()),         "YaraGenerator _should_add_string is true when string is greater than (min_string_bytes * 2) + (min_string_bytes -1)  and string is not duplicated");

done_testing();

