
package DeathByCaptcha::Exception;

use strict;
use warnings;

sub stringify;
use overload '""' => \&stringify, fallback => 1;

sub new
{
    my ($class, $text) = @_;
    return bless {
        ERROR_TEXT => $text,
    }, $class;
}

sub stringify
{
    my ($self) = @_;
    my $class = ref($self);
    my $text  = $self->{ERROR_TEXT};
    if (defined($text) && length($text)) {
        return "$class: $text";
    } else {
        return "$class";
    }
}

1;
