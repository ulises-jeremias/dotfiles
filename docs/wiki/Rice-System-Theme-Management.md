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

## State (single source of truth)

| Concern | Path |
|---------|------|
| Current rice id | `~/.local/state/dots/rice/current` |
| Wallpaper pointer | `~/.local/state/dots/wallpaper/path` |
| Live scheme | `~/.cache/dots/smart-colors/scheme.json` |
| Scheme prefs | `~/.local/state/dots/scheme/state.json` |

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
- Tracking: https://github.com/ulises-jeremias/dotfiles/issues/249
