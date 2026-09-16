# Architecture — HorneroOS/shell

Quickshell + QML + Qt6 desktop shell for Wayland (Hyprland-first).
Imported from `ulises-jeremias/dotfiles@b26db04`; see `MIGRATION.md`.

## Entry point

`shell.qml` (`ShellRoot`): mounts `Background`, `Drawers`, `AreaPicker`,
`Lock`, `Shortcuts`, `BatteryMonitor`, `IdleMonitors`. Pragmas pin
`QS_NO_RELOAD_POPUP=1`, threaded render loop, and flickable deceleration.

## Layers

| Layer | Paths | Role |
|---|---|---|
| Shell root | `shell.qml` | Composition only |
| Modules | `modules/` | Visible surfaces: bar, launcher, dashboard, controlcenter, lock, notifications, osd, session, sidebar, utilities, drawers, background, areapicker, layoutpicker, windowinfo |
| Services | `services/` | Singletons: `ThemePipeline`, `Colours`, `Wallpapers`, `Audio`, `Brightness`, `Hypr`, `Network`/`Nmcli`, `Notifs`, `Players`, `Recorder`, `SystemUsage`, `Weather`, `Time`, `Visibilities`, `GameMode`, `IdleInhibitor`, `VPN`, `ThemePipeline` |
| Config | `config/` | `Config.qml` + per-area `*Config.qml`; user-tunable knobs |
| Shared UI | `components/` | Reusable controls/containers/effects (`qs.components*`) |
| Helpers | `utils/` | `Paths`, `SysInfo`, `Icons`, `Images`, `Searcher`, `Strings`, `NetworkConnection`, JS (`fuzzysort.js`, `fzf.js`) |
| Assets | `assets/` | Logo, gifs, shaders, `wrap_term_launch.sh`, `pam.d/` samples |
| Native | `plugin/`, `extras/` | `Hornero` QML plugin (C++: image analysis, audio, calculator, models) + `version` helper |
| Data | `presets/` | 11 vendored layout presets (fallback for `dots-quickshell preset list`) |

## Runtime / config path model

Binding interface: `HorneroOS/hornero` `docs/PATH_CONTRACT.md` is the
canonical record of every runtime path the session reads or writes; this
repo does not redefine paths. The rule: **new writes go to `hornero/*`**;
readers check the canonical `hornero/*` location first and fall back to
the legacy `dots/*` location (**reads only**, never written) for one
migration window.

No chezmoi, no hardcoded home layouts. Resolution order everywhere is
**explicit env override → XDG → `$HOME` default**, centralized in
`utils/Paths.qml` (singleton, `qs.utils`). The `DOTS_*_DIR` overrides pin
the legacy `dots/*` roots only:

| Path | Canonical (writes) | Legacy fallback (reads only) |
|---|---|---|
| Shell data: theme packs `themes/<id>/theme.json` (row 1), installed wallpapers `wallpapers/` (row 11) | `$XDG_DATA_HOME/hornero` (`Paths.data`) | `$XDG_DATA_HOME/dots` (`Paths.dataFallback`, `DOTS_DATA_DIR` override) |
| Shell state: wallpaper pointer `wallpaper/path` (row 9), `notifs.json` (row 10) | `$XDG_STATE_HOME/hornero` (`Paths.state`, `Paths.wallpaperPointer`) | `$XDG_STATE_HOME/dots` (`Paths.stateFallback`, `Paths.wallpaperPointerFallback`, `DOTS_STATE_DIR` override) |
| Shell cache: `smart-colors/scheme.json` (row 4), `imagecache[/notifs]` (row 10) | `$XDG_CACHE_HOME/hornero` (`Paths.cache`, `Paths.imagecache`) | `$XDG_CACHE_HOME/dots` (`Paths.cacheFallback`, `Paths.imagecacheFallback`, `DOTS_CACHE_DIR` override) |
| Shell user config: `shell.json` (row 6, no fallback — already canonical) | `$XDG_CONFIG_HOME/hornero` (`Paths.config`, `DOTS_CONFIG_DIR` override) | none |
| Pictures / videos | `XDG_PICTURES_DIR` / `XDG_VIDEOS_DIR` | `~/Pictures`, `~/Videos` |
| Wallpapers dir | `HORNERO_WALLPAPERS_DIR` | `Config.paths.wallpaperDir` (absolute-resolved) |
| Recordings dir | `HORNERO_RECORDINGS_DIR` | `~/Videos/Recordings` |
| Native helper lib (row 12) | `/usr/lib/hornero` | `DOTS_LIB_DIR` / `HORNERO_LIB_DIR` lookup |
| XKB rules (dev/nix) | `HORNERO_XKB_RULES_PATH` | system xkeyboard-config |

System defaults vs user overrides:

- **System defaults** ship under the Quickshell config dir
  (`INSTALL_QSCONFDIR`, default `etc/xdg/quickshell/hornero`): QML tree,
  `presets/`, `LICENSE.GPL-3.0`, `NOTICE`.
- **Factory settings** live in this repo at `config/shell.default.json`:
  its content equals what `Config.qml` `serializeConfig()` persists with
  pristine defaults (values from the per-area `*Config.qml` initializers;
  see `tests/test_factory_config.py` for the key-by-key proof and the
  three intentionally unset runtime-resolved keys). HorneroOS/config
  packages that file to `/etc/xdg/hornero/shell.json` (path contract
  row 6, system default); this repo never installs it there itself.
- **User overrides** live outside this repo at
  `$XDG_CONFIG_HOME/hornero/shell.json` (`Paths.config`), plus
  theme/wallpaper data under the data dir. Load order is user file first,
  system default as fallback; a missing user file is not an error —
  compiled defaults apply (`Config.qml` `onLoadFailed` tolerates
  `FileNotFound`). The shell watches them (`FileView`, `watchFiles`) and
  live-reloads; a preset apply deep-merges into the user file, never into
  the shipped tree.
- `assets/pam.d/*` are **host-integration samples**, not installed to
  `/etc` by CMake. Distributors copy/adapt them in packaging.

## Theming pipeline

`services/ThemePipeline.qml` serializes appearance jobs (theme / wallpaper /
reload) and shells out **only** to the canonical CLIs `dots-m3-colors`
(color generation) and `dots-gtk-theme` (GTK apply), plus
`dots-color-scheme` (scheme state). It never invokes
`gtk-theme-manager.sh` directly and never runs bare
`python3 generate-m3-colors` (enforced by
`tests/test_appearance_consistency.py`). Theme data resolves from
`Paths.data/themes` (canonical) with `Paths.dataFallback/themes` as the
legacy read fallback, wallpapers from `Paths.data/wallpapers`
(+ `Paths.dataFallback` fallback), and the scheme from
`Paths.cache/smart-colors/scheme.json` (+ `Paths.cacheFallback`
fallback), with `Paths.pictures/Wallpapers` as the user-content root.
Notification state reads `Paths.state/notifs.json` (+
`Paths.stateFallback` fallback); image caches write to the canonical
`Paths.imagecache` and regenerate on miss.

## External coupling

All `dots-*` runtime CLI dependencies, their dispositions (A–G), fallback
behavior, and debt markers are inventoried in `docs/COMPAT.md`.
The Quickshell IPC surface (targets other components script against) is in
`docs/IPC.md`. Contributor rules for QML/Qt/IPC/Process usage are in
`AGENTS.md`.
