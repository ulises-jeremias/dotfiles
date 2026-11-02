# Chezmoi migration ledger

Per-file record of dotfiles-managed configuration that HorneroOS now
owns natively. A target is only removed through chezmoi after the
native replacement is implemented, packaged, installed, and validated;
removal rules live in `home/.chezmoiremove` plus the one-time,
version-gated migration script
`home/.chezmoiscripts/linux/run_after_remove-retired-kitty.sh.tmpl`.
Entries guarded by `horneroNative` apply only where the OS identity
is HorneroOS (or the
maintainer opts in with `HORNERO_NATIVE=1`, required on preview24
installations migrated in place, whose os-release keeps `ID=arch`).

Backup for every row: copy the target aside (or snapshot `~/.config`)
before `chezmoi apply`. Rollback differs by mechanism:

- One-shot script rows (Kitty): restoring the backup is enough. The
  migration records `~/.local/state/hornero/kitty-migration-done` and
  never deletes the file again.
- Persistent `.chezmoiremove` rows (Hyprland): chezmoi removes the
  target on **every** apply, so a restored file is deleted again by
  the next apply. To truly roll one back, first remove its entry from
  `home/.chezmoiremove` in the source, then restore the backup.

A second apply must be a no-op for managed content.

| Old dotfiles source                                                                                                                            | Target                                                                                      | New owner                                               | Required version           | Verification                                                               | Removal mechanism                                                                                                 | Status             |
|------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|---------------------------------------------------------|----------------------------|----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|--------------------|
| `home/dot_config/hypr/hyprland.conf` + `hyprland.conf.d/`                                                                                      | `.config/hypr/hyprland.conf`, `.config/hypr/hyprland.conf.d`                                | dotfiles Lua config (`hyprland.lua.d`)                  | Lua-only migration         | host + repo tests                                                          | `.chezmoiremove` (all hosts)                                                                                      | active             |
| `home/dot_config/hypr/scripts/executable_*.sh` / `*.lua`, `home/dot_local/bin/executable_hyprland-runtime*`, `executable_start-gnome-keyring*` | `.config/hypr/scripts/*`, `.local/bin/hyprland-runtime*`, `.local/bin/start-gnome-keyring*` | Lua modules inside `hyprland.lua.d`                     | Lua-only migration         | `tests/test_hyprland_lua_scripts.py`                                       | `.chezmoiremove` (all hosts)                                                                                      | active             |
| `home/dot_config/kitty/{kitty,hornero-dark,hornero-light,pampa}.conf` (deleted in #347)                                                        | `.config/kitty/{kitty,hornero-dark,hornero-light,pampa}.conf`                               | HorneroOS/config (`desktop/kitty`)                      | hornero-config 0.3.14      | preview28 Desktop VM install: packaged Kitty + Super+Enter terminal PASS   | one-shot `run_after_remove-retired-kitty.sh.tmpl` (`horneroNative` + hornero-config >= 0.3.14 gate + done marker) | active             |
| `home/dot_config/xfce4/helpers.rc` (deleted)                                                                                                   | `.config/xfce4/helpers.rc`                                                                  | HorneroOS/config + horneroctl terminal selection        | hornero-config 0.3.14      | preview28 Desktop VM: terminal helper resolves Kitty                       | `.chezmoiignore.tmpl` (preserve user choice; ignored targets are never removed by chezmoi)                        | active, no removal |
| `home/dot_local/share/hornero/wallpapers/*` rasters (deleted)                                                                                  | `.local/share/hornero/wallpapers/*`, `~/Pictures/Wallpapers/*` links                        | HorneroOS/config brand assets                           | config wallpaper migration | `tests/test_wallpaper_migration.py` (hash-checked, exact stale links only) | dedicated guarded script, not `.chezmoiremove`                                                                    | active             |
| `home/dot_config/systemd/user/hornero-hermes.service` (deleted)                                                                                | `.config/systemd/user/hornero-hermes.service`                                               | `horneroctl assistant` (see `docs/Hermes-Ownership.md`) | —                          | ownership contract tests                                                   | explicitly **not** `.chezmoiremove` (`chezmoi forget` + assistant receipts)                                       | transferred        |
| `/etc/os-release` branding script                                                                                                              | `/etc/os-release` (system file)                                                             | HorneroOS/installer identity step                       | preview28 ISO              | preview28 VM install: `ID=horneroos`                                       | none: system files are never removed by chezmoi; script is skipped on native                                      | native             |

## Adding a new row

1. Prove native parity in a clean HorneroOS install (no dotfiles).
2. Delete or guard the dotfiles source first; never list a path that
   chezmoi still manages.
3. Prefer exact paths. Guard with `horneroNative` unless the entry is
   obsolete on every host.
4. Extend `tests/test_kitty_native_migration.py` (or the owning
   contract test) and run it before opening the PR.

## Audited candidates — not ready (2026-11-02)

Audit of every remaining dotfiles-managed config with a counterpart in
HorneroOS/config (`desktop/`, `xdg/`; packaged as hornero-config,
installed under `/etc/xdg/<app>` plus `/etc/skel` seeds for a few apps).
No candidate met the ledger bar — implemented, packaged, installed,
and validated parity for **existing** users — so no removal script was
added. Deleting a `~/.config` file only preserves behaviour when the
application actually falls back to the packaged system location for
existing accounts; `/etc/skel` only seeds newly created accounts.

| Candidate (dotfiles source) | Packaged counterpart | Why not ready |
|---|---|---|
| `home/dot_config/btop/btop.conf`, `home/dot_config/cava/config` | `desktop/btop`, `desktop/cava`; byte-identical; `/etc/xdg` + `/etc/skel/.config` | HorneroOS/config `packaging/PKGBUILD` states btop/Cava "read user configuration rather than /etc/xdg defaults" and seeds skel for new accounts only. Existing users would lose the curated config on deletion. Needs an existing-user VM proof or a seed-copy (not delete) migration. |
| `home/dot_config/copyq/copyq.conf.tmpl` | `desktop/copyq/copyq.conf`; functionally identical (header only) | Packaged only under `/etc/xdg/copyq` (no skel seed). No proof CopyQ reads that path for existing users; CopyQ normally uses `~/.config/copyq`. |
| `home/dot_config/fastfetch/{config.jsonc,hornero.txt}` | `desktop/fastfetch/*` under `/etc/xdg/fastfetch` | Content drift, not parity: dotfiles adds `"format": "HorneroOS {build-id}"` and ships different logo art than the packaged file (changed in HorneroOS/config #109). Sync or explicitly accept the drift first. |
| `home/dot_config/fontconfig/fonts.conf` | `desktop/fontconfig/fonts.conf`; byte-identical; `/etc/xdg/fontconfig` | No verified proof fontconfig resolves `/etc/xdg/fontconfig/fonts.conf` for existing users (system fontconfig lives under `/etc/fonts`). Needs `fc-match`/clean-install validation. |
| `home/dot_config/handlr/handlr.toml` | `xdg/handlr/handlr.toml`; byte-identical; `/etc/xdg/handlr` | No verified proof handlr searches `XDG_CONFIG_DIRS` for existing users. Needs a clean-install/existing-user check. |
| `home/dot_config/Thunar/{accels.scm,renamerc,uca.xml}` | `desktop/thunar/*`; accels/renamerc byte-identical | Incomplete: `uca.xml` is deliberately excluded from the package (pacman ownership conflict; HorneroOS/config `tests/test_package.sh` asserts its absence under `/etc/xdg/Thunar`). Partial removal would strand custom actions. |
| `home/dot_config/gtk-3.0/settings.ini` (+ `bookmarks.tmpl`) | `desktop/gtk/settings.ini` under `/etc/xdg/gtk-3.0` | By design not parity: the dotfiles file omits theme/icon/dark keys because Hornero Shell/horneroctl own that dynamic state; the packaged file is the static `Hornero-Dark` factory. Deleting would regress dynamic appearance switching. Stays a personal layer. |
| `home/dot_config/git/{config.tmpl,config.user.tmpl,ignore}` | `xdg/git/{config,ignore}` under `/etc/xdg/git`; `ignore` byte-identical | Dotfiles config carries personal `[user]` identity; the package forbids it (guard-personal-data, `tests/test_package.sh`). Stays personal. |
| `home/dot_config/yazi`, `home/dot_config/tmux`, `home/dot_config/REAPER`, `home/dot_config/guitarix`, `home/dot_config/lxqt`, `home/dot_config/sss`, `home/dot_local/bin/*` (non-Hyprland) | none in HorneroOS/config | No native replacement implemented or packaged. Not candidates. |

Re-audit a row only when its "why not ready" is closed with evidence
(clean HorneroOS install without dotfiles, plus an existing-user
apply in a temporary HOME), then follow "Adding a new row" above.
