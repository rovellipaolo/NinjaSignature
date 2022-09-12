#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::MockObject;
use Test::MockModule;
use Test::More;

use lib './lib';
use Signature::Simple::SimpleGenerator;


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

# MOCK: Digest::SHA
my $sha_mock = Test::MockObject->new();
$sha_mock->mock('addfile', sub { return $sha_mock; });
my $hexdigest_calls = 0;
$sha_mock->mock('hexdigest', sub {
    my $hexdigest;
    if ($hexdigest_calls == 0) {
        $hexdigest = "AAA000";
    } elsif ($hexdigest_calls == 1) {
        $hexdigest = "BBB111";
    } else {
        $hexdigest = undef;
    }
    $hexdigest_calls++;
    return $hexdigest;
});
my $digest_mock = Test::MockModule->new('Digest::SHA');
$digest_mock->mock('new', sub { return $sha_mock; });

my $name = "TestSimpleSignature";
my @files = ("./t/data/sample1", "./t/data/sample2");
my $min_string_bytes = 4;

my $sut = SimpleGenerator->new(min_string_bytes => $min_string_bytes);

# TEST: min_string_bytes happy case
ok($sut->min_string_bytes eq $min_string_bytes, "SimpleGenerator min_string_bytes is correct");

# TEST: generate happy case
my $signature = $sut->generate($name, @files);
my @expected_sha256 = ("AAA000", "BBB111");
is_deeply($signature->sha256, \@expected_sha256, "SimpleGenerator signature->sha256 is correct");
my @expected_bytes = (ByteSequence->new(offset => 0, value => "41 41 42 42"));
is_deeply($signature->bytes, \@expected_bytes,   "SimpleGenerator signature->bytes is correct");

# TEST: empty file
$file_mock->mock('read', sub { return undef; });
$sha_mock->mock('hexdigest', sub { return "" });
my $empty_signature = $sut->generate($name, @files);
ok($empty_signature->is_empty(), "SimpleGenerator signature->is_empty is true when file is empty");
ok(@{ $empty_signature->bytes } == 0, "SimpleGenerator signature->bytes is empty when file is empty");

# TEST: match smaller than min_string_bytes
my $big_min_string_bytes = 8;
$sut = SimpleGenerator->new(min_string_bytes => $big_min_string_bytes);
$signature = $sut->generate($name, @files);
ok($empty_signature->is_empty(), "SimpleGenerator signature->is_empty is true when min_string_bytes is bigger than match");
ok(@{ $empty_signature->bytes } == 0, "SimpleGenerator signature->bytes is empty when min_string_bytes is bigger than match");

done_testing();

