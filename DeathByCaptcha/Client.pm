package DeathByCaptcha::Client;

use strict;
use warnings;
use Carp qw(croak);

use constant CLIENT_VERSION => '4.7.0';
our $VERSION = +CLIENT_VERSION;

use constant API_VERSION => 'DBC/Perl v' . +CLIENT_VERSION;
use constant SOFTWARE_VENDOR_ID => 0;

use constant DEFAULT_TIMEOUT => 60;
use constant POLLS_INTERVAL => (1, 1, 2, 3, 2, 2, 3, 2, 2);
use constant LEN_POLLS_INTVL => scalar(POLLS_INTERVAL);
use constant DFLT_POLL_INTERVAL => 3;


sub loadImage
{
    my ($fn) = @_;
    croak 'Image file path is required' if !defined $fn || $fn eq '';

    open my $fh, '<:raw', $fn or die "Failed opening $fn ($!)";
    local $/;
    my $img = <$fh>;
    close $fh;

    return $img;
}

sub connect
{
    return 1;
}

sub close
{
    return 1;
}

sub getBalance
{
    my ($self) = @_;
    if (defined(my $user = $self->getUser())) {
        if (0 < $user->{"user"}) {
            return $user->{"balance"};
        }
    }
    return;
}

sub getText
{
    my ($self, $captcha_id) = @_;

    if (defined(my $captcha = $self->getCaptcha($captcha_id))) {
        if (0 < $captcha->{"captcha"} and "" ne $captcha->{"text"}) {
            return $captcha->{"text"};
        }
    }
    return;
}

sub decode
{
    my ($self, $fn, $timeout) = @_;
    my $deadline = time + ((defined $timeout and 0 < $timeout)
        ? $timeout
        : +DEFAULT_TIMEOUT);
    my $idx = 0;
    my $intvl;

    if (defined(my $captcha = $self->upload($fn))) {
        while ($deadline > time and not defined $captcha->{"text"}) {
            ($intvl, $idx) = get_poll_interval($idx);
            sleep $intvl;
            $captcha = $self->getCaptcha($captcha->{"captcha"});
            return if !defined $captcha;
        }

        if (defined $captcha->{"text"} && $captcha->{"is_correct"}) {
            return $captcha;
        }
    }

    return;
}

sub decodeToken
{
    my ($self, $type, $param_key, $params, $timeout) = @_;

    my $deadline = time + ((defined $timeout and 0 < $timeout)
        ? $timeout
        : +DEFAULT_TIMEOUT);
    my $idx = 0;
    my $intvl;

    if (defined(my $captcha = $self->uploadToken($type, $param_key, $params))) {
        while ($deadline > time and not defined $captcha->{"text"}) {
            ($intvl, $idx) = get_poll_interval($idx);
            sleep $intvl;
            $captcha = $self->getCaptcha($captcha->{"captcha"});
            return if !defined $captcha;
        }

        if (defined $captcha->{"text"} && $captcha->{"text"} ne '') {
            return $captcha;
        }
    }

    return;
}

sub get_poll_interval
{
        my ($idx) = @_;
        my @poll_intervals = POLLS_INTERVAL;
        my $intvl = $idx < @poll_intervals
                ? $poll_intervals[$idx]
                : DFLT_POLL_INTERVAL;

        return ($intvl, $idx + 1);
}

1;
