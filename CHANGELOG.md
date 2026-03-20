# Changelog

All notable changes to this project are documented in this file.

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
