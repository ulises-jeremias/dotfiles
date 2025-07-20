<div align="center">

```ocaml
🚀 NEVER SKIP THE README - YOUR JOURNEY STARTS HERE! 🚀
```

<h1>🏠 HorneroConfig</h1>
<h3>✨ The Ultimate Linux Desktop Configuration Framework ✨</h3>

**Intelligent • Beautiful • Powerful • Seamless**

[📖 Documentation](https://ulises-jeremias.github.io/dotfiles) •
[🎨 Gallery](#-gallery) •
[🚀 Quick Start](#-quick-installation) •
[🤝 Contributing](CONTRIBUTING.md)

---

[![Awesome](https://awesome.re/mentioned-badge.svg)](https://github.com/PandaFoss/Awesome-Arch)
[![AUR Stable](https://img.shields.io/aur/version/dots-stable?label=AUR+Stable&style=for-the-badge)](https://aur.archlinux.org/packages/dots-stable)
[![AUR Development](https://img.shields.io/aur/version/dots-git?label=AUR+Development&style=for-the-badge)](https://aur.archlinux.org/packages/dots-git)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)

<img alt="" align="right" width="400px" src="./static/collage.png"/>

</div>

---

## 🌟 **What is HorneroConfig?**

**HorneroConfig** is a cutting-edge dotfiles framework that transforms your Linux desktop into a **masterpiece of functionality and beauty**. Named after the industrious hornero bird 🐦, renowned for its skillful nest-building, this framework empowers you to craft the perfect digital workspace.

### 🎯 **Why Choose HorneroConfig?**

- 🧠 **Smart Color Intelligence** - Revolutionary color system that adapts to any theme
- 🎨 **Beautiful Rice Themes** - 12+ stunning pre-configured desktop themes
- ⚡ **One-Command Setup** - From zero to hero in minutes
- 🔧 **100+ Automation Scripts** - Comprehensive tooling ecosystem
- 🪟 **Multi-WM Support** - Works with i3, Openbox, XFCE4, and more
- 🛡️ **Security-First** - Built-in security auditing and hardening
- 📦 **Zero Maintenance** - Powered by chezmoi for seamless updates

---

## ✨ **Key Features**

<div align="center">

|    🧠 **Smart Colors**     |   🎨 **Rice System**   |     📊 **Polybar**      |  🎛️ **EWW Widgets**   |
| :------------------------: | :--------------------: | :---------------------: | :-------------------: |
| Intelligent color analysis |  12+ beautiful themes  |       20+ modules       | Modern system widgets |
|  Theme-adaptive palettes   |  One-click switching   | Smart color integration | Dashboard & powermenu |
|   Semantic color mapping   | Wallpaper coordination |     Profile system      |     Auto-updating     |

| 🪟 **Window Managers** |  🔧 **Automation**   |  🛡️ **Security**  | 📦 **Management**  |
| :--------------------: | :------------------: | :---------------: | :----------------: |
|  i3 • Openbox • XFCE4  | 100+ utility scripts | Security auditing |  Chezmoi powered   |
|  Seamless integration  | Smart notifications  |  Hardening tools  |   Cross-platform   |
|   Custom keybindings   |  System monitoring   | Privacy features  | Version controlled |

</div>

### 🧠 **Revolutionary Smart Colors System**

Our **game-changing smart colors technology** automatically analyzes your color palette and intelligently selects optimal colors for different concepts:

- **🎯 Semantic Intelligence**: Error, success, warning, info colors that make sense
- **🎨 Theme Adaptation**: Perfect contrast and readability on any background
- **⚡ Auto-Application**: Instantly applies to Polybar, EWW, i3, and all scripts
- **🔄 Live Updates**: Colors refresh automatically when you change wallpapers

---

## 🎨 **Gallery**

<div align="center">

### 🌙 **Dark Theme Showcase**

<img src="./static/screen.png" alt="Dark Theme" width="800px"/>

### ☀️ **Light Theme Excellence**

<img src="./static/screen-2.jpg" alt="Light Theme" width="800px"/>

### 🚀 **Application Launcher**

<img src="./static/screenshot-launchpad.png" alt="Rofi Launcher" width="400px"/> <img src="./static/screenshot-spotlight-dark.png" alt="Spotlight Dark" width="400px"/>

</div>

---

## 🚀 **Quick Installation**

### ⚡ **One-Line Install** (Recommended)

Transform your desktop instantly with a single command:

```bash
sh -c "$(wget -qO- "https://github.com/ulises-jeremias/dotfiles/blob/main/scripts/install_dotfiles.sh?raw=true")"
```

> 💡 **Alternative with curl:**
>
> ```bash
> sh -c "$(curl -fsSL "https://github.com/ulises-jeremias/dotfiles/blob/main/scripts/install_dotfiles.sh?raw=true")"
> ```

### 📦 **Arch Linux Users** (AUR)

```bash
# Stable release
yay -S dots-stable

# Development release (latest features)
yay -S dots-git
```

### 🛠️ **Advanced Installation**

<details>
<summary>📋 Click to expand advanced installation methods</summary>

#### Using Chezmoi (Recommended)

```bash
chezmoi init --apply ulises-jeremias --source ~/.dotfiles
```

#### From Source

```bash
git clone https://github.com/ulises-jeremias/dotfiles ~/.dotfiles
~/.dotfiles/install.sh
```

#### Manual AUR Installation

```bash
git clone https://aur.archlinux.org/dots-stable.git /tmp/dots-stable
cd /tmp/dots-stable && makepkg -si
```

</details>

---

## 🎨 **Rice Themes Collection**

Choose from our curated collection of stunning desktop themes:

<div align="center">

| Theme                           | Style         | Palette                       | Description                     |
| :------------------------------ | :------------ | :---------------------------- | :------------------------------ |
| 🌸 **flowers**                  | Nature        | Vibrant florals               | Fresh and energizing            |
| 🍂 **gruvbox-anime**            | Retro Anime   | Warm earth + anime aesthetics | Classic gruvbox meets anime art |
| ☀️ **gruvbox-light**            | Retro Light   | Light warm earth tones        | Bright and comfortable gruvbox  |
| 🔲 **gruvbox-minimalistic**     | Retro Minimal | Clean warm earth tones        | Simplified gruvbox aesthetic    |
| 🎨 **gruvbox-mix**              | Retro Mixed   | Varied warm earth tones       | Diverse gruvbox palette         |
| 🖼️ **gruvbox-painting**         | Retro Art     | Artistic warm earth tones     | Painterly gruvbox aesthetic     |
| 🎮 **gruvbox-pixelart**         | Retro Gaming  | Pixelated warm earth tones    | 8-bit gruvbox nostalgia         |
| 🎲 **gruvbox-videogame-3d-art** | Gaming        | 3D art warm earth tones       | Modern gaming meets gruvbox     |
| 🌲 **landscape-dark**           | Nature        | Dark earth tones              | Professional and elegant        |
| ☀️ **landscape-light**          | Nature        | Light natural colors          | Clean and minimalist            |
| 🤖 **machines**                 | Cyberpunk     | Industrial grays              | Futuristic and bold             |
| 🔴 **red-blue**                 | High Contrast | Vibrant contrast              | Energetic and dynamic           |
| 🌌 **space**                    | Cosmic        | Deep blues & purples          | Mystical and calming            |

</div>

### 🎯 **Quick Theme Switching**

```bash
# Interactive theme selector
dots rofi-rice-selector

# Apply specific theme
dots rice apply gruvbox-anime

# Apply minimalistic theme
dots rice apply gruvbox-minimalistic

# Apply nature theme
dots rice apply landscape-dark

# List all available themes
dots rice list
```

---

## 🔧 **Core Applications**

<div align="center">

| Component             | Application                                                                        | Description           |
| :-------------------- | :--------------------------------------------------------------------------------- | :-------------------- |
| 🪟 **Window Manager** | [i3](https://i3wm.org) • [Openbox](http://openbox.org) • [XFCE](https://xfce.org)  | Flexible WM support   |
| 📊 **Status Bar**     | [Polybar](https://polybar.github.io)                                               | Beautiful & modular   |
| 🚀 **App Launcher**   | [Rofi](https://github.com/davatorium/rofi)                                         | Lightning fast        |
| 🐾 **Terminal**       | [Kitty](https://sw.kovidgoyal.net/kitty)                                           | GPU-accelerated       |
| 🐚 **Shell**          | [Zsh](https://zsh.org) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Feature-rich          |
| 🌿 **Notifications**  | [Dunst](https://github.com/dunst-project/dunst)                                    | Minimalist design     |
| 🍧 **Compositor**     | [Picom](https://github.com/yshui/picom)                                            | Smooth animations     |
| 🃏 **File Manager**   | [Thunar](https://docs.xfce.org/xfce/thunar/start)                                  | Customized interface  |
| 🎛️ **Widgets**        | [EWW](https://github.com/elkowar/eww)                                              | Modern system widgets |

</div>

---

## 🛠️ **Powerful Automation**

### 📜 **100+ Built-in Scripts**

Access a comprehensive toolkit through the `dots` command:

```bash
# Interactive script browser
dots scripts

# System management
dots sysupdate          # Comprehensive system updates
dots backup             # Automated backups with scheduling
dots security-audit     # Security analysis and hardening

# Theming & visuals
dots smart-colors       # Intelligent color analysis
dots wal-reload         # Complete theme refresh
dots rofi-rice-selector # Visual theme picker

# System monitoring
dots monitor            # Display management
dots performance        # System benchmarks
dots weather-info       # Weather integration
```

### 🧠 **Smart Color Intelligence**

Experience the future of desktop theming:

```bash
# Analyze your current palette
dots smart-colors --analyze

# Export colors for different applications
dots smart-colors --export --format=polybar
dots smart-colors --export --format=eww
dots smart-colors --export --format=i3

# Get optimal color for specific concepts
dots smart-colors --concept=error --format=hex
dots smart-colors --concept=success --format=rgb
```

---

## 🛡️ **Security & Privacy**

### 🔒 **Built-in Security Features**

- **🔍 Security Auditing**: Comprehensive system security analysis
- **🛡️ Hardening Tools**: Automated security configuration
- **🔐 Privacy Protection**: Privacy-focused defaults and tools
- **📊 Security Monitoring**: Continuous security health checks

```bash
# Run complete security audit
dots security-audit

# Apply security hardening
dots security-audit --apply

# Check system security status
dots security-audit --status
```

---

## 🧪 **Testing & Development**

### 🎮 **Playground Environment**

Test HorneroConfig safely with our Vagrant-based playground:

```bash
git clone https://github.com/ulises-jeremias/dotfiles
cd dotfiles

# Start testing environment
./bin/play

# Provision with different WMs
./bin/play --provision i3
./bin/play --provision openbox

# Clean up
./bin/play --remove
```

### 🔧 **Development Setup**

Contribute with confidence using our quality tools:

```bash
# Install development dependencies
pip install pre-commit

# Set up git hooks
pre-commit install

# Run quality checks
pre-commit run --all-files
```

---

## 🌍 **Platform Support**

<div align="center">

| Platform                 | Status              | Notes                          |
| :----------------------- | :------------------ | :----------------------------- |
| 🐧 **Arch Linux**        | ✅ **Full Support** | AUR packages available         |
| 🐧 **Ubuntu/Debian**     | ✅ **Supported**    | Manual dependency installation |
| 🐧 **Fedora/RHEL**       | ✅ **Supported**    | Manual dependency installation |
| ☁️ **GitHub Codespaces** | ✅ **Supported**    | Cloud development              |
| 🐳 **VS Code Remote**    | ✅ **Supported**    | Container development          |
| 🌐 **Gitpod**            | ✅ **Supported**    | Browser-based development      |

</div>

---

## 📖 **Documentation**

Comprehensive guides for every aspect:

- 🏠 [**Getting Started**](https://ulises-jeremias.github.io/dotfiles/#Home) - Your first steps
- 🎨 [**Rice System**](https://ulises-jeremias.github.io/dotfiles/#Rice-System-Theme-Management) - Theme management
- 🧠 [**Smart Colors**](https://ulises-jeremias.github.io/dotfiles/#Smart-Colors-System) - Intelligent theming
- 📊 [**Polybar Config**](https://ulises-jeremias.github.io/dotfiles/#Polybar-Configuration-Structure) - Status bar setup
- 🎛️ [**EWW Widgets**](https://ulises-jeremias.github.io/dotfiles/#EWW-Widgets) - Modern widgets
- 🔧 [**Scripts Guide**](https://ulises-jeremias.github.io/dotfiles/#Dots-Scripts) - Automation tools
- 🛡️ [**Security**](https://ulises-jeremias.github.io/dotfiles/#Security) - Privacy & security

---

## 🤝 **Contributing**

Join our amazing community! We welcome:

- 🐛 **Bug Reports** - Help us improve
- ✨ **Feature Requests** - Share your ideas
- 🎨 **New Rice Themes** - Show your creativity
- 📚 **Documentation** - Help others learn
- 🔧 **Code Contributions** - Make it better

### 🌟 **Contributors**

<div align="center">

<a href="https://github.com/ulises-jeremias/dotfiles/contributors">
  <img src="https://contrib.rocks/image?repo=ulises-jeremias/dotfiles" alt="Contributors" />
</a>

_Made with ❤️ by our amazing community_

</div>

---

<div align="center">

### 💝 **Show Your Support**

If HorneroConfig has improved your Linux experience, consider:

⭐ **Star this repository** • 🐦 **Share on social media** • 🤝 **Contribute to the project**

---

**🏠 HorneroConfig - Building the perfect digital nest, one configuration at a time**

_Licensed under [MIT License](LICENSE) • Made with ❤️ for the Linux community_

</div>
