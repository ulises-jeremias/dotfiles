<h1 align=center>HorneroConfig Quickshell</h1>

> **⚠️ ATTRIBUTION NOTICE**  
> This Quickshell implementation was **highly inspired by and adapted from** the amazing [**caelestia-dots/shell**](https://github.com/caelestia-dots/shell) project by [@soramane](https://github.com/soramane).  
> Original work licensed under GPL-3.0. See [LICENSE](LICENSE) for full license text.

<div align=center>

**Part of the [HorneroConfig](https://github.com/ulises-jeremias/dotfiles) Framework**

A beautiful, functional, and highly customizable desktop shell built with [Quickshell](https://quickshell.outfoxxed.me)

</div>

---

## 🌟 Features

- 🎨 **Theme-Adaptive UI** - Automatically adapts to rice color schemes via Smart Colors
- 🎯 **Unified Desktop Shell** - Bar, launcher, dashboard, notifications, and AI chat in one
- ⚡ **High Performance** - C++ plugin (Hornero) for performance-critical operations
- 🎵 **Audio Visualization** - Beat detection and spectrum analyzer
- 🖼️ **Intelligent Image Analysis** - Extract dominant colors from wallpapers
- 🧮 **Built-in Calculator** - Quick calculations via libqalculate
- 📊 **System Monitoring** - CPU, memory, network, and battery info
- 🔔 **Modern Notifications** - Beautiful notification center with history
- 🚀 **Application Launcher** - Fast app search with calculator integration
- 🎨 **Wallpaper Management** - Quick wallpaper switching with previews

---

## 🏗️ Architecture

### Components

- **Bar Module** - Top/bottom panel with system information
- **Launcher** - Application launcher with search and calculator
- **Dashboard** - Quick access panel with media controls, weather, calendar
- **Control Center** - Settings and appearance customization
- **Notification Center** - Notification history and management
- **AI Chat** - Integrated AI assistant (Ollama)
- **Lock Screen** - Secure lock screen with fetch display
- **Background** - Wallpaper management and audio visualizer

### Hornero C++ Plugin

The `plugin/` directory contains the **Hornero** C++ plugin for Quickshell, providing:

- **Image Analysis** - Dominant color extraction and analysis
- **Audio Processing** - Beat detection, spectrum analysis via libcava and aubio
- **Calculator** - Mathematical expression evaluation via libqalculate
- **Performance Optimizations** - Fast image caching, circular indicators
- **System Integration** - Hyprland extensions, logind manager, D-Bus services

---

## 📦 Installation

HorneroConfig Quickshell is automatically installed as part of the main HorneroConfig dotfiles:

```bash
# Install HorneroConfig (includes Quickshell)
sh -c "$(curl -fsSL "https://github.com/ulises-jeremias/dotfiles/blob/main/scripts/install_dotfiles.sh?raw=true")"
```

The installation script will:
1. Install Quickshell and dependencies
2. Build the Hornero C++ plugin
3. Configure integration with Hyprland
4. Set up auto-start on login

---

## 🔧 Configuration

Configuration is managed through:

- **`config/Config.qml`** - Main configuration file
- **Rice system** - Theme settings from `~/.local/share/dots/rices/`
- **Smart Colors** - Automatic color adaptation via `~/.cache/dots/smart-colors/`

### Customization

Edit configuration in your HorneroConfig rice:

```bash
# Edit current rice configuration
dots-rice edit

# Switch rice (changes entire theme including Quickshell)
dots-rice switch
```

---

## 🛠️ Building the Hornero Plugin

If you need to manually rebuild the C++ plugin:

```bash
cd ~/.config/quickshell
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build
sudo cmake --install build
```

Dependencies:
- `cmake`, `ninja`
- `qt6-base`, `qt6-declarative`
- `libcava`, `aubio`, `libpipewire`
- `libqalculate`
- `networkmanager`, `lm-sensors`
- `brightnessctl`, `ddcutil`

---

## 🚀 Usage

Quickshell starts automatically with Hyprland via the HorneroConfig configuration.

Manual start:
```bash
quickshell
```

### Keyboard Shortcuts

Configured via Hyprland global shortcuts. Default HorneroConfig bindings:

- **Super + Space** - Toggle launcher
- **Super + D** - Toggle dashboard
- **Super + N** - Toggle notifications
- **Super + L** - Lock screen
- **Super + Shift + A** - Toggle AI chat

> See [HorneroConfig Keyboard Shortcuts](https://github.com/ulises-jeremias/dotfiles/wiki/Keyboard-Shortcuts) for complete reference

---

## 🧪 Development

### File Structure

```
quickshell/
├── components/      # Reusable QML components
├── config/          # Configuration files
├── modules/         # Feature modules (bar, launcher, dashboard, etc.)
├── plugin/          # Hornero C++ plugin
│   └── src/
│       └── Hornero/ # Plugin source (formerly Caelestia)
├── services/        # Backend services (audio, colors, wallpapers, etc.)
├── utils/           # Utility QML modules
├── shell.qml        # Main entry point
└── CMakeLists.txt   # Build configuration
```

### Testing Changes

```bash
# Test without installation
quickshell -c ~/.config/quickshell

# Rebuild plugin after changes
cd ~/.config/quickshell
cmake --build build
sudo cmake --install build
```

---

## 📄 License

This Quickshell implementation is licensed under the **GNU General Public License v3.0 (GPL-3.0)**, maintaining the license of the original caelestia-dots/shell project from which it was adapted.

See [LICENSE](LICENSE) for full license text and attribution details.

The broader HorneroConfig framework is licensed under MIT. This Quickshell component specifically follows GPL-3.0 due to its derivation from caelestia-dots/shell.

---

## 🙏 Acknowledgments

Massive thanks to:

- **[@soramane](https://github.com/soramane)** - For the beautiful caelestia-dots/shell that inspired this implementation
- **[caelestia-dots](https://github.com/caelestia-dots)** - For the excellent reference implementation and design
- **[Quickshell](https://quickshell.outfoxxed.me)** - For the amazing QML-based desktop shell framework
- **[Hyprland](https://hyprland.org)** - For the smooth Wayland compositor

---

<div align=center>

**Part of [HorneroConfig](https://github.com/ulises-jeremias/dotfiles)**  
*Building the perfect digital nest, one configuration at a time* 🏠

</div>
