#!/usr/bin/perl
use strict;
use warnings;
use lib '.';
use Test::More;
use Cwd 'abs_path';
use File::Spec;

sub load_env {
    my ($env_file) = @_;
    my %env;

    open my $fh, '<', $env_file or die "Cannot open .env: $!";
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\s*#/ || $line =~ /^\s*$/;

        if ($line =~ /^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/) {
            my ($key, $value) = ($1, $2);
            if ($value =~ /^"(.*)"$/ || $value =~ /^'(.*)'$/) {
                $value = $1;
            } else {
                $value =~ s/^\s+//;
                $value =~ s/\s+$//;
            }
            $env{$key} = $value;
        }
    }
    close $fh;

    return %env;
}

sub poll_for_solution {
    my ($label, $client, $captcha_id, $timeout) = @_;

    my $start_time = time;
    my $poll_count = 0;
    my $captcha;

    diag("[$label] Polling for solution (captcha_id=$captcha_id, timeout=${timeout}s)");

    while (time - $start_time < $timeout) {
        $captcha = eval { $client->getCaptcha($captcha_id) };
        if ($@) {
            diag("[$label] Poll error: $@");
            last;
        }

        $poll_count++;
        my $elapsed = time - $start_time;
        my $is_correct = defined $captcha ? ($captcha->{is_correct} // 'undef') : 'undef';
        my $text = '(pending)';
        if (defined $captcha && defined $captcha->{text} && $captcha->{text} ne '') {
            $text = length($captcha->{text}) > 120
                ? substr($captcha->{text}, 0, 120) . '...'
                : $captcha->{text};
        }

        diag(sprintf("[%s] Poll #%d elapsed=%ds is_correct=%s text=%s",
            $label, $poll_count, $elapsed, $is_correct, $text));

        if ($captcha && defined $captcha->{text} && $captcha->{text} ne '') {
            my $preview = length($captcha->{text}) > 120
                ? substr($captcha->{text}, 0, 120) . '...'
                : $captcha->{text};
            diag("[$label] Solution received: $preview");
            return $captcha;
        }

        sleep 2;
    }

    diag("[$label] Timeout or no solution after $poll_count polls");
    return $captcha;
}

# Check for .env file
my $env_file = File::Spec->catfile(abs_path('.'), '.env');
unless (-e $env_file) {
    plan skip_all => "Integration test requires .env file with DBC_USERNAME and DBC_PASSWORD.\n"
                   . "Copy .env.example to .env and fill in your credentials.";
    exit;
}

my %env = load_env($env_file);

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

use_ok('DeathByCaptcha::SocketClient');
use_ok('DeathByCaptcha::HttpClient');

my $token_timeout = $env{DBC_TOKEN_TIMEOUT}
    ? int($env{DBC_TOKEN_TIMEOUT})
    : 120;
my %recaptcha_v2_params = (
    googlekey => ($env{DBC_RECAPTCHA_V2_GOOGLEKEY} || '6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-'),
    pageurl   => ($env{DBC_RECAPTCHA_V2_PAGEURL}   || 'http://test.com/path'),
);
$recaptcha_v2_params{proxy} = $env{DBC_RECAPTCHA_PROXY}
    if defined $env{DBC_RECAPTCHA_PROXY} && $env{DBC_RECAPTCHA_PROXY} ne '';
$recaptcha_v2_params{proxytype} = $env{DBC_RECAPTCHA_PROXYTYPE}
    if defined $env{DBC_RECAPTCHA_PROXYTYPE} && $env{DBC_RECAPTCHA_PROXYTYPE} ne '';

diag('=== DeathByCaptcha Integration Test ===');
diag("Username: $env{DBC_USERNAME}");
diag("Test image: $test_image");
diag("Token timeout: ${token_timeout}s");
diag('reCAPTCHA v2 params: googlekey=' . $recaptcha_v2_params{googlekey} . ', pageurl=' . $recaptcha_v2_params{pageurl});

my $socket_client = DeathByCaptcha::SocketClient->new(
    username => $env{DBC_USERNAME},
    password => $env{DBC_PASSWORD},
);
ok($socket_client, 'Socket client created successfully');

my $http_client = DeathByCaptcha::HttpClient->new(
    $env{DBC_USERNAME},
    $env{DBC_PASSWORD},
);
ok($http_client, 'HTTP client created successfully');

# HTTP auth baseline
my $http_user = eval { $http_client->getUser() };
ok(!$@, 'HTTP getUser call did not throw');
if ($@) {
    diag("HTTP getUser error: $@");
}
ok(defined $http_user && defined $http_user->{balance} && $http_user->{balance} >= 0,
    'HTTP user and balance are valid');
if (defined $http_user) {
    diag("HTTP balance: $http_user->{balance}");
}

# Socket is mandatory for this integration test.
my $socket_user = eval { $socket_client->getUser() };
ok(!$@, 'Socket getUser call did not throw');
if ($@) {
    diag("Socket getUser error: $@");
}
ok(defined $socket_user && defined $socket_user->{balance} && $socket_user->{balance} >= 0,
    'Socket user and balance are valid');
if (defined $socket_user) {
    diag("Socket balance: $socket_user->{balance}");
}

SKIP: {
    skip('Skipping solve flows because Socket auth failed', 6)
        if !defined $socket_user || !defined $socket_user->{balance};

    # Image solve via Socket (mandatory path)
    diag('--- [Socket Image] Uploading captcha image');
    my $socket_upload = eval { $socket_client->upload($test_image) };
    ok(!$@, 'Socket image upload did not throw');
    if ($@) {
        diag("Socket image upload error: $@");
    }

    my $socket_upload_ok = ok(
        defined $socket_upload && ($socket_upload->{captcha} || 0) > 0,
        'Socket image upload returned captcha id'
    );
    if ($socket_upload_ok) {
        diag('Socket image upload captcha_id=' . $socket_upload->{captcha}
            . ' is_correct=' . ($socket_upload->{is_correct} // 'undef'));

        my $socket_image_result = $socket_upload;
        if (!$socket_upload->{is_correct}) {
            $socket_image_result = poll_for_solution(
                'Socket Image',
                $socket_client,
                $socket_upload->{captcha},
                $token_timeout,
            );
        }

        ok(defined $socket_image_result && defined $socket_image_result->{text} && $socket_image_result->{text} ne '',
            'Socket image captcha solved with non-empty text');
    } else {
        ok(0, 'Socket image captcha solved with non-empty text');
    }

    # reCAPTCHA v2 via HTTP
    diag('--- [HTTP reCAPTCHA v2] Submitting token challenge');
    my $http_token_upload = eval {
        $http_client->uploadToken(4, 'token_params', \%recaptcha_v2_params)
    };
    ok(!$@, 'HTTP reCAPTCHA v2 upload did not throw');
    if ($@) {
        diag("HTTP reCAPTCHA v2 upload error: $@");
    }

    my $http_token_upload_ok = ok(
        defined $http_token_upload && ($http_token_upload->{captcha} || 0) > 0,
        'HTTP reCAPTCHA v2 upload returned captcha id'
    );
    if ($http_token_upload_ok) {
        diag('HTTP reCAPTCHA v2 captcha_id=' . $http_token_upload->{captcha}
            . ' is_correct=' . ($http_token_upload->{is_correct} // 'undef'));

        my $http_token_result = $http_token_upload;
        if (!defined $http_token_upload->{text} || $http_token_upload->{text} eq '') {
            $http_token_result = poll_for_solution(
                'HTTP reCAPTCHA v2',
                $http_client,
                $http_token_upload->{captcha},
                $token_timeout,
            );
        } else {
            diag('HTTP reCAPTCHA v2 solved immediately');
        }

        ok(defined $http_token_result && defined $http_token_result->{text} && $http_token_result->{text} ne '',
            'HTTP reCAPTCHA v2 solved with non-empty token');
    } else {
        ok(0, 'HTTP reCAPTCHA v2 solved with non-empty token');
    }

    # reCAPTCHA v2 via Socket
    diag('--- [Socket reCAPTCHA v2] Submitting token challenge');
    my $socket_token_upload = eval {
        $socket_client->uploadToken(4, 'token_params', \%recaptcha_v2_params)
    };
    ok(!$@, 'Socket reCAPTCHA v2 upload did not throw');
    if ($@) {
        diag("Socket reCAPTCHA v2 upload error: $@");
    }

    my $socket_token_upload_ok = ok(
        defined $socket_token_upload && ($socket_token_upload->{captcha} || 0) > 0,
        'Socket reCAPTCHA v2 upload returned captcha id'
    );
    if ($socket_token_upload_ok) {
        diag('Socket reCAPTCHA v2 captcha_id=' . $socket_token_upload->{captcha}
            . ' is_correct=' . ($socket_token_upload->{is_correct} // 'undef'));

        my $socket_token_result = $socket_token_upload;
        if (!defined $socket_token_upload->{text} || $socket_token_upload->{text} eq '') {
            $socket_token_result = poll_for_solution(
                'Socket reCAPTCHA v2',
                $socket_client,
                $socket_token_upload->{captcha},
                $token_timeout,
            );
        } else {
            diag('Socket reCAPTCHA v2 solved immediately');
        }

        ok(defined $socket_token_result && defined $socket_token_result->{text} && $socket_token_result->{text} ne '',
            'Socket reCAPTCHA v2 solved with non-empty token');
    } else {
        ok(0, 'Socket reCAPTCHA v2 solved with non-empty token');
    }
}

diag('=== Integration test finished ===');
done_testing();
