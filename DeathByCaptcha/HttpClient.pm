package DeathByCaptcha::HttpClient;

use strict;
use warnings;

use HTTP::Request::Common;
use HTTP::Status;
use LWP::UserAgent;
use JSON qw(decode_json encode_json);

use DeathByCaptcha::Exception;
use parent 'DeathByCaptcha::Client';

use constant API_SERVER_URL => 'https://api.dbcapi.me/api';
use constant API_RESPONSE_TYPE => 'application/json';


sub new
{
    my ($class, $username, $password) = @_;

    my $self = bless {
        username  => $username || '',
        password  => $password || '',
        useragent => LWP::UserAgent->new(agent => +DeathByCaptcha::Client::API_VERSION),
    }, $class;

    return $self;
}

sub _auth_content
{
    my ($self) = @_;
    return $self->{username} eq 'authtoken'
        ? (authtoken => $self->{password})
        : (username  => $self->{username}, password => $self->{password});
}

sub _decode_json_or_undef
{
    my ($content) = @_;
    my $decoded;
    eval { $decoded = decode_json($content); };
    return $decoded;
}


sub getUser
{
    my ($self) = @_;

    my $response = $self->{useragent}->request(HTTP::Request::Common::POST(
        join('/', +API_SERVER_URL, 'user'),
        Accept  => +API_RESPONSE_TYPE,
        Content => [ $self->_auth_content() ],
    ));

    if (HTTP::Status::RC_FORBIDDEN == $response->code) {
        die DeathByCaptcha::Exception->new("Access forbidden, check your credentials\n");
    }

    my $user = _decode_json_or_undef($response->content());
    return (defined $user and 0 < $user->{"user"}) ? $user : undef;
}

sub getCaptcha
{
    my ($self, $cid) = @_;

    if (0 < $cid) {
        my $response = $self->{useragent}->request(HTTP::Request::Common::GET(
            join('/', +API_SERVER_URL, 'captcha', $cid),
            Accept => +API_RESPONSE_TYPE
        ));

        if (HTTP::Status::RC_OK == $response->code) {
            my $captcha = _decode_json_or_undef($response->content);
            if (defined $captcha and 0 < $captcha->{"captcha"}) {
                if (defined $captcha->{"text"} and "" eq $captcha->{"text"}) {
                    $captcha->{"text"} = undef;
                }
                return $captcha;
            }
        }
    }
    return undef;
}

sub upload
{
    my ($self, $fn) = @_;

    if (defined $fn) {
        my $response = $self->{useragent}->request(HTTP::Request::Common::POST(
            join('/', +API_SERVER_URL, 'captcha'),
            Accept       => +API_RESPONSE_TYPE,
            Content_Type => 'form-data',
            Content      => [
                swid        => +DeathByCaptcha::Client::SOFTWARE_VENDOR_ID,
                $self->_auth_content(),
                captchafile => [undef, 'img', Content => DeathByCaptcha::Client::loadImage($fn)],
            ],
        ));

        if (HTTP::Status::RC_FORBIDDEN == $response->code) {
            die DeathByCaptcha::Exception->new("Access forbidden, check your credentials\n");
        }
        if (HTTP::Status::RC_BAD_REQUEST == $response->code) {
            die DeathByCaptcha::Exception->new(
                "CAPTCHA was rejected, check if it's a valid image"
            );
        }
        if (HTTP::Status::RC_SERVICE_UNAVAILABLE == $response->code) {
            die DeathByCaptcha::Exception->new(
                "CAPTCHA was rejected due to service overload, try again later"
            );
        }
        if (HTTP::Status::RC_SEE_OTHER == $response->code) {
            my ($url) = $response->header('Location');
            if ($url =~ m{/(\d+)$}) {
                return $self->getCaptcha($1);
            }
        }
    }
    return undef;
}

sub uploadToken
{
    my ($self, $type, $param_key, $params) = @_;

    if (!defined $type || !defined $param_key || $param_key eq '' || ref($params) ne 'HASH') {
        die DeathByCaptcha::Exception->new(
            "Token upload requires type, param_key and params hashref\n"
        );
    }

    my $response = $self->{useragent}->request(HTTP::Request::Common::POST(
        join('/', +API_SERVER_URL, 'captcha'),
        Accept  => +API_RESPONSE_TYPE,
        Content => [
            $self->_auth_content(),
            type => int($type),
            $param_key => encode_json($params),
        ],
    ));

    if (HTTP::Status::RC_FORBIDDEN == $response->code) {
        die DeathByCaptcha::Exception->new("Access forbidden, check your credentials\n");
    }
    if (HTTP::Status::RC_BAD_REQUEST == $response->code) {
        die DeathByCaptcha::Exception->new(
            "Token CAPTCHA request was rejected, check required parameters"
        );
    }
    if (HTTP::Status::RC_NOT_IMPLEMENTED == $response->code) {
        die DeathByCaptcha::Exception->new(
            "Token CAPTCHA type/params are not implemented or invalid"
        );
    }
    if (HTTP::Status::RC_SERVICE_UNAVAILABLE == $response->code) {
        die DeathByCaptcha::Exception->new(
            "Token CAPTCHA request rejected due to service overload, try again later"
        );
    }
    if (HTTP::Status::RC_SEE_OTHER == $response->code) {
        my ($url) = $response->header('Location');
        if ($url =~ m{/([0-9]+)$}) {
            return $self->getCaptcha($1);
        }
    }
    if (HTTP::Status::RC_OK == $response->code) {
        my $captcha = _decode_json_or_undef($response->content);
        if (defined $captcha and 0 < ($captcha->{"captcha"} || 0)) {
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
    my ($self, $cid) = @_;

    if (0 < $cid) {
        my $response = $self->{useragent}->request(HTTP::Request::Common::POST(
                join('/', +API_SERVER_URL, 'captcha', $cid, 'report'),
                Accept => +API_RESPONSE_TYPE,
                Content => [ $self->_auth_content() ]
            ));

        if (HTTP::Status::RC_FORBIDDEN == $response->code) {
            die DeathByCaptcha::Exception->new("Access forbidden, check your credentials\n");
        }

        if (HTTP::Status::RC_OK == $response->code) {
            my $captcha = _decode_json_or_undef($response->content);
            if (defined $captcha and not $captcha->{'is_correct'}) {
                return 1;
            }
        }
    }
    return 0;
}

1;
