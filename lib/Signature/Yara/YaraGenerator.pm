use v5.30;
use warnings FATAL => 'all';
use feature 'signatures';
no warnings 'experimental::signatures';

use Signature::BaseGenerator;
use Signature::Yara::YaraSignature;

=pod
=head1 Signature::YaraGenerator
Generates a signature based on YARA rules.
For more information see: https://virustotal.github.io/yara/
=cut

package YaraGenerator {
    use Moose;

    has 'min_string_bytes' => (
        is      => 'ro',
        isa     => 'Int',
        default => 4,
    );

    ##
    # Preconditions:
    #  - $name is always defined
    #  - @files always contain 2 or more files
    #
    sub generate ( $self, $name, @files ) {
        my @fhs     = BaseGenerator::_open_all_files(@files);
        my @strings = $self->_generate_byte_sequences(@fhs);
        BaseGenerator::_close_all_files(@fhs);

        return YaraSignature->new(
            name    => $name,
            strings => \@strings
        );
    }

    with 'BaseGenerator';

    sub _should_add_string ( $self, $string, @strings ) {
        return
          length($string) >=
          $self->min_string_bytes * 2 + ( $self->min_string_bytes - 1 )
          && grep( /$string/, @strings ) == 0;
    }

    ##
    # Algorithm: same bytes, different offsets.
    #
    sub _generate_byte_sequences ( $self, @fhs ) {
        my @strings = ();

        my $string = "";
        my $match;
        while ( defined( $match = File::read( $fhs[0] ) ) ) {
            for my $i ( 1 .. @fhs - 1 ) {
                my $current;
                while ( defined( $current = File::read( $fhs[$i] ) ) ) {
                    if ( $current eq $match ) {
                        if ( BaseGenerator::_is_last_file( $i, @fhs ) ) {
                            $string =
                              BaseGenerator::_append_byte_to_string( $current,
                                $string );
                        }
                        last;
                    }

                    if ( length($string) > 0 ) {
                        if ( $self->_should_add_string( $string, @strings ) ) {
                            push( @strings, $string );
                        }
                        BaseGenerator::_rewind_all_files( @fhs[ 1, @fhs - 1 ] );
                        $string = "";
                    }
                }

                if ( !defined($current) ) {
                    if ( length($string) > 0
                        && $self->_should_add_string( $string, @strings ) )
                    {
                        push( @strings, $string );
                    }
                    BaseGenerator::_rewind_all_files( @fhs[ 1, @fhs - 1 ] );
                    $string = "";
                    last;
                }
            }
        }

        if ( !defined($match) ) {
            if ( $self->_should_add_string( $string, @strings ) ) {
                push( @strings, $string );
            }
        }

        return @strings;
    }
}

1;
