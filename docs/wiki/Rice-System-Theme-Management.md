# 🎨 Rice System: Theme Management

The rice system provides a comprehensive theme management solution that allows you to switch between different desktop aesthetics with a single command.

> [!TIP]
> "Rice" is a term from the Linux customization community meaning to customize and theme your desktop environment. Each rice is a complete visual theme that transforms your entire desktop experience.

---

## 📋 Overview

The rice system manages:

- **Complete desktop themes** with coordinated colors and wallpapers
- **Polybar configurations** specific to each theme
- **Application theming** via pywal color generation
- **Window manager integration** (i3, Openbox, XFCE4)
- **Automatic wallpaper and color coordination**

### Current Available Rices

Your dotfiles include these beautiful rice themes:

- **arcane**: Magical purple and blue mystical theme
- **flowers**: Vibrant floral-inspired nature theme
- **gruvbox**: Retro warm colors with vintage aesthetics
- **landscape-dark**: Dark nature-inspired earth tones
- **landscape-light**: Light variant with natural colors
- **machines**: Cyberpunk industrial technology theme
- **red-blue**: High contrast red and blue color scheme
- **space**: Cosmic theme with deep blues and starry aesthetics

---

## 🎨 Smart Colors Integration

### Automatic Color Optimization

When you switch rice themes, the system now automatically applies **smart color optimization**:

```bash
# Theme switching process:
# 1. Apply rice theme → 2. Generate pywal colors → 3. Apply smart colors → 4. Update applications
dots rofi-rice-selector
```

### What Gets Optimized

**🧠 Intelligent Color Selection:**

- **Error colors**: Always red-ish and high contrast
- **Success colors**: Always green-ish and visible
- **Warning colors**: Always orange/yellow-ish
- **Info colors**: Always blue-ish and readable
- **Accent colors**: Always purple/highlight colors

**🔄 Automatic Application Updates:**

- **EWW widgets**: Enhanced `colors.scss` with semantic variables
- **Polybar modules**: Smart environment variables
- **i3 window manager**: Generated `colors-smart.conf`
- **Scripts**: Weather, player, and other polybar scripts

### Smart Colors vs Pywal

| Feature          | Pywal Only           | Smart Colors           |
| ---------------- | -------------------- | ---------------------- |
| Color extraction | ✅ From wallpaper    | ✅ From wallpaper      |
| Semantic meaning | ❌ Random assignment | ✅ Intelligent mapping |
| Readability      | ⚠️ Sometimes poor    | ✅ Always optimized    |
| Theme adaptation | ⚠️ Basic             | ✅ Advanced            |
| Fallback system  | ❌ None              | ✅ Robust              |

---

## 🔄 Rice Switching

### Quick Switch with Rofi

The fastest way to change themes is using the visual rice selector:

```bash
# Launch rice selector with visual previews
dots rofi-rice-selector

# Or use the keyboard shortcut (typically configured in WM)
# Default: Super + R
```

### Rice Selector Interface

The rofi rice selector provides:

- **Visual previews** of each rice theme
- **Current theme highlighting**
- **Background image selection** for chosen rice
- **Instant preview** of color schemes
- **Easy keyboard navigation**---

## 🏗️ Rice Architecture

### Directory Structure

Each rice is organized in a modular structure:

```text
~/.local/share/dots/rices/
├── arcane/
│   ├── config.sh              # Polybar configuration
│   ├── apply.sh               # Theme application script
│   ├── backgrounds/           # Wallpaper collection
│   │   ├── arcane-magic-1.jpg
│   │   ├── arcane-magic-2.jpg
│   │   └── arcane-wizard.jpg
│   └── preview.png           # Rice preview image
├── gruvbox/
│   ├── config.sh
│   ├── apply.sh
│   ├── backgrounds/
│   └── preview.png
└── [other rices...]
```

### Rice Configuration (`config.sh`)

Each rice defines its Polybar configuration:

```bash
#!/usr/bin/env bash

# Polybar bars to use for this rice
POLYBARS=("polybar-top" "polybar-bottom")

# Detect window manager and adjust bars accordingly
WM=$(wmctrl -m | grep -oE 'Name: .*' | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]')
if [ "${WM}" = "i3" ]; then
  POLYBARS=("i3-polybar-top" "i3-polybar-bottom")
fi
```

### Apply Script (`apply.sh`)

Handles the complete theme application:

```bash
#!/usr/bin/env bash

# Set wallpaper and generate colors
wpg -s "$SELECTED_BACKGROUND_IMAGE"

# Apply colors to applications
dots-wal-reload

# Restart polybar with rice-specific configuration
~/.config/polybar/launch.sh

# Additional rice-specific customizations
# (compositor settings, custom scripts, etc.)
```

---

## 🎨 Color System Integration

### Pywal Integration

The rice system integrates with pywal/wpg for automatic color generation:

1. **Wallpaper Selection**: Choose from rice-specific backgrounds
2. **Color Extraction**: Pywal generates color scheme from wallpaper
3. **Application Theming**: Colors propagate to all applications
4. **Cache Management**: Colors cached for fast theme switching

### Color Flow

```text
Wallpaper → Pywal → Color Cache → Applications
    ↓                               ↑
Rice System ← Manual Colors ← Override Files
```

### Supported Applications

Colors automatically theme:

- **Polybar**: Status bar modules and backgrounds
- **Rofi**: Application launcher and menus
- **Terminal**: Kitty, Alacritty color schemes
- **i3**: Window manager color scheme
- **EWW**: Dashboard and powermenu widgets
- **Dunst**: Notification styling
- **Zsh**: Terminal prompt colors

---

## 🎯 Rice Management

### Creating New Rices

1. **Create rice directory**:

   ```bash
   mkdir -p ~/.local/share/dots/rices/my-theme
   cd ~/.local/share/dots/rices/my-theme
   ```

2. **Add configuration**:

   ```bash
   # Create config.sh
   cat > config.sh << 'EOF'
   #!/usr/bin/env bash
   POLYBARS=("polybar-top" "polybar-bottom")
   WM=$(wmctrl -m | grep -oE 'Name: .*' | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]')
   if [ "${WM}" = "i3" ]; then
     POLYBARS=("i3-polybar-top" "i3-polybar-bottom")
   fi
   EOF
   ```

3. **Create apply script**:

   ```bash
   # Create apply.sh
   cat > apply.sh << 'EOF'
   #!/usr/bin/env bash
   wpg -s "$SELECTED_BACKGROUND_IMAGE"
   dots-wal-reload
   ~/.config/polybar/launch.sh
   EOF

   chmod +x apply.sh
   ```

4. **Add wallpapers**:

   ```bash
   mkdir backgrounds
   # Copy your wallpaper images to backgrounds/
   ```

5. **Generate preview**:

   ```bash
   # Take screenshot after applying rice
   scrot -z preview.png
   ```

### Rice Backup and Restore

```bash
# Backup current rice configuration
dots rice backup my-rice-backup

# Restore rice from backup
dots rice restore my-rice-backup

# Export rice for sharing
dots rice export my-theme rice-export.tar.gz

# Import shared rice
dots rice import rice-export.tar.gz
```

---

## 🔧 Advanced Configuration

### Custom Polybar Layouts

Create rice-specific polybar configurations:

```bash
# Create rice-specific polybar config
mkdir -p ~/.config/polybar/rices/my-theme/bars
```

Then reference in `config.sh`:

```bash
POLYBARS=("my-theme-custom-bar")
```

### Multiple Background Support

Add multiple wallpapers for variety:

```text
backgrounds/
├── morning-theme.jpg     # Different moods/times
├── evening-theme.jpg
├── minimal-variant.jpg   # Different styles
└── detailed-variant.jpg
```

### Window Manager Specific Settings

```bash
# In apply.sh - conditional customization
if [ "${WM}" = "i3" ]; then
    # i3-specific theming
    i3-msg reload
elif [ "${WM}" = "openbox" ]; then
    # Openbox-specific theming
    openbox --reconfigure
fi
```

---

## 🚨 Troubleshooting

### Common Issues

**Rice not switching**:

```bash
# Check current rice
dots rice current

# Manually apply rice
dots rice apply

# Check rice directory permissions
ls -la ~/.local/share/dots/rices/
```

**Colors not updating**:

```bash
# Force color regeneration
wpg -s /path/to/wallpaper

# Reload all applications
dots-wal-reload

# Restart desktop environment
```

**Missing rice files**:

```bash
# Verify rice structure
tree ~/.local/share/dots/rices/rice-name/

# Check for required files
ls ~/.local/share/dots/rices/rice-name/{config.sh,apply.sh}
```

### Performance Optimization

**Faster rice switching**:

```bash
# Preload color caches
for rice in ~/.local/share/dots/rices/*/; do
    echo "Preloading $(basename "$rice")..."
    dots rice set "$(basename "$rice")"
done
```

**Reduce startup time**:

- Use lightweight wallpapers (< 2MB)
- Cache generated colors
- Optimize apply scripts

---

## ✨ Rice Gallery

### Popular Combinations

**Minimal Productivity** (gruvbox):

- Warm, easy-on-eyes colors
- Clean polybar with essential modules
- Perfect for long coding sessions

**Vibrant Creative** (flowers):

- Bright, inspiring colors
- Rich visual elements
- Great for design work

**Dark Focus** (space):

- Deep blues and cosmic themes
- Minimal distractions
- Ideal for night sessions

**High Contrast** (red-blue):

- Bold, attention-grabbing colors
- Perfect for presentations
- High visibility interface

---

## ✅ Integration

### Works With

- ✅ **All window managers** (i3, Openbox, XFCE4)
- ✅ **Multiple monitors** with per-monitor wallpapers
- ✅ **Different screen resolutions**
- ✅ **Various image formats** (JPG, PNG, WebP)

### Pairs Well With

- **Polybar configurations** for status bar theming
- **EWW widgets** for dashboard coordination
- **Rofi launchers** for unified visual experience
- **Terminal themes** for complete coordination

---

Transform your desktop with beautiful, coordinated themes! 🌈

> [!TIP]
> Start with existing rices to understand the system, then create your own custom themes. The visual rice selector makes switching effortless, so experiment with different aesthetics for different moods and tasks.
