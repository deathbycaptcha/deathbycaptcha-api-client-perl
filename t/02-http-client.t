use strict;
use warnings;

use lib '.';

use Test::More;

use DeathByCaptcha::Client;
use DeathByCaptcha::HttpClient;

{
    package Local::MockResponse;

    sub new {
        my ($class, %args) = @_;
        return bless \%args, $class;
    }

    sub code    { return $_[0]->{code}; }
    sub content { return $_[0]->{content}; }

    sub header {
        my ($self, $name) = @_;
        return $self->{headers}{$name};
    }
}

{
    package Local::MockUA;

    sub new {
        my ($class, @responses) = @_;
        return bless {
            responses => \@responses,
            requests  => [],
        }, $class;
    }

    sub request {
        my ($self, $request) = @_;
        push @{$self->{requests}}, $request;
        return shift @{$self->{responses}};
    }

    sub requests { return $_[0]->{requests}; }
}

my $http = DeathByCaptcha::HttpClient->new('user', 'pass');

is_deeply(
    DeathByCaptcha::HttpClient::_decode_json_or_undef('{"ok":1}'),
    { ok => 1 },
    '_decode_json_or_undef parses valid JSON',
);
ok(
    !defined DeathByCaptcha::HttpClient::_decode_json_or_undef('{invalid-json'),
    '_decode_json_or_undef returns undef for invalid JSON',
);

is_deeply(
    [ $http->_auth_content() ],
    [ username => 'user', password => 'pass' ],
    '_auth_content builds username/password payload',
);

$http = DeathByCaptcha::HttpClient->new('authtoken', 'token-123');
is_deeply(
    [ $http->_auth_content() ],
    [ authtoken => 'token-123' ],
    '_auth_content builds authtoken payload',
);

# getUser success
$http = DeathByCaptcha::HttpClient->new('user', 'pass');
$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(code => 200, content => '{"user": 9, "balance": 123.4}'),
);
my $user = $http->getUser();
is($user->{user}, 9, 'getUser returns parsed user hash');
is($user->{balance}, 123.4, 'getUser returns parsed balance');

my $req = $http->{useragent}->requests->[0];
is($req->method, 'POST', 'getUser sends POST request');
like($req->uri->as_string, qr{/user$}, 'getUser targets /user endpoint');

# getUser forbidden
$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(code => 403, content => ''),
);
like(
    exception_text(sub { $http->getUser(); }),
    qr/Access forbidden, check your credentials/,
    'getUser throws on forbidden response',
);

# getUser invalid JSON
$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(code => 200, content => '{broken'),
);
ok(!defined $http->getUser(), 'getUser returns undef when response JSON is invalid');

# getCaptcha normalizes empty text
$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(code => 200, content => '{"captcha": 10, "text": ""}'),
);
my $captcha = $http->getCaptcha(10);
ok(defined $captcha, 'getCaptcha returns captcha hash on success');
ok(!defined $captcha->{text}, 'getCaptcha normalizes empty text to undef');

# getCaptcha invalid JSON and non-OK status
$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(code => 200, content => '{broken-json'),
);
ok(!defined $http->getCaptcha(10), 'getCaptcha returns undef on invalid JSON');

$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(code => 404, content => '{"captcha":10}'),
);
ok(!defined $http->getCaptcha(10), 'getCaptcha returns undef on non-200 status');

# report parses JSON payload
$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(code => 200, content => '{"captcha": 10, "is_correct": false}'),
);
ok($http->report(10), 'report returns true when API marks captcha as incorrect');

$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(code => 200, content => '{"captcha": 10, "is_correct": true}'),
);
ok(!$http->report(10), 'report returns false when API marks captcha as correct');

$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(code => 403, content => ''),
);
like(
    exception_text(sub { $http->report(10); }),
    qr/Access forbidden, check your credentials/,
    'report throws on forbidden response',
);

# upload success via redirect -> getCaptcha
{
    no warnings 'redefine';
    local *DeathByCaptcha::Client::loadImage = sub { return 'fake-image'; };

    $http = DeathByCaptcha::HttpClient->new('user', 'pass');
    $http->{useragent} = Local::MockUA->new(
        Local::MockResponse->new(
            code    => 303,
            content => '',
            headers => { Location => 'https://api.dbcapi.me/api/captcha/321' },
        ),
        Local::MockResponse->new(
            code    => 200,
            content => '{"captcha":321,"text":"ok","is_correct":true}',
        ),
    );

    my $uploaded = $http->upload('any-file.jpg');
    is($uploaded->{captcha}, 321, 'upload follows redirect and returns fetched captcha');
    is($uploaded->{text}, 'ok', 'upload returns solved text from redirected getCaptcha call');
}

# upload error mappings
for my $case (
    [ 403, qr/Access forbidden, check your credentials/, 'forbidden' ],
    [ 400, qr/CAPTCHA was rejected, check if it's a valid image/, 'bad request' ],
    [ 503, qr/CAPTCHA was rejected due to service overload/, 'service unavailable' ],
) {
    my ($status, $regex, $label) = @$case;

    no warnings 'redefine';
    local *DeathByCaptcha::Client::loadImage = sub { return 'fake-image'; };

    $http = DeathByCaptcha::HttpClient->new('user', 'pass');
    $http->{useragent} = Local::MockUA->new(
        Local::MockResponse->new(code => $status, content => ''),
    );

    like(
        exception_text(sub { $http->upload('any-file.jpg'); }),
        $regex,
        "upload throws expected error on $label",
    );
}

# invalid captcha id avoids request path
$http->{useragent} = Local::MockUA->new();
ok(!defined $http->getCaptcha(0), 'getCaptcha returns undef for invalid id');
ok(!$http->report(0), 'report returns false for invalid id');
is(scalar @{$http->{useragent}->requests}, 0, 'invalid id paths do not call user agent');

done_testing;

sub exception_text {
    my ($code) = @_;
    my $err;
    eval { $code->(); 1 } or $err = $@;
    return $err || '';
}
