# Rice System: Theme Management

The rice system is managed through the Quickshell-first appearance workflow.

## Canonical Commands

```bash
dots appearance list
dots appearance current
dots appearance apply neon-city
dots appearance set-variant vibrant
dots appearance set-mode dark
dots appearance set-wallpaper /path/to/wallpaper.jpg
dots appearance doctor
```

`dots rice ...` remains as a thin compatibility alias for the same commands.

When Quickshell is running, apply/set-wallpaper go through IPC into `Rice.qml`.
When Quickshell is not running, the same full pipeline runs via `apply-appearance.sh`.

## What a Rice Controls

- wallpaper selection (`backgrounds/`, first sorted image by default)
- smart-colors / M3 palette generation (`schemeType`, `darkMode`)
- GTK theme (`gtkTheme`, including `auto`)
- optional Hyprland animation profile / kitty opacity / snappy theme

## Light / dark model

Two related but distinct concepts:

| Layer           | Source                                                     | When it wins                                                                                        |
|-----------------|------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Rice default    | `config.json` → `darkMode`                                 | On **full rice apply** (`dots appearance apply`, launcher confirm, Control Center Apply for a rice) |
| Live preference | `scheme/state.json` → `mode` (mirrored into `scheme.json`) | After apply: Theme mode toggle, wallpaper-only changes, variant/mode CLI, boot regenerate           |

Rules:

1. **Applying a rice** sets live mode from that rice’s `darkMode` (preset).
2. **Theme mode** in Control Center updates the live preference only — it does **not** change the current rice id.
3. **Wallpaper-only** / reload use the **live** mode (`Colours.currentLight` / `state.json`), never the rice default. Otherwise flipping to dark and changing wallpaper would snap back to the rice’s light/dark.
4. Control Center shows when live mode diverges from the current rice default.

```bash
dots appearance set-mode dark   # live preference
dots appearance apply soft-morning  # preset (includes darkMode: false)
dots appearance doctor          # FAIL on wal≠pointer, empty hyprlock, GTK mode drift, orphans
```

`Appearances.Appearance` in Quickshell forwards `darkMode` / `schemeType` from `list-rices.py` so Control Center staging can honor light rices. Mode overrides after a rice apply wait for `Rice.applyFinished` and only run when Theme mode was toggled explicitly.

GTK / libadwaita keep `gtk-application-prefer-dark-theme` and `org.gnome.desktop.interface color-scheme` (`prefer-dark` / `prefer-light`) aligned with the live mode on rice apply and on `dots-color-scheme mode`.

## State (single source of truth)

| Concern           | Path                                     |
|-------------------|------------------------------------------|
| Current rice id   | `~/.local/state/dots/rice/current`       |
| Wallpaper pointer | `~/.local/state/dots/wallpaper/path`     |
| Live scheme       | `~/.cache/dots/smart-colors/scheme.json` |
| Scheme prefs      | `~/.local/state/dots/scheme/state.json`  |

There is **no** `.current_rice`, cache rice export, or per-rice `config.sh` / `apply.sh` on the maintained path.

```bash
dots appearance doctor
dots-color-scheme sync-state
```

## Quickshell Integration

Control Center → Appearance:

1. Hover / click **stages** a preview.
2. Explicit **Apply** commits staged changes.
3. Launcher rice selector applies immediately on confirm.

## Structure

`~/.local/share/dots/rices/<rice-name>/`

- `config.json` — sole rice config
- `backgrounds/` — wallpapers (PNG/JPG/WEBP/GIF/BMP; symlinks followed)
- `preview.png` — selector thumbnail

## Notes

- Maintained desktop path: Hyprland + Quickshell.
- Wallpaper display: Quickshell Background layershell + pywal + Material You.
- Tracking: <https://github.com/ulises-jeremias/dotfiles/issues/249>
