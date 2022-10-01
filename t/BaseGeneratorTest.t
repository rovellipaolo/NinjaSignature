#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Test::Exception;
use Test::MockModule;
use Test::Spec;

use lib './lib';
use Signature::BaseGenerator;

# MOCK: Signature::Utils::File
my $file_mock = Test::MockModule->new('File');
$file_mock->mock( 'open',  sub { return 0; } );
$file_mock->mock( 'close', sub { } );

describe "BaseGenerator _open_all_files" => sub {
    my @files = ( "./t/data/sample1", "./t/data/sample2" );

    it "opens all files correctly" => sub {
        my @fhs = BaseGenerator::_open_all_files(@files);
        BaseGenerator::_close_all_files(@fhs);
        my @expected_fhs = ( 0, 0 );
        is_deeply(\@fhs, \@expected_fhs);
    };

    it "fails to open a file" => sub {
        $file_mock->mock( 'open', sub { die("DIE TEST"); } );
        dies_ok { BaseGenerator::_open_all_files(@files) };
    };
};

describe "BaseGenerator _close_all_files" => sub {
    my @fhs = ( 0, 0 );

    it "fails to close a file" => sub {
        $file_mock->mock( 'close', sub { die("DIE TEST") } );
        dies_ok { BaseGenerator::_close_all_files(@fhs) };
    };
};

describe "BaseGenerator _is_first_file" => sub {
    it "returns true if the index is 0" => sub {
        ok(BaseGenerator::_is_first_file(0));
    };

    it "returns false if the index is not 0" => sub {
        ok(!BaseGenerator::_is_first_file(1));
    };
};

describe "BaseGenerator _is_last_file" => sub {
    it "returns true if the index is 0 and there is only one file" => sub {
        ok(BaseGenerator::_is_last_file( 0, ("FH0") ));
    };

    it "returns true if the index is 1 and there are two files" => sub {
        ok(BaseGenerator::_is_last_file( 1, ( "FH0", "FH1" ) ));
    };

    it "returns false if the index is 0 and there are two files" => sub {
        ok(!BaseGenerator::_is_last_file( 0, ( "FH0", "FH1" ) ));
    };

    it "returns false if the index is 1 and there are three files" => sub {
        ok(!BaseGenerator::_is_last_file( 1, ( "FH0", "FH1", "FH2" ) ));
    };
};

describe "BaseGenerator _append_byte_to_string" => sub {
    it "appends a byte to an undefined string" => sub {
        ok(BaseGenerator::_append_byte_to_string( "A", undef ) eq "41");
    };

    it "appends a byte to an empty string" => sub {
        ok(BaseGenerator::_append_byte_to_string( "A", "" ) eq "41");
    };

    it "appends a byte to a non-empty, one-byte string" => sub {
        ok(BaseGenerator::_append_byte_to_string( "B", "41" ) eq "41 42");
    };

    it "appends a byte to a non-empty, two-bytes string" => sub {
        ok(BaseGenerator::_append_byte_to_string( "C", "41 42" ) eq "41 42 43");
    };
};

runtests if !caller;
