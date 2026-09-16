# Shell migration: dotfiles → HorneroOS/shell

Source: `ulises-jeremias/dotfiles@b26db04`
(`refactor: clean up configuration and remove unused assets`).
Target branch: `feat/initial-shell-extraction` of `HorneroOS/shell`.

Method: COPY-never-MOVE. The dotfiles clone (`/tmp/hx-shell-src`) is read-only:
no remote added, no push, no edit. Everything below was copied with `cp`,
never `mv`, preserving file trees and license headers.

## 1. Migration matrix

| Source path (dotfiles@b26db04) | Target path (HorneroOS/shell) | Classification | Deps | Status |
|---|---|---|---|---|
| `home/dot_config/quickshell/shell.qml` | `shell.qml` | shell-runtime (GPL-3.0) | Quickshell | migrated |
| `home/dot_config/quickshell/modules/**` | `modules/**` | shell-runtime (GPL-3.0) | Quickshell, Qt6, dots-* CLIs (see §2) | migrated |
| `home/dot_config/quickshell/services/**` | `services/**` | shell-runtime (GPL-3.0) | Quickshell, dots-* CLIs (see §2) | migrated |
| `home/dot_config/quickshell/config/**` | `config/**` | shell-runtime (GPL-3.0) | Quickshell | migrated, paths adapted (§4) |
| `home/dot_config/quickshell/utils/**` | `utils/**` | shell-runtime (GPL-3.0) | Quickshell | migrated |
| `home/dot_config/quickshell/components/**` | `components/**` | shell-runtime (GPL-3.0) | Quickshell (`qs.components*` imports require it) | migrated (needed import; kept with tree) |
| `home/dot_config/quickshell/assets/**` | `assets/**` | shell-owned visual assets (GPL-3.0) | — | migrated |
| `home/dot_config/quickshell/CMakeLists.txt` | `CMakeLists.txt` | build-system | CMake ≥ 3.19, Qt6 | migrated, hardened for standalone configure (§5) |
| `home/dot_config/quickshell/plugin/**` | `plugin/**` | native Qt/C++ QML plugin (GPL-3.0) | Qt6, libqalculate, pipewire, aubio, libcava/cava | migrated |
| `home/dot_config/quickshell/extras/**` | `extras/**` | native helper binary (GPL-3.0) | C++ toolchain | migrated (required by default `ENABLE_MODULES`) |
| `home/dot_config/quickshell/flake.nix` | `flake.nix` | nix-packaging | nixpkgs, quickshell flake | migrated |
| `home/dot_config/quickshell/flake.lock` | `flake.lock` | nix-packaging (reproducibility) | — | migrated with tree |
| `home/dot_config/quickshell/nix/**` | `nix/**` | nix-packaging | nixpkgs | migrated, homepage repointed to HorneroOS/shell |
| `home/dot_config/quickshell/.clang-format` | `.clang-format` | code-style | clang-format | migrated |
| `home/dot_config/quickshell/LICENSE` (attribution + GPL-3.0) | `LICENSE.GPL-3.0` + `NOTICE` | licensing | — | migrated, split verbatim (see §3) |
| `home/dot_local/share/dots/shell-presets/*.json` (11 files) | `presets/*.json` (11 files) | data-presets (layout presets) | validated by `tests/test_shell_layout.py` | migrated |
| scaffold `LICENSE` (MIT) | `LICENSE` (MIT, unchanged) | licensing (scaffold) | — | kept |
| scaffold `README.md`, `.gitignore` | `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, `SECURITY.md`, `.gitignore`, `.editorconfig` | project-docs | — | replaced/expanded for HorneroOS |

Not migrated (stays in dotfiles): compositor config, terminal settings,
`home/dot_local/share/dots/themes/*`, `wallpapers/*`, user `shell.json`
overrides, install scripts, PAM host config under `assets/pam.d/`
(documented as host-integration sample, not installed as system config).

Template-marker check: zero `{{` markers in the source quickshell tree and
in `shell-presets/*.json`; verified again after copy
(`tests/test_static_scans.py::test_no_template_markers`).

## 2. dots-* dependency table

Dispositions:

- **A — external runtime CLI**: kept as a call-by-name dependency owned by
  another HorneroOS component. The shell degrades gracefully when absent.
- **B — compat-adapter**: call site already handles absence (fallback path,
  `FileView` watcher, or error signal). No new coupling added.
- **C — vendored data**: data migrated into this repo (`presets/`).
- **D — HorneroOS-native path**: dotfiles assumption replaced with
  XDG/env-based resolution (`utils/Paths.qml`, `docs/ARCHITECTURE.md`).
- **E — IPC/process contract**: interaction documented in `docs/IPC.md`,
  not a code dependency.
- **F — dropped**: personal-workstation integration, not migrated.
- **G — deferred debt**: kept call with `TODO(hornero-compat)` marker and a
  `docs/COMPAT.md` entry; a follow-up extraction must resolve it.

| dots-* reference | Call sites (representative) | Disposition | Notes |
|---|---|---|---|
| `dots-gtk-theme` | `services/GtkSettings.qml` (compat fallback), `modules/controlcenter/appearance/**` (list + yielding live queries) | A, E | Native-first since issue #2: `services/GtkSettings.qml` applies via gsettings; CLI kept for theme-pack ids, listings, and hosts without gsettings. Never `gtk-theme-manager.sh` directly |
| `dots-m3-colors` | `services/ThemePipeline.qml`, `services/Wallpapers.qml`, `modules/controlcenter/appearance/AppearancePane.qml` | A, E | Full M3 palette generation stays CLI; instant tone is native (`services/WallpaperAnalysis.qml`, `Colours.wallLuminance`/`wallDominantColour`, `AppearancePane.previewAnalyser`). Never bare `python3 generate-m3-colors` |
| `dots-color-scheme` | `services/ThemePipeline.qml`, `services/Colours.qml`, `modules/launcher/services/Schemes.qml`, `AppearancePane.qml` | A, E | Scheme list/set/mode/variant operations; no native palette store yet, stays compat |
| native `gsettings` application | `services/GtkSettings.qml` ← `services/ThemePipeline.qml`, `AppearancePane.qml` | D | HorneroOS-native path (issue #2, step a): deterministic GTK/icon/color-scheme writes + live reads |
| native `ImageAnalyser` analysis | `services/WallpaperAnalysis.qml`, `services/Colours.qml`, `services/Wallpapers.qml`, `AppearancePane.qml` | D | HorneroOS-native path (issue #2, step b): dominantColour/luminance without shelling out |
| `dots-accent-override` | `modules/controlcenter/appearance/sections/ColorVariantSection.qml` | A, E | Accent set/clear |
| `dots-quickshell` | `modules/layoutpicker/PresetGrid.qml` (`preset list/apply`) | A, C, E | Listing has local fallback data: `presets/*.json` |
| `dots-wallpaper-current` | `services/Wallpapers.qml` (`resolveProc`) | A, B | `FileView` pointer fallback keeps UI non-empty when absent |
| `dots-wallpaper-set` | `config/LauncherConfig.qml` (random-wallpaper action) | A | Optional launcher action only |
| `dots-night-mode` | `modules/dashboard/dash/QuickToggles.qml`, `modules/controlcenter/system/SystemPane.qml` | A | Toggle only |
| `dots-recorder` | `services/Recorder.qml` (`start/stop/pause`) | A, E | Screen-recording backend |
| `dots-snappy-switcher` | `services/ThemePipeline.qml` (`apply-theme-pack`) | A | Theme-pack side effect |
| `dots-hyprlock-theme` | `services/ThemePipeline.qml` | A | Lock-screen theme side effect |
| `dots-theme-selector` | `modules/controlcenter/system/SystemPane.qml` | A | Launched, not embedded |
| `dots-settings-gui` | `config/LauncherConfig.qml` | A | Launched, not embedded |
| `dots-lockscreen` | `modules/controlcenter/system/SystemPane.qml` | A | `--lock` action |
| `dots-screenshooter` | `modules/controlcenter/system/SystemPane.qml` | A | Launched, not embedded |
| `dots-sysupdate` | `modules/controlcenter/system/SystemPane.qml` (via `foot -e sh -c`) | A | Terminal wrapper, optional |
| `dots-keyboard-help` | `modules/controlcenter/system/SystemPane.qml` (`DOTS_BYPASS_QUICKSHELL=1 …`) | A | Launched, not embedded |
| `dots-appearance theme list` | `modules/launcher/services/Themes.qml` | A, E | Track 3a: theme-pack listing moved behind this CLI; bare-`python3` dropped. Registry ownership still dots-side (see `docs/GTK-PACK-OWNERSHIP.md`) |
| `Paths.data/state/cache/config` (`DOTS_*_DIR` / XDG) | `utils/Paths.qml` | D | No chezmoi-managed paths; overrides via env documented in `docs/ARCHITECTURE.md` |
| chezmoi-managed `~/Pictures/Wallpapers` symlink assumption | `modules/controlcenter/appearance/sections/ThemesSection.qml` (comment) | D | Comment reworded; runtime path is `Paths.wallsdir` (`HORNERO_WALLPAPERS_DIR` override) |
| `notify-send "HorneroConfig"` titles | `services/ThemePipeline.qml` | D | Rebranded to `Hornero Shell` |

No QML calls `gtk-theme-manager.sh` directly and no QML runs bare
`python3 generate-m3-colors` — enforced by
`tests/test_appearance_consistency.py`.

## 3. Licensing note

- The migrated quickshell subtree derives from
  [caelestia-dots/shell](https://github.com/caelestia-dots/shell) by
  [@soramane](https://github.com/soramane) and is **GPL-3.0-only**.
- `LICENSE.GPL-3.0` is the source `LICENSE` body verbatim (attribution
  header preserved, then the full GPL-3.0 text). `NOTICE` preserves the
  Caelestia credit and records HorneroOS modifications.
- The repo scaffold stays MIT (`LICENSE`, unchanged).
- No license headers were stripped. Effective license for `shell.qml`,
  `modules/`, `services/`, `config/`, `utils/`, `components/`, `assets/`,
  `plugin/`, `extras/`, `presets/` is GPL-3.0-only; project docs/scaffold
  are MIT. See `NOTICE` and `README.md` (License section).

## 4. Personal-data exclusions

Scanned before import with the repo's guard
(`scripts/check_personal_data.sh`, same patterns as CI):

- No email addresses, no tokens/keys (`ghp_*`, `gho_*`, `AKIA*`,
  `BEGIN * PRIVATE KEY`), no SSID values, hostnames, or home-directory
  literals in the imported tree. (`ssid` occurs only as generic
  NetworkManager field/property names in `services/Nmcli.qml` and
  `utils/NetworkConnection.qml` — not personal data.)
- `https://github.com/ulises-jeremias/dotfiles` provenance URLs were
  repointed to HorneroOS homes (`nix/default.nix` homepage,
  `README.md`); `HorneroConfig` product strings became `Hornero Shell`
  / HorneroOS. Excluded from migration: user `shell.json` overrides,
  `themes/*`, `wallpapers/*`, install scripts, host PAM config.
- `assets/pam.d/*` ships as a host-integration **sample**; it is not
  installed to `/etc` by CMake (docs note in `docs/ARCHITECTURE.md`).

## 5. Build adaptation for a standalone repo

- `CMakeLists.txt` keeps upstream modules/selectors but no longer fails
  when configured outside a `git checkout` with tags: `VERSION` and
  `GIT_REVISION` fall back to `0.0.0` / `unknown` with a warning, and
  `extras`/`plugin` entries are skipped gracefully if their directories
  are absent (they are present in this extraction).
- `presets/*.json` are installed alongside the shell config dir so
  `dots-quickshell preset list` has a vendored fallback dataset.
- `flake.lock` is kept for reproducibility; `nix/hm-module.nix` is
  unchanged apart from provenance comments.

## Provenance

- Import command (read-only source): `git clone --depth 50
  https://github.com/ulises-jeremias/dotfiles /tmp/hx-shell-src &&
  git -C /tmp/hx-shell-src checkout b26db04`.
- Copy command (from the pinned source only):
  `cp -r home/dot_config/quickshell/{shell.qml,modules,services,config,utils,components,assets,CMakeLists.txt,plugin,extras,flake.nix,flake.lock,nix,.clang-format,LICENSE}
  …` and `cp home/dot_local/share/dots/shell-presets/*.json presets/`.
- Follow-ups: resolve the `G` debt row (`Themes.qml` loader), extract
  `dots-*` CLIs into owned HorneroOS repos, then tighten the compat
  adapters into hard versioned contracts.
