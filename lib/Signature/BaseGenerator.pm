use v5.30;
use warnings FATAL => 'all';
use feature 'signatures';
no warnings 'experimental::signatures';

use Signature::BaseSignature;
use Signature::Utils::File;

=pod
=head1 Signature::BaseGenerator
Base role for signature generators.
=cut

package BaseGenerator {
    use Moose::Role;

    requires qw( min_string_bytes generate );

    sub _open_all_files (@files) {
        my @fhs;
        for my $file (@files) {
            my $fh = File::open($file);
            push @fhs, $fh;
        }
        return @fhs;
    }

    sub _seek_all_files ( $position, @fhs ) {
        for my $fh (@fhs) {
            File::seek( $fh, $position );
        }
    }

    sub _rewind_all_files (@fhs) {
        for my $fh (@fhs) {
            File::seek( $fh, 0 );
        }
    }

    sub _close_all_files (@fhs) {
        for my $fh (@fhs) {
            File::close($fh);
        }
    }

    sub _is_first_file ($i) {
        return $i == 0;
    }

    sub _is_last_file ( $i, @fhs ) {
        return $i == @fhs - 1;
    }

    sub _append_byte_to_string ( $byte, $string ) {
        if ( defined($string) && length $string > 0 ) {
            return $string . " " . sprintf( "%02X", ord $byte );
        }
        else {
            return sprintf( "%02X", ord $byte );
        }
    }
}

1;
