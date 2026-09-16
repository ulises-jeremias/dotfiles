# Contributing to HorneroOS/shell

## Workflow

1. Branch from `main` (`feat/…`, `fix/…`, `docs/…`). Never push to `main`.
2. Keep changes small and coherent; one concern per commit with a
   conventional prefix (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`,
   `chore:`, `ci:`).
3. Open a PR against `main` — do not merge your own PR.

## Before you push

```bash
cmake -S . -B build -D DISTRIBUTOR="local"
cmake --build build
python3 -m pytest tests/ -q
pre-commit run --all-files
./scripts/check_personal_data.sh
./scripts/check_forbidden_paths.sh
```

All five must pass. Never disable a failing check to get green.

## Rules that bite

- QML/Qt/IPC/Process rules: see `AGENTS.md` (imports, IPC docs+tests,
  forbidden appearance calls, no personal paths, no new `dots-*`
  coupling without a `docs/COMPAT.md` row).
- Licensing: imported runtime files are GPL-3.0-only — do not strip
  headers or relicense. New project docs/scaffold files are MIT.
- Provenance: imported code needs a source + commit reference in the
  commit message (see `docs/MIGRATION.md` for the format).

## Reporting issues / security

- Bugs: include shell rev (`hornero-shell --version` or git SHA),
  compositor, Quickshell version, and `qs ipc` repro where relevant.
- Security: see `SECURITY.md` — do not open public issues for
  vulnerabilities.
