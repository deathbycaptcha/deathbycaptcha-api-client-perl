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
    die "Usage: perl $0 <username|authtoken> <password|token> '<waf_params_json>' [timeout_seconds]\n\n" .
        "waf_params_json required fields: sitekey, pageurl, iv (initialization vector), context.\n" .
        "iv and context must be extracted from an active Amazon WAF CAPTCHA challenge at runtime.\n" .
        "Example:\n" .
        "  {\"sitekey\":\"<AWS_WAF_KEY>\",\"pageurl\":\"<URL>\",\"iv\":\"<IV>\",\"context\":\"<CONTEXT>\"}\n";
}

my $params = eval { decode_json($params_json) };
if ($@ || ref($params) ne 'HASH') {
    die "waf_params_json must be a valid JSON object\n";
}

my $client = DeathByCaptcha::HttpClient->new($username, $password);
my $result = $client->decodeToken(
    16,
    'waf_params',
    $params,
    (defined $timeout ? int($timeout) : +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT)
);

if (!defined $result) {
    die "Failed to solve Amazon WAF token\n";
}

print "CAPTCHA " . $result->{captcha} . " solved token: " . $result->{text} . "\n";
