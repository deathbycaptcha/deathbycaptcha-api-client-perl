#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DeathByCaptcha::Client;
use DeathByCaptcha::HttpClient;


my ($username, $password, $googlekey, $pageurl, $proxy, $proxytype, $timeout) = @ARGV;

if (!defined $username || !defined $password || !defined $googlekey || !defined $pageurl) {
    die "Usage: perl $0 <username|authtoken> <password|token> <googlekey> <pageurl> [proxy] [proxytype] [timeout_seconds]\n";
}

my %params = (
    googlekey => $googlekey,
    pageurl   => $pageurl,
);
$params{proxy} = $proxy if defined $proxy && $proxy ne '';
$params{proxytype} = $proxytype if defined $proxytype && $proxytype ne '';

my $client = DeathByCaptcha::HttpClient->new($username, $password);
my $result = $client->decodeToken(
    25,
    'token_enterprise_params',
    \%params,
    (defined $timeout ? int($timeout) : +DeathByCaptcha::Client::DEFAULT_TIMEOUT)
);

if (!defined $result) {
    die "Failed to solve reCAPTCHA v2 Enterprise token\n";
}

print "CAPTCHA " . $result->{captcha} . " solved token: " . $result->{text} . "\n";