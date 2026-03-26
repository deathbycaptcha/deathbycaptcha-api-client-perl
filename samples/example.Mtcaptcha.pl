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

# type=18: MTCaptcha
my $captcha = $client->decodeToken(
    18,
    'mtcaptcha_params',
    {
        proxy     => 'http://user:password@127.0.0.1:1234',
        proxytype => 'HTTP',
        sitekey   => 'MTPublic-KzqLY1cKH',
        pageurl   => 'https://2captcha.com/demo/mtcaptcha',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);

if (defined $captcha) {
    printf("CAPTCHA %d solved: %s\n", $captcha->{captcha}, $captcha->{text});

    # Report if the CAPTCHA was solved incorrectly.
    # $client->report($captcha->{captcha});
} else {
    print "Failed to solve MTCaptcha (timeout)\n";
}
