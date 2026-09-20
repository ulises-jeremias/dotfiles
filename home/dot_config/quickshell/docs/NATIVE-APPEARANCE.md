# Native appearance layers — HorneroOS/shell issue #2

QML applies theming through `horneroctl appearance …` verbs first and
keeps only `dots-settings-gui` / `dots-snappy-switcher` as required native
backends. Every remaining compat call site carries a `TODO(hornero-compat)`
marker pointing here or at `docs/COMPAT.md`.

## Native layers

### GtkSettings (`services/GtkSettings.qml`) — migration step (a)

Applies GTK themes, icon themes, and color-scheme policy through the
deterministic `gsettings` desktop APIs before falling back to
`horneroctl appearance gtk …` verbs.

Policy mapping (`toGsettingsScheme`, input normalized by
`ThemePipeline.normalizeGtkColorScheme`):

| Policy              | `org.gnome.desktop.interface color-scheme`        |
|---------------------|---------------------------------------------------|
| `prefer-light`      | `prefer-light`                                    |
| `prefer-dark`       | `prefer-dark`                                     |
| `default`           | `default`                                         |
| `follow` (or empty) | `prefer-dark` when dark mode, else `prefer-light` |

Native writes:

| Request      | `gsettings set` keys                                                              |
|--------------|-----------------------------------------------------------------------------------|
| GTK theme    | `org.gnome.desktop.interface gtk-theme`, `org.gnome.desktop.wm.preferences theme` |
| Icon theme   | `org.gnome.desktop.interface icon-theme`                                          |
| Color scheme | `org.gnome.desktop.interface color-scheme`                                        |

Live queries (`refreshLive`) read the same three keys back into
`liveGtkTheme` / `liveIconTheme` / `liveColorScheme`. When `gsettings` is
absent (exit 99) the layer falls through to the `horneroctl appearance gtk`
verbs (`_compatFor`); theme-pack ids resolve via
`horneroctl appearance gtk theme`.

Consumers: `ThemePipeline` (queued gtk/gtk-color-scheme/icons jobs and the
pipeline finalize step via `applyFull`), `AppearancePane` (live seeding via
`refreshLive` plus change connections).

### WallpaperAnalysis (`services/WallpaperAnalysis.qml`) — migration step (b)

Thin wrapper around the native `ImageAnalyser` plugin exposing
`dominantColour` / `luminance` plus `ready` and `isLight` helpers for any
wallpaper path via `analyze(path)`.

Consumers: `Wallpapers.preview()` (instant preview tone alongside the full
M3 palette job), `Colours.wallLuminance` / `Colours.wallDominantColour`
(translucency layering and native tone), `AppearancePane.previewAnalyser`
(an `ImageAnalyser` bound to the palette-generation input; the preview pane
shows its dominant colour as an instant swatch while the generated palette
is absent).

## Migrated call sites

| Former call site                                                                                                   | Native replacement                                                          |
|--------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `ThemePipeline` finalize script (`horneroctl appearance gtk theme/apply/set-icons/color-scheme/sync-color-scheme`) | `GtkSettings.applyFull`                                                     |
| `ThemePipeline` standalone gtk apply                                                                               | `GtkSettings.applyGtkTheme`                                                 |
| `ThemePipeline` standalone color-scheme                                                                            | `GtkSettings.applyColorScheme`                                              |
| `ThemePipeline` standalone set-icons                                                                               | `GtkSettings.applyIconTheme`                                                |
| `AppearancePane` live current GTK/icon/color-scheme queries                                                        | `GtkSettings.refreshLive` first                                             |
| Wallpaper tone for translucency                                                                                    | `Colours.wallLuminance` (already native) plus new `wallDominantColour`      |
| Wallpaper preview tone                                                                                             | `WallpaperAnalysis` (`Wallpapers`) and `previewAnalyser` (`AppearancePane`) |

## First-class built-in themes (P2 appearance tokens)

`hornero-dark` / `hornero-light` are fully described by the canonical
semantic tables in `services/Colours.qml` (`_horneroDark` / `_horneroLight`;
dark is byte-identical to the compiled palette defaults, fixed colours are
shared mode-independent per M3). `ThemePipeline.applyTheme` short-circuits
these ids natively — no wallpaper, `wal`, or `dots-m3-colors` round-trip —
then follows GTK color-scheme policy through `GtkSettings.applyFull` with
an empty theme id (stays off the dots-owned registry path). The launcher
`Themes` model always lists both first, even when the dots registry is
absent. The default theme id lives in `config/AppearanceConfig.qml`
(`theme: "hornero-dark"`), persisted via `serializeAppearance()` and pinned
in `config/shell.default.json`. Switching writes the whole table, so there
is no light/dark leakage; text pairs are covered by contrast tests in
`tests/test_appearance_tokens.py`.

### Flagship provenance (cross-repo mapping)

Both tables are GENERATED by `scripts/gen-flagship-m3.py` (M3 tonal-spot,
`materialyoucolor==3.0.4`) from one HorneroOS/config brand seed: `#E07856`
(the `palette.primary` of `profiles/themes/hornero-dark/theme.json`). One
source feeds both modes because M3 Fixed colors are mode-independent --
two seeds would break that invariant. Config owns static semantic
palettes; the shell owns M3 tonal roles, so the two namespaces never
share hexes role-for-role -- coherence means the same terracotta hue
family, with role-appropriate lightness per the M3 spec (a dark-mode
primary is tone 80, hence lighter than the brand hex). If config moves
that primary, update the seed here and re-run; `test_gen_stability`
fails CI on drift. `scrim`/`shadow`/`success*`/`term*` are hand-owned extras
outside the generated roles.

## Remaining compat adapters (with reasons)

| Call site                                                                                                                                       | CLI                                                                          | Reason native is not yet deterministic                                           |
|-------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| `ThemePipeline.m3Proc`, `Wallpapers` preview colours, `AppearancePane.previewPaletteProc`                                                       | `horneroctl appearance colors m3`                                            | Full M3 palette generation needs materialyoucolor, which lives outside this repo |
| `ThemePipeline` scheme regenerate/sync-state; `Colours.setMode`; `Schemes` list/current/set; `M3Variants`; `AppearancePane` scheme/mode commits | `horneroctl appearance scheme …`                                             | Scheme persistence lives in the native store                                     |
| `GtkSettings` full-mode with theme-pack id                                                                                                      | `horneroctl appearance gtk theme`                                            | Theme-pack id resolution is native                                               |
| `GtkThemeSection` / `IconThemeSection` listings                                                                                                 | `horneroctl appearance gtk list/icons`                                       | Native directory scan with de-dup across system/user roots                       |
| `AppearancePane` live queries (fallback branch)                                                                                                 | `horneroctl appearance gtk current*`                                         | Hosts without `gsettings`                                                        |
| `ThemePipeline` side effects                                                                                                                    | `dots-snappy-switcher`                                                       | Dots-owned tooling with no native equivalent                                     |
| `Themes.qml` loader                                                                                                                             | `horneroctl appearance theme list --full` (empty-model fallback when absent) | Native registry (see `docs/GTK-PACK-OWNERSHIP.md`)                               |
| `PresetGrid.qml` loader                                                                                                                         | `horneroctl shell preset list --full` (vendored fallback when absent)        | Native catalogue                                                                 |

Retired since issue #2: `dots-accent-override`, `dots-quickshell`,
`dots-night-mode`, and launcher-only actions (`dots-theme-selector`,
`dots-settings-gui` stays as the `config gui` backend, `dots-lockscreen`,
`dots-keyboard-help`) — all resolve to `horneroctl` verbs now.
(Wallpaper `current`/`set` migrated to `horneroctl wallpaper`;
screenshot/record/clipboard migrated to `horneroctl capture`;
system-update tile migrated to `horneroctl package upgrade`.)

## Contracts and checks

- `gtk-theme-manager.sh` is never called from QML and bare
  `python3 generate-m3-colors` never runs — enforced by
  `tests/test_appearance_consistency.py` and
  `scripts/check_forbidden_paths.sh`.
- The same test file requires both native layers to exist and every
  remaining compat QML call site to carry a `TODO(hornero-compat)` marker.
- Outbound process contracts are documented in `docs/IPC.md`; the `dots-*`
  dependency table in `docs/MIGRATION.md` §2 records the native-first
  status per CLI.
