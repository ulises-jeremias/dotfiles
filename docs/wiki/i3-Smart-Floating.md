# 🪟 i3: Smart Floating Windows

The **Smart Floating** system provides intelligent window management that automatically optimizes floating window size and positioning for better user experience.

> [!TIP]
> Instead of manually resizing and centering floating windows every time, smart floating does it automatically with perfect sizing based on your screen dimensions.

---

## 📋 Overview

### What Smart Floating Solves

Traditional i3 floating mode often results in:

- **Poor window sizing**: Windows float at their original tiled size
- **Manual repositioning**: Need to manually center and resize each time
- **Inconsistent experience**: No standardized floating window behavior
- **Workflow interruption**: Breaking focus to adjust window layout

Smart floating automatically solves these issues by:

- **Intelligent sizing**: Automatically calculates optimal window dimensions
- **Perfect centering**: Windows are automatically positioned in screen center
- **Screen-aware**: Adapts to different screen sizes and resolutions
- **Consistent behavior**: Same experience across all applications

---

## 🎯 Key Features

### 🚀 **Smart Toggle (`$Mod+Shift+F`)**

A single keybind that intelligently handles floating mode:

**From Tiled → Floating:**

- ✨ Converts window to floating mode
- 📏 Automatically resizes to comfortable dimensions (70% width, 65% height)
- 🎯 Centers window perfectly on screen
- ✅ Respects minimum/maximum size limits

**From Floating → Tiled:**

- 🔄 Simply returns window to tiled mode
- 🎨 Maintains i3's default tiling behavior

### 📐 **Intelligent Sizing Algorithm**

```bash
# Calculates optimal size based on screen dimensions
width = screen_width × 70%
height = screen_height × 65%

# With safety constraints
minimum: 600×400 pixels
maximum: 1400×900 pixels
```

### 🎛️ **Default Floating Constraints**

All floating windows respect global size limits:

```ini
floating_minimum_size 400 x 300
floating_maximum_size 1400 x 900
```

---

## ⌨️ Keybindings

| Keybind            | Action              | Description                                       |
| ------------------ | ------------------- | ------------------------------------------------- |
| `$Mod+Space`       | **Standard Toggle** | Original i3 floating toggle (no auto-sizing)      |
| `$Mod+Shift+F`     | **🆕 Smart Toggle** | Intelligent toggle with auto-resize and centering |
| `$Mod+Shift+Space` | **Focus Toggle**    | Switch focus between tiling/floating areas        |

### Usage Examples

```bash
# Toggle floating with smart sizing
Super + Shift + F

# Standard floating toggle (no smart features)
Super + Space

# Move floating window manually
Super + Mouse drag

# Resize floating window manually
Super + Right-click drag
```

---

## 🔧 Technical Implementation

### Smart Floating Script

The system uses an intelligent script (`~/.config/i3/smart-float.sh`) that:

1. **Detects current window state** using i3's JSON API
2. **Calculates optimal dimensions** based on screen resolution
3. **Applies size constraints** to ensure usability
4. **Centers window** using i3's positioning commands

### Screen Adaptation

**Multiple Monitor Support:**

- Automatically detects current monitor dimensions
- Calculates optimal size for each screen independently
- Maintains consistent proportions across different resolutions

**Resolution Examples:**

| Screen Resolution | Smart Window Size | Percentage                 |
| ----------------- | ----------------- | -------------------------- |
| 1920×1080         | 1344×702          | 70% × 65%                  |
| 2560×1440         | 1400×900          | Limited by max constraints |
| 1366×768          | 956×499           | 70% × 65%                  |

---

## 🎨 Configuration

### Window Manager Settings

Smart floating works with existing i3 configuration:

```ini
# Smart floating: toggle floating + center + resize to comfortable size
bindsym $Mod+Shift+f exec --no-startup-id ~/.config/i3/smart-float.sh

# Default floating window size constraints
floating_minimum_size 400 x 300
floating_maximum_size 1400 x 900

# Use Mouse+$mod to drag floating windows
floating_modifier $mod
```

### Size Customization

To modify the default sizing behavior, edit the smart-float script:

```bash
# Custom sizing percentages
width=$((WIDTH * 80 / 100))    # 80% instead of 70%
height=$((HEIGHT * 70 / 100))  # 70% instead of 65%

# Custom size limits
[[ $width -lt 800 ]] && width=800     # Larger minimum
[[ $width -gt 1600 ]] && width=1600   # Larger maximum
```

---

## 🔄 Workflow Integration

### Common Usage Patterns

**Quick Application Focus:**

```text
1. Launch application (Super+Return for terminal)
2. Use Smart Float (Super+Shift+F) for focused work
3. Application automatically sized and centered
4. Return to tiling (Super+Shift+F) when done
```

**Multi-Window Setup:**

```text
1. Keep main work in tiling mode
2. Float secondary applications (calculator, notes)
3. Smart sizing ensures consistent overlay experience
4. Easy switching between modes
```

**Presentation Mode:**

```text
1. Float presentation application
2. Automatic centering for optimal viewing
3. Consistent sizing across different projectors
4. Quick return to desktop layout
```

---

## 🎯 Best Practices

### When to Use Smart Floating

**✅ Ideal Use Cases:**

- **Calculator applications**: Perfect for quick calculations
- **Note-taking apps**: Overlay notes while reading
- **Media players**: Video players and music controls
- **System utilities**: Settings panels and configuration tools
- **Terminal sessions**: Quick command execution

**⚠️ Consider Standard Tiling For:**

- **Primary work applications**: Code editors, browsers
- **Document editing**: Full-screen writing and editing
- **Multitasking workflows**: Multiple applications side-by-side

### Window Management Tips

**Maximize Efficiency:**

- Use smart floating for temporary/utility applications
- Reserve tiling for primary productivity applications
- Combine with scratchpad for frequently accessed tools
- Use focus toggle to quickly switch context

**Avoid Common Pitfalls:**

- Don't float too many windows simultaneously
- Remember smart sizing works best for utility applications
- Use manual resize when specific dimensions are needed

---

## 🛠️ Troubleshooting

### Common Issues

**Smart float not working:**

```bash
# Check if script exists and is executable
ls -la ~/.config/i3/smart-float.sh

# Test script manually
bash ~/.config/i3/smart-float.sh

# Reload i3 configuration
i3-msg reload
```

**Wrong window dimensions:**

```bash
# Check screen detection
xdotool getdisplaygeometry

# Verify i3 can resize windows
i3-msg "resize set 800 600"

# Test manual positioning
i3-msg "move position center"
```

**Script errors:**

```bash
# Check dependencies
command -v xdotool
command -v jq

# Check i3 API access
i3-msg -t get_tree | jq '.. | select(.focused? == true)'
```

### Performance Optimization

**Reduce Script Execution Time:**

- Cache screen dimensions for better performance
- Use faster JSON parsing if available
- Optimize i3-msg command sequence

**System Integration:**

- Ensure xdotool is installed for screen detection
- Verify jq is available for JSON parsing
- Test with different window managers if needed

---

## ✅ Integration

### Works With

- ✅ **All window managers**: Primarily designed for i3
- ✅ **Multi-monitor setups**: Automatic per-monitor optimization
- ✅ **All application types**: Universal window management
- ✅ **Rice switching**: Maintains behavior across themes

### Pairs Well With

- **Scratchpad functionality**: Quick access to floating utilities
- **i3 layouts**: Complement existing workspace management
- **Application-specific rules**: Custom floating behaviors per app

---

## 🚀 Future Enhancements

### Planned Features

- **Application-specific sizing**: Custom dimensions per application type
- **Saved positions**: Remember window positions for specific apps
- **Smart tiling return**: Intelligent placement when returning to tiled mode
- **Animation support**: Smooth transitions between states

### Customization Opportunities

- **Profile-based sizing**: Different size profiles for different workflows
- **Hot corners**: Screen edge triggers for floating mode
- **Gesture support**: Touch/trackpad gestures for window management

---

Enjoy effortless floating window management that adapts to your screen and workflow! 🚀

> [!TIP]
> Try using `Super+Shift+F` instead of `Super+Space` for a week - you'll never go back to manual window positioning!
