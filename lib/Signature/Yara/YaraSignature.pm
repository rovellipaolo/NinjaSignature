use v5.30;
use warnings FATAL => 'all';
use feature 'signatures';
no warnings 'experimental::signatures';

use Signature::BaseSignature;

=pod
=head1 Signature::Yara::YaraSignature
Represents a YARA rule.
For more information on the output YARA format see: https://virustotal.github.io/yara/
=cut

package YaraSignature {
    use Moose;

    extends 'BaseSignature';

    has 'strings' => (
        is  => 'ro',
        isa => 'ArrayRef',
    );

    override is_empty => sub {
        my $self    = shift;
        my @strings = @{ $self->strings };

        return @strings == 0;
    };

    override dump => sub {
        my $self    = shift;
        my @strings = @{ $self->strings };

        return qq{rule @{[$self->name]}
{
    strings:
        @{[join("\n        ", map { "\$s$_ = {" . $strings[$_] . "}" } (0 .. @strings - 1))]}

    condition:
        @{[join(" and ", map { "\$s$_" } (0 .. @strings - 1))]}
}};
    }
}

1;
