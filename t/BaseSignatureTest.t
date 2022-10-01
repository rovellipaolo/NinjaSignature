#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::Spec;

use lib './lib';
use Signature::BaseSignature;

describe "BaseSignature" => sub {
    my $name = "TestBaseSignature";
    my $sut = BaseSignature->new( name => $name );

    it "returns correct name" => sub {
        ok($sut->name eq $name);
    };

    it "returns is_empty() false" => sub {
        ok(!$sut->is_empty());
    };

    it "returns correct dump()" => sub {
        ok($sut->dump() eq $name);
    };
};

runtests if !caller;
