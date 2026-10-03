# Hornero Shell Integration

HorneroOS/shell owns the Quickshell implementation. This repository provisions
the runtime checkout at `~/.config/quickshell` with a safe fast-forward update;
chezmoi ignores that tree and does not carry a second implementation copy.

## Current interfaces

- `horneroctl shell start|stop|restart|status|logs` manages the running shell.
- `horneroctl shell ipc -- …` invokes the supported Shell IPC surface.
- `horneroctl shell preset list|current|apply …` reads and applies installed
  layouts. Apply with `--yes` for explicit confirmation.
- `horneroctl appearance …` and `horneroctl wallpaper …` own appearance and
  wallpaper operations.
- The in-shell Layout Picker and Control Center are user-facing interfaces to
  the same installed product data and IPC destinations.

## Ownership and compatibility

HorneroOS/config packages own the installed themes, layouts and defaults.
HorneroOS/shell owns the runtime presentation and its source fallback data.
HorneroOS/hornero owns the stable CLI and system operations.

The `dots` data directories and `dots-*` names that remain in migration code
are compatibility paths for existing HorneroConfig installations. New
Hornero-facing operations should use `horneroctl`; do not add another
`dots-quickshell` adapter or copy the Shell layout catalogue into this repo.

## Validation

- `scripts/test-shell-layout-consistency.sh` checks the installed catalogue
  through `horneroctl` without maintaining a local preset list.
- `scripts/audit-horneroctl-binds.sh` checks configured CLI calls against the
  current command surface.
- The full multi-layout schema, geometry and rendering tests live in
  HorneroOS/shell and HorneroOS/qa.
