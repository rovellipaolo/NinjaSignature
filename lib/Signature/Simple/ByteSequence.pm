use v5.30;
use warnings FATAL => 'all';
use feature 'signatures';
no warnings 'experimental::signatures';

use Signature::BaseSignature;


=pod
=head1 Signature::Simple::ByteSequence
Represents a sequence of contiguous bytes in a string signature.
=cut
package ByteSequence {
    use Moose;

    has 'offset' => (
        is      => 'ro',
        isa     => 'Str',
    );

    has 'value' => (
        is      => 'ro',
        isa     => 'Str',
    );

    sub length($self) {
        return length $self->value
    }
}


1;