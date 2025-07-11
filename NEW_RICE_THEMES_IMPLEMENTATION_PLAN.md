# New Rice Themes Implementation Plan

## Overview

This document outlines the implementation plan for adding five new rice themes to the dotfiles configuration: **Dracula**, **Tokyo Night**, **Catppuccin**, **Nord**, and **Rosé Pine**. Each theme will include custom Polybar layouts, wallpapers, and color schemes integrated with the existing rice system architecture.

## Current Architecture Analysis

### Existing Rice System Structure

- **Location**: `~/.local/share/dots/rices/`
- **Current Themes**: arcane, flowers, gruvbox, landscape-dark, landscape-light, machines, red-blue, space
- **Components per rice**:
  - `config.sh` - Polybar configuration selection
  - `apply.sh` - Theme application script
  - `backgrounds/` - Wallpaper directory
  - `preview.png` - Theme preview image

### Existing Polybar Configuration

- **Location**: `~/.config/polybar/`
- **Bar Types**:
  - `polybar-top` / `polybar-bottom` (for general WMs)
  - `i3-polybar-top` / `i3-polybar-bottom` (for i3)
- **Current Layouts**:
  - Top bar: `jgmenu dots apps sep window_switch sep rices dots pipewire-microphone sep pipewire-bar sep backlight-acpi-bar | date-popup weather | night-mode sep feh-blur-toggle sep github dots tray`
  - Bottom bar: `workspaces-with-icons | player sep playing | keyboard dots filesystem sep memory sep cpu sep temperature`

## Implementation Plan

### Phase 1: Theme Research and Asset Collection

#### 1.1 Dracula Theme

- **Aesthetic**: Dark theme with purple/magenta accents
- **Color Palette**:
  - Background: `#282A36`
  - Foreground: `#F8F8F2`
  - Primary: `#BD93F9` (purple)
  - Secondary: `#FF79C6` (pink)
  - Accent colors: `#8BE9FD` (cyan), `#50FA7B` (green), `#FFB86C` (orange), `#F1FA8C` (yellow)
- **Wallpapers to source**:
  - Nocturnal cityscape with purple neon lights
  - Abstract futuristic neon design
  - Gothic night scene with purple moon
- **Polybar Layout**: Single top bar (minimalist)
  - Semi-transparent black/purple background
  - Bright accent colors for active modules
  - Clean, focused design

#### 1.2 Tokyo Night Theme

- **Aesthetic**: Dark blue/navy with electric blue and magenta accents
- **Color Palette**:
  - Background: `#1A1B26`
  - Foreground: `#C0CAF5`
  - Primary: `#7AA2F7` (blue)
  - Secondary: `#BB9AF7` (purple)
  - Accent colors: `#73DACA` (teal), `#9ECE6A` (green), `#E0AF68` (yellow), `#F7768E` (red)
- **Wallpapers to source**:
  - Tokyo street with neon signs
  - Urban alley with blue/pink neon
  - Tokyo skyline at night with Tokyo Tower
- **Polybar Layout**: Dual bar system
  - Top bar: System info (minimal style)
  - Bottom bar: App launcher/dock style
  - Semi-opaque blue backgrounds with electric accents

#### 1.3 Catppuccin Theme

- **Aesthetic**: Soft pastel colors, warm and cozy
- **Color Palette** (Mocha variant):
  - Background: `#1E1E2E`
  - Foreground: `#CDD6F4`
  - Primary: `#CBA6F7` (mauve)
  - Secondary: `#F5C2E7` (pink)
  - Accent colors: `#94E2D5` (teal), `#A6E3A1` (green), `#F9E2AF` (yellow), `#FAB387` (peach)
- **Wallpapers to source**:
  - Pastel sunrise/sunset sky
  - Minimal abstract pastel geometric patterns
  - Soft-focus flower photography in pastel tones
- **Polybar Layout**: Vertical sidebar (left side)
  - Translucent warm brown background
  - Circular/rounded design elements
  - Pastel accent colors for active states

#### 1.4 Nord Theme

- **Aesthetic**: Arctic-inspired cool blues and grays
- **Color Palette**:
  - Background: `#2E3440`
  - Foreground: `#D8DEE9`
  - Primary: `#88C0D0` (frost blue)
  - Secondary: `#81A1C1` (light blue)
  - Accent colors: `#8FBCBB` (cyan), `#A3BE8C` (green), `#EBCB8B` (yellow), `#D08770` (orange)
- **Wallpapers to source**:
  - Aurora borealis over arctic landscape
  - Minimalist iceberg/glacier scene
  - Nordic mountain landscape with snow
- **Polybar Layout**: Single top bar (transparent)
  - Glass-frosted appearance with blur effect
  - Subtle blue-gray background
  - Clean, minimal module layout
  - Arctic-inspired iconography

#### 1.5 Rosé Pine Theme

- **Aesthetic**: Vintage romantic with muted rose and pine tones
- **Color Palette**:
  - Background: `#191724`
  - Foreground: `#E0DEF4`
  - Primary: `#EB6F92` (love/rose)
  - Secondary: `#F6C177` (gold)
  - Accent colors: `#9CCFD8` (foam), `#C4A7E7` (iris), `#EBBCBA` (rose)
- **Wallpapers to source**:
  - Warm minimalist interior with vintage furniture
  - Subtle nature scene with muted tones
  - Abstract vintage art patterns
- **Polybar Layout**: Bottom dock-style bar
  - Centered floating bar with rounded corners
  - Pine-brown semi-opaque background
  - Elegant serif fonts or refined minimal design
  - Rose/gold accent highlights

### Phase 2: Polybar Layout Implementation

#### 2.1 Create New Bar Configurations

**Files to create:**

```
~/.config/polybar/bars/
├── dracula-top.conf
├── tokyo-night-top.conf
├── tokyo-night-bottom.conf
├── catppuccin-sidebar.conf
├── nord-top.conf
├── rose-pine-bottom.conf
└── rose-pine-bottom-dock.conf
```

#### 2.2 Dracula Bar Configuration

- **Type**: Single top bar
- **Features**:
  - Semi-transparent background with purple tint
  - Bright colorful modules using Dracula palette
  - Minimal module selection to maintain focus
- **Modules**: `jgmenu | workspace-info date-popup | system-controls tray`

#### 2.3 Tokyo Night Dual Bar System

- **Top Bar**:
  - System information (time, weather, notifications)
  - Blue-navy background with electric blue accents
- **Bottom Bar**:
  - Workspace navigation and app launcher
  - Media controls and system resources
  - Complementary styling to top bar

#### 2.4 Catppuccin Vertical Sidebar

- **Position**: Left side vertical bar
- **Features**:
  - Warm translucent background
  - Circular/rounded module design
  - Pastel color highlights
  - Coffee shop aesthetic elements

#### 2.5 Nord Minimal Top Bar

- **Features**:
  - Glass-frosted appearance
  - Minimal module count
  - Arctic blue color scheme
  - Subtle transparency effects

#### 2.6 Rosé Pine Dock Bar

- **Position**: Bottom center (floating dock style)
- **Features**:
  - Rounded corners
  - Vintage-inspired typography
  - Rose and gold accent colors
  - Centered module layout

### Phase 3: Rice Directory Structure Creation

#### 3.1 Directory Creation

For each theme, create:

```
~/.local/share/dots/rices/{theme-name}/
├── config.sh
├── apply.sh
├── backgrounds/
│   ├── wallpaper-1.{jpg|png}
│   ├── wallpaper-2.{jpg|png}
│   └── wallpaper-3.{jpg|png}
└── preview.png
```

#### 3.2 Config.sh Templates

Each theme's `config.sh` should specify appropriate bar combinations:

**Dracula**:

```bash
POLYBARS=("dracula-top")
if [ "${WM}" = "i3" ]; then
  POLYBARS=("i3-dracula-top")
fi
```

**Tokyo Night**:

```bash
POLYBARS=("tokyo-night-top" "tokyo-night-bottom")
if [ "${WM}" = "i3" ]; then
  POLYBARS=("i3-tokyo-night-top" "i3-tokyo-night-bottom")
fi
```

**Catppuccin**:

```bash
POLYBARS=("catppuccin-sidebar")
if [ "${WM}" = "i3" ]; then
  POLYBARS=("i3-catppuccin-sidebar")
fi
```

**Nord**:

```bash
POLYBARS=("nord-top")
if [ "${WM}" = "i3" ]; then
  POLYBARS=("i3-nord-top")
fi
```

**Rosé Pine**:

```bash
POLYBARS=("rose-pine-bottom-dock")
if [ "${WM}" = "i3" ]; then
  POLYBARS=("i3-rose-pine-bottom-dock")
fi
```

### Phase 4: Wallpaper Integration and Color Scheme Setup

#### 4.1 Wallpaper Sourcing Strategy

- Use Creative Commons or public domain images from Unsplash
- Ensure proper licensing documentation
- Create consistent naming convention: `{theme}-{descriptor}-{number}.{ext}`
- Optimize images for common resolutions (1920x1080, 2560x1440, 3840x2160)

#### 4.2 Pywal Integration

- Ensure each theme's `apply.sh` properly integrates with wpg/pywal
- Test color generation from wallpapers
- Create fallback color schemes if automatic generation doesn't match theme

#### 4.3 Color Scheme Testing

- Verify colors work across all modules
- Test readability and contrast
- Ensure consistency with theme aesthetic

### Phase 5: Module Customization and Theme-Specific Adjustments

#### 5.1 Create Theme-Specific Module Variants

Some modules may need theme-specific styling:

```
~/.config/polybar/modules/
├── dracula/
├── tokyo-night/
├── catppuccin/
├── nord/
└── rose-pine/
```

#### 5.2 Icon and Font Considerations

- Ensure Nerd Fonts compatibility
- Test icon visibility against theme backgrounds
- Consider theme-appropriate icon choices

#### 5.3 EWW Integration

Update EWW configurations to support new themes:

- Dashboard styling adjustments
- Powermenu theme variants
- Color variable integration

### Phase 6: Testing and Quality Assurance

#### 6.1 Functionality Testing

- [ ] Test rice switching via `dots rofi-rice-selector`
- [ ] Verify Polybar layout rendering
- [ ] Test wallpaper application
- [ ] Verify color scheme propagation
- [ ] Test module functionality

#### 6.2 Visual Consistency Testing

- [ ] Screenshot generation for documentation
- [ ] Cross-application theme consistency
- [ ] Monitor multi-monitor setups
- [ ] Test with different window managers

#### 6.3 Performance Testing

- [ ] Polybar startup time
- [ ] Resource usage assessment
- [ ] Theme switching speed

### Phase 7: Documentation and Integration

#### 7.1 Update Documentation

- [ ] Add theme descriptions to wiki
- [ ] Update rice selector documentation
- [ ] Create theme-specific customization guides
- [ ] Update main README with new themes

#### 7.2 Preview Generation

- [ ] Create preview images for rofi selector
- [ ] Generate screenshots for documentation
- [ ] Create theme comparison gallery

#### 7.3 Integration with Existing Systems

- [ ] Update rice selector to include new themes
- [ ] Verify chezmoi integration
- [ ] Test backup and restore functionality

## Implementation Timeline

### Week 1: Research and Planning

- Finalize color palettes
- Source and prepare wallpapers
- Create detailed bar layout specifications

### Week 2: Polybar Configuration

- Implement all bar configurations
- Create theme-specific modules
- Test basic functionality

### Week 3: Rice System Integration

- Create rice directories and configurations
- Implement apply scripts
- Test theme switching

### Week 4: Testing and Refinement

- Comprehensive testing across different scenarios
- Visual consistency improvements
- Performance optimization

### Week 5: Documentation and Polish

- Complete documentation updates
- Generate preview images
- Final quality assurance

## Success Criteria

1. **Functional Requirements**:

   - All five themes switch successfully via rice selector
   - Polybar layouts render correctly on different screen sizes
   - Color schemes propagate consistently across all applications
   - Wallpapers apply correctly with proper color generation

2. **Visual Requirements**:

   - Each theme maintains its aesthetic identity
   - Polybar layouts match the described design intentions
   - Readability and usability are maintained across all themes
   - Smooth visual transitions between themes

3. **Performance Requirements**:

   - Theme switching completes within 5 seconds
   - No significant impact on system resources
   - Stable operation across multiple theme switches

4. **Integration Requirements**:
   - Seamless integration with existing dotfiles workflow
   - Compatibility with both Openbox and i3 window managers
   - Proper chezmoi integration for version control

## Risk Mitigation

### Potential Issues and Solutions

1. **Color Scheme Conflicts**:

   - Solution: Thorough testing with wpg/pywal color generation
   - Fallback: Manual color scheme definitions

2. **Polybar Layout Issues**:

   - Solution: Progressive testing with incremental complexity
   - Fallback: Simplified layouts that maintain theme identity

3. **Wallpaper Licensing**:

   - Solution: Use only CC0 or properly licensed images
   - Fallback: Generate abstract wallpapers programmatically

4. **Performance Impact**:
   - Solution: Monitor resource usage during development
   - Fallback: Optimize module configurations and reduce complexity

## Conclusion

This implementation plan provides a comprehensive roadmap for adding five distinctive rice themes to the dotfiles configuration. Each theme offers a unique aesthetic experience while maintaining consistency with the existing architecture. The phased approach ensures systematic development and thorough testing, resulting in a polished and reliable theming system that expands the visual customization options for users.

The plan emphasizes maintaining the existing dotfiles philosophy of modularity, ease of use, and visual excellence while introducing exciting new aesthetic options that cater to different user preferences and moods.
