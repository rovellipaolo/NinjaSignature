#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::Exception;
use Test::More;

use lib './lib';
use Signature::GeneratorFactory;


my %types = (
    GeneratorFactory::SIMPLE => "SimpleGenerator",
    GeneratorFactory::YARA => "YaraGenerator"
);

# TEST: happy case
for my $key (keys %types) {
    my $sut = GeneratorFactory::build($key);
    isa_ok($sut, $types{$key}, "GeneratorFactory build for '$key' type is correct");
}

# TEST: build fails
dies_ok { GeneratorFactory::build("NOT_EXISTING_TYPE") } "GeneratorFactory build for 'NOT_EXISTING_TYPE' type fails";

done_testing();
