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

# TEST: _is_first_file
ok(BaseGenerator::_is_first_file(0), "BaseGenerator _is_first_file returns true if the index is 0");
ok(!BaseGenerator::_is_first_file(1), "BaseGenerator _is_first_file returns false if the index is not 0");

# TEST: _is_last_file
ok(BaseGenerator::_is_last_file(0, ("FH0")), "BaseGenerator _is_last_file returns true if the index is 0 and there is only one file");
ok(BaseGenerator::_is_last_file(1, ("FH0", "FH1")), "BaseGenerator _is_last_file returns true if the index is 1 and there are two files");
ok(!BaseGenerator::_is_last_file(0, ("FH0", "FH1")), "BaseGenerator _is_last_file returns false if the index is 0 and there are two files");
ok(!BaseGenerator::_is_last_file(1, ("FH0", "FH1", "FH2")), "BaseGenerator _is_last_file returns false if the index is 1 and there are three files");

# TEST: _append_byte_to_string
ok(BaseGenerator::_append_byte_to_string("A", undef) eq "41", "BaseGenerator append byte to undefined string correctly");
ok(BaseGenerator::_append_byte_to_string("A", "") eq "41", "BaseGenerator append byte to empty string correctly");
ok(BaseGenerator::_append_byte_to_string("B", "41") eq "41 42", "BaseGenerator append byte to non-empty, one byte string correctly");
ok(BaseGenerator::_append_byte_to_string("C", "41 42") eq "41 42 43", "BaseGenerator append byte to non-empty, two bytes string correctly");

done_testing();
