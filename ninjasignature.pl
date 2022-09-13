#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';

use Getopt::Long;

use lib './lib';
use Signature::Simple::SimpleGenerator;

sub main {
    my $name = "Generic";
    my @files = ();

    GetOptions (
        "name=s" => \$name,
        "file=s" => \@files,
        "files=s{2,}" => \@files
    );

    if ( @files != 2 ) {
        die "Can compare only two files at a time!";
    }

    my $signature = SimpleGenerator->new(min_string_bytes => 4)->generate($name, @files);
    if ($signature->is_empty()) {
        say("No signature could be generated!");
    } else {
        say($signature->dump());
    }
}

main();
