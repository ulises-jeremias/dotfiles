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

Do not duplicate an installed theme catalogue, copy internal scripts, or add
fallback implementations when a product package is missing. Explain the
missing dependency and let the owner layer fix it.

## Chezmoi templates

Templates should be deterministic, idempotent, and scoped to a managed target.
Use explicit template data for host-specific choices. Never start a GUI,
contact a location service, install packages, or delete user data merely
because a template changed.

## Optional applications

Use the application when installed and otherwise leave the desktop usable.
Do not download missing tools, assume a particular browser or editor, or
silently claim an unavailable integration succeeded.
