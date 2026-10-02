# Dots Scripts Utility Guide

`horneroctl` is the unified entrypoint for Hornero system operations. The
former `dots` dispatcher and most `dots-*` wrappers are retired; Settings
uses Hornero Shell IPC, and the external `dots-snappy-switcher` adapter is
still used for switcher theme changes. See [docs/Horneroctl.md](../Horneroctl.md)
for the migration map.

## Usage

```sh
horneroctl --help
horneroctl <command> --help
```

## Native-first workflows (horneroctl)

### launcher

```bash
horneroctl apps launch
horneroctl apps launch --backend=quickshell
```

### clipboard

```bash
horneroctl capture clipboard
horneroctl capture clipboard --backend copyq
horneroctl capture clipboard --backend cliphist
```

### power-menu

- Primary: the session drawer via shell IPC (bound to `Super+X`)

```bash
horneroctl shell ipc -- call drawers toggle session
```

### settings-gui

- Opens a Control Center destination through the running Hornero Shell.
- Use `--pane` for a direct destination; the Shell reports if the desktop
  session is unavailable.

```bash
horneroctl config gui
horneroctl config gui --pane appearance
```

### keyboard-help

- Readout: `horneroctl hardware keyboard keys [--category=CAT] [--search=TERM]`
- With Hornero Shell running: opens Hornero System Settings through IPC

```bash
horneroctl hardware keyboard keys
horneroctl hardware keyboard keys --search=workspace
```

## Theme and color workflows

### appearance

- Unified appearance API for Quickshell UI and scripts
- Manages appearance theme packs plus variant/mode/wallpaper syncing

```bash
dots appearance list
dots appearance current
dots appearance apply neon-city
dots appearance set-variant vibrant
dots appearance set-mode dark
```

Reads also available natively: `horneroctl appearance status`.

### smart-colors

- Generates semantic colors and M3 `scheme.json`
- Dots cache: `~/.cache/dots/smart-colors/` (canonical writes go to `~/.cache/hornero/smart-colors/`)

```bash
dots smart-colors --generate --m3
dots smart-colors --concept=error
```

Native equivalents: `horneroctl appearance colors generate --m3 --yes`,
`horneroctl appearance colors concept error`.

### wallpaper (retired wrappers)

```bash
horneroctl wallpaper set /path/to/wallpaper.jpg --yes
horneroctl wallpaper current
horneroctl wallpaper reload --yes
dots appearance doctor
```

## Notes

- Legacy Waybar/EWW/Rofi/JGMenu integration was intentionally removed.
- `dots appearance theme` remains available as a thin alias; `dots appearance` is the canonical contract.
- `hornero-settings-shim` is an opt-in compatibility adapter; it is no
  longer selected by default. `dots-snappy-switcher` remains the external
  switcher theme adapter. Other supported operations run through `horneroctl`.
