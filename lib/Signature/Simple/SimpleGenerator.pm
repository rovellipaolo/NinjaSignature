use v5.30;
use warnings FATAL => 'all';
use feature 'signatures';
no warnings 'experimental::signatures';

use Digest::SHA;

use Signature::BaseGenerator;
use Signature::Simple::SimpleSignature;
use Signature::Simple::ByteSequence;
use Signature::Utils::File;

=pod
=head1 Signature::Simple::SimpleGenerator
Generates a simple string signature, where the same byte sequence is found in different files at the same offsets.
=cut

package SimpleGenerator {
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
        my @hashes = $self->_generate_sha256_hashes(@files);

        my @fhs   = BaseGenerator::_open_all_files(@files);
        my @bytes = $self->_generate_byte_sequences(@fhs);
        BaseGenerator::_close_all_files(@fhs);

        return SimpleSignature->new(
            name   => $name,
            sha256 => \@hashes,
            bytes  => \@bytes
        );
    }

    with 'BaseGenerator';

    sub _should_add_string ( $self, $current_offset, $string_offset ) {
        return $current_offset - $string_offset >= $self->min_string_bytes;
    }

    sub _generate_sha256_hashes ( $self, @files ) {
        my @hashes = ();

        for my $file (@files) {
            push( @hashes, Digest::SHA->new(256)->addfile($file)->hexdigest() );
        }

        return @hashes;
    }

    ##
    # Algorithm: same bytes, same offsets.
    #
    sub _generate_byte_sequences ( $self, @fhs ) {
        my @strings = ();

        my $current_offset = 0;
        my $has_bytes      = 0;
        my $string         = "";
        my $string_offset  = 0;
        while ( $has_bytes == 0 ) {
            my $last_byte;
            for my $i ( 0 .. @fhs - 1 ) {
                my $current_byte = File::read( $fhs[$i] );
                if ( !defined($current_byte) ) {
                    if (
                        $self->_should_add_string(
                            $current_offset, $string_offset
                        )
                      )
                    {
                        push(
                            @strings,
                            ByteSequence->new(
                                offset => $string_offset,
                                value  => $string
                            )
                        );
                    }
                    $has_bytes = 1;
                    last;
                }

                if ( BaseGenerator::_is_first_file($i) ) {
                    $current_offset += 1;
                    $last_byte = $current_byte;
                    next;
                }

                if ( $current_byte ne $last_byte ) {
                    if (
                        $self->_should_add_string(
                            $current_offset, $string_offset
                        )
                      )
                    {
                        push(
                            @strings,
                            ByteSequence->new(
                                offset => $string_offset,
                                value  => $string
                            )
                        );
                    }
                    $string        = "";
                    $string_offset = $current_offset;
                    BaseGenerator::_seek_all_files( $current_offset, @fhs );
                    last;
                }

                if ( BaseGenerator::_is_last_file( $i, @fhs ) ) {
                    $string =
                      BaseGenerator::_append_byte_to_string( $current_byte,
                        $string );
                }
            }
        }

        return @strings;
    }
}

1;
