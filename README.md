# DeathByCaptcha Perl Client

## Index

- [Introduction](#introduction)
- [CI and Quality](#ci-and-quality)
- [Installation](#installation)
- [Project Conventions](#project-conventions)
- [Authentication](#authentication)
- [API Methods (Perl)](#api-methods-perl)
- [Test Coverage](#test-coverage)
- [Integration Testing](#integration-testing)
- [Samples](#samples)
- [Samples Guide](SAMPLES.md)

## Introduction

This repository contains a Perl client for DeathByCaptcha with two transport options:

- HTTP API via `DeathByCaptcha::HttpClient`
- Socket API via `DeathByCaptcha::SocketClient`

The socket API is generally faster and recommended when network rules allow it. If you use socket mode, ensure outbound TCP to `api.dbcapi.me` on ports `8123-8130` is allowed.

Perl clients in this repo are not thread-safe. Use one client instance per thread.

## CI and Quality

| CI / Quality | Status |
|---|---|
| Unit Tests (Perl 5.38) | [![Unit Tests (Perl 5.38.5)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.38.5.yml/badge.svg?branch=master)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.38.5.yml) |
| Unit Tests (Perl 5.40) | [![Unit Tests (Perl 5.40.3)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.40.3.yml/badge.svg?branch=master)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.40.3.yml) |
| Unit Tests (Perl 5.42) | [![Unit Tests (Perl 5.42.1)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.42.1.yml/badge.svg?branch=master)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/unit-tests-perl-5.42.1.yml) |
| Integration Tests (Perl 5.42) | [![Integration Tests (Perl 5.42.1)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/integration-perl-5.42.1.yml/badge.svg?branch=master)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/integration-perl-5.42.1.yml) |
| Coverage (Perl 5.42) | [![Coverage %](https://raw.githubusercontent.com/deathbycaptcha/deathbycaptcha-api-client-perl/gh-pages/badges/coverage.svg)](https://github.com/deathbycaptcha/deathbycaptcha-api-client-perl/actions/workflows/coverage-badge-perl-5.42.1.yml) |

## Installation

Install dependencies using `cpanfile`:

```bash
cpanm --installdeps .
```

Or install modules manually:

```bash
cpanm LWP::UserAgent HTTP::Request::Common HTTP::Status JSON IO::Socket MIME::Base64
```

## Project Conventions

- Dependencies are declared in `cpanfile`.
- Unit tests live under `t/`.
- Samples live under `samples/`.

Run unit tests:

```bash
prove -l t/0[0-4]-*.t
```

## Authentication

Supported authentication modes:

- Username/password
- Authtoken (set username to `authtoken` and password to the token)

## API Methods (Perl)

All methods return `undef`/false on failure unless noted.

- `hash DeathByCaptcha::Client->upload(string $imageFileName)`
- `hash DeathByCaptcha::Client->getCaptcha(int $captchaId)`
- `bool DeathByCaptcha::Client->report(int $captchaId)`
- `hash DeathByCaptcha::Client->decode(string $imageFileName, int $timeout)`
- `float DeathByCaptcha::Client->getBalance()`

CAPTCHA hashes use keys:

- `"captcha"`: numeric CAPTCHA ID
- `"text"`: solved text
- `"is_correct"`: correctness flag

## Test Coverage

Generate coverage locally:

```bash
rm -rf cover_db
HARNESS_PERL_SWITCHES=-MDevel::Cover prove -l t/0[0-4]-*.t
cover -summary
```

## Integration Testing

The project includes integration test `t/05-integration.t`.

What it verifies:

- Reads credentials from `.env`
- Authenticates against DBC API
- Checks balance is `>= 0`
- Uploads `samples/test.jpg`
- Polls for CAPTCHA solution

Requirements:

- Valid DeathByCaptcha API credentials
- Network connectivity to DBC API

Setup and run:

```bash
cp .env.example .env
# edit credentials in .env
prove -l t/05-integration.t
```

Integration tests do not run in GitLab CI.

## Samples

Detailed samples documentation is available in [SAMPLES.md](SAMPLES.md).

It includes:

- Script-by-script usage (`samples/get_balance.pl`, `samples/example.pl`)
- Advanced token examples for reCAPTCHA v2/v3/Enterprise, Cloudflare Turnstile, and Amazon WAF
- CLI examples for HTTP and Socket modes
- Perl snippets for balance, decode, and report flows
