#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::More;

use lib './lib';
use Signature::Simple::ByteSequence;


my $offset = 0;
my $value = "41 41 42 42";

my $sut = ByteSequence->new(offset => $offset, value => $value);

# TEST: happy case
ok($sut->offset == $offset, "ByteSequence offset is correct");
ok($sut->value eq $value,   "ByteSequence value is correct");
ok($sut->length() == 11,    "ByteSequence length is correct");

done_testing();
