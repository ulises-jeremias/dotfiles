# Color Audit - Hardcoded Colors Migration Plan

## Overview

This document identifies hardcoded colors in configuration files that could benefit from migration to the smart-colors system for better theme consistency and adaptability.

## Audit Date

2025-01-XX

## Findings

### 1. Rofi Themes

**Location**: `home/dot_config/rofi/`

#### `apps.rasi`
- **Line 32**: `background-color: #1a1e2485;` (semi-transparent dark)
- **Line 35**: `background-color: #1a1e2480;` (semi-transparent dark)
- **Line 40**: `background-color: #f5f5f530;` (semi-transparent light)
- **Line 41**: `border-color: #f5f5f540;` (semi-transparent light border)
- **Line 58**: `placeholder-color: #f5f5f5;` (light placeholder)

**Migration Priority**: Medium
**Notes**: These colors are used for the main application launcher. Should use smart-colors background/foreground with opacity.

#### `riceselector.rasi`
- **Line 25**: `background-color: #1a1e2475;` (semi-transparent dark)

**Migration Priority**: Low
**Notes**: Rice selector theme, less frequently used.

#### `riceselector-enhanced.rasi`
- **Line 15**: `background-color: rgba(30, 30, 46, 0.95);` (dark background)
- **Line 28**: `background-color: rgba(0, 0, 0, 0.2);` (semi-transparent black)
- **Line 140**: `background-color: rgba(255, 255, 255, 0.05);` (semi-transparent white)

**Migration Priority**: Low
**Notes**: Enhanced rice selector, uses rgba format.

### 2. Kitty Terminal

**Location**: `home/dot_config/kitty/kitty.conf`

**Colors Found**:
- **Line 14**: `foreground #CBCCC6` (light gray)
- **Line 15**: `background #202734` (dark blue-gray)
- **Lines 17-32**: Full 16-color palette (color0-color15)

**Migration Priority**: High
**Notes**: Kitty supports environment variable substitution and can use colors from pywal/smart-colors. The current colors appear to be from a specific theme (possibly OneDark or similar).

**Migration Strategy**:
1. Use Kitty's `include` directive to load colors from a generated file
2. Generate `colors-kitty.conf` via `dots-smart-colors --generate`
3. Reference pywal colors or smart-colors variables

### 3. Hyprland Configuration

**Location**: `home/dot_config/hypr/`

**Status**: ✅ Already using smart-colors
**Notes**: Hyprland configs use environment variables and smart-colors integration is already implemented.

### 4. Waybar Configuration

**Location**: `home/dot_config/waybar/`

**Status**: ✅ Already using smart-colors
**Notes**: Waybar styles are generated via `dots-smart-colors` and use CSS templates with color placeholders.

### 5. EWW Widgets

**Location**: `home/dot_config/eww/`

**Status**: ✅ Already using smart-colors
**Notes**: EWW styles are generated via `dots-smart-colors` with SCSS templates.

### 6. Mako Notifications

**Location**: `home/dot_config/mako/`

**Status**: ✅ Already using smart-colors
**Notes**: Mako config uses environment variables populated by smart-colors.

## Migration Recommendations

### Priority 1: Kitty Terminal (High)

**Rationale**: Terminal is frequently used and benefits greatly from theme consistency.

**Implementation Steps**:
1. Extend `dots-smart-colors` to generate `colors-kitty.conf`
2. Update `kitty.conf` to include generated colors file
3. Map smart-colors semantic colors to Kitty's color palette
4. Test with both light and dark themes

**Example Structure**:
```conf
# In kitty.conf
include ~/.cache/dots/smart-colors/colors-kitty.conf

# Generated colors-kitty.conf would contain:
foreground ${COLOR_FOREGROUND}
background ${COLOR_BACKGROUND}
color0 ${COLOR_BLACK}
color1 ${COLOR_RED}
# ... etc
```

### Priority 2: Rofi Themes (Medium)

**Rationale**: Application launcher is visible frequently, but less critical than terminal.

**Implementation Steps**:
1. Extend `dots-smart-colors` to generate Rofi color variables
2. Update Rofi theme files to use variables instead of hardcoded colors
3. Handle opacity/transparency appropriately
4. Test with various themes

**Challenges**:
- Rofi themes use CSS-like syntax but don't support all CSS features
- Opacity handling may require rgba() format
- Need to ensure compatibility with Rofi's theme system

### Priority 3: Rice Selector Themes (Low)

**Rationale**: Less frequently used, lower priority.

**Implementation Steps**:
- Similar to Priority 2, but can be done after main Rofi themes

## Implementation Notes

### Smart-Colors Integration Points

1. **Color Generation**: Extend `dots-smart-colors --generate` to create:
   - `colors-kitty.conf`
   - `colors-rofi.sh` (environment variables)
   - Or direct theme file updates

2. **Theme Detection**: Ensure smart-colors detects light/dark themes correctly for all applications

3. **Fallback Handling**: Maintain fallback colors if smart-colors generation fails

### Testing Requirements

- Test with light themes
- Test with dark themes
- Test with various wallpaper colors
- Verify opacity/transparency rendering
- Ensure readability and contrast

## Future Considerations

- **Other Applications**: Consider auditing other applications (e.g., Alacritty, Foot) if they become part of the stack
- **Dynamic Updates**: Ensure colors update when wallpapers change via `dots-wal-reload`
- **Performance**: Monitor any performance impact of color generation

## References

- [Smart Colors Documentation](wiki/Smart-Colors-System.md)
- [Development Standards](Development-Standards.md)
- [Kitty Configuration](https://sw.kovidgoyal.net/kitty/conf.html)
- [Rofi Theme Format](https://github.com/davatorium/rofi/blob/next/doc/rofi-theme.5.markdown)

