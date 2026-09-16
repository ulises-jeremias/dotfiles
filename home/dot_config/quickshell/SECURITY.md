# Security policy — HorneroOS/shell

## Supported versions

Only the latest `main` and the latest tagged release receive security
fixes. Extraction branches (`feat/initial-shell-extraction`, …) are
development snapshots: do not deploy them as-is.

## Reporting a vulnerability

Email the HorneroOS maintainers (see the organization profile) with:

- Affected rev (git SHA / release tag) and how the shell was installed
  (Nix package, CMake install, dev checkout).
- Description, impact, and repro steps (QML file + IPC call if
  applicable). Do **not** open a public issue for vulnerabilities.

We will acknowledge within 7 days and coordinate a fix + disclosure.

## Scope notes

- The shell executes local helper CLIs (`dots-*`) and renders remote
  content (album art, notification images, weather data). Treat those as
  untrusted input: image loading goes through the caching/error-tolerant
  paths (`components/images/`), network data is displayed, never `eval`'d.
- `assets/pam.d/*` are samples, not installed system config; reviewers:
  verify packaging never writes them to `/etc` unsupervised.
- No secrets belong in this repo (enforced by
  `scripts/check_personal_data.sh` in CI).
