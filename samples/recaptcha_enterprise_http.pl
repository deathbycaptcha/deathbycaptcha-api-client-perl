#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Request::Common qw(GET POST);
use HTTP::Status qw(
    RC_BAD_REQUEST
    RC_FORBIDDEN
    RC_NOT_IMPLEMENTED
    RC_OK
    RC_SEE_OTHER
    RC_SERVICE_UNAVAILABLE
    status_message
);
use JSON qw(decode_json encode_json);
use LWP::UserAgent;

use constant API_SERVER_URL => 'https://api.dbcapi.me/api';
use constant SAMPLE_USER_AGENT => 'DBC/Perl token sample v4.7.0';


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

my $result = submit_and_poll_token_captcha(
    username  => $username,
    password  => $password,
    type      => 25,
    param_key => 'token_enterprise_params',
    params    => \%params,
    timeout   => $timeout,
);

print "CAPTCHA " . $result->{captcha} . " solved token: " . $result->{text} . "\n";

sub submit_and_poll_token_captcha {
    my (%args) = @_;

    my $username  = $args{username};
    my $password  = $args{password};
    my $type      = $args{type};
    my $param_key = $args{param_key};
    my $params    = $args{params};
    my $timeout   = defined $args{timeout} ? int($args{timeout}) : 120;
    my $interval  = 5;

    die "username is required\n" if !defined $username || $username eq '';
    die "password/token is required\n" if !defined $password || $password eq '';
    die "type is required\n" if !defined $type;
    die "param_key is required\n" if !defined $param_key || $param_key eq '';
    die "params hashref is required\n" if ref($params) ne 'HASH';
    die "timeout must be > 0\n" if $timeout <= 0;

    my $ua = LWP::UserAgent->new(agent => SAMPLE_USER_AGENT, timeout => 30);

    my @content = (
        auth_content($username, $password),
        type => $type,
        $param_key => encode_json($params),
    );

    my $upload_response = $ua->request(POST(
        join('/', API_SERVER_URL, 'captcha'),
        Accept  => 'application/json',
        Content => \@content,
    ));

    my $captcha_id = extract_captcha_id($upload_response);
    my $deadline = time() + $timeout;

    while (time() < $deadline) {
        my $poll_response = $ua->request(GET(
            join('/', API_SERVER_URL, 'captcha', $captcha_id),
            Accept => 'application/json',
        ));

        my $payload = decode_json_or_die($poll_response);
        if (defined $payload->{text} && $payload->{text} ne '') {
            return {
                captcha => $captcha_id,
                text    => $payload->{text},
                raw     => $payload,
            };
        }

        sleep $interval;
    }

    die "Timed out waiting for captcha $captcha_id after $timeout seconds\n";
}

sub auth_content {
    my ($username, $password) = @_;
    return $username eq 'authtoken'
        ? (authtoken => $password)
        : (username => $username, password => $password);
}

sub extract_captcha_id {
    my ($response) = @_;

    if ($response->code == RC_SEE_OTHER) {
        my $location = $response->header('Location') // '';
        if ($location =~ m{/(\d+)$}) {
            return int($1);
        }
        die "Upload succeeded but Location header did not contain captcha id\n";
    }

    if ($response->code == RC_OK) {
        my $payload = decode_json_or_die($response);
        if (defined $payload->{captcha} && $payload->{captcha} =~ /^\d+$/) {
            return int($payload->{captcha});
        }
        die "Upload response does not include a numeric captcha id\n";
    }

    die_for_http_error($response, 'upload');
}

sub decode_json_or_die {
    my ($response) = @_;
    my $content = $response->decoded_content;
    my $decoded;

    eval { $decoded = decode_json($content); 1 } or do {
        my $status = $response->code;
        die "Failed to decode JSON response (HTTP $status): $content\n";
    };

    return $decoded;
}

sub die_for_http_error {
    my ($response, $operation) = @_;
    my $code = $response->code;
    my $content = $response->decoded_content;

    my $error_msg;
    my $decoded = eval { decode_json($content) };
    if ($decoded && ref($decoded) eq 'HASH') {
        $error_msg = $decoded->{error};
    }

    if ($code == RC_FORBIDDEN) {
        die "HTTP 403 during $operation: invalid credentials or insufficient balance\n";
    }
    if ($code == RC_BAD_REQUEST) {
        die "HTTP 400 during $operation: invalid request payload" . ($error_msg ? " ($error_msg)" : '') . "\n";
    }
    if ($code == RC_NOT_IMPLEMENTED) {
        die "HTTP 501 during $operation: captcha type/params not implemented" . ($error_msg ? " ($error_msg)" : '') . "\n";
    }
    if ($code == RC_SERVICE_UNAVAILABLE) {
        die "HTTP 503 during $operation: service overloaded, retry later\n";
    }

    die "HTTP $code during $operation: " . status_message($code) . ($error_msg ? " ($error_msg)" : '') . "\n";
}