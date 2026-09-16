# hornero-shell PKGBUILD validation

Branch: `feat/shell-package-validation`, based on `main` at
`329b6858c9bade373efba908fe452e23369d364f`
(Merge pull request #7 from HorneroOS/feat/vm-test-harness).

Validated: 2026-09-10 on Arch Linux (x86_64, 24 cores).
Tool versions: makepkg (pacman) 7.1.0, GNU bash 5.3.15,
ShellCheck 0.11.0, Python 3.14.7 with pytest 9.1.1.

## Summary

| Check | Command | Result |
| --- | --- | --- |
| SRCINFO parses | `makepkg --printsrcinfo` in `packaging/` | PASS, exit 0 |
| Bash syntax | `bash -n PKGBUILD` | PASS |
| ShellCheck | `shellcheck -S warning PKGBUILD` | see analysis below, no real defect, PKGBUILD untouched |
| namcap | `namcap PKGBUILD` / `namcap *.pkg.tar.zst` | SKIPPED, not installed, sudo blocked (details below) |
| depends/makedepends in real repos | `pacman -Si <name>` for every entry | PASS with notes (table below) |
| Real `makepkg` build | — | NOT ATTEMPTED, two deps uninstallable here (details below) |
| DESTDIR layout vs docs | static cross-check against `CMakeLists.txt` | PASS |
| Packaging tests | `python3 -m pytest tests/test_packaging.py` | 7 passed |

## `makepkg --printsrcinfo`

Exit 0. Output:

```ini
pkgbase = hornero-shell
pkgdesc = Hornero OS desktop shell, built with Quickshell, QML and Qt for Wayland
pkgver = 1.0.0
pkgrel = 1
url = https://github.com/HorneroOS/shell
arch = x86_64
license = GPL-3.0-or-later
makedepends = cmake
makedepends = git
makedepends = ninja
makedepends = pkgconf
makedepends = qt6-tools
depends = aubio
depends = libcava
depends = libqalculate
depends = pipewire
depends = qt6-base
depends = qt6-declarative
depends = quickshell
optdepends = app2unit: launch apps as systemd user units
optdepends = brightnessctl: laptop backlight control
optdepends = ddcutil: external monitor brightness control
optdepends = fish: shell used by helper scripts
optdepends = hyprland: compositor integration via hyprctl
optdepends = lm_sensors: temperature sensor readings
optdepends = networkmanager: network status via nmcli
optdepends = swappy: screenshot annotation
optdepends = wl-clipboard: clipboard integration via wl-copy
source = hornero-shell::git+https://github.com/HorneroOS/shell.git
sha256sums = SKIP

pkgname = hornero-shell
```

(`sha256sums = SKIP` is correct for a `git+https` VCS source.)

## ShellCheck analysis

Raw run reports one SC2148 (missing shebang/shell directive), eleven
SC2034 (`pkgrel`, `pkgdesc`, `arch`, `url`, `license`, `depends`,
`makedepends`, `optdepends`, `source`, `sha256sums` "unused"), and one
SC2154 (`pkgdir` "not assigned"). Every one of these is structural to
the PKGBUILD format: the SC2034 variables are consumed by makepkg, not
by shell code, and `pkgdir`/`srcdir`/`pkgname` are provided by makepkg
at build time. There are no findings in the executable logic of
`build()` or `package()` beyond the makepkg-provided `$pkgdir`. The
PKGBUILD was intentionally left without shellcheck directives: silencing
these format-inherent notes would mean disabling checks. Repo CI lints
`scripts/*.sh` and `assets/wrap_term_launch.sh`, not `packaging/`.

## namcap: skipped and why

`namcap` is not installed (`pacman -Q namcap`: not found) and installing
it needs root (`sudo -n true`: "a password is required"), so no install
was attempted. It is available as `extra/namcap 3.6.0-3` for a
privileged run. The pre-AUR `namcap` step in `packaging/README.md`
remains recommended and unexecuted.

## Dependency verification against real repos (`pacman -Si`)

| Entry | Repo | Note |
| --- | --- | --- |
| aubio | extra | — |
| libcava | chaotic-aur (this host) | AUR-only on stock Arch; see note |
| libqalculate | extra | — |
| pipewire | extra | — |
| qt6-base | extra | — |
| qt6-declarative | extra | — |
| quickshell | extra (0.3.1-1) | no longer AUR-only; corroborated on archlinux.org |
| cmake, git, ninja | extra | — |
| pkgconf | core | — |
| qt6-tools | extra | — |
| app2unit (opt) | not in official repos | AUR-only |
| brightnessctl, ddcutil, fish, hyprland, lm_sensors, networkmanager, swappy, wl-clipboard (opt) | extra | — |

Installed on this host (`pacman -Q`): aubio 0.4.9-25, libqalculate
5.12.0-1, pipewire 1:1.6.8-1, qt6-base 6.11.2-3, qt6-declarative
6.11.2-1, quickshell satisfied via installed quickshell-git
0.3.1.r0.g1a4716c-1 (`Provides: quickshell`), cmake 4.4.3-2,
git 2.55.0-1, ninja 1.13.2-3, pkgconf 3.0.7-1. C library present as
`lib-cava` 0.10.7-1, which ships `/usr/lib/pkgconfig/libcava.pc`
(`pkg-config --modversion libcava` returns 0.10.7) but declares
`Provides: None`. Missing: `libcava` (pacman name), `qt6-tools`.

## Real build: not attempted and why

Per the no-sudo-install rule, no `makepkg` build was attempted. Two
blockers, both verified above:

1. The `depends` name `libcava` is unsatisfiable by the local pacman:
   the installed `lib-cava` package provides nothing under that name,
   so makepkg dependency resolution fails here. (On stock Arch,
   `libcava` is AUR-only; on this host it additionally resolves via
   the configured `chaotic-aur` third-party repo, version 1.0.0-1.)
2. The declared makedepends `qt6-tools` is not installed.

Both would require privileged installs, which are out of scope. The
named build-dependency set otherwise checks out on this host: Qt6
(incl. `qmltyperegistrar`/`qmlcachegen` from qt6-declarative at
`/usr/lib/qt6/`), quickshell (via the `provides` name), pipewire,
aubio, and the CAVA library with pkg-config file. No build files
reference qt6-tools utilities (no linguist/lrelease usage found in
`CMakeLists.txt`, `plugin/`, `extras/`, `nix/`), so its necessity is
unproven, but it was left in `makedepends` because only a successful
build without it could justify removal.

## DESTDIR layout cross-check (static, PASS)

Documented in `packaging/README.md`, confirmed against the build files:

- `/etc/xdg/quickshell/hornero`: `INSTALL_QSCONFDIR` default
  `etc/xdg/quickshell/hornero` (`CMakeLists.txt`), overridden to the
  absolute path by the PKGBUILD; `install(DIRECTORY assets components
  config modules services utils presets ...)` plus `shell.qml`,
  `LICENSE.GPL-3.0`, `NOTICE`.
- `/usr/lib/hornero`: `INSTALL_LIBDIR`; `extras/CMakeLists.txt`
  installs the `version` helper binary there.
- `/usr/lib/qt6/qml/Hornero*`: `INSTALL_QMLDIR` combined with the
  module target paths; URIs declared in
  `plugin/src/Hornero/CMakeLists.txt` (`Hornero`) and its
  `Internal`/`Models`/`Services` subdirectories match the documented
  `Hornero`, `Hornero.Internal`, `Hornero.Models`, `Hornero.Services`.
- `assets/wrap_term_launch.sh` is mode 100755 in git
  (`git ls-files -s`); the explicit `chmod 755` in `package()` is
  redundant but harmless hardening.
- `package()` installs `LICENSE.GPL-3.0` and `NOTICE` under
  `/usr/share/licenses/hornero-shell/`, matching the declared
  `GPL-3.0-or-later` license.

## Observations (not defects)

- `packaging/README.md` said quickshell lives only on the AUR. It is
  now in `extra`, so the AUR paragraph was corrected in this branch
  (only `libcava` still needs an AUR helper on stock Arch).
- This clone has no git tags (`git describe --tags` finds nothing), so
  a bare `cmake` configure without `-DVERSION` falls back to `0.0.0`
  with a warning. The PKGBUILD always passes `-DVERSION=$pkgver`, so
  packaging is unaffected.

## Reproduce

```bash
git clone https://github.com/HorneroOS/shell.git
cd shell
git checkout feat/shell-package-validation
cd packaging && makepkg --printsrcinfo
bash -n PKGBUILD
shellcheck -S warning PKGBUILD
cd .. && python3 -m pytest tests/test_packaging.py
```
