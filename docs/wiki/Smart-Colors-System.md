# 🎨 Smart Colors System

The smart colors system provides **theme-adaptive color selection** that automatically finds the best colors for different concepts (error, success, info, etc.) from any color palette, ensuring optimal readability and visual hierarchy regardless of your current theme.

> [!TIP]
> Instead of hardcoded colors that may not work well with all themes, smart colors **intelligently analyze** your current palette and select the most appropriate colors for each semantic concept.

---

## 📋 Overview

### What Smart Colors Solve

Traditional theming approaches often suffer from:

- **Poor contrast** in certain color palettes
- **Hardcoded colors** that don't adapt to themes
- **Semantic inconsistency** (e.g., "error" colors that aren't red-ish)
- **Manual configuration** for each theme

Smart colors automatically solve these issues by:

- **Analyzing your palette** using color science algorithms
- **Finding optimal colors** for each concept from available colors
- **Providing semantic fallbacks** when ideal colors aren't available
- **Integrating seamlessly** with existing applications

---

## 🧠 How It Works

### Color Analysis Algorithm

```bash
# Analyze your current palette
dots-smart-colors --analyze
```

The system uses **euclidean distance calculations** in RGB color space to find the closest available color to ideal target colors:

- **Error/Danger**: Targets pure red (255,0,0)
- **Warning**: Targets orange (255,165,0)
- **Success**: Targets green (0,255,0)
- **Info**: Targets blue (0,100,255)
- **Accent**: Targets purple/violet (128,0,255)

### Smart Selection Process

1. **Preference-based selection**: Uses predefined color preferences based on Base16 standards
2. **Distance calculation**: If preferences fail, calculates color distances to find best match
3. **Fallback system**: Always provides a valid color even in limited palettes

---

## 🚀 Available Tools

### `dots-smart-colors` Command

#### Basic Usage

```bash
# Quick palette analysis
dots-smart-colors

# Detailed analysis with recommendations
dots-smart-colors --analyze

# Get specific color
dots-smart-colors --concept=error
dots-smart-colors --concept=blue --format=polybar
```

#### Export Formats

**Shell Environment Variables:**

```bash
# Export for shell/scripts
dots-smart-colors --export
eval "$(dots-smart-colors --export)"
```

**Polybar Integration:**

```bash
# Get polybar-format colors
dots-smart-colors --concept=success --format=polybar
# Output: ${xrdb:color10}
```

**EWW SCSS Generation:**

```bash
# Generate complete EWW color file
dots-smart-colors --export --format=eww > ~/.config/eww/dashboard/colors.scss
```

**i3 Configuration:**

```bash
# Generate i3 color variables
dots-smart-colors --export --format=i3 > ~/.config/i3/colors-smart.conf
```

#### Supported Concepts

**Semantic Colors:**

- `error`, `warning`, `success`, `info`, `accent`

**Basic Colors:**

- `red`, `green`, `blue`, `yellow`, `cyan`, `magenta`, `orange`, `pink`, `brown`, `white`, `black`, `gray`

---

## 🔄 Automatic Integration

### Wal-Reload Integration

Smart colors are **automatically applied** when you change wallpapers via `wpg`:

```mermaid
graph LR
    A[wpg wallpaper change] --> B[wal-reload]
    B --> C[pywal generation]
    C --> D[smart-colors analysis]
    D --> E[EWW colors.scss]
    D --> F[polybar environment]
    D --> G[i3 colors-smart.conf]
    E --> H[EWW restart]
    F --> I[polybar restart]
```

**No manual configuration needed!**

### What Gets Updated Automatically

**EWW Widgets:**

- Replaces pywal symlinks with smart-generated `colors.scss`
- Includes semantic variables (`$smart-error`, `$smart-success`)
- Maintains compatibility with existing configs

**Polybar:**

- Exports smart colors to environment variables
- All modules automatically use optimal colors
- Automatic restart to apply new colors

**i3 Window Manager:**

- Generates `~/.config/i3/colors-smart.conf`
- Provides smart color variables for window theming
- Include with: `include ~/.config/i3/colors-smart.conf`

**Scripts:**

- All polybar scripts use smart colors when available
- Fallback to xrdb if smart colors not available

---

## 🎯 Usage Examples

### Polybar Module Development

```ini
[module/my-module]
type = internal/cpu
format-prefix-foreground = ${colors.accent}    # Smart accent color
label-foreground = ${colors.info}              # Smart info color
format-warn-foreground = ${colors.warning}     # Smart warning color
```

### EWW Widget Styling

```scss
@import "colors.scss";

.error-button {
  background-color: $smart-error; // Always optimal error color
}

.success-message {
  color: $smart-success; // Always optimal success color
}

.info-text {
  color: $smart-info; // Always optimal info color
}
```

### Shell Scripts

```bash
#!/bin/bash
# Load smart colors
eval "$(dots-smart-colors --export)"

echo -e "\\033[${SMART_COLOR_ERROR}mError message\\033[0m"
echo -e "\\033[${SMART_COLOR_SUCCESS}mSuccess message\\033[0m"
```

### i3 Configuration

```ini
# Include smart colors
include ~/.config/i3/colors-smart.conf

# Use smart colors in window theming
client.focused          $smart_accent  $smart_accent  $background     $smart_info    $smart_accent
client.urgent           $smart_error   $smart_error   $background     $smart_error   $smart_error
```

---

## 🔧 Advanced Configuration

### Environment Variables

You can override smart colors for specific applications:

```bash
export POLYBAR_THEME_ACCENT="#ff0000"      # Force specific accent color
export POLYBAR_THEME_SUCCESS="#00ff00"     # Force specific success color
```

### Custom Color Mappings

Smart colors work with any Base16-compatible color scheme and automatically adapt to:

- **Dark themes**: Prioritizes lighter colors for text
- **Light themes**: Prioritizes darker colors for text
- **High contrast themes**: Maximizes color differences
- **Limited palettes**: Finds best available approximations

---

## 🐛 Troubleshooting

### Common Issues

**Smart colors not applying:**

```bash
# Check if dots-smart-colors is available
which dots-smart-colors

# Test smart color generation
dots-smart-colors --analyze
```

**Polybar not using smart colors:**

```bash
# Check if environment variables are set
env | grep SMART_COLOR

# Manually apply and restart polybar
eval "$(dots-smart-colors --export)"
dots toggle polybar
```

**EWW widgets using old colors:**

```bash
# Check if colors.scss exists and is not a symlink
ls -la ~/.config/eww/dashboard/colors.scss

# Manually regenerate
dots-smart-colors --export --format=eww > ~/.config/eww/dashboard/colors.scss
eww reload
```

### Debug Mode

```bash
# Verbose analysis
dots-smart-colors --analyze --verbose

# Check what would be applied without changing anything
dots-wal-reload --dry-run  # (if implemented)
```

---

## 📚 Related Documentation

- [Rice System Theme Management](Rice-System-Theme-Management.md) - Complete theme switching
- [Polybar Configuration Structure](Polybar-Configuration-Structure.md) - Polybar color system
- [EWW Widgets](EWW-Widgets.md) - EWW theming integration
- [Dots Scripts](Dots-Scripts.md) - Available dots commands
