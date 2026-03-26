#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DeathByCaptcha::Client;
use DeathByCaptcha::SocketClient;

# Put your DeathByCaptcha username & password here.
# If using authtoken authentication, set $USERNAME = 'authtoken'
# and $PASSWORD = your authtoken from the user panel.
my $USERNAME = 'your_username';
my $PASSWORD = 'your_password';

my $client = DeathByCaptcha::SocketClient->new($USERNAME, $PASSWORD);

printf("Your balance is %.4f US cents\n", $client->getBalance());

# type=9: GeeTest v4
my $captcha = $client->decodeToken(
    9,
    'geetest_params',
    {
        proxy      => 'http://user:password@127.0.0.1:1234',
        proxytype  => 'HTTP',
        captcha_id => 'fcd636b4514bf7ac4143922550b3008b',
        pageurl    => 'https://www.geetest.com/en/adaptive-captcha-demo',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);

if (defined $captcha) {
    printf("CAPTCHA %d solved: %s\n", $captcha->{captcha}, $captcha->{text});

    # Report if the CAPTCHA was solved incorrectly.
    # $client->report($captcha->{captcha});
} else {
    print "Failed to solve GeeTest v4 (timeout)\n";
}
