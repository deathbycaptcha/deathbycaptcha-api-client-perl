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

# type=15: Capy CAPTCHA
my $captcha = $client->decodeToken(
    15,
    'capy_params',
    {
        proxy      => 'http://user:password@127.0.0.1:1234',
        proxytype  => 'HTTP',
        captchakey => 'PUZZLE_Cv345hL3yQquBKbQ6Tz',
        api_server => 'https://api.capy.me/',
        pageurl    => 'https://www.capy.me/',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);

if (defined $captcha) {
    printf("CAPTCHA %d solved: %s\n", $captcha->{captcha}, $captcha->{text});

    # Report if the CAPTCHA was solved incorrectly.
    # $client->report($captcha->{captcha});
} else {
    print "Failed to solve Capy CAPTCHA (timeout)\n";
}
