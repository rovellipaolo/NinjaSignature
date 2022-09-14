#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::More;

use lib './lib';
use Signature::BaseSignature;

my $name = "TestBaseSignature";

my $sut = BaseSignature->new( name => $name );

# TEST: happy case
ok( $sut->name eq $name,   "BaseSignature name is correct" );
ok( !$sut->is_empty(),     "BaseSignature is_empty is correct" );
ok( $sut->dump() eq $name, "BaseSignature dump is correct" );

done_testing();
