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

# type=14: Lemin CAPTCHA
my $captcha = $client->decodeToken(
    14,
    'lemin_params',
    {
        proxy     => 'http://user:password@127.0.0.1:1234',
        proxytype => 'HTTP',
        captchaid => 'CROPPED_099216d_8ba061383fa24ef498115023aa7189d4',
        pageurl   => 'https://dashboard.leminnow.com/auth/signup',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);

if (defined $captcha) {
    printf("CAPTCHA %d solved: %s\n", $captcha->{captcha}, $captcha->{text});

    # Report if the CAPTCHA was solved incorrectly.
    # $client->report($captcha->{captcha});
} else {
    print "Failed to solve Lemin CAPTCHA (timeout)\n";
}
