# Hyprland Setup Guide

## Overview

HorneroConfig is a Wayland-first dotfiles configuration built for Hyprland. The implementation follows a modular architecture and integrates seamlessly with the rice system, smart-colors, Waybar, and configuration management.

## Quick Start

### Installation

```bash
# Install Hyprland and all dependencies
dots hyprland-setup

# For NVIDIA users
dots hyprland-setup --nvidia
```

### First Run

1. Log out and select "Hyprland" from your display manager
2. Set up colors and theme:
   ```bash
   dots wal-reload
   dots rice selector
   ```

## Architecture

### Configuration Structure

```
~/.config/hypr/
├── hyprland.conf              # Main config (sources conf.d/*)
└── hyprland.conf.d/
    ├── monitors.conf          # Display configuration
    ├── environment.conf       # Wayland environment vars
    ├── input.conf             # Keyboard/mouse/touchpad
    ├── animations.conf        # Animation settings (Hyprland-inspired bezier curves)
    ├── keybindings.conf       # All keybindings
    ├── window-rules.conf      # Window rules and layer rules
    ├── colors.conf            # Smart-colors integration
    └── autostart.conf         # Startup applications (mirrors i3 autostart pattern)
```

### Design Consistency with X11 Stack

The Hyprland configuration follows the same architectural principles as the X11 stack:

#### Visual Consistency
- **Corner Radius**: 12px (matching picom.conf)
- **Gaps**: inner=12, outer=18 (matching i3 gaps configuration)
- **Border Size**: 2px (matching i3 border pixel 2)
- **Blur**: Similar to picom's dual_kawase strength 6
- **Shadow**: Matching picom's shadow settings (radius 12, offset -12)

#### Configuration Pattern
- **Modular Structure**: Split configs in `.conf.d/` (like picom-rules.conf separation)
- **Smart Colors Integration**: All color values replaced by dots-smart-colors via dots-wal-reload
- **Autostart**: Uses `dex --autostart` for XDG desktop files (same as i3)
- **Comments**: Extensive documentation headers in all config files

#### Component Equivalents

| X11 Stack | Wayland Stack | Design Principle |
|-----------|---------------|------------------|
| picom.conf | hyprland.conf decoration{} | 12px corners, shadows, blur |
| dunst | mako | Smart-colors, urgency levels, app-specific rules |
| polybar | waybar | Modular CSS, semantic colors, rich modules |
| rofi | rofi-wayland | Same .rasi themes, session-aware clipboard |
| i3 autostart | hyprland autostart | XDG autostart, service daemons, theme loading |

### Integration with Existing Systems

#### Smart Colors

Smart-colors automatically generates Hyprland-compatible color files:

```bash
dots-smart-colors --generate
```

Generates:
- `~/.cache/dots/smart-colors/colors-hyprland.conf`
- `~/.cache/dots/smart-colors/colors-waybar.css`
- `~/.cache/dots/smart-colors/colors-mako.conf`

#### Waybar (Status Bar)

Follows the same profile system as Polybar:

```
~/.config/waybar/
├── launch.sh                  # Launch script (WM-aware)
├── profiles/
│   └── default.sh            # Profile configuration
└── configs/
    └── default/
        ├── config            # Waybar config (JSON)
        └── style.css         # Imports smart-colors
```

#### Rice System

Rice themes now support both X11 and Wayland:

```bash
# ~/.local/share/dots/rices/gruvbox-wayland/config.sh
POLYBAR_PROFILE="default"    # For X11
WAYBAR_PROFILE="default"     # For Wayland
```

Apply scripts automatically detect the session type and configure accordingly.

## Utility Scripts

All follow the `dots-*` pattern:

### Screenshots
```bash
dots hyprshot                 # Full screen
dots hyprshot --region        # Select region
dots hyprshot --window        # Active window
dots hyprshot --edit          # Open in swappy
dots hyprshot --clipboard     # Copy to clipboard
```

### Wallpapers
```bash
dots hyprlock set /path/to/wallpaper
dots hyprlock reload
```

## Keybindings

### Essential Apps
- `Super + Return` - Terminal (kitty)
- `Super + D` - Application launcher
- `Super + F` - File manager
- `Super + X` - Power menu

### Window Management
- `Super + Q` - Close window
- `Super + Space` - Toggle floating
- `Super + M` - Toggle fullscreen
- `Super + H/J/K/L` - Move focus (vim-like)

### Workspaces
- `Super + 1-9` - Switch workspace
- `Super + Shift + 1-9` - Move window to workspace
- `Super + Mouse scroll` - Switch workspace

### Screenshots
- `Print` - Full screenshot
- `Shift + Print` - Region screenshot
- `Super + Print` - Window screenshot

### Media Keys
- `XF86AudioRaiseVolume/LowerVolume` - Volume control
- `XF86MonBrightnessUp/Down` - Brightness control
- `XF86AudioPlay/Next/Prev` - Media playback

## Updating Colors/Theme

The workflow is the same as X11:

```bash
# After changing wallpaper or colors
dots wal-reload

# Select a different rice
dots rice selector
```

This automatically:
1. Generates smart-color files for all applications
2. Reloads Hyprland colors
3. Restarts Waybar
4. Reloads Mako notifications
5. Updates all EWW widgets

## Creating New Rices

Rice themes can support both X11 and Wayland. Example structure:

```bash
# ~/.local/share/dots/rices/my-rice/config.sh
RICE_NAME="My Rice"
POLYBAR_PROFILE="default"    # For i3/Polybar
WAYBAR_PROFILE="default"     # For Hyprland/Waybar
```

The apply script detects session type:

```bash
# ~/.local/share/dots/rices/my-rice/apply.sh
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    # Apply Wayland configuration
    dots-wal-reload
    ~/.config/waybar/launch.sh restart
else
    # Apply X11 configuration
    ~/.config/polybar/launch.sh restart
fi
```

## Troubleshooting

### Check Dependencies
```bash
dots hyprland-setup --check-only
```

### View Logs
```bash
# Waybar logs
tail -f ~/.cache/waybar/waybar.log

# Hyprland logs
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -1)/hyprland.log
```

### Restart Components
```bash
# Waybar
killall waybar && ~/.config/waybar/launch.sh

# Mako
killall mako && mako &

# Hyprland (reload config)
hyprctl reload
```

## NVIDIA Users

Add to kernel parameters in bootloader:
```
nvidia_drm.modeset=1
```

The environment.conf automatically sets NVIDIA-specific variables when detected.

## Migration from X11

Your existing configuration is preserved. Both X11 and Wayland configs coexist:

- X11: i3, Polybar, Dunst, Picom
- Wayland: Hyprland, Waybar, Mako (no compositor needed)

Switch between them by selecting different sessions at login.

## Contributing

When adding Hyprland features, follow the HorneroConfig principles:

1. **Modular** - Separate configs in `hyprland.conf.d/`
2. **Theme-adaptive** - Use smart-colors integration
3. **Script pattern** - Name utilities `dots-*`
4. **Rice-aware** - Support profile system
5. **Documentation** - Update this guide

See [Architecture Philosophy](../Architecture-Philosophy.md) for details.
