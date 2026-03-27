# Changelog

All notable changes to this project are documented in this file.

## [4.7.1] - 2026-03-27

### Added
- Added `RESPONSIBLE_USE.md` with responsible-use guidance.
- Added `LICENSE` to complete repository licensing metadata.
- Added dedicated sample scripts for additional CAPTCHA types:
  - `example.Atb.pl`
  - `example.Audio.pl`
  - `example.Capy.pl`
  - `example.Cutcaptcha.pl`
  - `example.Datadome.pl`
  - `example.Friendly.pl`
  - `example.Geetest_v3.pl`
  - `example.Geetest_v4.pl`
  - `example.Lemin.pl`
  - `example.Mtcaptcha.pl`
  - `example.Siara.pl`
  - `example.Tencent.pl`
  - `example.Textcaptcha.pl`
  - `example.reCAPTCHA_Coordinates.pl`
  - `example.reCAPTCHA_Image_Group.pl`
- Added `getStatus()` implementation to `DeathByCaptcha::HttpClient` for querying `/status`.

### Changed
- Expanded `README.md` and `SAMPLES.md` with:
  - CAPTCHA type index and per-type quick snippets
  - Extended API reference sections for reCAPTCHA, Amazon WAF, and Turnstile
  - CI/Quality status documentation improvements
- Updated token-based sample scripts (`recaptcha_v2_http.pl`, `recaptcha_v3_http.pl`, `recaptcha_enterprise_http.pl`, `turnstile_http.pl`, `amazon_waf_http.pl`) to align with the refreshed docs and usage flow.
- Updated GitHub Actions workflows to install dependencies using the MetaCPAN mirror (`https://cpan.metacpan.org/`) for more reliable installs.

### Fixed
- `decodeToken()` in `DeathByCaptcha::Client` now uses `DEFAULT_TOKEN_TIMEOUT` (120s) instead of image timeout defaults.
- Added base `getStatus()` stub in `DeathByCaptcha::Client` to align client interface expectations.
- Improved integration test flow for socket image solves to handle immediate solutions explicitly.

### Tests
- Extended unit coverage in `t/01-client.t` for `decodeToken()` and timeout constants.
- Extended unit coverage in `t/02-http-client.t` for token upload paths and `getStatus()` behavior.

### Versioning
- Bumped `DeathByCaptcha::Client` version to `4.7.1`.

## [4.7.0] - 2026-03-20

### Added
- Added `README.md` as main project documentation in Markdown format.
- Added `cpanfile` with runtime and test dependency declarations.
- Added unit tests:
  - `t/00-load.t`
  - `t/01-client.t`
  - `t/02-http-client.t`
  - `t/03-socket-client.t`
  - `t/04-exception.t`
- Added integration test `t/05-integration.t` that reads credentials from `.env`.
- Added `.env.example` template for integration credentials.
- Added GitLab CI pipeline (`.gitlab-ci.yml`) with Perl matrix (`5.38.5`, `5.40.3`, `5.42.1`) and coverage output.
- Added GitHub Actions workflows:
  - Unit tests per Perl version (`5.38.5`, `5.40.3`, `5.42.1`)
  - Integration tests on latest Perl (`5.42.1`)
  - Coverage badge generation on latest Perl (`5.42.1`)
- Added coverage badge publication workflow to `gh-pages` (no external coverage service required).
- Added project badges in `README.md` for unit tests, integration tests, and coverage.

### Changed
- Modernized `DeathByCaptcha::Client` internals:
  - Binary-safe image loading (`<:raw`) with lexical filehandles
  - Input validation via `Carp::croak`
  - Cleaner decode/polling flow and returns
- Modernized `DeathByCaptcha::HttpClient`:
  - Switched to `use parent`
  - Refactored auth payload and JSON decoding helpers
  - Improved HTTP error handling consistency
- Modernized `DeathByCaptcha::SocketClient`:
  - Switched to `use parent`
  - Cleaner constructor style
  - Removed library-internal noisy auth prints
- Modernized `DeathByCaptcha::Exception` constructor and overload fallback behavior.
- Reorganized example scripts and assets under `samples/`:
  - `samples/example.pl`
  - `samples/get_balance.pl`
  - `samples/test.jpg`
- Updated scripts to use `FindBin` and improved usage validation.
- Updated `.gitignore` to cover Perl build/test/coverage artifacts and credentials (`.env`).

### Fixed
- Fixed HTTP `report()` parsing bug in `DeathByCaptcha::HttpClient` (response JSON is now parsed correctly).
- Fixed include-path and execution issues after moving samples.
- Fixed CI YAML script quoting/parsing issues for local runner compatibility.

### Documentation
- Converted and cleaned legacy HTML docs into current Perl-focused `README.md`.
- Added integration testing section with setup, execution, and troubleshooting.
- Added local coverage generation instructions using `Devel::Cover`.

### Versioning
- Unified version declaration in `DeathByCaptcha::Client`:
  - Single source: `CLIENT_VERSION => '4.7.0'`
  - `our $VERSION` derived from `CLIENT_VERSION`
  - `API_VERSION` derived from `CLIENT_VERSION` (avoids duplicated version strings)
