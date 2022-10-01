#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::Exception;
use Test::Spec;

use lib './lib';
use Signature::GeneratorFactory;

describe "GeneratorFactory build" => sub {
    it "creates a SimpleGenerator when type is simple" => sub {
        my $sut = GeneratorFactory::build(GeneratorFactory::SIMPLE);
        isa_ok($sut, "SimpleGenerator");
    };

    it "creates a YaraGenerator when type is yara" => sub {
        my $sut = GeneratorFactory::build(GeneratorFactory::YARA);
        isa_ok($sut, "YaraGenerator");
    };

    it "fails when type does not exist" => sub {
        dies_ok { GeneratorFactory::build("NOT_EXISTING_TYPE") };
    };
};

runtests if !caller;
