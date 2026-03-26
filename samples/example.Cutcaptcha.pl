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

# type=19: Cutcaptcha
my $captcha = $client->decodeToken(
    19,
    'cutcaptcha_params',
    {
        proxy      => 'http://user:password@127.0.0.1:1234',
        proxytype  => 'HTTP',
        apikey     => 'SAs61IAI',
        miserykey  => '56a9e9b989aa8cf99e0cea28d4b4678b84fa7a4e',
        pageurl    => 'https://filecrypt.cc/Contact.html',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);

if (defined $captcha) {
    printf("CAPTCHA %d solved: %s\n", $captcha->{captcha}, $captcha->{text});

    # Report if the CAPTCHA was solved incorrectly.
    # $client->report($captcha->{captcha});
} else {
    print "Failed to solve Cutcaptcha (timeout)\n";
}
