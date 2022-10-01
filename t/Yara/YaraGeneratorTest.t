#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::MockObject;
use Test::MockModule;
use Test::Spec;

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

describe "YaraGenerator min_string_bytes" => sub {
    my $sut = YaraGenerator->new(min_string_bytes => $min_string_bytes);

    it "returns correct value" => sub {
        ok($sut->min_string_bytes eq $min_string_bytes);
    };
};

describe "YaraGenerator generate(...) happy case" => sub {
    my $sut = YaraGenerator->new(min_string_bytes => $min_string_bytes);
    my $signature = $sut->generate($name, @files);

    it "returns correct signature->strings list" => sub {
        my @expected_strings = ("41 41 42 42");
        is_deeply($signature->strings, \@expected_strings);
    };
};

describe "YaraGenerator generate(...) with match smaller than min_string_bytes" => sub {
    my $big_min_string_bytes = 8;
    my $sut = YaraGenerator->new(min_string_bytes => $big_min_string_bytes);
    my $empty_signature = $sut->generate($name, @files);

    it "returns signature->is_empty() true when min_string_bytes is bigger than match" => sub {
        ok($empty_signature->is_empty());
    };

    it "returns empty signature->strings list when min_string_bytes is bigger than match" => sub {
        ok(@{ $empty_signature->strings } == 0);
    };
};

describe "YaraGenerator generate(...) with empty signature" => sub {
    $file_mock->mock('read', sub { return undef; });
    my $sut = YaraGenerator->new(min_string_bytes => $min_string_bytes);
    my $empty_signature = $sut->generate($name, @files);

    it "returns signature->is_empty() true when file is empty" => sub {
        ok($empty_signature->is_empty());
    };

    it "returns empty signature->strings list when file is empty" => sub {
        ok(@{ $empty_signature->strings } == 0);
    };
};

describe "YaraGenerator _should_add_string(...)" => sub {
    my $sut = YaraGenerator->new(min_string_bytes => $min_string_bytes);

    it "returns false when string is smaller than min_string_bytes" => sub {
        ok(!$sut->_should_add_string("41", ()));
    };

    it "returns false when string is equal to min_string_bytes" => sub {
        ok(!$sut->_should_add_string("4141", ()));
    };

    it "returns false when string is greater than min_string_bytes but not enough" => sub {
        ok(!$sut->_should_add_string("41414242", ()));
    };

    it "returns true when string is equal to (min_string_bytes * 2) + (min_string_bytes -1) and there is no previous string" => sub {
        ok($sut->_should_add_string("41 41 42 42", ()));
    };

    it "returns true when string is equal to (min_string_bytes * 2) + (min_string_bytes -1) and string is not duplicated" => sub {
        ok($sut->_should_add_string("41 41 42 42", ("43 43 44 44")));
    };

    it "returns false when string is equal to (min_string_bytes * 2) + (min_string_bytes -1) but is duplicated" => sub {
        ok(!$sut->_should_add_string("41 41 42 42", ("41 41 42 42")));
    };

    it "returns true when string is greater than (min_string_bytes * 2) + (min_string_bytes -1)  and string is not duplicated" => sub {
        ok($sut->_should_add_string("41 41 42 42 43 43", ()));
    };
};

runtests if !caller;
