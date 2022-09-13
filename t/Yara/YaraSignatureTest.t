#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::More;

use lib './lib';
use Signature::Yara::YaraSignature;


my $name = "TestYaraSignature";
my @strings = (
    "41 41 42 42",
    "43 43 44 44 45 45 46 46",
    "30 30 46 46"
);

# TEST: happy case
my $sut = YaraSignature->new(
    name   => $name,
    strings => \@strings
);
ok($sut->name eq $name,             "YaraSignature name is correct");
is_deeply($sut->strings, \@strings, "YaraSignature strings is correct");
ok(!$sut->is_empty(),               "YaraSignature is_empty is correct");
ok($sut->dump() eq qq{rule $name
{
    strings:
        \$s0 = {$strings[0]}\n        \$s1 = {$strings[1]}\n        \$s2 = {$strings[2]}

    condition:
        \$s0 and \$s1 and \$s2
}},                                 "YaraSignature dump is correct");

# TEST: empty signature
my @empty_strings = ();
$sut = YaraSignature->new(
    name   => $name,
    strings => \@empty_strings
);
ok($sut->is_empty(), "YaraSignature is_empty is correct when strings is empty");

done_testing();
