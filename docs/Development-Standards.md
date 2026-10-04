# Development standards

## Keep product behavior in the product repositories

Before adding a setting, command, theme field, or Shell integration, identify
its canonical owner:

- System defaults, package integration, theme packs: HorneroOS/config.
- Desktop interaction and UI state: HorneroOS/shell.
- Stable OS operations and CLI behavior: HorneroOS/hornero.
- Personal application preferences and optional media: this repository.

Do not copy a product helper into this chezmoi source to preserve an older
interface. Use documented `horneroctl` commands or Shell IPC contracts.

## Declarative source

- Prefer native app configuration and chezmoi templates over scripts.
- Scripts must be narrowly scoped, idempotent, and safe to re-run.
- Never download and execute remote code from a template or change script.
- Do not overwrite files outside chezmoi-managed targets.
- Resolve configurable locations through XDG variables.
- Never embed usernames, machine-specific paths, secrets, or local credentials.

## Tests

- Use fake HOME and isolated XDG directories.
- Do not run `chezmoi apply` on a developer account during validation.
- Test a missing optional application and verify that the rest of the
  configuration remains usable.
- Verify every managed source file has a target with
  `scripts/verify-delivery.sh`.
- Use `scripts/audit-horneroctl-binds.sh` and the shell-contract checks when
  changing desktop bindings or preset composition.
- Keep historical material in `docs/wiki/`; do not cite it as active behavior.
