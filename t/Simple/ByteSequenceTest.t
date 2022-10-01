#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::Spec;

use lib './lib';
use Signature::Simple::ByteSequence;

describe "ByteSequence" => sub {
    my $offset = 0;
    my $value = "41 41 42 42";
    my $sut = ByteSequence->new(offset => $offset, value => $value);

    it "returns correct offset" => sub {
        ok($sut->offset == $offset);
    };

    it "returns correct value" => sub {
        ok($sut->value eq $value);
    };

    it "returns correct length()" => sub {
        ok($sut->length() == 11);
    };
};

runtests if !caller;
