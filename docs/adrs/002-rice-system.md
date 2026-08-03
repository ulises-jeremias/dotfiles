# ADR-002: Appearance System and Theme Packs

## Status

Superseded 2026-08-02 (formerly “Modular Rice System Architecture”)

## Context

Desktop theming previously used sticky “rices” (`rices/<id>/`, `rice/current`,
`Rice.qml` IPC). That model duplicated state, caused GTK/mode drift, and forced
every wallpaper/palette change through a rice identity. We keep curated look
packs, but they are apply-once recipes — not a live source of truth.

## Decision

- **Live SoT**
  - Wallpaper: `~/.local/state/dots/wallpaper/path`
  - Palette: `~/.cache/dots/smart-colors/scheme.json`
  - Mode/flavour prefs: `~/.local/state/dots/scheme/state.json`
  - GTK/icons: gtk `settings.ini` + gsettings
  - Shell chrome: QS `Config` / `~/.config/hornero/shell.json`
- **Theme packs** (optional recipes): `~/.local/share/dots/themes/<id>/theme.json`
  - Apply once via Control Center Themes or `dots appearance theme apply <id>`
  - **Never** write a sticky `current` theme/rice id
- **Wallpapers**: `~/.local/share/dots/wallpapers/<id>/` → symlinked to
  `~/Pictures/Wallpapers/<id>/`
- **Orchestrator**: Quickshell `ThemePipeline.qml` (IPC target `appearance`) +
  `apply-appearance.sh` shell fallback
- **CLI**: `dots appearance …` (`theme`, `set-wallpaper`, `set-mode`, `set-gtk`, …)

Removed: `~/.local/share/dots/rices/`, `dots-rice`, `rice/current`, per-rice
`config.sh` / `apply.sh`, IPC target `rice`.

## Consequences

### Positive

- One live appearance model; theme packs are inspiration, not identity
- Control Center can configure wallpaper, mode, variant, scheme, GTK, icons
- Offline apply without Quickshell

### Negative

- External forks that only ship rice `config.sh` trees need a `theme.json` pack
- Users must not expect “current rice” restores from old snapshots

### Neutral

- Shell layout presets (`shell-presets/`) remain a separate apply-once system
