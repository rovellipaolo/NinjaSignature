#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::More;

use lib './lib';
use Signature::Simple::SimpleSignature;
use Signature::Simple::ByteSequence;


my $name = "TestSimpleSignature";
my @sha256 = (
    "266cdd168de3e6363ac76059905c1608ce126e6c7f8e4a1fcc7389f9d7f9f897",
    "91638dbf219262900aea9b13dbe9b0528b7d8056f16ba1d52d2a38b60cb7c90a"
);
my @bytes = (
    ByteSequence->new(offset => 0, value => "41 41 42 42"),
    ByteSequence->new(offset => 22, value => "41 41 42 42 43 43 44 44 45 45 46 46"),
    ByteSequence->new(offset => 42, value => "30 30 46 46 0A")
);

# TEST: happy case
my $sut = SimpleSignature->new(
    name   => $name,
    sha256 => \@sha256,
    bytes  => \@bytes
);
ok($sut->name eq $name,           "SimpleSignature name is correct");
is_deeply($sut->sha256, \@sha256, "SimpleSignature sha256 is correct");
is_deeply($sut->bytes, \@bytes,   "SimpleSignature bytes is correct");
ok(!$sut->is_empty(),             "SimpleSignature is_empty is correct");
ok($sut->dump() eq qq{{
    name: "$name"
    sha256:
        - $sha256[0]\n        - $sha256[1]
    bytes:
        @{[$bytes[0]->offset]}: @{[$bytes[0]->value]}\n        @{[$bytes[1]->offset]}: @{[$bytes[1]->value]}\n        @{[$bytes[2]->offset]}: @{[$bytes[2]->value]}
}},                               "SimpleSignature dump is correct");

# TEST: empty signature
my @empty_sha256 = ();
my @empty_bytes = ();
$sut = SimpleSignature->new(
    name   => $name,
    sha256 => \@empty_sha256,
    bytes  => \@empty_bytes
);
ok($sut->is_empty(), "SimpleSignature is_empty is correct when bytes is empty");

done_testing();
