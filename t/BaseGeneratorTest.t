#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::Exception;
use Test::MockModule;
use Test::More;

use lib './lib';
use Signature::BaseGenerator;


# MOCK: Signature::Utils::File
my $file_mock = Test::MockModule->new('File');
$file_mock->mock('open', sub { return 0; });
$file_mock->mock('close', sub { });

my @files = ("./t/data/sample1", "./t/data/sample2");

# TEST: happy case
my @fhs = BaseGenerator::_open_all_files(@files);
BaseGenerator::_close_all_files(@fhs);
my @expected_fhs = (0, 0);
is_deeply(\@fhs, \@expected_fhs, "BaseGenerator open all files correctly");

# TEST: open fails
$file_mock->mock('open', sub { die "DIE TEST"; });
dies_ok { BaseGenerator::_open_all_files(@files) } "BaseGenerator fails to open all files correctly";

# TEST: close fails
$file_mock->mock('close', sub { die "DIE TEST" });
dies_ok { BaseGenerator::_close_all_files(@fhs) } "BaseGenerator fails to close all files correctly";

done_testing();
