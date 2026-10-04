# Architecture principles

This repository is a personal chezmoi source that complements HorneroOS. The
HorneroOS repositories are the source of truth for the desktop product; this
repository owns only personal workstation choices and optional user media.

## Principles

1. **One owner per behavior.** Product settings and system defaults belong to
   HorneroOS. Personal application preferences belong here.
2. **Declarative first.** Prefer tracked configuration files and templates to
   imperative setup scripts.
3. **User data stays user-owned.** Updates do not delete, migrate, or rewrite
   state outside explicitly managed targets.
4. **Use stable interfaces.** Interact with Hornero through documented
   `horneroctl` commands and Shell IPC contracts, not copied implementation
   code.
5. **Optional software degrades clearly.** A missing application may disable
   its optional integration, but must not trigger downloads or pretend to
   succeed.
6. **Keep appearance coherent.** Theme metadata is canonical in
   [HorneroOS/config](https://github.com/HorneroOS/config). This source may
   provide wallpaper files; it does not maintain another theme catalogue.
7. **Validate without the host.** Tests use temporary HOME and XDG paths and
   never apply changes to a live user session.

## Current ownership map

- [HorneroOS/config](https://github.com/HorneroOS/config): packaged defaults,
  theme packs, GTK integration, wallpaper contracts, and profile data.
- [HorneroOS/shell](https://github.com/HorneroOS/shell): Quickshell surfaces,
  layout presets, and presentation state.
- [HorneroOS/hornero](https://github.com/HorneroOS/hornero): OS capabilities,
  user-facing CLI, and stable system operations.
- This repository: optional desktop applications, per-user preferences,
  host-level composition, and wallpaper media.

Historical architecture and retired experiments remain in `docs/wiki/` and
must not be used as current integration contracts.
