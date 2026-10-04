# Testing strategy

Test declarative source without changing the developer's account or graphical
session. Use a temporary HOME and isolated XDG directories for tests that need
filesystem state.

## Source checks

- Validate tracked chezmoi templates with managed and static configuration
  data.
- Run `tests/test_hornero_source_contract.py` to assert ownership of theme
  metadata, wallpaper paths, and removal of retired runtime helpers.
- Run `scripts/verify-delivery.sh` to ensure managed files reach a target.
- Run `scripts/audit-horneroctl-binds.sh` and the layout-contract test when
  changing desktop bindings or layout interactions.

## Product acceptance

The authoritative Shell, CLI, package, and graphical acceptance suites live in
[HorneroOS/qa](https://github.com/HorneroOS/qa). Use those scenarios when a
change affects installed product behavior. A local source test is not proof
that the full desktop works.

Never run chezmoi apply against the host as part of automated validation.
Never submit external bug reports or telemetry from a test run.
