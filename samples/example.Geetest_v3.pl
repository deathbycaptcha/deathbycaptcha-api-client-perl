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

# type=8: GeeTest v3
# IMPORTANT: the 'challenge' value changes every time the page reloads.
# You must extract it from the live API calls made to GeeTest on the target page.
my $captcha = $client->decodeToken(
    8,
    'geetest_params',
    {
        proxy     => 'http://user:password@127.0.0.1:1234',
        proxytype => 'HTTP',
        gt        => '022397c99c9f646f6477822485f30404',
        challenge => '536b43c61236cf1964dc93bfde421126',
        pageurl   => 'https://www.geetest.com/en/demo',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);

if (defined $captcha) {
    printf("CAPTCHA %d solved: %s\n", $captcha->{captcha}, $captcha->{text});

    # Report if the CAPTCHA was solved incorrectly.
    # $client->report($captcha->{captcha});
} else {
    print "Failed to solve GeeTest v3 (timeout)\n";
}
