# hornero-shell packaging (Arch Linux)

This directory holds the Arch Linux package definition for the Hornero OS
desktop shell. The package builds the CMake project and installs it to the
standard prefixes verified against a local `DESTDIR` install:

- `/etc/xdg/quickshell/hornero` — shell QML runtime, assets, presets
- `/usr/lib/hornero` — `version` helper binary
- `/usr/lib/qt6/qml/Hornero*` — native QML plugin modules
  (`Hornero`, `Hornero.Internal`, `Hornero.Models`, `Hornero.Services`)

## Build the package

Install the build dependencies, then run `makepkg`:

```bash
sudo pacman -S --needed base-devel cmake ninja pkgconf git qt6-base qt6-declarative qt6-tools
makepkg -s
```

The `-s` flag resolves the remaining `depends` via pacman where available.
`quickshell` is available in Arch `extra`, so only `libcava` lives on the
AUR (on stock Arch) and must be installed first with an AUR helper (or
`makepkg` by hand):

```bash
paru -S libcava
```

Any package providing the `quickshell` name (such as AUR
`quickshell-git`) also satisfies that dependency.

Then install the built package:

```bash
sudo pacman -U hornero-shell-*.pkg.tar.zst
```

## namcap expectations

`namcap` is not available in this container, so run it on an Arch host
before submitting to the AUR:

```bash
namcap PKGBUILD
namcap hornero-shell-*.pkg.tar.zst
```

Expected results:

- No missing-dependency warnings: every directly linked library observed in
  the built modules (`libqalculate`, `libaubio`, `libcava`, `libpipewire`,
  Qt6 Core/Gui/Qml/Quick/Network/Sql/Concurrent) maps to a `depends` entry.
- Possible informational note about the AUR-only dependencies (`quickshell`
  resolved via the `quickshell-git` provides, and `libcava`): this is normal
  for AUR packages and not a defect.
- No ELF or permission warnings: the helper script
  `assets/wrap_term_launch.sh` is explicitly kept executable in `package()`.

## Dependency notes

- `extra/cava` does **not** provide the `libcava` shared library or its
  pkg-config file (it ships only the `cava` binary), so the build depends on
  the AUR `libcava` package instead.
- Quickshell is resolved through the `quickshell` provides name (currently
  supplied by AUR `quickshell-git`); depending on the provides name keeps the
  PKGBUILD working no matter which Quickshell package supplies it.
- `qt6-tools` is a build-only dependency for the Qt QML module tooling used
  by `qt_add_qml_module`.

## Version bumping

`pkgver` mirrors the release line in `nix/default.nix` (`version`). To cut a
new release:

1. Tag upstream (`v<version>`) and update `nix/default.nix`.
2. Set `pkgver` here to the new version (without the leading `v`).
3. Reset `pkgrel` to `1`; raise `pkgrel` (without touching `pkgver`) for
   packaging-only changes such as dependency or install fixes.
4. Refresh `.SRCINFO` with `makepkg --printsrcinfo > .SRCINFO` when this
   directory is submitted to the AUR.
5. Re-run `makepkg -s` and `namcap` as described above.

## License

The packaged shell runtime is GPL-3.0 (see `LICENSE.GPL-3.0` and `NOTICE` at
the repository root), so the package declares `GPL-3.0-or-later` and installs
both files under `/usr/share/licenses/hornero-shell/`.
