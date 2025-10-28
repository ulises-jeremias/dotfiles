# Lockscreen System

> **Wayland-native lockscreen management with swaylock-effects**  
> Alternative to betterlockscreen for Wayland environments

## Overview

`dots-lockscreen` provides a Wayland-compatible lockscreen solution using `swaylock-effects`. It processes wallpapers with various visual effects and integrates with the dots ecosystem's smart color system.

## Features

- **Multiple Effects**: dim, blur, dimblur, pixel
- **Smart Color Integration**: Automatically uses colors from the smart-colors system
- **Cached Images**: Pre-generates lockscreen images for instant locking
- **ImageMagick Processing**: Creates professional-looking lockscreen backgrounds
- **Graceful Fallbacks**: Falls back to base image if effect images aren't available

## Installation

The lockscreen system is automatically installed with Hyprland:

```bash
yay -S --noconfirm --needed swaylock-effects
```

For manual installation:

```bash
dots hyprland-setup
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
            :onclick "~/.config/eww/powermenu/launch.sh; dots-lockscreen -l blur"
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

## Swaylock Options

The script uses these swaylock-effects options:

```bash
swaylock \
  --image <effect-image> \
  --color <bg-color> \
  --inside-color <bg-color>99 \
  --ring-color <primary-color> \
  --key-hl-color <success-color> \
  --bs-hl-color <error-color> \
  --indicator-radius 100 \
  --indicator-thickness 7 \
  --effect-blur 7x5 \
  --effect-vignette 0.5:0.5 \
  --grace 2 \
  --fade-in 0.2
```

## Comparison with Betterlockscreen

| Feature | betterlockscreen | dots-lockscreen |
|---------|------------------|-----------------|
| Platform | X11 (i3lock) | Wayland (swaylock) |
| Effects | 6 effects | 4 core effects |
| Multi-monitor | Native support | Via swaylock |
| Color integration | Manual config | Smart-colors system |
| Dependencies | i3lock-color, imagemagick | swaylock-effects, imagemagick |
| Login box | Custom rendering | Swaylock built-in |

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

### Swaylock not found

Install swaylock-effects:

```bash
yay -S swaylock-effects
```

### Lock command fails

Generate lockscreen images first:

```bash
dots lockscreen --update=~/.cache/current_wallpaper
```

## Dependencies

- `swaylock` or `swaylock-effects` (required)
- `imagemagick` (required)
- `jq` (for resolution detection)
- `swaymsg` (for Wayland display info)

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
