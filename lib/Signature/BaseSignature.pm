use v5.30;
use warnings FATAL => 'all';
use feature 'signatures';
no warnings 'experimental::signatures';

=pod
=head1 Signature::BaseSignature
Base interface for a signature.
=cut

package BaseSignature {
    use Moose;

    has 'name' => (
        is  => 'ro',
        isa => 'Str',
    );

    sub is_empty ($self) {
        return 0;
    }

    sub dump ($self) {
        return $self->name;
    }
}

1;
