# Release 4.7.1 (2026-03-27)

This release consolidates documentation, sample coverage, CI reliability, and token flow correctness since `v4.7.0`.

## Highlights

- Added complete repository compliance docs:
  - `LICENSE`
  - `RESPONSIBLE_USE.md`
- Expanded documentation across `README.md` and `SAMPLES.md` with:
  - CAPTCHA type index
  - Per-type quick snippets
  - Extended API references for reCAPTCHA, Amazon WAF, and Turnstile
  - CI/Quality status section
- Added dedicated sample scripts for additional CAPTCHA types:
  - `example.Atb.pl`, `example.Audio.pl`, `example.Capy.pl`, `example.Cutcaptcha.pl`, `example.Datadome.pl`
  - `example.Friendly.pl`, `example.Geetest_v3.pl`, `example.Geetest_v4.pl`, `example.Lemin.pl`, `example.Mtcaptcha.pl`
  - `example.Siara.pl`, `example.Tencent.pl`, `example.Textcaptcha.pl`
  - `example.reCAPTCHA_Coordinates.pl`, `example.reCAPTCHA_Image_Group.pl`
- Added HTTP client service status retrieval:
  - `DeathByCaptcha::HttpClient::getStatus()` now queries `/status`
- Improved timeout behavior for token solves:
  - `DeathByCaptcha::Client::decodeToken()` now defaults to `DEFAULT_TOKEN_TIMEOUT` (120s)
  - `DeathByCaptcha::Client` now exposes `DEFAULT_TOKEN_TIMEOUT`
- Improved CI package install reliability by switching dependency install steps to MetaCPAN mirror in GitHub workflows.
- Expanded test coverage:
  - `t/01-client.t`: `decodeToken()` behavior and timeout constants
  - `t/02-http-client.t`: token upload and `getStatus()` behavior
  - `t/05-integration.t`: improved socket immediate-solve handling

## Upgrade Notes

- Version bumped from `4.7.0` to `4.7.1`.
- No breaking API changes were introduced.

## Full Changelog

See `CHANGELOG.md` for complete categorized details.
