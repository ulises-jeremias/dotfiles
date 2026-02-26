# Color Audit - Smart Colors Migration Status

## Overview

This audit tracks migration from hardcoded UI colors to the Smart Colors system across HorneroConfig.

## Audit Date

2026-02-23

## Current Status

### 1) Rofi

**Location**: `home/dot_config/rofi/`

- `apps.rasi`: ✅ migrated to tokenized colors
- `riceselector.rasi`: ✅ migrated to tokenized colors
- `riceselector-enhanced.rasi`: ⚠️ still uses some static `rgba(...)` overlays

**Runtime integration**:
- `dots-wal-reload` now prefers `~/.cache/dots/smart-colors/colors-rofi.rasi`
- Falls back to pywal rofi colors if smart-colors output is unavailable

### 2) Kitty

**Location**: `home/dot_config/kitty/kitty.conf`

- ✅ `kitty.conf` includes `~/.cache/dots/smart-colors/colors-kitty.conf`
- ✅ `dots-smart-colors --generate` emits `colors-kitty.conf`
- ✅ `dots-wal-reload` applies smart kitty colors first, then pywal fallback

### 3) Waybar

**Location**: `home/dot_config/waybar/`

- ✅ Calendar hardcoded hex values removed from profile JSON files (default/top + profile variants)
- ✅ Profile palette aliases migrated to smart token mappings in:
  - `configs/retro-wave/style.css.tmpl`
  - `configs/cozy-minimal/style.css.tmpl`
  - `configs/floating-neon/style.css.tmpl`
- ✅ `dots-wal-reload` links smart `colors-waybar.css` into all Waybar profile directories

**Remaining debt**:
- Some profile-specific aesthetic `rgba(...)` overlays are intentionally retained

### 4) EWW

**Location**: `home/dot_config/eww/`

- ✅ Dashboard hardcoded hex values reduced and replaced with semantic tokens in key sections
- ⚠️ Some non-critical style surfaces may still use static `rgba(...)` overlays for profile identity

### 5) Hyprland / Mako

- Hyprland: ✅ smart-colors integrated
- Mako: ✅ smart-colors output generated and integration paths present

## Remaining Migration Priorities

### Priority 1 (High)

- Tokenize `riceselector-enhanced.rasi` static `rgba(...)` overlays while preserving UX identity.

### Priority 2 (Medium)

- Continue reducing profile-specific static `rgba(...)` values in Waybar/EWW where they impact theme consistency.

### Priority 3 (Low)

- Keep selective static accents only where they are intentionally part of profile branding, and document those exceptions.

## Validation Checklist

- Run smart-colors generation:
  - `dots-smart-colors --generate`
- Reload app colors:
  - `dots-wal-reload`
- Verify script standards:
  - `./scripts/validate-dots-scripts.sh`

## References

- [Smart Colors Documentation](wiki/Smart-Colors-System.md)
- [Development Standards](Development-Standards.md)
- [System Architecture](System-Architecture.md)# Color Audit - Hardcoded Colors Migration Plan

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
2026-02-23
**Location**: `home/dot_config/kitty/kitty.conf`

**Status**: ✅ Migrated

**Completed**:
- Replaced hardcoded hex literals with tokenized values from `colors.rasi`
- Runtime pipeline now prioritizes `~/.cache/dots/smart-colors/colors-rofi.rasi`

**Status**: ✅ Migrated

**Completed**:
- Replaced hardcoded overlay hex with tokenized background
3. Reference pywal colors or smart-colors variables
**Status**: ⚠️ Pending

**Remaining Debt**:
- Uses static `rgba(...)` values for overlays and surfaces

**Migration Priority**: Medium
**Notes**: Keep profile identity, but map rgba overlays to semantic token-based equivalents.
**Status**: ✅ Already using smart-colors
**Status**: ✅ Migrated

**Completed**:
1. `kitty.conf` now includes `~/.cache/dots/smart-colors/colors-kitty.conf`
2. `dots-smart-colors --generate` emits `colors-kitty.conf`
3. `dots-wal-reload` now prefers smart kitty colors with pywal fallback

**Notes**: Static palette remains as fallback values in config, but smart-colors is now first-class.
### 5. EWW Widgets
**Status**: ✅ In Progress (major debt reduced)
**Completed**:
- Calendar hardcoded hex values removed from default/top and profile configs
- Profile color aliases migrated to smart tokens in `retro-wave`, `cozy-minimal`, and `floating-neon`
- `dots-wal-reload` now links smart `colors-waybar.css` into all profile directories

**Remaining Debt**:
- Some intentionally profile-specific `rgba(...)` aesthetic overlays remain
**Location**: `home/dot_config/eww/`
**Status**: ✅ In Progress
**Completed**:
- Replaced key hardcoded dashboard hex colors with semantic smart tokens (`$error`, `$info`, `$foreground`, `$background-alt`)

**Remaining Debt**:
- Additional profile/style files may still contain non-tokenized `rgba(...)` stylistic values
**Status**: ✅ Already using smart-colors
### Priority 1: Rofi Enhanced Theme (High)

**Rationale**: Main Rofi themes are migrated; `riceselector-enhanced.rasi` still has static overlays.

**Location**: `home/dot_config/mako/`
1. Replace static `rgba(...)` overlays with semantic tokenized values
2. Keep opacity behavior while sourcing base colors from smart tokens
3. Validate readability in light/dark palettes
## Migration Recommendations
### Priority 2: Waybar & EWW Residual `rgba(...)` Debt (Medium)
include ~/.cache/dots/smart-colors/colors-kitty.conf
**Rationale**: Hex debt is largely removed; remaining effort is normalizing static rgba overlays where appropriate.
# Generated colors-kitty.conf would contain:
foreground ${COLOR_FOREGROUND}
1. Audit remaining profile-specific overlays in Waybar/EWW
2. Convert to token+opacity equivalents where visual identity is preserved
3. Keep explicit exceptions documented for intentionally static brand accents
```
### Priority 2: Rofi Themes (Medium)
**Rationale**: This document and related wiki pages should match current implementation state.
**Rationale**: Application launcher is visible frequently, but less critical than terminal.

- Update examples to token-first configuration
- Remove obsolete hardcoded-line references that are already fixed
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
