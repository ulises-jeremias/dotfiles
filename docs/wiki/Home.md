<div align="center">
  <h1>🏠 HorneroConfig - Comprehensive Dotfiles Framework</h1>

  [Docs](https://ulises-jeremias.github.io/dotfiles) |
  [Changelog](#) |
  [Contributing](https://github.com/ulises-jeremias/dotfiles/blob/main/.github/CONTRIBUTING.md)

</div> <!-- center -->

<div align="center">

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/PandaFoss/Awesome-Arch)
[![AUR Stable](https://img.shields.io/aur/version/dots-stable?label=AUR+Stable)](https://aur.archlinux.org/packages/dots-stable)
[![AUR Development](https://img.shields.io/aur/version/dots-git?label=AUR+Development)](https://aur.archlinux.org/packages/dots-git)
[![License: MIT][licensebadge]][licenseurl]

</div>

You might be here looking for (Linux) rice reference or to (full?) replicate my personal
configuration of my favorite Window Managers and several apps as well. ⛄

HorneroConfig is your artisanal toolkit for crafting the perfect digital workspace.
Named after the industrious hornero bird, renowned for its skillful nest-building,
our framework empowers you to construct a robust, functional, and personalized computing environment.

Perfectly suited for a wide array of Desktop Environments and Window Managers,
HorneroConfig thrives across different platforms including [GitHub Codespaces](https://docs.github.com/codespaces/customizing-your-codespace/personalizing-codespaces-for-your-account#dotfiles), [Gitpod](https://www.gitpod.io/docs/config-dotfiles), [VS Code Remote - Containers](https://code.visualstudio.com/docs/remote/containers#_personalizing-with-dotfile-repositories), or even Linux distributions that are not Arch Linux.

Backed by the versatile [Chezmoi](https://www.chezmoi.io/), HorneroConfig stands out as a dotfiles manager
that adapts flexibly to your needs, streamlining machine setup and ensuring consistency across devices.
Embrace the spirit of the hornero, and let HorneroConfig transform your configurations
into a harmonious blend of elegance and efficiency.

## ✨ Key Features

- **🎨 Advanced Rice System**: Switch between beautiful desktop themes instantly
- **🧠 Smart Colors**: Intelligent color adaptation for optimal readability and theme consistency  
- **📊 Waybar**: Beautiful dual-bar status configuration with 20+ modules
- **🎛️ EWW Widgets**: Modern system widgets (dashboard, powermenu, sidebar)
- **🌊 Hyprland**: Dynamic tiling Wayland compositor with smooth animations
- **📦 Easy Management**: Simple installation and configuration via chezmoi
- **🔧 100+ Scripts**: Comprehensive automation and utility scripts
- **🔄 Automatic Theming**: Seamless wallpaper-to-theme integration
- **🛡️ Security**: Built-in security auditing and hardening tools

Most were written from scratch. Core stack:

- **Compositor** 🌊 [Hyprland](https://hyprland.org) - Dynamic tiling Wayland compositor
- **Status Bar** 📊 [Waybar](https://github.com/Alexays/Waybar) - Beautiful, customizable status bar
- **Application Launcher** 🚀 [Rofi](https://github.com/lbonn/rofi) - Blazing fast app launcher (Wayland fork)
- **Notifications** 🔔 [Mako](https://github.com/emersion/mako) - Lightweight notification daemon
- **Terminal Emulator** 🐾 [Kitty](https://sw.kovidgoyal.net/kitty/) - GPU-accelerated terminal
- **Shell** 🐚 [Zsh](https://zsh.org) with Powerlevel10k prompt
- **Lockscreen** 🔒 [Hyprlock](https://github.com/hyprwm/hyprlock) - Secure lock screen
- **Wallpaper** 🖼️ [Hyprpaper](https://github.com/hyprwm/hyprpaper) - Fast wallpaper daemon
- **File Manager** 🃏 [Thunar](https://docs.xfce.org/xfce/thunar/start) with customized side pane
- **Widgets** 🎨 [EWW](https://github.com/elkowar/eww) with dashboard and powermenu
- and many more!

![Dotfiles Screen Overview](https://github.com/ulises-jeremias/dotfiles/blob/main/static/screen.png?raw=true)

![Dotfiles Anime Light Theme Overview](https://github.com/ulises-jeremias/dotfiles/blob/main/static/anime.jpeg?raw=true)

![Dotfiles Anime Dark Overview](https://github.com/ulises-jeremias/dotfiles/blob/main/static/anime-girl-screen.png?raw=true)

![Dotfiles Dark Overview](https://github.com/ulises-jeremias/dotfiles/blob/main/static/screen-2.jpg?raw=true)

![Nord Two Lines](https://github.com/ulises-jeremias/dotfiles/blob/main/static/screenshot-nord-two-lines.png?raw=true)

![Launchpad](https://github.com/ulises-jeremias/dotfiles/blob/main/static/screenshot-launchpad.png?raw=true)

## 🚀 Installation & Performance

### Chaotic-AUR Repository

HorneroConfig automatically configures the [Chaotic-AUR](https://aur.chaotic.cx/) repository during installation. This provides:

- **⚡ Precompiled Binaries**: Skip building AUR packages from source
- **🎯 Faster Setup**: Reduce installation time by 50-70%
- **🔄 Regular Updates**: Automatically maintained packages
- **📦 Popular Packages**: Hyprland ecosystem, nwg-* tools, pamac-aur, auto-cpufreq, and more

The repository is configured automatically by the chezmoi script at:

```text
home/.chezmoiscripts/linux/run_onchange_before_install-000-chaotic-aur.sh.tmpl
```

For more information, visit the [Chaotic-AUR documentation](https://aur.chaotic.cx/docs).

[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[licenseurl]: https://github.com/ulises-jeremias/dotfiles/blob/main/LICENSE
