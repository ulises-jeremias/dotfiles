# Hyprland Setup Guide

## Overview

HorneroConfig is a Wayland-first dotfiles configuration built for Hyprland. The implementation follows a modular architecture and integrates seamlessly with the rice system, smart-colors, Waybar, and configuration management.

## Quick Start

### Installation

Hyprland and all dependencies are automatically installed when you apply the dotfiles with chezmoi:

```bash
# Apply dotfiles (includes Hyprland installation)
chezmoi apply

# Or for initial setup
chezmoi init --apply https://github.com/ulises-jeremias/dotfiles
```

The installation script is located at:

```text
home/.chezmoiscripts/linux/run_onchange_before_install-hyprland.sh.tmpl
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

### Design Principles

The Hyprland configuration follows HorneroConfig's architectural principles:

#### Visual Design

- **Corner Radius**: 12px rounded corners for a polished look
- **Gaps**: inner=12, outer=18 for comfortable spacing
- **Border Size**: 2px borders for clear window separation
- **Blur**: Dual kawase blur (strength 6) for elegant transparency
- **Shadow**: Soft shadows (radius 12, offset -12) for depth perception

#### Configuration Pattern

- **Modular Structure**: Split configs in `.conf.d/` for maintainability
- **Smart Colors Integration**: All color values replaced by dots-smart-colors via dots-wal-reload
- **Autostart**: Uses `dex --autostart` for XDG desktop files
- **Comments**: Extensive documentation headers in all config files

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

Rice themes support Wayland configurations:

```bash
# ~/.local/share/dots/rices/gruvbox-wayland/config.sh
WAYBAR_PROFILE="default"
```

Apply scripts automatically detect the session type and configure accordingly.

## Utility Scripts

All follow the `dots-*` pattern:

### Screenshots

```bash
dots screenshooter                    # Interactive region selection (default)
dots screenshooter --fullscreen       # Full screen
dots screenshooter --region           # Select region with slurp
dots screenshooter --window           # Active window
```

The screenshot tool uses `grim` and `slurp` for Wayland-native screenshots.

### Lockscreen

```bash
dots lockscreen --lock                # Lock with default blur effect
dots lockscreen --lock-effect=dim     # Lock with dim effect
dots lockscreen --lock-effect=pixel   # Lock with pixelated effect
dots lockscreen --update=<wallpaper>  # Update lockscreen images
```

### Wallpapers

```bash
dots hyprpaper-set                    # Set wallpaper with hyprpaper
dots wal-reload                       # Reload wallpaper and update all themes
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

## Theme Management

### Updating Colors/Theme

Update colors and themes with these commands:

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

### Creating New Rices

Rice themes can be created with Wayland-specific configurations:

```bash
# ~/.local/share/dots/rices/my-rice/config.sh
RICE_NAME="My Rice"
WAYBAR_PROFILE="default"
```

The apply script handles session-specific configuration:

```bash
# ~/.local/share/dots/rices/my-rice/apply.sh
# Apply Wayland configuration
dots-wal-reload
~/.config/waybar/launch.sh restart
```

## Troubleshooting

### Check Installed Packages

You can verify which Hyprland-related packages are installed:

```bash
# Check Hyprland
pacman -Q hyprland

# Check all Wayland tools
pacman -Q | grep -E "(hypr|wayland|waybar|mako|grim|slurp)"
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

### Kernel Parameters

Add to kernel parameters in your bootloader configuration:

```text
nvidia_drm.modeset=1
```

### Automatic Detection

The `environment.conf` automatically detects NVIDIA GPUs and sets the appropriate environment variables when needed. No manual configuration is required after setting the kernel parameter.

For detailed NVIDIA setup and troubleshooting, see:

- [Hybrid GPU Performance Guide](Hybrid-GPU-Performance.md)
- [Hardware NVIDIA Troubleshooting](wiki/Hardware-nvidia-troubleshooting.md)

## Contributing

When adding Hyprland features, follow the HorneroConfig principles:

1. **Modular** - Separate configs in `hyprland.conf.d/`
2. **Theme-adaptive** - Use smart-colors integration
3. **Script pattern** - Name utilities `dots-*`
4. **Rice-aware** - Support profile system
5. **Documentation** - Update this guide

See [Architecture Philosophy](../Architecture-Philosophy.md) for details.
