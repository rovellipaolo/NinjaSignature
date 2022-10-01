#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::Spec;

use lib './lib';
use Signature::Yara::YaraSignature;

my $name = "TestYaraSignature";

describe "YaraSignature happy case" => sub {
    my @strings = (
        "41 41 42 42",
        "43 43 44 44 45 45 46 46",
        "30 30 46 46"
    );
    my $sut = YaraSignature->new(
        name   => $name,
        strings => \@strings
    );

    it "returns correct name" => sub {
        ok($sut->name eq $name);
    };

    it "returns correct strings list" => sub {
        is_deeply($sut->strings, \@strings);
    };

    it "returns is_empty() false" => sub {
        ok(!$sut->is_empty());
    };

    it "returns correct dump()" => sub {
        ok($sut->dump() eq qq{rule $name
{
    strings:
        \$s0 = {$strings[0]}\n        \$s1 = {$strings[1]}\n        \$s2 = {$strings[2]}

    condition:
        \$s0 and \$s1 and \$s2
}});
    };
};

describe "YaraSignature with empty signature" => sub {
    my @empty_strings = ();
    my $sut = YaraSignature->new(
        name   => $name,
        strings => \@empty_strings
    );

    it "returns empty strings list" => sub {
        ok(@{ $sut->strings } == 0);
    };

    it "returns is_empty() true when strings list is empty" => sub {
        ok($sut->is_empty());
    };
};

runtests if !caller;
