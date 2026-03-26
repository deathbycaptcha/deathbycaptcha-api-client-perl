#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DeathByCaptcha::Client;
use DeathByCaptcha::HttpClient;
use MIME::Base64 qw(encode_base64);

# Put your DeathByCaptcha username & password here.
# If using authtoken authentication, set $USERNAME = 'authtoken'
# and $PASSWORD = your authtoken from the user panel.
my $USERNAME = 'your_username';
my $PASSWORD = 'your_password';

# Path to the audio file (mp3, wav, etc.)
my $audio_file = 'samples/audio.mp3';

my $client = DeathByCaptcha::HttpClient->new($USERNAME, $PASSWORD);

printf("Your balance is %.4f US cents\n", $client->getBalance());

# Read and base64-encode the audio file
open my $fh, '<:raw', $audio_file or die "Cannot open $audio_file: $!";
local $/;
my $audio_b64 = encode_base64(<$fh>, '');
close $fh;

# type=13: Audio CAPTCHA
my $captcha = $client->decodeToken(
    13,
    'audio',
    {
        audio    => $audio_b64,
        language => 'en',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);

if (defined $captcha) {
    printf("CAPTCHA %d solved: %s\n", $captcha->{captcha}, $captcha->{text});

    # Report if the CAPTCHA was solved incorrectly.
    # $client->report($captcha->{captcha});
} else {
    print "Failed to solve Audio CAPTCHA (timeout)\n";
}
