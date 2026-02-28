# Lockscreen System

> **Wayland-native lockscreen management with hyprlock**  
> Alternative to betterlockscreen for Wayland/Hyprland environments

## Overview

`dots-lockscreen` provides a Wayland-compatible lockscreen solution using `hyprlock`. It processes wallpapers with various visual effects and integrates with the dots ecosystem's smart color system.

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
dots wal-reload
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

### EWW Powermenu

The lockscreen is integrated into the EWW powermenu:

```lisp
(defwidget lock []
  (box :class "genwin" :vexpand "false" :hexpand "false"
    (button :class "btn_lock"
            :onclick "~/.local/bin/dots-power-menu --mode=minimal; dots-lockscreen -l blur"
            "")))
```

### Wal Reload

Automatically updates lockscreen when changing themes:

```bash
dots wal-reload  # Updates wallpaper and lockscreen
```

### Rice System

Rice themes can trigger lockscreen updates in their `apply.sh`:

```bash
if command -v dots-lockscreen &>/dev/null; then
  dots-lockscreen --update="$wallpaper"
fi
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

## Rice-Style-Aware Layouts

The lockscreen automatically adapts its layout based on your current rice's `RICE_STYLE`. This provides a cohesive aesthetic experience across your entire desktop.

### Available Layouts

| Layout | Rice Styles | Description |
|--------|-------------|-------------|
| **Default** | Any unlisted style | Clean, centered layout with standard typography |
| **Cyberpunk** | cyberpunk, neon, futuristic | Glowing neon elements, tech-inspired fonts |
| **Cozy** | cozy, kawaii, cute, warm | Soft, rounded elements with pastel accents |
| **Vaporwave** | vaporwave, retro, synthwave | Gradient effects, 80s-inspired typography |
| **Minimal** | minimal, clean, productive | Ultra-clean with minimal UI elements |

### How It Works

1. When locking, the script reads `RICE_STYLE` from your current rice's `config.sh`
2. Based on the style, it selects the appropriate layout template
3. Colors are pulled from the smart-colors cache
4. The hyprlock configuration is generated dynamically

### Rice Configuration

To enable style-aware layouts, add `RICE_STYLE` to your rice's `config.sh`:

```bash
# Example for cyberpunk rice
RICE_STYLE="Cyberpunk"

# Example for cozy rice
RICE_STYLE="Cozy"
```

The style matching is case-insensitive and supports partial matches (e.g., "cozy warm" matches the Cozy layout).

## Comparison with Betterlockscreen

| Feature | betterlockscreen | dots-lockscreen |
|---------|------------------|-----------------|
| Platform | X11 (i3lock) | Wayland (hyprlock) |
| Effects | 6 effects | 4 core effects |
| Multi-monitor | Native support | Via hyprlock |
| Color integration | Manual config | Smart-colors system |
| Dependencies | i3lock-color, imagemagick | hyprlock, imagemagick |
| Login box | Custom rendering | Hyprlock built-in |

## Troubleshooting

### Lockscreen doesn't show colors

Ensure smart-colors cache exists:

```bash
dots smart-colors analyze
dots wal-reload
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

Generate lockscreen images first:

```bash
dots lockscreen --update=~/.cache/current_wallpaper
```

## Dependencies

- `hyprlock` (required)
- `imagemagick` (required)
- `jq` (for resolution detection)
- `hyprctl` (for Hyprland display info)

## Files

- Script: `~/.local/bin/dots-lockscreen`
- Cache: `~/.cache/dots-lockscreen/current/`
- Current wallpaper: `~/.cache/current_wallpaper`
- Smart colors: `~/.cache/dots/smart-colors/current.env`

## See Also

- [Smart Colors System](Smart-Colors-System.md)
- [Rice System](Rice-System-Theme-Management.md)
- [EWW Widgets](EWW-Widgets.md)
- [Hyprland Setup](../Hyprland-Setup.md)
