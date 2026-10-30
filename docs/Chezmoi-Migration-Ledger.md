# Chezmoi migration ledger

Per-file record of dotfiles-managed configuration that HorneroOS now
owns natively. A target is only removed through chezmoi after the
native replacement is implemented, packaged, installed, and validated;
removal rules live in `home/.chezmoiremove.tmpl`. Entries guarded by
`horneroNative` apply only where the OS identity is HorneroOS (or the
maintainer opts in with `HORNERO_NATIVE=1`, required on preview24
installations migrated in place, whose os-release keeps `ID=arch`).

Backup for every row: copy the target aside (or snapshot `~/.config`)
before `chezmoi apply`. Rollback for every row: restore the backup
copy; chezmoi no longer manages these paths, so nothing recreates
them. A second apply must be a no-op.

| Old dotfiles source | Target | New owner | Required version | Verification | Removal mechanism | Status |
|---|---|---|---|---|---|---|
| `home/dot_config/hypr/hyprland.conf` + `hyprland.conf.d/` | `.config/hypr/hyprland.conf`, `.config/hypr/hyprland.conf.d` | dotfiles Lua config (`hyprland.lua.d`) | Lua-only migration | host + repo tests | `.chezmoiremove.tmpl` (all hosts) | active |
| `home/dot_config/hypr/scripts/executable_*.sh` / `*.lua`, `home/dot_local/bin/executable_hyprland-runtime*`, `executable_start-gnome-keyring*` | `.config/hypr/scripts/*`, `.local/bin/hyprland-runtime*`, `.local/bin/start-gnome-keyring*` | Lua modules inside `hyprland.lua.d` | Lua-only migration | `tests/test_hyprland_lua_scripts.py` | `.chezmoiremove.tmpl` (all hosts) | active |
| `home/dot_config/kitty/{kitty,hornero-dark,hornero-light,pampa}.conf` (deleted in #347) | `.config/kitty/{kitty,hornero-dark,hornero-light,pampa}.conf` | HorneroOS/config (`desktop/kitty`) | hornero-config 0.3.14 | preview28 Desktop VM install: packaged Kitty + Super+Enter terminal PASS | `.chezmoiremove.tmpl` (`horneroNative` only) | active |
| `home/dot_config/xfce4/helpers.rc` (deleted) | `.config/xfce4/helpers.rc` | HorneroOS/config + horneroctl terminal selection | hornero-config 0.3.14 | preview28 Desktop VM: terminal helper resolves Kitty | `.chezmoiignore.tmpl` (preserve user choice; ignored targets are never removed by chezmoi) | active, no removal |
| `home/dot_local/share/hornero/wallpapers/*` rasters (deleted) | `.local/share/hornero/wallpapers/*`, `~/Pictures/Wallpapers/*` links | HorneroOS/config brand assets | config wallpaper migration | `tests/test_wallpaper_migration.py` (hash-checked, exact stale links only) | dedicated guarded script, not `.chezmoiremove` | active |
| `home/dot_config/systemd/user/hornero-hermes.service` (deleted) | `.config/systemd/user/hornero-hermes.service` | `horneroctl assistant` (see `docs/Hermes-Ownership.md`) | — | ownership contract tests | explicitly **not** `.chezmoiremove` (`chezmoi forget` + assistant receipts) | transferred |
| `/etc/os-release` branding script | `/etc/os-release` (system file) | HorneroOS/installer identity step | preview28 ISO | preview28 VM install: `ID=horneroos` | none: system files are never removed by chezmoi; script is skipped on native | native |

## Adding a new row

1. Prove native parity in a clean HorneroOS install (no dotfiles).
2. Delete or guard the dotfiles source first; never list a path that
   chezmoi still manages.
3. Prefer exact paths. Guard with `horneroNative` unless the entry is
   obsolete on every host.
4. Extend `tests/test_chezmoiremove_native_cleanup.py` (or the owning
   contract test) and run it before opening the PR.
