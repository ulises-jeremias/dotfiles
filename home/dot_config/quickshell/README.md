# HorneroOS shell

The official HorneroOS desktop shell, built with
[Quickshell](https://quickshell.org/) + QML + Qt 6 for Wayland
(Hyprland-first): bar, launcher, dashboard, control center, notifications,
lock screen, wallpaper/theme pipeline, and a native `Hornero` C++ plugin
for performance-critical work (image analysis, audio, calculator).

![Hornero desktop](docs/assets/desktop-hero.png)

*Pre-release snapshot from the graphical test VM (1280×720).*

## Position in HorneroOS

- **This repo owns**: the shell runtime (`shell.qml`, `modules/`,
  `services/`, `config/`, `utils/`, `components/`), shell-owned visual
  assets (`assets/`), the native plugin (`plugin/`) and helper (`extras/`),
  vendored layout presets (`presets/`), and Nix/CMake packaging.
- **Does not own**: compositor/terminal/app defaults
  ([HorneroOS/config](https://github.com/HorneroOS/config)), distribution
  composition ([HorneroOS/hornero](https://github.com/HorneroOS/hornero)),
  user overrides (`~/.config/hornero`, theme/wallpaper data), or the
  `dots-*` helper CLIs it shells out to (external runtime contracts, see
  `docs/COMPAT.md`).

## Status

Initial extraction from `ulises-jeremias/dotfiles@b26db04`
(`feat/initial-shell-extraction`). Functional parity with the dotfiles
shell minus personal-workstation assumptions. Known debt: `dots-*`
compat adapters (`docs/COMPAT.md`), bare-`python3` theme loader
(`modules/launcher/services/Themes.qml`).

## Build

```bash
cmake -S . -B build -D DISTRIBUTOR="local"
cmake --build build
```

Requires CMake ≥ 3.19, Qt 6.9+ (Core, Qml, Gui, Quick, Concurrent, Sql,
Network, DBus), `libqalculate`, `pipewire`, `aubio`, `libcava`/`cava`.
`VERSION`/`GIT_REVISION` come from git tags when available, else default
to `0.0.0`/`unknown` with a warning. Select modules with
`-D ENABLE_MODULES="extras;plugin;shell"`.

Nix: `nix build .#hornero-shell` (see `flake.nix`, `nix/`).

## Test / lint

```bash
python3 -m pytest tests/ -q        # layout, appearance, IPC, path + static scans
pre-commit run --all-files          # portable lint subset (see below)
./scripts/check_personal_data.sh    # personal-data guard
./scripts/check_forbidden_paths.sh  # no chezmoi/personal-path regressions
```

## Run

```bash
# CMake install (default INSTALL_QSCONFDIR=etc/xdg/quickshell/hornero):
QML2_IMPORT_PATH=<install-prefix>/usr/lib/qt6/qml \
  qs -p <install-prefix>/etc/xdg/quickshell/hornero
# Nix layout installs the QML tree to <prefix>/share/hornero-shell
# instead — or just run the `hornero-shell` wrapper.
qs ipc call <target> <fn> …                  # see docs/IPC.md
```

Runtime knobs are env-first: `DOTS_{DATA,STATE,CACHE,CONFIG}_DIR`,
`HORNERO_WALLPAPERS_DIR`, `HORNERO_RECORDINGS_DIR`, `HORNERO_LIB_DIR`
(see `docs/ARCHITECTURE.md`).

## Provenance

COPY-never-MOVE import from `ulises-jeremias/dotfiles@b26db04`
(`home/dot_config/quickshell/` → repo root,
`home/dot_local/share/dots/shell-presets/` → `presets/`).
Full matrix: `docs/MIGRATION.md`.

## Structure

```text
shell.qml presets/ modules/ services/ config/ utils/ components/ assets/
plugin/ extras/ nix/ tests/ scripts/ docs/ CMakeLists.txt flake.nix
```

## License

Dual layout (see `NOTICE`): scaffold and project docs are
[MIT](LICENSE); the shell runtime, native code, and presets are
[GPL-3.0-only](LICENSE.GPL-3.0) (derived from
[caelestia-dots/shell](https://github.com/caelestia-dots/shell) by
[@soramane](https://github.com/soramane) — credit preserved).
