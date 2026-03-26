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

# Grid image (e.g. 3x3 or 4x4 grid of images to select from)
my $captcha_file = 'samples/test.jpg';

# Optional grid size hint (e.g. '3x3', '2x4'). Leave undef for auto-detect.
# my $grid = '3x3';

my $client = DeathByCaptcha::SocketClient->new($USERNAME, $PASSWORD);

printf("Your balance is %.4f US cents\n", $client->getBalance());

# type=3: reCAPTCHA Image Group
# banner and banner_text describe the selection instruction shown to the user.
my $captcha = $client->decodeToken(
    3,
    'captchafile',
    {
        captchafile => 'base64:' . do {
            open my $fh, '<:raw', $captcha_file or die "Cannot open $captcha_file: $!";
            local $/;
            require MIME::Base64;
            MIME::Base64::encode_base64(<$fh>, '');
        },
        banner      => 'base64:your_banner_base64_here',
        banner_text => 'select all pizza',
        # grid      => '3x3',
    },
    +DeathByCaptcha::Client::DEFAULT_TIMEOUT,
);

if (defined $captcha) {
    printf("CAPTCHA %d solved: %s\n", $captcha->{captcha}, $captcha->{text});

    # Report if the CAPTCHA was solved incorrectly.
    # $client->report($captcha->{captcha});
} else {
    print "Failed to solve CAPTCHA (timeout)\n";
}
