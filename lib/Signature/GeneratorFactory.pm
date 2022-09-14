use v5.30;
use warnings FATAL => 'all';
use feature 'signatures';
no warnings 'experimental::signatures';

use Signature::Simple::SimpleGenerator;
use Signature::Yara::YaraGenerator;

=pod
=head1 Signature::GeneratorFactory
Factory for signature generators.
=cut

package GeneratorFactory {
    use Moose;

    use constant {
        SIMPLE => "simple",
        YARA   => "yara",
    };

    sub build ($type) {
        my $generator;
        if ( $type eq SIMPLE ) {
            $generator = SimpleGenerator->new( min_string_bytes => 4 );
        }
        elsif ( $type eq "yara" ) {
            $generator = YaraGenerator->new( min_string_bytes => 4 );
        }
        else {
            die("No generator matching '$type' type found!");
        }
        return $generator;
    }
}

1;
