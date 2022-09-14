use v5.30;
use warnings FATAL => 'all';
use feature 'signatures';
no warnings 'experimental::signatures';

=pod
=head1 Signature::Utils::File
A file utils collection.
=cut

package File {
    use Moose;

    sub open ($file) {
        open( my $fh, '<:raw', $file ) or die "Cannot open '$file' file: $!";
        return $fh;
    }

    sub read ( $fh, $length = 1 ) {
        my $bytes = read( $fh, my $byte, $length );
        if ( !defined($bytes) || $bytes == 0 ) {
            return undef;
        }
        return $byte;
    }

    sub seek ( $fh, $position ) {
        seek( $fh, $position, 0 );
    }

    sub rewind ($fh) {
        File::seek( $fh, 0 );
    }

    sub close ($fh) {
        close($fh)
          or warn $! ? "Cannot close file: $!" : "Cannot close file: $?";
    }
}

1;
