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

    sub _open_all_files(@files) {
        my @fhs;
        for my $file (@files) {
            my $fh = File::open($file);
            push @fhs, $fh;
        }
        return @fhs;
    }

    sub _close_all_files(@fhs) {
        for my $fh (@fhs) {
            File::close($fh);
        }
    }
}


1;