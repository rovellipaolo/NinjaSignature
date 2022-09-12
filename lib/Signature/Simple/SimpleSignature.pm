use v5.30;
use warnings FATAL => 'all';
use feature 'signatures';
no warnings 'experimental::signatures';

use Signature::BaseSignature;
use Signature::Simple::ByteSequence;


=pod
=head1 Signature::Simple::SimpleSignature
Represents a simple string signature.
The output JSON format is invented for example purposes.
=cut
package SimpleSignature {
    use Moose;

    extends 'BaseSignature';

    has 'sha256' => (
        is      => 'ro',
        isa     => 'ArrayRef',
    );

    has 'bytes' => (
        is      => 'ro',
        isa     => 'ArrayRef',
    );

    override is_empty => sub {
        my $self = shift;
        my @bytes = @{ $self->bytes };

        return @bytes == 0;
    };

    override dump => sub {
        my $self = shift;
        my @sha256 = @{ $self->sha256 };
        my @bytes = @{ $self->bytes };

        return qq{{
    name: "@{[$self->name]}"
    sha256:
        @{[join("\n        ", map { "- $_" } @sha256)]}
    bytes:
        @{[join("\n        ", map { $_->offset . ": " . $_->value } @bytes)]}
}};
    };
}


1;