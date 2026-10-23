# Integration patterns

## Ownership

HorneroOS has three product layers: Hornero Config provides declarative
system defaults and catalogues, Hornero Shell presents the desktop, and
`horneroctl` exposes stable OS capabilities. This repository configures the
personal workstation around those layers.

## Use public interfaces

- Use documented `horneroctl` commands for OS and desktop actions.
- Use documented Shell IPC when opening a Shell surface from another product
  component.
- Keep GUI presentation and session state in Hornero Shell.
- Keep package defaults, theme metadata, and GTK integration in Hornero Config.
- Keep personal app preferences and optional wallpaper binaries in this
  chezmoi source.

Do not duplicate an installed theme or layout catalogue, clone the Shell into
the user config tree, compile a second copy of its plugin, or add fallback
implementations when a product package is missing. The Arch bootstrap installs
the required AUR packages and fails with a useful version error if their
contract is not met.

## Chezmoi templates

Templates should be deterministic, idempotent, and scoped to a managed target.
Use explicit template data for host-specific choices. Never start a GUI,
contact a location service, install packages from arbitrary templates, or
delete user data merely because a template changed. Required Hornero packages
are handled only by the dedicated Arch bootstrap scripts.

## Optional applications

Use the application when installed and otherwise leave the desktop usable.
Do not download missing tools, assume a particular browser or editor, or
silently claim an unavailable integration succeeded.
