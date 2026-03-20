package DeathByCaptcha::SocketClient;

use strict;
use warnings;

use IO::Socket;
use JSON qw(encode_json decode_json);
use MIME::Base64 qw(encode_base64);

use DeathByCaptcha::Exception;
use parent 'DeathByCaptcha::Client';


use constant API_SERVER_HOST => "api.dbcapi.me";
use constant API_SERVER_FIRST_PORT => 8123;
use constant API_SERVER_LAST_PORT => 8130;
use constant API_CMD_TERMINATOR => "\r\n";


sub connect
{
    my $self = shift;
    if (!$self->{"sock"}) {
        #printf("%d CONN\n", time);
        my $host = gethostbyname(+API_SERVER_HOST) or die new DeathByCaptcha::Exception(
            "Failed resolving API server host name"
        );
        $self->{"sock"} = IO::Socket::INET->new(
            Proto => "tcp",
            PeerAddr => inet_ntoa($host),
            PeerPort => +API_SERVER_FIRST_PORT + int(rand(+API_SERVER_LAST_PORT - +API_SERVER_FIRST_PORT + 1)),
        ) or die new DeathByCaptcha::Exception(
            "Failed connecting to the API server \n"
        );
    }
    return $self->{"sock"};
}

sub close
{
    my $self = shift;
    if ($self->{"sock"}) {
        #printf("%d CLOSE\n", time);
        shutdown($self->{"sock"}, 2);
        close($self->{"sock"});
        $self->{"sock"} = 0;
    }
}

sub new
{
    my ($class, $username, $password) = @_;

    my $self = bless {
        sock     => 0,
        username => $username || '',
        password => $password || '',
    }, $class;

    return $self;
}

sub DESTROY
{
    my $self = shift;
    $self->close();
}


sub _call
{
    my $self = shift;
    my $cmd = shift;
    my $cmdargs = {@_,
                   "version" => +DeathByCaptcha::Client::API_VERSION,
                   "cmd" => $cmd};

    my $request = encode_json($cmdargs);
    #printf("%d SEND: %d %s\n", time, length($request), $request);
    $request .= +API_CMD_TERMINATOR;

    my $attempts = 2;
    while (0 < $attempts) {
        $attempts--;

        if (!$self->{"sock"} and $cmd ne "login") {
                if ($self->{"username"} eq "authtoken"){
                    $self->_call("login", (authtoken => $self->{"password"}));
                } else {
                    $self->_call("login", (username => $self->{"username"},
                                           password => $self->{"password"}));
                }
        }

        my $sock = $self->connect();

        print $sock $request;

        my $buff = "";
        while ((0 == length($buff) or +API_CMD_TERMINATOR ne substr($buff, length($buff) - 2, 2)) and defined (my $s = <$sock>)) {
            $buff .= $s;
        }

        if (0 < length($buff)) {
            $buff = substr($buff, 0, length($buff) - 2);
            #printf("%d RECV: %d %s\n", time, length($buff), $buff);
            my $response;
            eval { $response = decode_json($buff); };
            if (defined $response) {
                if (defined $response->{"error"}) {
                    $self->close();
                    if ("not-logged-in" eq $response->{"error"}) {
                        die new DeathByCaptcha::Exception(
                            "Access denied, check your credentials\n"
                        );
                    }
                    if ("banned" eq $response->{"error"}) {
                        die new DeathByCaptcha::Exception(
                            "Access denied, account is suspended\n"
                        );
                    }
                    if ("insufficient-funds" eq $response->{"error"}) {
                        die new DeathByCaptcha::Exception(
                            "CAPTCHA was rejected due to low balance\n"
                        );
                    }
                    if ("invalid-captcha" eq $response->{"error"}) {
                        die new DeathByCaptcha::Exception(
                            "CAPTCHA was rejected by the service, check if it's a valid image\n"
                        );
                    }
                    if ("service-overload" eq $response->{"error"}) {
                        die new DeathByCaptcha::Exception(
                            "CAPTCHA was rejected due to service overload, try again later\n"
                        );
                    }
                    die new DeathByCaptcha::Exception(
                        "Service error occured: " . $response->{"error"} . "\n"
                    );
                } else {
                    return $response;
                }
            }
        }
        $self->close();
    }
    return undef;
}


sub getUser
{
    my $self = shift;
    my $user = $self->_call("user");
    return (defined $user and 0 < $user->{"user"})
        ? $user
        : undef;
}

sub getCaptcha
{
    my $self = shift;
    my $cid = shift;
    if (0 < $cid) {
        my $captcha = $self->_call("captcha", ("captcha" => $cid));
        if (defined $captcha and 0 < $captcha->{"captcha"}) {
            if (defined $captcha->{"text"} and "" eq $captcha->{"text"}) {
                $captcha->{"text"} = undef;
            }
            return $captcha;
        }
    }
    return undef;
}

sub report
{
    my $self = shift;
    my $cid = shift;
    if (0 < $cid) {
        my $captcha = $self->_call("report", (captcha => $cid));
        if (defined $captcha and not $captcha->{"is_correct"}) {
            return 1;
        }
    }
    return 0;
}

sub upload
{
    my $self = shift;
    my $fn = shift;
    my $captcha = $self->_call("upload", ("captcha" => encode_base64(DeathByCaptcha::Client::loadImage($fn), ""),
                                          "swid" => +DeathByCaptcha::Client::SOFTWARE_VENDOR_ID));
    if (defined $captcha and 0 < $captcha->{"captcha"}) {
        if ("" eq $captcha->{"text"}) {
            $captcha->{"text"} = undef;
        }
        return $captcha;
    }
    return undef;
}

1;
