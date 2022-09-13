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

    sub generate($self, $name, @files) {
        my @fhs = BaseGenerator::_open_all_files(@files);
        my @strings = $self->_generate_byte_sequences(@fhs);
        BaseGenerator::_close_all_files(@fhs);

        return YaraSignature->new(
            name    => $name,
            strings => \@strings
        );
    }

    with 'BaseGenerator';

    sub _should_add_string($self, $string, @strings) {
        return defined($string) &&
            length($string) >= $self->min_string_bytes * 2 + ($self->min_string_bytes - 1) &&
            grep(/$string/, @strings) == 0
    }

    # Algorithm: same bytes, different offsets.
    sub _generate_byte_sequences($self, @fhs) {
        my @strings = ();

        my $string = "";
        my $match = File::read($fhs[0]);
        while (defined($match)) {
            my $current = File::read($fhs[1]);
            while (defined($current)) {
                if ($current eq $match) {
                    $string = BaseGenerator::_append_byte_to_string($current, $string);
                    last;
                }
                else {
                    if ($self->_should_add_string($string, @strings)) {
                        push(@strings, $string);
                        File::rewind($fhs[1]);
                    }
                    $string = "";
                }
                $current = File::read($fhs[1]);
            }
            $match = File::read($fhs[0]);
            if (!defined($match)) {
                if ($self->_should_add_string($string, @strings)) {
                    push(@strings, $string);
                }
            }
            elsif (!defined($current)) {
                if ($self->_should_add_string($string, @strings)) {
                    push(@strings, $string);
                }
                File::rewind($fhs[1]);
            }
        }

        return @strings;
    }
}


1;