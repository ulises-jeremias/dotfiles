# Lockscreen System

> **Wayland-native lockscreen management with hyprlock**  
> Alternative to betterlockscreen for Wayland/Hyprland environments

## Overview

Locking runs through `horneroctl power lock --yes` (hyprlock backend) or the Quickshell lock module over IPC. Colors come from the smart-colors system via `horneroctl appearance hyprlock`.

## Features

- **Multiple Effects**: dim, blur, dimblur, pixel
- **Smart Color Integration**: Automatically uses colors from the smart-colors system
- **Cached Images**: Pre-generates lockscreen images for instant locking
- **ImageMagick Processing**: Creates professional-looking lockscreen backgrounds
- **Graceful Fallbacks**: Falls back to base image if effect images aren't available

## Installation

The lockscreen system is automatically installed when you apply the dotfiles with chezmoi. The installation script is located at:

```text
home/.chezmoiscripts/linux/run_onchange_before_install-hyprland.sh.tmpl
```

It installs:

```bash
yay -S --noconfirm --needed hyprlock hypridle
```

## Usage

### Update Lockscreen Images

Generate lockscreen images from a wallpaper:

```bash
dots lockscreen --update=/path/to/wallpaper.png
```

With custom effects parameters:

```bash
dots lockscreen --update=/path/to/wallpaper.png --dim=50 --blur=7 --pixel=15
```

### Lock the Screen

Lock with default blur effect:

```bash
dots lockscreen --lock
dots lockscreen -l
```

Lock with specific effect:

```bash
dots lockscreen --lock --lock-effect=dim
dots lockscreen --lock --lock-effect=blur
dots lockscreen --lock --lock-effect=dimblur
dots lockscreen --lock --lock-effect=pixel
```

### Automatic Updates

The lockscreen is automatically updated when you change wallpapers using:

```bash
horneroctl wallpaper reload --yes
```

## Effects

### Dim

Darkens the wallpaper by a specified percentage (default: 40%)

```bash
dots lockscreen --update=wallpaper.png --dim=60
```

### Blur

Applies Gaussian blur to the wallpaper (default level: 5)

```bash
dots lockscreen --update=wallpaper.png --blur=7
```

### DimBlur

Combines dimming and blurring for a professional look

```bash
dots lockscreen --update=wallpaper.png --dim=40 --blur=5
```

### Pixel

Creates a pixelated/mosaic effect (default scale: 10)

```bash
dots lockscreen --update=wallpaper.png --pixel=15
```

## Configuration

### Cache Directory

Lockscreen images are stored in:

```text
~/.cache/dots-lockscreen/current/
├── lock_resize.png    # Base resized image
├── lock_dim.png       # Dimmed version
├── lock_blur.png      # Blurred version
├── lock_dimblur.png   # Dim + blur version
└── lock_pixel.png     # Pixelated version
```

### Smart Colors

The lockscreen automatically uses colors from:

```text
~/.cache/dots/smart-colors/current.env
```

Colors used:

- `SMART_BG`: Background color
- `SMART_FG`: Foreground/text color
- `SMART_PRIMARY`: Ring color
- `SMART_ACCENT`: Accent color
- `SMART_SUCCESS`: Correct password indicator
- `SMART_ERROR`: Wrong password indicator

## Integration

### Session Controls

The lockscreen is part of the Quickshell lock module
(`modules/lock`), driven by PAM authentication and exposed over IPC:

```bash
horneroctl shell ipc -- call lock lock      # lock the session
horneroctl shell ipc -- call lock unlock    # escape-hatch unlock (no PAM)
horneroctl power lock --yes                 # lock via hyprlock
qs ipc call lock isLocked                   # query lock state
```

The idle pipeline (see `modules/IdleMonitors`) locks the session
automatically after the configured inactivity timeout.`

### Wal Reload

Automatically updates lockscreen when changing themes:

```bash
horneroctl wallpaper reload --yes  # Updates wallpaper and lockscreen
```

### Appearance

Theme / wallpaper apply regenerates lockscreen colors via `horneroctl appearance hyprlock --yes`
(retired `dots-hyprlock-theme` wrapper) after scheme generation (Quickshell `ThemePipeline`
and shell `apply-appearance.sh`).

```bash
dots appearance theme apply vapor-dreams
horneroctl appearance hyprlock --yes
```

## Hyprlock Configuration

The script dynamically generates a hyprlock configuration with these features:

```conf
background {
  path = <effect-image>
  blur_passes = 3
  blur_size = 7
  contrast = 0.8916
  brightness = 0.8172
  vibrancy = 0.1696
}

input-field {
  size = 300, 60
  outline_thickness = 2
  outer_color = rgba(<primary-color>)
  inner_color = rgba(<bg-color>)
  font_color = rgba(<fg-color>)
  fail_color = rgba(<error-color>)
  # ... and more
}
```

## Style-Aware Layouts

The lockscreen adapts layout from the **current wallpaper path** and optional
theme-pack `tags` (there is no sticky “current theme” id).

### Available Layouts

| Layout        | Matching tags / path hints     | Description                                     |
| ------------- | ------------------------------ | ----------------------------------------------- |
| **Default**   | Any unmatched                  | Clean, centered layout with standard typography |
| **Cyberpunk** | cyberpunk, neon, futuristic    | Glowing neon elements, tech-inspired fonts      |
| **Cozy**      | cozy, kawaii, cute, warm, soft | Soft, rounded elements with pastel accents      |
| **Vaporwave** | vaporwave, retro, synthwave    | Gradient effects, 80s-inspired typography       |
| **Minimal**   | minimal, clean                 | Ultra-clean with minimal UI elements            |

### How It Works

1. `horneroctl power lock` resolves the wallpaper from `~/.local/state/dots/wallpaper/path`
2. Path segments (e.g. `…/vapor-dreams/…`) provide a first hint
3. If the parent folder matches a theme pack id, `tags` from `theme.json` refine the layout
4. Colors come from the smart-colors / hyprlock cache

### Theme pack tags

```json
{
  "id": "neon-city",
  "tags": ["cyberpunk", "neon", "dark", "city"]
}
```

Matching is case-insensitive and supports partial keyword matches.

## Comparison with Betterlockscreen

| Feature           | betterlockscreen          | horneroctl lock       |
| ----------------- | ------------------------- | --------------------- |
| Platform          | X11 (i3lock)              | Wayland (hyprlock)    |
| Effects           | 6 effects                 | 4 core effects        |
| Multi-monitor     | Native support            | Via hyprlock          |
| Color integration | Manual config             | Smart-colors system   |
| Dependencies      | i3lock-color, imagemagick | hyprlock, imagemagick |
| Login box         | Custom rendering          | Hyprlock built-in     |

## Troubleshooting

### Lockscreen doesn't show colors

Ensure smart-colors cache exists:

```bash
horneroctl appearance colors status
horneroctl wallpaper reload --yes
```

### Images not generating

Check ImageMagick installation:

```bash
magick --version
# or
convert --version
```

### Hyprlock not found

Install hyprlock:

```bash
yay -S hyprlock
```

### Lock command fails

Regenerate the hyprlock colors from the active scheme first:

```bash
horneroctl appearance hyprlock --yes
```

## Dependencies

- `hyprlock` (required)
- `imagemagick` (required)
- `jq` (for resolution detection)
- `hyprctl` (for Hyprland display info)

## Files

- Command: `horneroctl power lock --yes`
- Cache: `~/.cache/dots-lockscreen/current/` (legacy effect images)
- Current wallpaper pointer: `~/.local/state/dots/wallpaper/path`
- Smart colors: `~/.cache/dots/smart-colors/current.env`

## See Also

- [Smart Colors System](Smart-Colors-System.md)
- [Appearance Themes](Rice-System-Theme-Management.md)
- [Hyprland Setup](../Hyprland-Setup.md)
