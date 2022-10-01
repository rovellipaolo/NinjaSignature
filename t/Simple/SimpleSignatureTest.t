#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::Spec;

use lib './lib';
use Signature::Simple::SimpleSignature;
use Signature::Simple::ByteSequence;

my $name = "TestSimpleSignature";

describe "SimpleSignature happy case" => sub {
    my @sha256 = (
        "266cdd168de3e6363ac76059905c1608ce126e6c7f8e4a1fcc7389f9d7f9f897",
        "91638dbf219262900aea9b13dbe9b0528b7d8056f16ba1d52d2a38b60cb7c90a"
    );
    my @bytes = (
        ByteSequence->new(offset => 0, value => "41 41 42 42"),
        ByteSequence->new(offset => 22, value => "41 41 42 42 43 43 44 44 45 45 46 46"),
        ByteSequence->new(offset => 42, value => "30 30 46 46 0A")
    );
    my $sut = SimpleSignature->new(
        name   => $name,
        sha256 => \@sha256,
        bytes  => \@bytes
    );

    it "returns correct name" => sub {
        ok($sut->name eq $name);
    };

    it "returns correct sha256 list" => sub {
        is_deeply($sut->sha256, \@sha256);
    };

    it "returns correct bytes list" => sub {
        is_deeply($sut->bytes, \@bytes);
    };

    it "returns is_empty() false" => sub {
        ok(!$sut->is_empty());
    };

    it "returns correct dump()" => sub {
        ok($sut->dump() eq qq{{
    name: "$name"
    sha256:
        - $sha256[0]\n        - $sha256[1]
    bytes:
        @{[$bytes[0]->offset]}: @{[$bytes[0]->value]}\n        @{[$bytes[1]->offset]}: @{[$bytes[1]->value]}\n        @{[$bytes[2]->offset]}: @{[$bytes[2]->value]}
}});
    };
};

describe "SimpleSignature with empty signature" => sub {
    my @empty_sha256 = ();
    my @empty_bytes = ();
    my $sut = SimpleSignature->new(
        name   => $name,
        sha256 => \@empty_sha256,
        bytes  => \@empty_bytes
    );

    it "returns empty sha256 list" => sub {
        ok(@{ $sut->sha256 } == 0);
    };

    it "returns empty bytes list" => sub {
        ok(@{ $sut->bytes } == 0);
    };

    it "returns is_empty() true when bytes list is empty" => sub {
        ok($sut->is_empty());
    };
};

runtests if !caller;
