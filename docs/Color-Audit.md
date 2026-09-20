# Color Audit - Quickshell Era

## Scope

Audit status for Smart Colors in the maintained stack (Hyprland + Quickshell).

## Status

- Quickshell: primary consumer via `~/.cache/dots/smart-colors/scheme.json`
- Hyprland: color environment integration active
- Hyprlock: `colors-hyprlock.env` generated and consumed
- Kitty: `colors-kitty.conf` generated and consumable
- Scripts: `colors.sh` and `colors.env` available for shell consumers

## Runtime Flow

```bash
dots wal-reload
```

This command regenerates Smart Colors and requests Quickshell color reload.

## Hard-Cut Notes

- Legacy Waybar/EWW/Rofi-focused migration items were removed from active audit scope.
- This audit tracks only maintained integration paths.

## Verification Checklist

```bash
horneroctl appearance colors generate --m3 --yes
ls -la ~/.cache/dots/smart-colors/
horneroctl shell ipc -- call colours reload
```
