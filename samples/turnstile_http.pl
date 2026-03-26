#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DeathByCaptcha::Client;
use DeathByCaptcha::HttpClient;
use JSON qw(decode_json);


my ($username, $password, $params_json, $timeout) = @ARGV;

if (!defined $username || !defined $password || !defined $params_json) {
    die "Usage: perl $0 <username|authtoken> <password|token> '<turnstile_params_json>' [timeout_seconds]\n";
}

my $params = eval { decode_json($params_json) };
if ($@ || ref($params) ne 'HASH') {
    die "turnstile_params_json must be a valid JSON object\n";
}

my $client = DeathByCaptcha::HttpClient->new($username, $password);
my $result = $client->decodeToken(
    12,
    'turnstile_params',
    $params,
    (defined $timeout ? int($timeout) : +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT)
);

if (!defined $result) {
    die "Failed to solve Cloudflare Turnstile token\n";
}

print "CAPTCHA " . $result->{captcha} . " solved token: " . $result->{text} . "\n";