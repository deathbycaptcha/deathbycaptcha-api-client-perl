#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DeathByCaptcha::Client;
use DeathByCaptcha::HttpClient;


my ($username, $password, $googlekey, $pageurl, $action, $min_score, $proxy, $proxytype, $timeout) = @ARGV;

if (!defined $username || !defined $password || !defined $googlekey || !defined $pageurl || !defined $action || !defined $min_score) {
    die "Usage: perl $0 <username|authtoken> <password|token> <googlekey> <pageurl> <action> <min_score> [proxy] [proxytype] [timeout_seconds]\n";
}

my %params = (
    googlekey => $googlekey,
    pageurl   => $pageurl,
    action    => $action,
    min_score => 0 + $min_score,
);
$params{proxy} = $proxy if defined $proxy && $proxy ne '';
$params{proxytype} = $proxytype if defined $proxytype && $proxytype ne '';

my $client = DeathByCaptcha::HttpClient->new($username, $password);
my $result = $client->decodeToken(
    5,
    'token_params',
    \%params,
    (defined $timeout ? int($timeout) : +DeathByCaptcha::Client::DEFAULT_TIMEOUT)
);

if (!defined $result) {
    die "Failed to solve reCAPTCHA v3 token\n";
}

print "CAPTCHA " . $result->{captcha} . " solved token: " . $result->{text} . "\n";