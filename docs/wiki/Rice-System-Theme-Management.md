# Rice System: Theme Management

The rice system is now managed through the Quickshell-first appearance workflow.

## Canonical Commands

```bash
dots appearance list
dots appearance current
dots appearance apply neon-city
dots appearance set-variant vibrant
dots appearance set-mode dark
dots appearance set-wallpaper /path/to/wallpaper.jpg
```

`dots rice ...` is retained as compatibility naming, but `dots appearance ...` is the canonical interface.

## What a Rice Controls

- wallpaper selection
- smart-colors / M3 palette generation
- light/dark mode and M3 variant
- GTK theme metadata and optional extras
- Quickshell-facing appearance state

## Quickshell Integration

Appearance changes done from the control center can be previewed first, then committed with Apply/Save.

```mermaid
flowchart LR
  user[UserSelectsAppearance] --> preview[QuickshellPreview]
  preview --> apply[ApplyOrSave]
  apply --> cli[dots-appearanceApply]
  cli --> palette[dots-smart-colorsAndScheme]
  palette --> shell[QuickshellReload]
```

## Structure

Rices live under:

`~/.local/share/dots/rices/<rice-name>/`

Typical files:

- `config.sh`
- `executable_apply.sh`
- `backgrounds/`
- optional `preview.*`

## Notes

- Legacy Rofi/JGMenu theme selectors were removed from the maintained path.
- The maintained desktop path is Hyprland + Quickshell.
