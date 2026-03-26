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

# captcha image file (screenshot where the user must click coordinates)
my $captcha_file = 'samples/test.jpg';

my $client = DeathByCaptcha::SocketClient->new($USERNAME, $PASSWORD);

printf("Your balance is %.4f US cents\n", $client->getBalance());

my $captcha = $client->decode($captcha_file, +DeathByCaptcha::Client::DEFAULT_TIMEOUT);

if (defined $captcha) {
    printf("CAPTCHA %d solved: %s\n", $captcha->{captcha}, $captcha->{text});

    # Report if the CAPTCHA was solved incorrectly.
    # $client->report($captcha->{captcha});
} else {
    print "Failed to solve CAPTCHA (timeout)\n";
}
