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
perl samples/recaptcha_v2_http.pl "$DBC_USERNAME" "$DBC_PASSWORD" "site_key_here" "https://example.com/login"
```

## Run: reCAPTCHA v3 Token (HTTP)

```bash
perl samples/recaptcha_v3_http.pl "$DBC_USERNAME" "$DBC_PASSWORD" "site_key_here" "https://example.com/login" "login" "0.3"
```

## Run: reCAPTCHA v2 Enterprise (HTTP)

```bash
perl samples/recaptcha_enterprise_http.pl "$DBC_USERNAME" "$DBC_PASSWORD" "enterprise_site_key" "https://example.com/signup"
```

## Run: Cloudflare Turnstile (HTTP)

```bash
perl samples/turnstile_http.pl "$DBC_USERNAME" "$DBC_PASSWORD" '{"sitekey":"site_key_here","pageurl":"https://example.com/challenge"}'
```

## Run: Amazon WAF (HTTP)

```bash
perl samples/amazon_waf_http.pl "$DBC_USERNAME" "$DBC_PASSWORD" '{"sitekey":"site_key_here","pageurl":"https://example.com/challenge"}'
```

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
