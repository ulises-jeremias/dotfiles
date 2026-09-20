# Compat adapters — external CLI dependencies

Every external CLI the shell shells out to is owned outside this repo.
The shell must keep working (possibly degraded) when one is missing, must
never hard-require a dotfiles checkout, and must never grow new coupling
without a row here. Dispositions A–G are defined in `docs/MIGRATION.md` §2.

## Adapter rules

1. Call CLIs by bare name (`horneroctl …`, `dots-settings-gui`,
   `dots-snappy-switcher` — never `$HOME/…` paths).
2. Absence must degrade, not crash: guard with `FileView` fallbacks
   (wallpaper pointer), empty-model fallbacks (theme/scheme lists), or
   error signals (`ThemePipeline.lastError`).
3. Appearance path is fixed: QML calls **only** `horneroctl appearance …`
   verbs for GTK/M3 application, scheme ops, and theme-pack listing
   (`list --full`). Never `gtk-theme-manager.sh` directly, never bare
   `python3 generate-m3-colors`, never bare `python3` for theme listing
   (`tests/test_appearance_consistency.py`).
4. Markers: coupling points carry `TODO(hornero-compat)` pointing here.

## Per-CLI notes

| CLI                                                                                                                                                                                                                                                            | Fallback when missing                                                | Marker                                                  |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------|---------------------------------------------------------|
| `horneroctl appearance gtk …` (retired `dots-gtk-theme`)                                                                                                                                                                                                       | Appearance apply fails the job with `lastError`; shell keeps running | `services/ThemePipeline.qml`                            |
| `horneroctl appearance colors m3` (retired `dots-m3-colors`)                                                                                                                                                                                                   | Preview/apply colours fail the job; cached `scheme.json` still loads | `services/ThemePipeline.qml`, `services/Wallpapers.qml` |
| `horneroctl appearance scheme …` (retired `dots-color-scheme`)                                                                                                                                                                                                 | Scheme lists render empty; mode/variant actions no-op                | `services/Colours.qml`, `services/ThemePipeline.qml`    |
| `horneroctl appearance accent …` (retired `dots-accent-override`)                                                                                                                                                                                              | Accent section actions no-op                                         | `ColorVariantSection.qml`                               |
| `horneroctl shell preset …` (retired `dots-quickshell`)                                                                                                                                                                                                        | `presets/*.json` vendored dataset is the fallback list               | `modules/layoutpicker/PresetGrid.qml`                   |
| `horneroctl wallpaper current` (retired `dots-wallpaper-current`)                                                                                                                                                                                              | `FileView` on `Paths.wallpaperPointer` seeds `actualCurrent`         | `services/Wallpapers.qml`                               |
| `horneroctl wallpaper set` (retired `dots-wallpaper-set`)                                                                                                                                                                                                      | Random-wallpaper launcher action                                     | `config/LauncherConfig.qml`                             |
| `horneroctl appearance night-mode …` (retired `dots-night-mode`)                                                                                                                                                                                               | Quick-toggle action no-ops                                           | `QuickToggles.qml`, `SystemPane.qml`                    |
| `horneroctl capture record` (retired `dots-recorder`)                                                                                                                                                                                                          | Recording actions no-op                                              | `services/Recorder.qml`                                 |
| `dots-snappy-switcher`, `horneroctl appearance hyprlock` (retired `dots-hyprlock-theme`)                                                                                                                                                                       | Theme side effects skipped (`\|\| true` semantics)                   | `services/ThemePipeline.qml`                            |
| `dots-settings-gui`, `horneroctl shell ipc …` (retired `dots-theme-selector`, `dots-lockscreen`, `dots-keyboard-help`), `horneroctl capture screenshot` (retired `dots-screenshooter`), `horneroctl package upgrade` (retired dead `dots-sysupdate` reference) | Launched actions fail silently in terminal/launcher                  | `SystemPane.qml`, `LauncherConfig.qml`                  |
| `horneroctl appearance theme list --full` (retired `dots-appearance theme list`)                                                                                                                                                                               | Theme search list renders empty when absent (JSON-parse fallback)    | `modules/launcher/services/Themes.qml`                  |

## Debt to resolve in follow-ups

- (G, resolved) `Themes.qml` loader and `PresetGrid.qml` consume the native
  `--full` JSON arrays; the bare-`python3` calls are dropped.
- Promote this table into versioned per-CLI contracts with the owning
  HorneroOS repos as they are extracted.
