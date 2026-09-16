# horneroctl Dependency

> **Optional dependency** for the `dots-*` script ecosystem.

## What it is

[horneroctl](https://github.com/HorneroOS/hornero) is the Hornero OS
system CLI. Migrated `dots-*` scripts work as delegation shims: they
prefer `horneroctl` when the matching subcommand exists and fall back
to the legacy implementation in the same file otherwise. Nothing
breaks when `horneroctl` is absent.

## Install

```sh
git clone https://github.com/HorneroOS/hornero
cd hornero/cli
./make.vsh build-cli
install -m0755 horneroctl ~/.local/bin/horneroctl
```

The installer (`scripts/install_dotfiles.sh`) prints a warning — not an
error — when `horneroctl` is missing from `PATH`.

## `HORNEROCTL_BIN` override

All shims resolve the binary through the `HORNEROCTL_BIN` environment
variable, defaulting to `horneroctl` on `PATH`:

```sh
# Use a custom build instead of the one on PATH.
export HORNEROCTL_BIN="$HOME/src/hornero/horneroctl"

# Force legacy behavior even when horneroctl is installed.
HORNEROCTL_BIN=false dots-appearance status
```

Unset or empty `HORNEROCTL_BIN` means plain `horneroctl` from `PATH`.
