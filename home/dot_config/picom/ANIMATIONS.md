# 🎨 Hyprland-Inspired Picom Animations

This document describes the comprehensive animation system implemented for your dotfiles setup.

## 🚀 Overview

The animation system provides smooth, modern transitions inspired by Hyprland while being perfectly tailored to your i3/Openbox + Polybar + EWW ecosystem.

## 📋 Animation Categories

### 🖥️ **Core Window Animations**

- **Normal Windows**: Smooth scale + fade with professional easing curves
- **Opening**: `cubic-bezier(0.05, 0.7, 0.1, 1.0)` - 0.25s duration
- **Closing**: `cubic-bezier(0.36, 0, 0.66, -0.56)` - 0.18s duration
- **Geometry**: `cubic-bezier(0.25, 0.46, 0.45, 0.94)` - 0.3s duration

### 🎯 **Application-Specific Profiles**

#### **Terminals** (Kitty/Alacritty)

- **Effect**: Slide up from bottom
- **Curve**: `cubic-bezier(0.4, 0, 0.2, 1)`
- **Duration**: 0.2s open, 0.15s close
- **Perfect for**: Quick terminal access

#### **Browsers** (Firefox/Chrome/Brave)

- **Effect**: Gentle scale + fade
- **Curve**: `cubic-bezier(0.25, 0.46, 0.45, 0.94)`
- **Duration**: 0.3s open, 0.2s close
- **Perfect for**: Large window launches

#### **Development Tools** (VS Code/JetBrains)

- **Effect**: Quick slide from top
- **Curve**: `cubic-bezier(0.16, 1, 0.3, 1)`
- **Duration**: 0.2s open, 0.15s close
- **Perfect for**: Fast IDE access

#### **Media Players** (mpv/VLC)

- **Effect**: Simple fade (no scaling)
- **Curve**: `cubic-bezier(0.4, 0, 0.6, 1)`
- **Duration**: 0.25s open, 0.2s close
- **Perfect for**: Minimal distraction

#### **File Managers** (Thunar/Nautilus)

- **Effect**: Smooth scale from center
- **Curve**: `cubic-bezier(0.25, 0.46, 0.45, 0.94)`
- **Duration**: 0.25s open, 0.18s close

### 🎛️ **UI Component Animations**

#### **Rofi Launcher**

- **Effect**: Quick scale from center
- **Opening**: Scale from 0.8 with bounce
- **Duration**: 0.15s open, 0.1s close
- **Ultra-responsive for app launching**

#### **Dunst Notifications**

- **Effect**: Slide from right edge
- **Curve**: Smooth ease curves
- **Duration**: 0.2s open, 0.15s close
- **Non-intrusive notification flow**

#### **Jgmenu**

- **Effect**: Minimal scale + fade
- **Duration**: 0.12s open, 0.08s close
- **Lightning-fast menu access**

#### **Scratchpad Windows**

- **Effect**: Drop down from top
- **Curve**: Bounce-like easing
- **Perfect for**: i3 scratchpad workflow

### 🎨 **EWW Widget Animations**

#### **Dashboard Widgets**

- **Effect**: Scale + fade with slight bounce
- **Curve**: `cubic-bezier(0.16, 1, 0.3, 1)`
- **Duration**: 0.18s open, 0.15s close

#### **Topbar**

- **Effect**: No animations (performance)
- **Optimized for**: Smooth bar experience

#### **Sidebar**

- **Effect**: Slide from left edge
- **Curve**: Professional easing with smooth deceleration
- **Duration**: 0.25s open, 0.2s close
- **95% opacity for modern look**

### 🪟 **Window Manager Specific**

#### **i3 Floating Windows**

- **Detection**: `_NET_WM_STATE_ABOVE`
- **Effect**: Enhanced scale + fade
- **Optimized for**: i3 floating workflow

#### **Dialog Windows**

- **Effect**: Modal-style scale from center
- **Curve**: Smooth professional curves
- **Duration**: 0.2s open, 0.15s close

#### **Splash Screens**

- **Effect**: Quick fade only
- **Duration**: 0.15s open, 0.12s close
- **Minimal interference with startup**

### 🛠️ **Utility & System Apps**

#### **System Monitors** (htop/btop)

- **Effect**: Slide up from bottom
- **Perfect for**: Terminal-based monitors

#### **Calculators**

- **Effect**: Quick scale animation
- **Duration**: 0.15s open, 0.1s close
- **Instant utility access**

#### **Picture-in-Picture**

- **Effect**: Smooth scale for video windows
- **Non-disruptive media viewing**

## 🎛️ **Performance Optimizations**

### **Backend Configuration**

- **Backend**: GLX with experimental features
- **GLX Options**: Optimized for animation performance
- **Refresh Rate**: Auto-detection for smooth sync

### **Visual Quality**

- **Corner Radius**: Increased to 6px for modern look
- **Shadow Quality**: Enhanced blur and opacity
- **Blur Strength**: Optimized to 6 for performance
- **Fade Steps**: Faster transitions (5ms intervals)

### **Animation Timing**

- **Opening**: 0.1s - 0.3s range (faster than before)
- **Closing**: Always faster than opening
- **Geometry**: Medium speed for window operations
- **UI Elements**: Ultra-fast (0.08s - 0.15s)

## 🎨 **Curve Profiles Used**

### **Smooth Bounce**

`cubic-bezier(0.16, 1, 0.3, 1)`

- Used for: UI elements, quick interactions

### **Professional Ease**

`cubic-bezier(0.25, 0.46, 0.45, 0.94)`

- Used for: Normal windows, browsers, file managers

### **Quick Response**

`cubic-bezier(0.4, 0, 0.2, 1)`

- Used for: Terminals, system tools

### **Elegant Exit**

`cubic-bezier(0.7, 0, 0.84, 0)`

- Used for: Closing animations

### **Smooth Back**

`cubic-bezier(0.36, 0, 0.66, -0.56)`

- Used for: Window closing with slight overshoot

## 🚀 **Usage Instructions**

### **Apply Changes**

```bash
# Restart picom with new settings
pkill picom && picom --experimental-backends &

# Or restart your window manager
# i3: mod+shift+r
# Openbox: openbox --reconfigure
```

### **Test Animations**

1. Open different application types
2. Test Rofi launcher (Mod+d)
3. Try EWW widgets
4. Test scratchpad (if using i3)
5. Check notification animations

### **Fine-Tuning**

- All durations can be adjusted in `picom-rules.conf`
- Curves can be modified for different feels
- Application matching can be extended

## 🎯 **Integration with Your Setup**

### **Rice System Compatibility**

- Animations work with all your rice themes
- Color changes don't affect animation performance
- Wallpaper changes are smooth

### **Window Manager Integration**

- **i3**: Perfect for tiling + floating workflow
- **Openbox**: Smooth stacking window experience
- **XFCE4**: Compatible with panel animations

### **Performance on Your Hardware**

- Optimized for modern GPUs
- Fallback options for older hardware
- Minimal CPU overhead

---

**🌟 Result**: A cohesive, modern animation system that makes your desktop feel as smooth as Hyprland while maintaining the flexibility and power of your current setup!
