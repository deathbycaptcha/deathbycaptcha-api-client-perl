# [DeathByCaptcha](https://deathbycaptcha.com/)


<p align="center">
  <a href="https://github.com/deathbycaptcha/deathbycaptcha-api-client-python"><img alt="Python" src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"></a>
  <a href="https://github.com/deathbycaptcha/deathbycaptcha-api-client-nodejs"><img alt="Node.js" src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white"></a>
  <a href="https://github.com/deathbycaptcha/deathbycaptcha-api-client-dotnet"><img alt=".NET" src="https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white"></a>
  <a href="https://github.com/deathbycaptcha/deathbycaptcha-api-client-java"><img alt="Java" src="https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white"></a>
  <a href="https://github.com/deathbycaptcha/deathbycaptcha-api-client-php"><img alt="PHP" src="https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white"></a>
  <a href="https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl"><img alt="› Perl" src="https://img.shields.io/badge/%E2%80%BA%20Perl-39457E?style=for-the-badge&logo=perl&logoColor=white&labelColor=555555"></a>
  <a href="https://github.com/deathbycaptcha/deathbycaptcha-api-client-c11"><img alt="C" src="https://img.shields.io/badge/C-A8B9CC?style=for-the-badge&logo=c&logoColor=black"></a>
</p>


## 📖 Introduction

The [DeathByCaptcha](https://deathbycaptcha.com) Perl client is the official library for the DeathByCaptcha **captcha solving service**, designed for teams that need a reliable recaptcha solver API in automation and scraping pipelines. It provides a simple, well-documented interface for integrating image, audio, and token-based CAPTCHA workflows, and it helps evaluate captcha solving API pricing in real projects by giving a consistent implementation across HTTPS and socket transports. It supports both the HTTPS API (encrypted transport — recommended when security is a priority) and the socket-based API (faster and lower latency, recommended for high-throughput production workloads). Requires Perl 5.20+.

Key features:

- 🧩 Send image, audio and modern token-based CAPTCHA types (reCAPTCHA v2/v3, Turnstile, GeeTest, etc.).
- 🔄 Unified client API across HTTP and socket transports — switching implementations is straightforward.
- 🔐 Built-in support for proxies, timeouts and advanced token parameters for modern CAPTCHA flows.

Quick start example (HTTP):

```perl
use DeathByCaptcha::HttpClient;
use DeathByCaptcha::Client;

my $client = DeathByCaptcha::HttpClient->new('your_username', 'your_password');
my $captcha = $client->decode('path/to/captcha.jpg', +DeathByCaptcha::Client::DEFAULT_TIMEOUT);
if (defined $captcha) {
    print $captcha->{text}, "\n";
}
```

> **🚌 Transport options:** Use `HttpClient` for encrypted HTTPS communication — credentials and data travel over TLS. Use `SocketClient` for lower latency and higher throughput — it is faster but communicates over a plain TCP connection to `api.dbcapi.me` on ports `8123–8130`.

---

### Tests Status

[![Unit Tests (Perl 5.42)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.42.1.yml/badge.svg?branch=master)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.42.1.yml)
[![Coverage](https://raw.githubusercontent.com/deathbycaptcha/deathbycaptcha-api-client-perl/gh-pages/badges/coverage.svg)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/coverage-badge-perl-5.42.1.yml)

---

## 🗂️ Index

- [Installation](#installation)
- [How to Use DBC API Clients](#how-to-use-dbc-api-clients)
    - [Common Clients' Interface](#common-clients-interface)
    - [Available Methods](#captcha-methods)
- [Credentials & Configuration](#credentials--configuration)
    - [Quick Setup](#quick-setup)
- [CAPTCHA Types Quick Reference & Examples](#captcha-types-reference)
    - [Quick Start](#quick-start)
    - [Type Reference](#sample-index-by-captcha-type)
    - [Per-Type Code Snippets](#quick-type-snippets)
- [CAPTCHA Types Extended Reference](#captcha-types-extended-reference)
    - [reCAPTCHA Image-Based API — Deprecated (Types 2 & 3)](#recaptcha-image-based-api)
    - [reCAPTCHA Token API (v2 & v3)](#recaptcha-token-api)
    - [reCAPTCHA v2 API FAQ](#recaptcha-v2-api-faq)
    - [What is reCAPTCHA v3?](#what-is-recaptcha-v3)
    - [reCAPTCHA v3 API FAQ](#recaptcha-v3-api-faq)
    - [Amazon WAF API (Type 16)](#amazon-waf-api-faq)
    - [Cloudflare Turnstile API (Type 12)](#cloudflare-turnstile-api-faq)


<a id="installation"></a>
## 🛠️ Installation

Clone the repository:

```bash
git clone https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl.git
cd deathbycaptcha-api-client-perl
```

Then install dependencies using **cpanm** (recommended):

```bash
cpanm --installdeps .
```

Or install modules manually:

```bash
cpanm LWP::UserAgent LWP::Protocol::https HTTP::Request::Common HTTP::Status JSON IO::Socket MIME::Base64
```

<a id="how-to-use-dbc-api-clients"></a>
## 🚀 How to Use DBC API Clients

<a id="common-clients-interface"></a>
### 🔌 Common Clients' Interface

All clients must be instantiated with your DeathByCaptcha credentials — either *username* and *password*, or an *authtoken* (available in the DBC user panel). Replace `HttpClient` with `SocketClient` to use the socket transport instead.

```perl
use DeathByCaptcha::HttpClient;
use DeathByCaptcha::SocketClient;

# Username + password (HTTPS transport — encrypted, recommended when security matters)
my $client = DeathByCaptcha::HttpClient->new($username, $password);

# Username + password (socket transport — faster, lower latency, recommended for high throughput)
# my $client = DeathByCaptcha::SocketClient->new($username, $password);

# Authtoken — set $username to 'authtoken' and $password to the token
# my $client = DeathByCaptcha::HttpClient->new('authtoken', $authtoken);
```

| Transport | Class | Best for |
|---|---|---|
| HTTPS | `DeathByCaptcha::HttpClient` | Encrypted TLS transport — safer for credential handling and network-sensitive environments |
| Socket | `DeathByCaptcha::SocketClient` | Plain TCP — faster and lower latency, recommended for high-throughput production workloads |

All clients share the same interface. Below is a summary of every available method and its signature.

> **⚠️ Thread safety:** Perl clients in this repo are not thread-safe. Use one client instance per thread.

<a id="captcha-methods"></a>

| Method | Signature | Returns | Description |
|---|---|---|---|
| `upload()` | `upload($file)` | `hashref` or `undef` | Upload an image CAPTCHA for solving without waiting. Returns the captcha hashref immediately. |
| `uploadToken()` | `uploadToken($type, $key, $params)` | `hashref` or `undef` | Upload a token CAPTCHA without polling. |
| `decode()` | `decode($file, $timeout)` | `hashref` or `undef` | Upload image and poll until solved or timed out. Preferred method for image CAPTCHAs. |
| `decodeToken()` | `decodeToken($type, $key, $params, $timeout)` | `hashref` or `undef` | Upload token CAPTCHA and poll until solved or timed out. |
| `getCaptcha()` | `getCaptcha($id)` | `hashref` or `undef` | Fetch status and result of a previously uploaded CAPTCHA by numeric ID. |
| `getText()` | `getText($id)` | `string` or `undef` | Convenience wrapper — return only the `text` value. |
| `report()` | `report($id)` | `bool` | Report a CAPTCHA as incorrectly solved to request a refund. Only report genuine errors. |
| `getBalance()` | `getBalance()` | `float` | Return the current account balance in US cents. |
| `getStatus()` | `getStatus()` | `hashref` or `undef` | Return service status (`is_service_overloaded`). |
| `close()` | `close()` | — | Release resources (socket connection). |

**Constants:**

- `DeathByCaptcha::Client::DEFAULT_TIMEOUT` — 60 s (image captchas)
- `DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT` — 120 s (token captchas)

### 📬 CAPTCHA Result Hashref

All methods that return a solved CAPTCHA return a plain hashref with the following keys:

| Key | Type | Description |
|---|---|---|
| `"captcha"` | `int` | Numeric CAPTCHA ID assigned by DBC |
| `"text"` | `string` | Solved text or token (the value you inject into the page) |
| `"is_correct"` | `bool` | Whether DBC considers the solution correct |

```perl
# Example result hashref
{
    captcha    => 123456789,
    text       => '03AOPBWq_...',
    is_correct => 1,
}
```

### 💡 Full Usage Example

```perl
use DeathByCaptcha::HttpClient;
use DeathByCaptcha::Client;

my $client = DeathByCaptcha::HttpClient->new($username, $password);

printf("Balance: %.4f US cents\n", $client->getBalance());

my $captcha = $client->decode('path/to/captcha.jpg', +DeathByCaptcha::Client::DEFAULT_TIMEOUT);
if (defined $captcha) {
    printf("Solved CAPTCHA %d: %s\n", $captcha->{captcha}, $captcha->{text});

    # Report only if you are certain the solution is wrong:
    # $client->report($captcha->{captcha});
}
```

<a id="credentials--configuration"></a>
## 🔑 Credentials & Configuration

The integration test reads credentials from a `.env` file in the project root. Credential values may be provided with or without surrounding quotes.

<a id="quick-setup"></a>
### ⚡ Quick Setup

```bash
# ① Copy template and add credentials
cp .env.example .env
# Edit .env with your username and password
# Supported formats:
#   DBC_USERNAME=user
#   DBC_PASSWORD=pass
#   DBC_USERNAME='user'
#   DBC_PASSWORD='pass'

# ② Run unit tests locally
prove -l t/0[0-4]-*.t

# ③ Run integration test (requires valid DBC credentials and network)
prove -l t/05-integration.t

# ④ Push to repo for GitHub Actions
git push
```

<a id="captcha-types-reference"></a>
## 🧩 CAPTCHA Types Quick Reference & Examples

This section covers every supported CAPTCHA type, how to run the corresponding example scripts, and ready-to-copy code snippets. Start with the Quick Start below, then use the Type Reference to find the type you need.

<a id="quick-start"></a>
### 🏁 Quick Start

1. **📦 Install dependencies** (see [Installation](#installation))
2. **📂 Navigate to the `samples/` directory** and run the script for the type you need:

```bash
cd samples
perl example.pl your_username your_password path/to/captcha.jpg
```

Before running any script, set your DBC credentials at the top of the file:

```perl
my $USERNAME = 'your_username';
my $PASSWORD = 'your_password';
```

<a id="sample-index-by-captcha-type"></a>
### 📋 Type Reference

The table below maps every supported type to its use case, a code snippet, and the corresponding example file in `samples/`.

| Type ID | CAPTCHA Type | Use Case | Quick Use | Perl Sample |
| --- | --- | --- | --- | --- |
| 0 | Standard Image | Basic image CAPTCHA | [snippet](#sample-type-0-standard-image) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.pl) |
| 2 | ~~reCAPTCHA Coordinates~~ | Deprecated — do not use for new integrations | — | — |
| 3 | ~~reCAPTCHA Image Group~~ | Deprecated — do not use for new integrations | — | — |
| 4 | reCAPTCHA v2 Token | reCAPTCHA v2 token solving | [snippet](#sample-type-4-recaptcha-v2-token) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/recaptcha_v2_http.pl) |
| 5 | reCAPTCHA v3 Token | reCAPTCHA v3 with risk scoring | [snippet](#sample-type-5-recaptcha-v3-token) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/recaptcha_v3_http.pl) |
| 25 | reCAPTCHA v2 Enterprise | reCAPTCHA v2 Enterprise tokens | [snippet](#sample-type-25-recaptcha-v2-enterprise) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/recaptcha_enterprise_http.pl) |
| 8 | GeeTest v3 | Geetest v3 verification | [snippet](#sample-type-8-geetest-v3) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Geetest_v3.pl) |
| 9 | GeeTest v4 | Geetest v4 verification | [snippet](#sample-type-9-geetest-v4) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Geetest_v4.pl) |
| 11 | Text CAPTCHA | Text-based question solving | [snippet](#sample-type-11-text-captcha) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Textcaptcha.pl) |
| 12 | Cloudflare Turnstile | Cloudflare Turnstile token | [snippet](#sample-type-12-cloudflare-turnstile) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/turnstile_http.pl) |
| 13 | Audio CAPTCHA | Audio CAPTCHA solving | [snippet](#sample-type-13-audio-captcha) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Audio.pl) |
| 14 | Lemin | Lemin CAPTCHA | [snippet](#sample-type-14-lemin) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Lemin.pl) |
| 15 | Capy | Capy CAPTCHA | [snippet](#sample-type-15-capy) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Capy.pl) |
| 16 | Amazon WAF | Amazon WAF verification | [snippet](#sample-type-16-amazon-waf) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/amazon_waf_http.pl) |
| 17 | Siara | Siara CAPTCHA | [snippet](#sample-type-17-siara) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Siara.pl) |
| 18 | MTCaptcha | Mtcaptcha CAPTCHA | [snippet](#sample-type-18-mtcaptcha) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Mtcaptcha.pl) |
| 19 | Cutcaptcha | Cutcaptcha CAPTCHA | [snippet](#sample-type-19-cutcaptcha) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Cutcaptcha.pl) |
| 20 | Friendly Captcha | Friendly Captcha | [snippet](#sample-type-20-friendly-captcha) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Friendly.pl) |
| 21 | DataDome | Datadome verification | [snippet](#sample-type-21-datadome) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Datadome.pl) |
| 23 | Tencent | Tencent CAPTCHA | [snippet](#sample-type-23-tencent) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Tencent.pl) |
| 24 | ATB | ATB CAPTCHA | [snippet](#sample-type-24-atb) | [open](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Atb.pl) |

<a id="quick-type-snippets"></a>
### 📝 Per-Type Code Snippets

Minimal usage snippet for each supported type. Use these as a starting point and refer to the full sample files in `samples/` for complete implementations.

<a id="sample-type-0-standard-image"></a>
#### 🖼️ Sample Type 0: Standard Image
Official description: [Supported CAPTCHAs](https://deathbycaptcha.com/api#supported_captchas)
Full sample: [samples/example.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.pl)

```perl
my $captcha = $client->decode('images/normal.jpg', +DeathByCaptcha::Client::DEFAULT_TIMEOUT);
```

---

<a id="sample-type-4-recaptcha-v2-token"></a>
#### 🤖 Sample Type 4: reCAPTCHA v2 Token
Official description: [reCAPTCHA Token API (v2)](https://deathbycaptcha.com/api/newtokenrecaptcha#token-v2)
Full sample: [samples/recaptcha_v2_http.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/recaptcha_v2_http.pl)

```perl
my $captcha = $client->decodeToken(
    4,
    'token_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        googlekey => 'sitekey',
        pageurl   => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-5-recaptcha-v3-token"></a>
#### 🤖 Sample Type 5: reCAPTCHA v3 Token
Official description: [reCAPTCHA v3](https://deathbycaptcha.com/api/newtokenrecaptcha#reCAPTCHAv3)
Full sample: [samples/recaptcha_v3_http.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/recaptcha_v3_http.pl)

```perl
my $captcha = $client->decodeToken(
    5,
    'token_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        googlekey => 'sitekey',
        pageurl   => 'https://target',
        action    => 'verify',
        min_score => 0.3,
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-25-recaptcha-v2-enterprise"></a>
#### 🏢 Sample Type 25: reCAPTCHA v2 Enterprise
Official description: [reCAPTCHA v2 Enterprise](https://deathbycaptcha.com/api/newtokenrecaptcha#reCAPTCHAv2Enterprise)
Full sample: [samples/recaptcha_enterprise_http.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/recaptcha_enterprise_http.pl)

```perl
my $captcha = $client->decodeToken(
    25,
    'token_enterprise_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        googlekey => 'sitekey',
        pageurl   => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-8-geetest-v3"></a>
#### 🧩 Sample Type 8: GeeTest v3
Official description: [GeeTest](https://deathbycaptcha.com/api/geetest)
Full sample: [samples/example.Geetest_v3.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Geetest_v3.pl)

```perl
my $captcha = $client->decodeToken(
    8,
    'geetest_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        gt        => 'gt_value',
        challenge => 'challenge_value',
        pageurl   => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-9-geetest-v4"></a>
#### 🧩 Sample Type 9: GeeTest v4
Official description: [GeeTest](https://deathbycaptcha.com/api/geetest)
Full sample: [samples/example.Geetest_v4.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Geetest_v4.pl)

```perl
my $captcha = $client->decodeToken(
    9,
    'geetest_params',
    {
        proxy      => 'http://user:pass@127.0.0.1:1234',
        proxytype  => 'HTTP',
        captcha_id => 'captcha_id',
        pageurl    => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-11-text-captcha"></a>
#### 💬 Sample Type 11: Text CAPTCHA
Official description: [Text CAPTCHA](https://deathbycaptcha.com/api/textcaptcha)
Full sample: [samples/example.Textcaptcha.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Textcaptcha.pl)

```perl
my $captcha = $client->decodeToken(
    11,
    'textcaptcha',
    { textcaptcha => 'What is two plus two?' },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-12-cloudflare-turnstile"></a>
#### ☁️ Sample Type 12: Cloudflare Turnstile
Official description: [Cloudflare Turnstile](https://deathbycaptcha.com/api/turnstile)
Full sample: [samples/turnstile_http.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/turnstile_http.pl)

```perl
my $captcha = $client->decodeToken(
    12,
    'turnstile_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        sitekey   => 'sitekey',
        pageurl   => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-13-audio-captcha"></a>
#### 🔊 Sample Type 13: Audio CAPTCHA
Official description: [Audio CAPTCHA](https://deathbycaptcha.com/api/audio)
Full sample: [samples/example.Audio.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Audio.pl)

```perl
use MIME::Base64 qw(encode_base64);

open my $fh, '<:raw', 'audio.mp3' or die $!;
my $audio_b64 = encode_base64(do { local $/; <$fh> }, '');
close $fh;

my $captcha = $client->decodeToken(
    13,
    'audio',
    { audio => $audio_b64, language => 'en' },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-14-lemin"></a>
#### 🔵 Sample Type 14: Lemin
Official description: [Lemin](https://deathbycaptcha.com/api/lemin)
Full sample: [samples/example.Lemin.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Lemin.pl)

```perl
my $captcha = $client->decodeToken(
    14,
    'lemin_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        captchaid => 'CROPPED_xxx',
        pageurl   => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-15-capy"></a>
#### 🏴 Sample Type 15: Capy
Official description: [Capy](https://deathbycaptcha.com/api/capy)
Full sample: [samples/example.Capy.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Capy.pl)

```perl
my $captcha = $client->decodeToken(
    15,
    'capy_params',
    {
        proxy      => 'http://user:pass@127.0.0.1:1234',
        proxytype  => 'HTTP',
        captchakey => 'PUZZLE_xxx',
        api_server => 'https://api.capy.me/',
        pageurl    => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-16-amazon-waf"></a>
#### 🛡️ Sample Type 16: Amazon WAF
Official description: [Amazon WAF](https://deathbycaptcha.com/api/amazonwaf)
Full sample: [samples/amazon_waf_http.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/amazon_waf_http.pl)

```perl
my $captcha = $client->decodeToken(
    16,
    'waf_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        sitekey   => 'sitekey',
        pageurl   => 'https://target',
        iv        => 'iv_value',
        context   => 'context_value',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-17-siara"></a>
#### 🔍 Sample Type 17: Siara
Official description: [Siara](https://deathbycaptcha.com/api/siara)
Full sample: [samples/example.Siara.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Siara.pl)

```perl
my $captcha = $client->decodeToken(
    17,
    'siara_params',
    {
        proxy      => 'http://user:pass@127.0.0.1:1234',
        proxytype  => 'HTTP',
        slideurlid => 'slide_master_url_id',
        pageurl    => 'https://target',
        useragent  => 'Mozilla/5.0',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-18-mtcaptcha"></a>
#### 🔒 Sample Type 18: MTCaptcha
Official description: [MTCaptcha](https://deathbycaptcha.com/api/mtcaptcha)
Full sample: [samples/example.Mtcaptcha.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Mtcaptcha.pl)

```perl
my $captcha = $client->decodeToken(
    18,
    'mtcaptcha_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        sitekey   => 'MTPublic-xxx',
        pageurl   => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-19-cutcaptcha"></a>
#### ✂️ Sample Type 19: Cutcaptcha
Official description: [Cutcaptcha](https://deathbycaptcha.com/api/cutcaptcha)
Full sample: [samples/example.Cutcaptcha.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Cutcaptcha.pl)

```perl
my $captcha = $client->decodeToken(
    19,
    'cutcaptcha_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        apikey    => 'api_key',
        miserykey => 'misery_key',
        pageurl   => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-20-friendly-captcha"></a>
#### 💚 Sample Type 20: Friendly Captcha
Official description: [Friendly Captcha](https://deathbycaptcha.com/api/friendly)
Full sample: [samples/example.Friendly.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Friendly.pl)

```perl
my $captcha = $client->decodeToken(
    20,
    'friendly_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        sitekey   => 'FCMG...',
        pageurl   => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-21-datadome"></a>
#### 🛡️ Sample Type 21: DataDome
Official description: [DataDome](https://deathbycaptcha.com/api/datadome)
Full sample: [samples/example.Datadome.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Datadome.pl)

```perl
my $captcha = $client->decodeToken(
    21,
    'datadome_params',
    {
        proxy       => 'http://user:pass@127.0.0.1:1234',
        proxytype   => 'HTTP',
        pageurl     => 'https://target',
        captcha_url => 'https://target/captcha',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-23-tencent"></a>
#### 🔷 Sample Type 23: Tencent
Official description: [Tencent](https://deathbycaptcha.com/api/tencent)
Full sample: [samples/example.Tencent.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Tencent.pl)

```perl
my $captcha = $client->decodeToken(
    23,
    'tencent_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        appid     => 'appid',
        pageurl   => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

---

<a id="sample-type-24-atb"></a>
#### 🏷️ Sample Type 24: ATB
Official description: [ATB](https://deathbycaptcha.com/api/atb)
Full sample: [samples/example.Atb.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/example.Atb.pl)

```perl
my $captcha = $client->decodeToken(
    24,
    'atb_params',
    {
        proxy     => 'http://user:pass@127.0.0.1:1234',
        proxytype => 'HTTP',
        appid     => 'appid',
        apiserver => 'https://cap.aisecurius.com',
        pageurl   => 'https://target',
    },
    +DeathByCaptcha::Client::DEFAULT_TOKEN_TIMEOUT,
);
```

<a id="captcha-types-extended-reference"></a>
## 📚 CAPTCHA Types Extended Reference

Full API-level documentation for selected CAPTCHA types: parameter references, payload schemas, request/response formats, token lifespans, and integration notes.

<a id="recaptcha-image-based-api"></a>
### ⛔ reCAPTCHA Image-Based API — Deprecated (Types 2 & 3)

> ⚠️ **Deprecated.** Types 2 (Coordinates) and 3 (Image Group) are legacy image-based reCAPTCHA challenge methods that are no longer used at captcha solving. Do not use them for new integrations — use the [reCAPTCHA Token API (v2 & v3)](#recaptcha-token-api) instead.

---

<a id="recaptcha-token-api"></a>
### 🔐 reCAPTCHA Token API (v2 & v3)

The Token-based API solves reCAPTCHA challenges by returning a token you inject directly into the page form, rather than clicking images. Given a site URL and site key, DBC solves the challenge on its side and returns a token valid for one submission.

- **Token Image API**: Provided a site URL and site key, the API returns a token that you use to submit the form on the page with the reCAPTCHA challenge.

---

<a id="recaptcha-v2-api-faq"></a>
### ❓ reCAPTCHA v2 API FAQ

**What's the Token Image API URL?**
To use the Token Image API you will have to send a HTTP POST Request to <http://api.dbcapi.me/api/captcha>

**What are the POST parameters for the Token image API?**
-   **`username`**: Your DBC account username
-   **`password`**: Your DBC account password
-   **`type`=4**: Type 4 specifies this is the reCAPTCHA v2 Token API
-   **`token_params`=json(payload)**: the data to access the recaptcha challenge
json payload structure:
    -   **`proxy`**: your proxy url and credentials (if any). Examples:
        -   <http://127.0.0.1:3128>
        -   <http://user:password@127.0.0.1:3128>

    -   **`proxytype`**: your proxy connection protocol. Example:
        -   HTTP

    -   **`googlekey`**: the google recaptcha site key of the website with the recaptcha. Example:
        -   6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-

    -   **`pageurl`**: the url of the page with the recaptcha challenges. Example: if the recaptcha you want to solve is in <http://test.com/path1>, pageurl has to be <http://test.com/path1> and not <http://test.com>.

    -   **`data-s`**: This parameter is only required for solving google search tokens. Use the data-s value inside the google search response html. For regular tokens don't use this parameter.

The **`proxy`** parameter is optional, but we strongly recommend to use one to prevent token rejection by the provided page due to inconsistencies between the IP that solved the captcha (ours if no proxy is provided) and the IP that submitted the token for verification (yours).
**Note**: If **`proxy`** is provided, **`proxytype`** is a required parameter.

Full example of **`token_params`**:
```json
{
  "proxy": "http://127.0.0.1:3128",
  "proxytype": "HTTP",
  "googlekey": "6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-",
  "pageurl": "http://test.com/path_with_recaptcha"
}
```
Example of **`token_params`** for google search captchas:
```json
{
  "googlekey": "6Le-wvkSA...",
  "pageurl": "...",
  "data-s": "IUdfh4rh0sd..."
}
```
**What's the response from the Token image API?**
The token image API response has the same structure as regular captchas' response. Refer to Polling for uploaded CAPTCHA status for details about the response. The token will come in the `text` key of the response. It's valid for one use and has a 2 minute lifespan. It will be a string like the following:
```bash
"03AOPBWq_RPO2vLzyk0h8gH0cA2X4v3tpYCPZR6Y4yxKy1s3Eo7CHZRQntxrdsaD2H0e6S3547xi1FlqJB4rob46J0-wfZMj6YpyVa0WGCfpWzBWcLn7tO_EYsvEC_3kfLNINWa5LnKrnJTDXTOz-JuCKvEXx0EQqzb0OU4z2np4uyu79lc_NdvL0IRFc3Cslu6UFV04CIfqXJBWCE5MY0Ag918r14b43ZdpwHSaVVrUqzCQMCybcGq0yxLQf9eSexFiAWmcWLI5nVNA81meTXhQlyCn5bbbI2IMSEErDqceZjf1mX3M67BhIb4"
```

---

<a id="what-is-recaptcha-v3"></a>
### 🔎 What is reCAPTCHA v3?
This API extends the reCAPTCHA v2 Token API with two additional parameters: `action` and **minimal score (`min_score`)**.

reCAPTCHA v3 returns a score from each user, that evaluates if the user is a bot or human. Then the website uses the score value that could range from 0 to 1 to decide if will accept or not the requests. Lower scores near to 0 are identified as bot.

The `action` parameter at reCAPTCHA v3 is an additional data used to separate different captcha validations like for example **login**, **register**, **sales**, **etc**.

---

<a id="recaptcha-v3-api-faq"></a>
### ❓ reCAPTCHA v3 API FAQ

**What is `action` in reCAPTCHA v3?**
Is a new parameter that allows processing user actions on the website differently.
To find this we need to inspect the javascript code of the website looking for call of grecaptcha.execute function. Example:
```javascript
grecaptcha.execute('6Lc2fhwTAAAAAGatXTzFYfvlQMI2T7B6ji8UVV_f', {action: something})
```
Sometimes it's really hard to find it and we need to look through all javascript files. The API will use "verify" default value if we won't provide action in our request.

**What is `min-score` in reCAPTCHA v3 API?**
The minimal score needed for the captcha resolution. We recommend using the 0.3 min-score value, scores higher than 0.3 are hard to get.

**What are the POST parameters for the reCAPTCHA v3 API?**
-   **`username`**: Your DBC account username
-   **`password`**: Your DBC account password
-   **`type`=5**: Type 5 specifies this is reCAPTCHA v3 API
-   **`token_params`**=json(payload): the data to access the recaptcha challenge

Full example of **`token_params`**:
```json
{
  "proxy": "http://127.0.0.1:3128",
  "proxytype": "HTTP",
  "googlekey": "6Le-wvkSAAAAAPBMRTvw0Q4Muexq9bi0DJwx_mJ-",
  "pageurl": "http://test.com/path_with_recaptcha",
  "action": "example/action",
  "min_score": 0.3
}
```

**What's the response from reCAPTCHA v3 API?**
The response has the same structure as a regular captcha. The solution will come in the **text** key of the response. It's valid for one use and has a 1 minute lifespan.

---

<a id="amazon-waf-api-faq"></a>
### 🛡️ Amazon WAF API (Type 16)

Amazon WAF Captcha (also referred to as AWS WAF Captcha) is part of the Intelligent Threat Mitigation system within Amazon AWS. It presents image-alignment challenges that DBC solves by returning a token you set as the `aws-waf-token` cookie on the target page.

- **Official documentation:** [deathbycaptcha.com/api/amazonwaf](https://deathbycaptcha.com/api/amazonwaf)
- **Perl sample:** [samples/amazon_waf_http.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/amazon_waf_http.pl)

`waf_params` payload fields:

| Parameter | Required | Description |
|---|---|---|
| `proxy` | Optional\* | Proxy URL with credentials. E.g. `http://user:password@127.0.0.1:3128` |
| `proxytype` | Required if proxy set | Proxy protocol. Currently only `HTTP` is supported. |
| `sitekey` | Required | Amazon WAF site key found in the page's captcha script (value of the `key` parameter) |
| `pageurl` | Required | Full URL of the page showing the Amazon WAF challenge (must include the path) |
| `iv` | Required | Value of the `iv` parameter found in the captcha script on the page |
| `context` | Required | Value of the `context` parameter found in the captcha script on the page |
| `challengejs` | Optional | URL of the `challenge.js` script referenced on the page |
| `captchajs` | Optional | URL of the `captcha.js` script referenced on the page |

> The `proxy` parameter is optional but strongly recommended — using a proxy prevents token rejection caused by IP inconsistencies between the solving machine (DBC) and the submitting machine (yours).
> **📌 Note:** If `proxy` is provided, `proxytype` is required.

Full example of `waf_params`:

```json
{
  "proxy": "http://user:password@127.0.0.1:1234",
  "proxytype": "HTTP",
  "sitekey": "AQIDAHjcYu/GjX+QlghicBgQ/7bFaQZ+m5FKCMDnO+vTbNg96AHDh0IR5vgzHNceHYqZR+GO...",
  "pageurl": "https://efw47fpad9.execute-api.us-east-1.amazonaws.com/latest",
  "iv": "CgAFRjIw2vAAABSM",
  "context": "zPT0jOl1rQlUNaldX6LUpn4D6Tl9bJ8VUQ/NrWFxPii..."
}
```

**Response:** Once received, set the token as the `aws-waf-token` cookie on the target page before submitting the form.

---

<a id="cloudflare-turnstile-api-faq"></a>
### 🌐 Cloudflare Turnstile API (Type 12)

Cloudflare Turnstile is a CAPTCHA alternative that protects pages without requiring user interaction in most cases. DBC solves it by returning a token you inject into the target form or pass to the page's callback.

- **Official documentation:** [deathbycaptcha.com/api/turnstile](https://deathbycaptcha.com/api/turnstile)
- **Perl sample:** [samples/turnstile_http.pl](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/blob/master/samples/turnstile_http.pl)

**`turnstile_params` payload fields:**

| Field | Required | Description |
|---|---|---|
| `proxy` | Optional | Proxy URL with optional credentials. E.g. `http://user:password@127.0.0.1:3128` |
| `proxytype` | Required if `proxy` set | Proxy connection protocol. Currently only `HTTP` is supported. |
| `sitekey` | Required | The Turnstile site key found in `data-sitekey` attribute, the captcha iframe URL, or the `turnstile.render` call. E.g. `0x4AAAAAAAGlwMzq_9z6S9Mh` |
| `pageurl` | Required | Full URL of the page hosting the Turnstile challenge, including path. E.g. `https://testsite.com/xxx-test` |
| `action` | Optional | Value of the `data-action` attribute or the `action` option passed to `turnstile.render`. |

> **📌 Note:** The `proxy` parameter is optional but strongly recommended to avoid rejection due to IP inconsistency between the solver and the submitter. If `proxy` is provided, `proxytype` becomes required.

**Example `turnstile_params`:**

```json
{
    "proxy": "http://user:password@127.0.0.1:1234",
    "proxytype": "HTTP",
    "sitekey": "0x4AAAAAAAGlwMzq_9z6S9Mh",
    "pageurl": "https://testsite.com/xxx-test"
}
```

**Response:** The API returns a token string valid for one use with a 2-minute lifespan. Submit it via the `input[name="cf-turnstile-response"]` field (or `input[name="g-recaptcha-response"]` when reCAPTCHA compatibility mode is enabled), or pass it to the callback defined in `turnstile.render` / `data-callback`.

---

## CI and Quality

| CI / Quality | Status |
|---|---|
| Unit Tests (Perl 5.38) | [![Unit Tests (Perl 5.38.5)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.38.5.yml/badge.svg?branch=master)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.38.5.yml) |
| Unit Tests (Perl 5.40) | [![Unit Tests (Perl 5.40.3)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.40.3.yml/badge.svg?branch=master)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.40.3.yml) |
| Unit Tests (Perl 5.42) | [![Unit Tests (Perl 5.42.1)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.42.1.yml/badge.svg?branch=master)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.42.1.yml) |
| Integration Tests (Perl 5.42) | [![Integration Tests (Perl 5.42.1)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/integration-perl-5.42.1.yml/badge.svg?branch=master)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/integration-perl-5.42.1.yml) |
| Coverage (Perl 5.42) | [![Coverage %](https://raw.githubusercontent.com/deathbycaptcha/deathbycaptcha-api-client-perl/gh-pages/badges/coverage.svg)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/coverage-badge-perl-5.42.1.yml) |

---

## ⚖️ Responsible Use

See [Responsible Use Agreement](RESPONSIBLE_USE.md).
