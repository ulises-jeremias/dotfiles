# Compat adapters — external runtime CLIs

Every external CLI the shell shells out to is owned outside this repo
(`horneroctl` by `HorneroOS/hornero`, the M3 synthesizer backend by the host
`HORNERO_M3_SCRIPT`). The shell must keep working (possibly degraded) when
one is missing, must never hard-require a dotfiles checkout, and must never
grow new external coupling without a row here. Dispositions A–G are defined
in `docs/MIGRATION.md` §2.

## Adapter rules

1. Call `horneroctl` by bare name. The M3 synthesizer is reached only
   through the `horneroctl appearance colors m3 -- …` passthrough — never
   bare `python3 generate-m3-colors`, never a `$HOME/.local/bin` path.
2. Absence must degrade, not crash: guard with `FileView` fallbacks
   (wallpaper pointer), empty-model fallbacks (theme/scheme lists), or
   error signals (`ThemePipeline.lastError`).
3. Appearance path is fixed: QML calls **only** `horneroctl appearance …`
   / `horneroctl scheme …` / `horneroctl wallpaper …` /
   `horneroctl capture …` for GTK/M3/scheme/wallpaper/capture operations.
   Never `gtk-theme-manager.sh` directly, never bare `python3`
   (`tests/test_appearance_consistency.py`).
4. Markers: retired-adapter removals cite this file; remaining external
   coupling points cite the owning HorneroOS repo.

## Per-CLI notes

| CLI | Fallback when missing | Marker |
|---|---|---|
| `horneroctl appearance gtk …` | Appearance apply fails the job with `lastError`; shell keeps running | `services/ThemePipeline.qml` |
| `horneroctl appearance colors m3 -- …` | Preview/apply colours fail the job; cached `scheme.json` still loads | `services/ThemePipeline.qml`, `services/Wallpapers.qml` |
| `horneroctl scheme …` | Scheme lists render empty; mode/variant actions no-op | `services/Colours.qml`, `services/ThemePipeline.qml` |
| `horneroctl appearance accent …` | Accent section actions no-op | `ColorVariantSection.qml` |
| `horneroctl` (missing/failed `shell preset list`) | Grid falls back to the empty state with the store-path hint; stale `current` pointers select nothing | `modules/layoutpicker/PresetGrid.qml` |
| `horneroctl wallpaper current` | `FileView` on `Paths.wallpaperPointer` seeds `actualCurrent` | `services/Wallpapers.qml` |
| `horneroctl wallpaper set --yes` | Random-wallpaper launcher action fails if `horneroctl` is missing (shell cannot run without it) | `config/LauncherConfig.qml` |
| `horneroctl appearance night-mode toggle --yes` | Quick-toggle action no-ops | `QuickToggles.qml`, `SystemPane.qml` |
| `horneroctl capture record … --yes` | Recording actions no-op | `services/Recorder.qml` |
| `horneroctl apps switcher apply-theme-pack`, `horneroctl appearance hyprlock` | Theme side effects fail without failing the apply job (fire-and-forget processes) (`\|\| true` semantics) | `services/ThemePipeline.qml` |
| `horneroctl lock/capture/appearance/hardware …` (control-center tiles, launcher actions) | Launched actions fail silently in terminal/launcher | `SystemPane.qml`, `LauncherConfig.qml` |
| `horneroctl appearance theme list --full` | Theme search list renders empty when absent (JSON-parse fallback) | `modules/launcher/services/Themes.qml` |

## Debt to resolve in follow-ups

- (G, resolved track 3a) `Themes.qml` loader: theme listing moved behind
  `horneroctl appearance theme list --full` (bare-`python3` call dropped).
  The theme-pack catalogue itself resolves CLI-side (`HORNERO_THEMES_DIR`,
  else XDG data); a HorneroOS-owned data source remains a follow-up
  (see `docs/GTK-PACK-OWNERSHIP.md`).
- Promote this table into versioned per-CLI contracts with the owning
  HorneroOS repos as they are extracted.
