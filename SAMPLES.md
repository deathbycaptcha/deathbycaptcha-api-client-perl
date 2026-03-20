# Samples Guide

This document contains usage examples for scripts in `samples/`.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Sample Scripts](#sample-scripts)
- [Run: Get Balance](#run-get-balance)
- [Run: Solve CAPTCHA](#run-solve-captcha)
- [Run: reCAPTCHA v2 Token (HTTP)](#run-recaptcha-v2-token-http)
- [Run: reCAPTCHA v3 Token (HTTP)](#run-recaptcha-v3-token-http)
- [Run: reCAPTCHA v2 Enterprise (HTTP)](#run-recaptcha-v2-enterprise-http)
- [Run: Cloudflare Turnstile (HTTP)](#run-cloudflare-turnstile-http)
- [Run: Amazon WAF (HTTP)](#run-amazon-waf-http)
- [Known Test Settings by Type](#known-test-settings-by-type)
- [Perl API Snippets](#perl-api-snippets)
- [Notes](#notes)

## Overview

Available sample assets:

- `samples/get_balance.pl`
- `samples/example.pl`
- `samples/recaptcha_v2_http.pl`
- `samples/recaptcha_v3_http.pl`
- `samples/recaptcha_enterprise_http.pl`
- `samples/turnstile_http.pl`
- `samples/amazon_waf_http.pl`
- `samples/test.jpg`

## Prerequisites

Install dependencies:

```bash
cpanm --installdeps .
```

## Sample Scripts

### `samples/get_balance.pl`

Checks account balance using HTTP or Socket transport.

Usage:

```bash
perl samples/get_balance.pl <username|authtoken> <password|token> [HTTP|SOCKET]
```

### `samples/example.pl`

Prints account balance and solves a CAPTCHA image.

Usage:

```bash
perl samples/example.pl <username|authtoken> <password|token> <captcha_file>
```

### `samples/recaptcha_v2_http.pl`

Submits type `4` with `token_params` for reCAPTCHA v2 and polls for a token result.

```bash
perl samples/recaptcha_v2_http.pl <username|authtoken> <password|token> <googlekey> <pageurl> [proxy] [proxytype] [timeout_seconds]
```

### `samples/recaptcha_v3_http.pl`

Submits type `5` with `token_params` (`action`, `min_score`) and polls for a token result.

```bash
perl samples/recaptcha_v3_http.pl <username|authtoken> <password|token> <googlekey> <pageurl> <action> <min_score> [proxy] [proxytype] [timeout_seconds]
```

### `samples/recaptcha_enterprise_http.pl`

Submits type `25` with `token_enterprise_params` and polls for a token result.

```bash
perl samples/recaptcha_enterprise_http.pl <username|authtoken> <password|token> <googlekey> <pageurl> [proxy] [proxytype] [timeout_seconds]
```

### `samples/turnstile_http.pl`

Submits type `12` with `turnstile_params` as JSON and polls for a token result.

```bash
perl samples/turnstile_http.pl <username|authtoken> <password|token> '<turnstile_params_json>' [timeout_seconds]
```

### `samples/amazon_waf_http.pl`

Submits type `16` with `waf_params` as JSON and polls for a token result.

```bash
perl samples/amazon_waf_http.pl <username|authtoken> <password|token> '<waf_params_json>' [timeout_seconds]
```

> **Note:** Amazon WAF requires `iv` and `context` alongside `sitekey` and `pageurl`. These values are specific to each live challenge instance and must be extracted from the protected page at runtime.

## Run: Get Balance

HTTP:

```bash
perl samples/get_balance.pl <username|authtoken> <password|token> HTTP
```

Socket:

```bash
perl samples/get_balance.pl <username|authtoken> <password|token> SOCKET
```

## Run: Solve CAPTCHA

```bash
perl samples/example.pl <username|authtoken> <password|token> samples/test.jpg
```

## Run: reCAPTCHA v2 Token (HTTP)

```bash
perl samples/recaptcha_v2_http.pl "$DBC_USERNAME" "$DBC_PASSWORD" \
    "6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-" \
    "http://test.com/path"
```

## Run: reCAPTCHA v3 Token (HTTP)

Test with `action` and `min_score` parameters:

```bash
perl samples/recaptcha_v3_http.pl "$DBC_USERNAME" "$DBC_PASSWORD" \
    "6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-" \
    "http://test.com/path" "login" "0.3"
```

## Run: reCAPTCHA v2 Enterprise (HTTP)

```bash
perl samples/recaptcha_enterprise_http.pl "$DBC_USERNAME" "$DBC_PASSWORD" \
    "6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-" \
    "http://test.com/path"
```

## Run: Cloudflare Turnstile (HTTP)

Test with [Cloudflare's official always-pass sitekey](https://developers.cloudflare.com/turnstile/reference/testing/):

```bash
perl samples/turnstile_http.pl "$DBC_USERNAME" "$DBC_PASSWORD" \
    '{"sitekey":"1x00000000000000000000AA","pageurl":"https://demo.turnstile.cloudflare.com/"}'
```

## Run: Amazon WAF (HTTP)

Amazon WAF CAPTCHA requires `iv` and `context` values from a live WAF challenge in addition to `sitekey` and `pageurl`.
These values change with each challenge instance and must be extracted from the protected page at runtime.

```bash
perl samples/amazon_waf_http.pl "$DBC_USERNAME" "$DBC_PASSWORD" \
    '{"sitekey":"<AWS_WAF_KEY>","pageurl":"<PROTECTED_URL>","iv":"<IV>","context":"<CONTEXT>"}'
```

## Known Test Settings by Type

Use these settings as a starting point while testing the token samples:

| Type | Sample | Settings used |
|---|---|---|
| `4` reCAPTCHA v2 | `samples/recaptcha_v2_http.pl` | `googlekey=6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-`, `pageurl=http://test.com/path` |
| `5` reCAPTCHA v3 | `samples/recaptcha_v3_http.pl` | `googlekey=6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-`, `pageurl=http://test.com/path`, `action=login`, `min_score=0.3` |
| `25` reCAPTCHA v2 Enterprise | `samples/recaptcha_enterprise_http.pl` | `googlekey=6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-`, `pageurl=http://test.com/path` |
| `12` Cloudflare Turnstile | `samples/turnstile_http.pl` | `sitekey=1x00000000000000000000AA`, `pageurl=https://demo.turnstile.cloudflare.com/` |
| `16` Amazon WAF | `samples/amazon_waf_http.pl` | `sitekey=AQIDAHjcYu/GjX+QlghicBg4CQG345nUGDFTbNH1h5zmP4MHSgF4BObLIm50T/dCQ7XG`, `pageurl=https://efw47fpad9.execute-api.us-east-1.amazonaws.com/latest`, plus required dynamic `iv` and `context` |

For Amazon WAF, `iv` and `context` must come from a live challenge page at request time; static values do not work.

## Perl API Snippets

### Create Client and Check Balance (HTTP)

```perl
use strict;
use warnings;

use lib '.';
use DeathByCaptcha::HttpClient;

my ($username, $password) = @ARGV;
my $client = DeathByCaptcha::HttpClient->new($username, $password);

printf("Your balance is %f US cents\n", $client->getBalance());
```

### Decode CAPTCHA

```perl
use strict;
use warnings;

use lib '.';
use DeathByCaptcha::HttpClient;
use DeathByCaptcha::Client;

my ($username, $password, $filename) = @ARGV;
my $client = DeathByCaptcha::HttpClient->new($username, $password);

my $captcha = $client->decode($filename, +DeathByCaptcha::Client::DEFAULT_TIMEOUT);
if (defined $captcha) {
    print "CAPTCHA " . $captcha->{"captcha"} . " solved: " . $captcha->{"text"} . "\n";
}
```

### Report Incorrect Solution

```perl
my $ok = $client->report($captcha->{"captcha"});
print $ok ? "Reported\n" : "Not reported\n";
```

## Notes

- Only report a CAPTCHA when it is truly incorrect.
- For socket mode, ensure outbound TCP to `api.dbcapi.me` ports `8123-8130`.
- The token samples are aligned with `deathbycaptcha-agent-api-metadata/spec/openapi/http.yaml` type IDs and parameter field names.
- `LWP::Protocol::https` must be installed for HTTPS requests to work (`cpanm --installdeps .` or `sudo dnf install perl-LWP-Protocol-https`).
- Amazon WAF (type 16) requires `iv` and `context` from a live challenge — these change per request and must be extracted from the real protected page at runtime.
