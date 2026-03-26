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
- [Run: GeeTest v3 (Socket)](#run-geetest-v3-socket)
- [Run: GeeTest v4 (Socket)](#run-geetest-v4-socket)
- [Run: Text CAPTCHA (HTTP)](#run-text-captcha-http)
- [Run: Audio CAPTCHA (HTTP)](#run-audio-captcha-http)
- [Run: Lemin (Socket)](#run-lemin-socket)
- [Run: Capy (Socket)](#run-capy-socket)
- [Run: Siara (Socket)](#run-siara-socket)
- [Run: MTCaptcha (Socket)](#run-mtcaptcha-socket)
- [Run: Cutcaptcha (Socket)](#run-cutcaptcha-socket)
- [Run: Friendly Captcha (Socket)](#run-friendly-captcha-socket)
- [Run: DataDome (Socket)](#run-datadome-socket)
- [Run: Tencent (Socket)](#run-tencent-socket)
- [Run: ATB (Socket)](#run-atb-socket)
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
- `samples/example.reCAPTCHA_Coordinates.pl`
- `samples/example.reCAPTCHA_Image_Group.pl`
- `samples/example.Geetest_v3.pl`
- `samples/example.Geetest_v4.pl`
- `samples/example.Textcaptcha.pl`
- `samples/example.Audio.pl`
- `samples/example.Lemin.pl`
- `samples/example.Capy.pl`
- `samples/example.Siara.pl`
- `samples/example.Mtcaptcha.pl`
- `samples/example.Cutcaptcha.pl`
- `samples/example.Friendly.pl`
- `samples/example.Datadome.pl`
- `samples/example.Tencent.pl`
- `samples/example.Atb.pl`
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
perl samples/example.pl <username|authtoken> <password|token> [captcha_file]
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

## Run: GeeTest v3 (Socket)

Edit `samples/example.Geetest_v3.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Geetest_v3.pl
```

## Run: GeeTest v4 (Socket)

Edit `samples/example.Geetest_v4.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Geetest_v4.pl
```

## Run: Text CAPTCHA (HTTP)

Edit `samples/example.Textcaptcha.pl` with your credentials and question text, then run:

```bash
perl samples/example.Textcaptcha.pl
```

## Run: Audio CAPTCHA (HTTP)

Edit `samples/example.Audio.pl` with your credentials and the path to the audio file, then run:

```bash
perl samples/example.Audio.pl
```

## Run: Lemin (Socket)

Edit `samples/example.Lemin.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Lemin.pl
```

## Run: Capy (Socket)

Edit `samples/example.Capy.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Capy.pl
```

## Run: Siara (Socket)

Edit `samples/example.Siara.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Siara.pl
```

## Run: MTCaptcha (Socket)

Edit `samples/example.Mtcaptcha.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Mtcaptcha.pl
```

## Run: Cutcaptcha (Socket)

Edit `samples/example.Cutcaptcha.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Cutcaptcha.pl
```

## Run: Friendly Captcha (Socket)

Edit `samples/example.Friendly.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Friendly.pl
```

## Run: DataDome (Socket)

Edit `samples/example.Datadome.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Datadome.pl
```

## Run: Tencent (Socket)

Edit `samples/example.Tencent.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Tencent.pl
```

## Run: ATB (Socket)

Edit `samples/example.Atb.pl` with your credentials and parameters, then run:

```bash
perl samples/example.Atb.pl
```

## Known Test Settings by Type

Use these settings as a starting point while testing the token samples:

| Type | Sample | Key parameters |
|---|---|---|
| `0` Standard Image | `samples/example.pl` | any valid CAPTCHA image |
| `2` reCAPTCHA Coordinates | `samples/example.reCAPTCHA_Coordinates.pl` | CAPTCHA screenshot image |
| `3` reCAPTCHA Image Group | `samples/example.reCAPTCHA_Image_Group.pl` | grid image, banner, banner_text |
| `4` reCAPTCHA v2 | `samples/recaptcha_v2_http.pl` | `googlekey=6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-`, `pageurl=http://test.com/path` |
| `5` reCAPTCHA v3 | `samples/recaptcha_v3_http.pl` | `googlekey=6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-`, `pageurl=http://test.com/path`, `action=login`, `min_score=0.3` |
| `8` GeeTest v3 | `samples/example.Geetest_v3.pl` | `gt`, `challenge` (changes per reload), `pageurl` |
| `9` GeeTest v4 | `samples/example.Geetest_v4.pl` | `captcha_id`, `pageurl` |
| `11` Text CAPTCHA | `samples/example.Textcaptcha.pl` | `textcaptcha` (the question string) |
| `12` Cloudflare Turnstile | `samples/turnstile_http.pl` | `sitekey=1x00000000000000000000AA`, `pageurl=https://demo.turnstile.cloudflare.com/` |
| `13` Audio | `samples/example.Audio.pl` | audio file path, `language=en` |
| `14` Lemin | `samples/example.Lemin.pl` | `captchaid`, `pageurl` |
| `15` Capy | `samples/example.Capy.pl` | `captchakey`, `api_server`, `pageurl` |
| `16` Amazon WAF | `samples/amazon_waf_http.pl` | `sitekey`, `pageurl`, `iv`, `context` (dynamic) |
| `17` Siara | `samples/example.Siara.pl` | `slideurlid`, `pageurl`, `useragent` |
| `18` MTCaptcha | `samples/example.Mtcaptcha.pl` | `sitekey`, `pageurl` |
| `19` Cutcaptcha | `samples/example.Cutcaptcha.pl` | `apikey`, `miserykey`, `pageurl` |
| `20` Friendly Captcha | `samples/example.Friendly.pl` | `sitekey`, `pageurl` |
| `21` DataDome | `samples/example.Datadome.pl` | `pageurl`, `captcha_url` |
| `23` Tencent | `samples/example.Tencent.pl` | `appid`, `pageurl` |
| `24` ATB | `samples/example.Atb.pl` | `appid`, `apiserver`, `pageurl` |
| `25` reCAPTCHA v2 Enterprise | `samples/recaptcha_enterprise_http.pl` | `googlekey=6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-`, `pageurl=http://test.com/path` |

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
