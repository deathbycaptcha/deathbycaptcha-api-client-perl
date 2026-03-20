#!/usr/bin/perl
use strict;
use warnings;
use lib '.';
use Test::More;
use Cwd 'abs_path';
use File::Spec;

# Check for .env file
my $env_file = File::Spec->catfile(abs_path('.'), '.env');
unless (-e $env_file) {
    plan skip_all => "Integration test requires .env file with DBC_USERNAME and DBC_PASSWORD.\n"
                   . "Copy .env.example to .env and fill in your credentials.";
    exit;
}

# Load .env file
my %env;
open my $fh, '<', $env_file or die "Cannot open .env: $!";
while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*#/ || $line =~ /^\s*$/;
    if ($line =~ /^([^=]+)=(.*)$/) {
        $env{$1} = $2;
    }
}
close $fh;

# Validate required env vars
unless ($env{DBC_USERNAME} && $env{DBC_PASSWORD}) {
    plan skip_all => "DBC_USERNAME and DBC_PASSWORD must be set in .env file";
    exit;
}

# Find test image in samples folder
my $test_image = File::Spec->catfile(abs_path('.'), 'samples', 'test.jpg');
unless (-e $test_image) {
    plan skip_all => "Test image not found at $test_image";
    exit;
}

plan tests => 9;

use_ok('DeathByCaptcha::SocketClient');
use_ok('DeathByCaptcha::HttpClient');

# Test Socket client
my $client = DeathByCaptcha::SocketClient->new(
    username => $env{DBC_USERNAME},
    password => $env{DBC_PASSWORD},
);
ok($client, "Socket client created successfully");

# Get user balance
my $user = eval { $client->getUser() };
if ($@) {
    if ($@ =~ /credentials|access denied|invalid/i) {
        SKIP: {
            skip("Invalid DBC credentials in .env - cannot run integration test", 6);
        }
        exit 0;
    }
    BAIL_OUT("Failed to connect to DBC API: $@");
}
ok(defined $user, "Got user info from API");
ok($user->{balance} >= 0, "User balance is non-negative: $user->{balance}");

# Test HTTP(S) client only for balance retrieval.
my $http_client = DeathByCaptcha::HttpClient->new(
    $env{DBC_USERNAME},
    $env{DBC_PASSWORD},
);
ok($http_client, "HTTP client created successfully");

my $http_user = eval { $http_client->getUser() };
if ($@) {
    if ($@ =~ /credentials|access denied|invalid|forbidden/i) {
        BAIL_OUT("HTTPS integration check failed due to credentials/auth: $@");
    }
    BAIL_OUT("HTTPS integration check failed: $@");
}
ok(defined $http_user, "Got user info from HTTPS API");
ok($http_user->{balance} >= 0, "HTTPS user balance is non-negative: $http_user->{balance}");

# Upload captcha image
my $captcha_response = eval { $client->upload(captcha => $test_image) };
if ($@) {
    diag("Failed to upload captcha: $@");
    BAIL_OUT("Cannot upload captcha - integration test aborted");
}
ok(
    defined $captcha_response && $captcha_response->{is_correct} == 0,
    "Captcha uploaded successfully, waiting for solving"
);

# Poll for result (with timeout)
my $captcha_id = $captcha_response->{captcha};
my $start_time = time;
my $timeout = 120;  # 2 minutes timeout
my $poll_count = 0;
my $captcha;

while (time - $start_time < $timeout) {
    $captcha = eval { $client->getCaptcha($captcha_id) };
    if ($@) {
        diag("Error polling captcha: $@");
        last;
    }
    
    $poll_count++;
    if ($captcha && $captcha->{is_correct}) {
        diag("Solution text: $captcha->{text}");
        last;
    }
    
    # Wait before next poll
    sleep 2;
}

if ($poll_count > 0 && defined $captcha && !$captcha->{is_correct}) {
    diag("Captcha not solved within $timeout seconds (polled $poll_count times)");
    diag("This is expected behavior - the API service may still be processing");
}

