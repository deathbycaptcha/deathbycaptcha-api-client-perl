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

# uploadToken success via redirect -> getCaptcha
{
    no warnings 'redefine';

    $http = DeathByCaptcha::HttpClient->new('user', 'pass');
    $http->{useragent} = Local::MockUA->new(
        Local::MockResponse->new(
            code    => 303,
            content => '',
            headers => { Location => 'https://api.dbcapi.me/api/captcha/555' },
        ),
        Local::MockResponse->new(
            code    => 200,
            content => '{"captcha":555,"text":"token-abc","is_correct":true}',
        ),
    );

    my $token = $http->uploadToken(4, 'token_params', {
        googlekey => 'site-key',
        pageurl   => 'https://example.test/',
    });
    is($token->{captcha}, 555, 'uploadToken follows redirect and returns fetched captcha');
    is($token->{text}, 'token-abc', 'uploadToken returns text from redirected getCaptcha');

    my $req = $http->{useragent}->requests->[0];
    is($req->method, 'POST', 'uploadToken sends POST request');
    like($req->uri->as_string, qr{/captcha$}, 'uploadToken targets /captcha endpoint');
    like($req->content, qr/type=4/, 'uploadToken encodes type in body');
    like($req->content, qr/token_params/, 'uploadToken encodes param_key in body');
}

# uploadToken: 200 OK path (no redirect)
{
    $http = DeathByCaptcha::HttpClient->new('user', 'pass');
    $http->{useragent} = Local::MockUA->new(
        Local::MockResponse->new(
            code    => 200,
            content => '{"captcha":777,"text":"","is_correct":false}',
        ),
    );

    my $token = $http->uploadToken(4, 'token_params', { googlekey => 'k', pageurl => 'u' });
    ok(defined $token, 'uploadToken returns captcha on 200 OK response');
    is($token->{captcha}, 777, 'uploadToken returns correct captcha id on 200 OK');
    ok(!defined $token->{text}, 'uploadToken normalizes empty text to undef on 200 OK');
}

# uploadToken error mappings
for my $case (
    [ 403, qr/Access forbidden, check your credentials/, 'forbidden' ],
    [ 400, qr/Token CAPTCHA request was rejected/, 'bad request' ],
    [ 501, qr/Token CAPTCHA type\/params are not implemented/, 'not implemented' ],
    [ 503, qr/Token CAPTCHA request rejected due to service overload/, 'service unavailable' ],
) {
    my ($status, $regex, $label) = @$case;

    $http = DeathByCaptcha::HttpClient->new('user', 'pass');
    $http->{useragent} = Local::MockUA->new(
        Local::MockResponse->new(code => $status, content => ''),
    );

    like(
        exception_text(sub { $http->uploadToken(4, 'token_params', { googlekey => 'k', pageurl => 'u' }); }),
        $regex,
        "uploadToken throws expected error on $label",
    );
}

# uploadToken validation: missing required params
like(
    exception_text(sub { $http->uploadToken(undef, 'token_params', {}); }),
    qr/Token upload requires type/,
    'uploadToken throws when type is undef',
);
like(
    exception_text(sub { $http->uploadToken(4, '', { k => 'v' }); }),
    qr/Token upload requires type/,
    'uploadToken throws when param_key is empty',
);
like(
    exception_text(sub { $http->uploadToken(4, 'token_params', 'not-a-hash'); }),
    qr/Token upload requires type/,
    'uploadToken throws when params is not a hashref',
);

# getStatus success
$http = DeathByCaptcha::HttpClient->new('user', 'pass');
$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(
        code    => 200,
        content => '{"is_service_overloaded":false}',
    ),
);
my $status = $http->getStatus();
ok(defined $status, 'getStatus returns parsed hash on 200 OK');
ok(!$status->{is_service_overloaded}, 'getStatus returns is_service_overloaded flag');

my $status_req = $http->{useragent}->requests->[0];
is($status_req->method, 'GET', 'getStatus sends GET request');
like($status_req->uri->as_string, qr{/status$}, 'getStatus targets /status endpoint');

# getStatus non-200
$http->{useragent} = Local::MockUA->new(
    Local::MockResponse->new(code => 503, content => ''),
);
ok(!defined $http->getStatus(), 'getStatus returns undef on non-200 response');

done_testing;

sub exception_text {
    my ($code) = @_;
    my $err;
    eval { $code->(); 1 } or $err = $@;
    return $err || '';
}
