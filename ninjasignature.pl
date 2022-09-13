#!/usr/bin/perl
use v5.30;
use warnings FATAL => 'all';
use feature 'signatures';
no warnings 'experimental::signatures';

use Getopt::Long;

use lib './lib';
use Signature::GeneratorFactory;

sub print_help($name, $type) {
    say(qq{usage: ninjasignature.pl [-h] [-t TYPE] [-n NAME] -f FILE1 -f FILE2

examples:
  >> ninjasignature.pl --files ./t/data/sample1 ./t/data/sample2
  >> ninjasignature.pl --type simple --files ./t/data/sample1 ./t/data/sample2
  >> ninjasignature.pl --type yara --files ./t/data/sample1 ./t/data/sample2
  >> ninjasignature.pl --type yara --name TestSignature --files ./t/data/sample1 ./t/data/sample2

optional arguments:
  -h, --help     show this help message and exit
  -t, --type     set the type of signature between '@{[GeneratorFactory::SIMPLE]}' and '@{[GeneratorFactory::YARA]}' (default: '$type')
  -n, --name     set the signature name (default: '$name')});
}

sub main {
    my $help;
    my $type = GeneratorFactory::YARA;
    my $name  = "Generic";
    my @files = ();

    GetOptions(
        "h"           => \$help,
        "help"        => \$help,
        "t=s"         => \$type,
        "type=s"      => \$type,
        "n=s"         => \$name,
        "name=s"      => \$name,
        "f=s"         => \@files,
        "file=s"      => \@files,
        "files=s{2,}" => \@files
    );
    if (defined($help)) {
        print_help($name, $type);
        return 0;
    }
    if ( @files != 2 ) {
        die "Can compare only two files at a time!";
    }

    my $signature = GeneratorFactory::build($type)->generate($name, @files);
    if ( $signature->is_empty() ) {
        say("No signature could be generated!");
    }
    else {
        say( $signature->dump() );
    }

    return 0;
}

main();
