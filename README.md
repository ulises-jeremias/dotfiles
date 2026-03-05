<div align="center">

```ocaml
🚀 NEVER SKIP THE README - YOUR JOURNEY STARTS HERE! 🚀
```

<h1>🏠 HorneroConfig</h1>
<h3>✨ The Ultimate Linux Desktop Configuration Framework ✨</h3>

**Intelligent • Beautiful • Powerful • Seamless**

[📖 Documentation](https://github.com/ulises-jeremias/dotfiles/wiki) •
[🎨 Gallery](#-gallery) •
[🚀 Quick Start](#-quick-installation) •
[🤝 Contributing](CONTRIBUTING.md)

<div align="center">
  <a href="https://github.com/ulises-jeremias/dotfiles-template">
    <img src="./static/template-banner.svg" alt="Template Repository Available - Click to use HorneroConfig Template" width="800"/>
  </a>
</div>

<div align="center">
  <a href="https://github.com/ulises-jeremias/dotfiles/tree/x11-openbox-i3wm-xfce4">
    <img src="./static/x11-branch-banner.svg" alt="Looking for X11 with i3, OpenBox, XFCE4? Check our X11 branch!" width="800"/>
  </a>
</div>

<div align="center">
  <a href="https://github.com/ulises-jeremias/dotfiles/tree/wayland-hyprland-waybar-rofi-eww">
    <img src="./static/wayland-legacy-branch-banner.svg" alt="Looking for the classic Wayland stack (Hyprland + Waybar + Rofi + EWW)? Check this branch!" width="800"/>
  </a>
</div>

[![Awesome](https://awesome.re/mentioned-badge.svg)](https://github.com/PandaFoss/Awesome-Arch)
[![AUR Stable](https://img.shields.io/aur/version/dots-stable?label=AUR+Stable&style=for-the-badge)](https://aur.archlinux.org/packages/dots-stable)
[![AUR Development](https://img.shields.io/aur/version/dots-git?label=AUR+Development&style=for-the-badge)](https://aur.archlinux.org/packages/dots-git)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)

</div>

---

## 🌟 What is HorneroConfig?

<img alt="HorneroConfig Collage" align="right" width="400px" src="./static/collage.png"/>

**HorneroConfig** is a cutting-edge dotfiles framework that transforms your Linux desktop into a masterpiece of functionality and beauty. Named after the industrious hornero bird 🐦, renowned for its skillful nest-building, this framework empowers you to craft the perfect digital workspace.

### ✨ Highlights

🧠 **Smart Color Intelligence** — Automatic theme-aware color adaptation  
🎨 **13 Beautiful Themes** — Cyberpunk, Cozy, Vaporwave, Nature & more  
⚡ **One-Command Setup** — From zero to hero in minutes  
🌊 **Hyprland/Wayland** — Modern compositor with smooth animations  
🔧 **100+ Automation Scripts** — Comprehensive tooling ecosystem  
🛡️ **Security-First** — Built-in auditing and hardening  
📦 **Zero Maintenance** — Powered by chezmoi for seamless updates

<br clear="right"/>

---

## 🎨 Gallery

<details>
<summary>🖼️ <b>Click to view screenshots</b></summary>

<div align="center">

### 🌙 Dark Theme

<img src="./static/screen.png" alt="Dark Theme" width="800px"/>

### ☀️ Light Theme

<img src="./static/screen-2.jpg" alt="Light Theme" width="800px"/>

### 🚀 Application Launchers

<img src="./static/screenshot-launchpad.png" alt="Application Launcher" width="400px"/> <img src="./static/screenshot-spotlight-dark.png" alt="Spotlight Dark" width="400px"/>

</div>

</details>

---

## 🚀 Quick Installation

### ⚡ One-Line Install (Recommended)

```bash
sh -c "$(curl -fsSL "https://github.com/ulises-jeremias/dotfiles/blob/main/scripts/install_dotfiles.sh?raw=true")"
```

### 📦 Arch Linux (AUR)

```bash
yay -S dots-stable      # Stable release
yay -S dots-git         # Latest features
```

> 💡 **Performance Tip**: HorneroConfig automatically configures [Chaotic-AUR](https://aur.chaotic.cx/) during installation, providing precompiled binaries for popular AUR packages in the Hyprland + Quickshell ecosystem to significantly reduce installation time.

<details>
<summary>🛠 <b>More installation methods</b></summary>

#### Using Chezmoi

```bash
chezmoi init --apply ulises-jeremias --source ~/.dotfiles
```

#### From Source

```bash
git clone https://github.com/ulises-jeremias/dotfiles ~/.dotfiles
~/.dotfiles/install.sh
```

#### Manual AUR Build

```bash
git clone https://aur.archlinux.org/dots-stable.git /tmp/dots-stable
cd /tmp/dots-stable && makepkg -si
```

</details>

---

## 💎 Key Features

### 🧠 Revolutionary Smart Colors System

Our **game-changing smart colors technology** automatically analyzes your color palette and intelligently selects optimal colors for UI elements:

✨ **Semantic Intelligence** — Error, success, warning, info colors that make sense  
🎨 **Theme Adaptation** — Perfect contrast and readability on any background  
⚡ **Auto-Application** — Instantly applies to Quickshell, Hyprland, and scripts via Material Design 3  
🔄 **Live Updates** — Colors refresh automatically when you change wallpapers

> 📖 [Learn more about Smart Colors →](https://github.com/ulises-jeremias/dotfiles/wiki/Smart-Colors-System)

### 🎨 Rice System & Themes

Choose from **13 stunning themes** organized by aesthetic: Cyberpunk, Cozy, Vaporwave, Nature, and Cosmic:

```bash
dots appearance list        # List available appearances 🎯
dots appearance apply flowers
dots rice apply flowers     # Apply a specific theme
dots rice list              # See all available themes
```

> 📖 [Explore all themes →](https://github.com/ulises-jeremias/dotfiles/wiki/Rice-System-Theme-Management)

### 🔧 Core Stack

🌊 **[Hyprland](https://hyprland.org)** — Dynamic tiling Wayland compositor  
🐚 **[Quickshell](https://quickshell.org)** — Unified QML desktop shell (bar, launcher, dashboard, notifications, AI chat)  
🐾 **[Kitty](https://sw.kovidgoyal.net/kitty)** — GPU-accelerated terminal emulator  
🐚 **[Zsh](https://zsh.org) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k)** — Feature-rich shell with beautiful prompt  
🔒 **[Hyprlock](https://github.com/hyprwm/hyprlock)** — Secure lock screen  
🖼️ **Quickshell + wpgtk wallpaper flow** — Unified wallpaper management via `dots-wallpaper-set`  
🎨 **Rice System** — Instant theme switching with Material Design 3 colors

> 📖 [Complete component list →](https://github.com/ulises-jeremias/dotfiles/wiki/Home)

### 🛠️ Powerful Automation

Access **100+ built-in scripts** via the `dots` command:

```bash
dots --list             # List all available scripts
dots sysupdate          # Comprehensive system updates
dots smart-colors       # Intelligent color analysis
dots security-audit     # Security analysis and hardening
dots appearance apply neon-city
```

📂 `dots-eject` — Export configs for manual use  
🔄 `dots-update` — Sync with upstream changes

> 📖 [Scripts documentation →](https://github.com/ulises-jeremias/dotfiles/wiki/Dots-Scripts)

---

## 🧪 Development & Testing

### 🎮 Safe Testing Environment

Try HorneroConfig risk-free with our Vagrant playground:

```bash
git clone https://github.com/ulises-jeremias/dotfiles && cd dotfiles
./bin/play                        # Start VM
./bin/play --provision hyprland   # Provision with Hyprland
./bin/play --remove               # Clean up
```

> 📖 [Testing guide →](docs/Testing-Strategy.md)

### 🔧 Contributing

We use [pre-commit](https://pre-commit.com/) for code quality:

```bash
pipx install pre-commit           # Install pre-commit
cd ~/.dotfiles && pre-commit install   # Set up hooks
pre-commit run --all-files        # Run all checks
```

> 🤝 [Contributing guide →](CONTRIBUTING.md) | [Development standards →](docs/Development-Standards.md)

---

## 📖 Documentation

### 📚 For Users

🏠 [**Getting Started**](https://github.com/ulises-jeremias/dotfiles/wiki/Home) — First steps and basic setup  
🎨 [**Rice System**](https://github.com/ulises-jeremias/dotfiles/wiki/Rice-System-Theme-Management) — Theme management  
🧠 [**Smart Colors**](https://github.com/ulises-jeremias/dotfiles/wiki/Smart-Colors-System) — Intelligent theming  
🐚 [**Quickshell**](https://github.com/ulises-jeremias/dotfiles/wiki/Quickshell-Shell) — Desktop shell configuration  
🔧 [**Scripts**](https://github.com/ulises-jeremias/dotfiles/wiki/Dots-Scripts) — Automation tools  
🛡️ [**Security**](https://github.com/ulises-jeremias/dotfiles/wiki/Security) — Privacy and security

### 🤖 For Developers & AI Agents

📋 [**AGENTS.md**](AGENTS.md) — Quick reference guide  
🏗️ [**Architecture**](docs/Architecture-Philosophy.md) — Design principles  
📐 [**ADRs**](docs/adrs/) — Architecture decisions  
🔒 [**Security**](docs/Security-Guidelines.md) — Security practices  
⚡ [**Performance**](docs/Performance-Guidelines.md) — Optimization strategies

---

## 🌍 Platform Support

🐧 **Arch Linux** — Full support with AUR packages  
🐧 **Ubuntu/Debian** — Supported (manual dependencies)  
🐧 **Fedora/RHEL** — Supported (manual dependencies)  
☁️ **Cloud Dev** — GitHub Codespaces, Gitpod, VS Code Remote

> 📖 [Platform-specific guides →](https://github.com/ulises-jeremias/dotfiles/wiki/Home)

---

## 🤝 Contributing

We welcome all contributions! 🎉

🐛 Bug reports • ✨ Feature requests • 🎨 New themes • 📚 Documentation • 🔧 Code

<div align="center">

### 🌟 Contributors

<a href="https://github.com/ulises-jeremias/dotfiles/contributors">
  <img src="https://contrib.rocks/image?repo=ulises-jeremias/dotfiles" alt="Contributors" />
</a>

</div>

---

## 🙏 Credits & Attribution

### Quickshell Desktop Shell

The **Quickshell** implementation in HorneroConfig was highly inspired by and adapted from the amazing work of the [**caelestia-dots/shell**](https://github.com/caelestia-dots/shell) project by [@soramane](https://github.com/soramane).

- **Original Project**: [caelestia-dots/shell](https://github.com/caelestia-dots/shell)
- **License**: GNU General Public License v3.0 (GPL-3.0)
- **What we adapted**: UI/UX design, desktop shell architecture, C++ plugin structure

The original GPL-3.0 license is preserved in `home/dot_config/quickshell/LICENSE`. We are deeply grateful for the beautiful and functional desktop shell that inspired our implementation.

---

<div align="center">

### 💝 Show Your Support

If HorneroConfig has improved your Linux experience:

⭐ **[Star this repo](https://github.com/ulises-jeremias/dotfiles)** • 🐦 **Share it** • 🤝 **Contribute**

<br>

**🏠 HorneroConfig**  
*Building the perfect digital nest, one configuration at a time*

<sub>Licensed under [MIT License](LICENSE) • Made with ❤️ for the Linux community</sub>

</div>
