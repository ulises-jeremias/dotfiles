# Dots Scripts Utility Guide

`dots` is the unified entrypoint for Hornero scripts. Most former
`dots-*` wrappers are retired — run `dots --list` (entries marked
`RETIRED` point at the native `horneroctl` replacement) or see
[docs/Horneroctl.md](../Horneroctl.md) for the full migration map.

## Usage

```sh
dots --help
dots --list
dots <script> [options]
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

- Primary: `dots-quickshell ipc session toggle`
- Fallback: minimal TUI selector

```bash
dots power-menu
dots power-menu --mode=quickshell
dots power-menu --mode=minimal
```

### settings-gui

- Quickshell control-center entrypoint
- Starts Quickshell when needed, then toggles `utilities`

```bash
dots settings-gui
```

### keyboard-help

- Readout: `horneroctl hardware keyboard keys [--category=CAT] [--search=TERM]`
- Under Quickshell (no bypass): settings-gui system menu

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
- Retained `dots-*` scripts remain modular and can be called directly.
