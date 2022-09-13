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

    sub generate($self, $name, @files) {
        my @hashes = $self->generate_sha256_hashes(@files);

        my @fhs = _open_all_files(@files);
        my @bytes = $self->generate_byte_sequences(@fhs);
        _close_all_files(@fhs);

        return SimpleSignature->new(
            name   => $name,
            sha256 => \@hashes,
            bytes  => \@bytes
        );
    }

    with 'BaseGenerator';

    sub should_add_string($self, $current_offset, $string_offset) {
        return $current_offset - $string_offset >= $self->min_string_bytes;
    }

    sub generate_sha256_hashes($self, @files) {
        my @hashes = ();

        for my $file (@files) {
            push(@hashes, Digest::SHA->new(256)->addfile($file)->hexdigest());
        }

        return @hashes;
    }

    # Algorithm: same bytes, same offsets.
    sub generate_byte_sequences($self, @fhs) {
        my @strings = ();

        my $current_offset = 0;
        my $has_bytes = 0;
        my $string = "";
        my $string_offset = 0;
        while ( $has_bytes == 0 ) {
            my $last_byte;
            for my $i (0 .. @fhs - 1) {
                my $current_byte = File::read($fhs[$i]);
                if (!defined $current_byte) {
                    if ($self->should_add_string($current_offset, $string_offset)) {
                        push(@strings, ByteSequence->new(offset => $string_offset, value => $string));
                    }
                    $has_bytes = 1;
                    last;
                }
                if ($i == 0) {
                    $current_offset += 1;
                    $last_byte = $current_byte;
                }
                else {
                    if ($current_byte eq $last_byte) {
                        if (length $string > 0) {
                            $string .= " " . sprintf("%02X", ord $current_byte);
                        }
                        else {
                            $string = sprintf("%02X", ord $current_byte);
                        }
                    }
                    else {
                        if ($self->should_add_string($current_offset, $string_offset)) {
                            push(@strings, ByteSequence->new(offset => $string_offset, value => $string));
                        }
                        $string = "";
                        $string_offset = $current_offset;
                    }
                }
            }
        }

        return @strings;
    }
}


1;