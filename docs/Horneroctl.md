# Hornero CLI integration

`horneroctl` is shipped by [HorneroOS/hornero](https://github.com/HorneroOS/hornero). It owns stable OS operations and the command-line interface for desktop capabilities. Quickshell owns presentation and live interaction; this chezmoi source does not implement fallback copies of those operations.

## Inspect the installed interface

The installed binary reports its own capabilities, which may differ by release:

```sh
horneroctl --help
horneroctl shell --help
horneroctl appearance --help
horneroctl apps --help
```

Use `--dry-run` to inspect supported changes and `--yes` only for an intentional mutation. Desktop Settings opens through the Hornero Shell's Control Center IPC contract.

## Workstation configuration

This repository may call the CLI from declarative Hyprland bindings or narrowly scoped chezmoi scripts. Keep argument order and documented confirmation flags. Do not parse raw help output as a product registry, duplicate CLI command lists, or add a private command shim. If an operation is missing, add it to HorneroOS/hornero and keep the product documentation in HorneroOS/docs.

See the current [Hornero CLI guide](https://horneroos.com/docs/desktop/horneroctl/) and [shortcuts](https://horneroos.com/docs/desktop/shortcuts/).
