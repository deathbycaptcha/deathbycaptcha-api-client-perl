use strict;
use warnings;

use lib '.';

use Test::More;
use JSON qw(decode_json);

use DeathByCaptcha::Client;
use DeathByCaptcha::SocketClient;

my $ctor_named = DeathByCaptcha::SocketClient->new(
    username => 'named-user',
    password => 'named-pass',
);
is($ctor_named->{username}, 'named-user', 'constructor accepts named username');
is($ctor_named->{password}, 'named-pass', 'constructor accepts named password');

my $ctor_hashref = DeathByCaptcha::SocketClient->new({
    username => 'hash-user',
    password => 'hash-pass',
});
is($ctor_hashref->{username}, 'hash-user', 'constructor accepts hashref username');
is($ctor_hashref->{password}, 'hash-pass', 'constructor accepts hashref password');

{
    package Local::SocketClientMock;
    use parent 'DeathByCaptcha::SocketClient';

    sub new {
        my ($class, %args) = @_;
        return bless {
            username => $args{username} // '',
            password => $args{password} // '',
            queue    => $args{queue} || [],
        }, $class;
    }

    sub _call {
        my ($self, $cmd, %args) = @_;
        push @{$self->{calls}}, { cmd => $cmd, args => { %args } };
        return shift @{$self->{queue}};
    }

    sub calls { return $_[0]->{calls} || []; }
}

my $client = Local::SocketClientMock->new(
    queue => [ { user => 11, balance => 77.3 } ],
);
my $user = $client->getUser();
is($user->{user}, 11, 'getUser returns user hash when user id is valid');
is($client->calls->[0]{cmd}, 'user', 'getUser delegates to _call("user")');

$client = Local::SocketClientMock->new(queue => [ { user => 0, balance => 10 } ]);
ok(!defined $client->getUser(), 'getUser returns undef when user id is invalid');

$client = Local::SocketClientMock->new(
    queue => [ { captcha => 123, text => '' } ],
);
my $captcha = $client->getCaptcha(123);
ok(defined $captcha, 'getCaptcha returns hash when captcha id is valid');
ok(!defined $captcha->{text}, 'getCaptcha normalizes empty text to undef');

$client = Local::SocketClientMock->new(queue => [ { captcha => 0, text => 'x' } ]);
ok(!defined $client->getCaptcha(123), 'getCaptcha returns undef when payload captcha id is invalid');
ok(!defined $client->getCaptcha(0), 'getCaptcha returns undef for invalid input id');

$client = Local::SocketClientMock->new(queue => [ { captcha => 50, is_correct => 0 } ]);
ok($client->report(50), 'report returns true when captcha is marked incorrect');

$client = Local::SocketClientMock->new(queue => [ { captcha => 50, is_correct => 1 } ]);
ok(!$client->report(50), 'report returns false when captcha is marked correct');
ok(!$client->report(0), 'report returns false for invalid captcha id');

# upload wraps _call payload and normalizes text
{
    no warnings 'redefine';
    local *DeathByCaptcha::Client::loadImage = sub { return 'bin-data'; };

    $client = Local::SocketClientMock->new(
        queue => [ { captcha => 222, text => '' } ],
    );

    my $uploaded = $client->upload('file.jpg');
    ok(defined $uploaded, 'upload returns captcha hash on success');
    is($uploaded->{captcha}, 222, 'upload returns captcha id from response');
    ok(!defined $uploaded->{text}, 'upload normalizes empty text to undef');

    my $call = $client->calls->[0];
    is($call->{cmd}, 'upload', 'upload delegates to _call("upload")');
    ok(defined $call->{args}{captcha}, 'upload sends encoded captcha payload');
    is($call->{args}{swid}, DeathByCaptcha::Client::SOFTWARE_VENDOR_ID, 'upload sends software vendor id');
}

# uploadToken wraps _call payload and keeps token params as encoded JSON string
{
    $client = Local::SocketClientMock->new(
        queue => [ { captcha => 333, text => '' } ],
    );

    my $token = $client->uploadToken(4, 'token_params', {
        googlekey => 'site-key',
        pageurl   => 'https://example.test/',
    });

    ok(defined $token, 'uploadToken returns captcha hash on success');
    is($token->{captcha}, 333, 'uploadToken returns captcha id from response');
    ok(!defined $token->{text}, 'uploadToken normalizes empty text to undef');

    my $call = $client->calls->[0];
    is($call->{cmd}, 'upload', 'uploadToken delegates to _call("upload")');
    is($call->{args}{type}, 4, 'uploadToken sends token type');
    is($call->{args}{swid}, DeathByCaptcha::Client::SOFTWARE_VENDOR_ID, 'uploadToken sends software vendor id');

    my $decoded = decode_json($call->{args}{token_params});
    is($decoded->{googlekey}, 'site-key', 'uploadToken sends googlekey in token_params');
    is($decoded->{pageurl}, 'https://example.test/', 'uploadToken sends pageurl in token_params');
}

done_testing;
