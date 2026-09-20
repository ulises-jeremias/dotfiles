# Dots Scripts Utility Guide

`horneroctl` is the unified entrypoint for Hornero scripts. The former
`dots` dispatcher and all `dots-*` wrappers are retired except
`dots-settings-gui` (the `config gui` backend) and `dots-snappy-switcher`
(the switcher theme backend) — see [docs/Horneroctl.md](../Horneroctl.md)
for the full migration map.

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
- Retained `dots-*` scripts (`dots-settings-gui`, `dots-snappy-switcher`)
  remain modular and can be called directly; everything else runs through
  `horneroctl`.
