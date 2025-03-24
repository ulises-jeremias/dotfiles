# 🖥️ XFCE4 Configuration Guide

XFCE4 is a **versatile**, **lightweight**, and **fully customizable** desktop environment. It comes with a set of default configurations and strikes a great balance between performance and functionality. With the dotfiles installation, all your XFCE4 customizations are versioned and managed through chezmoi.

> [!TIP]
> Everything in this setup is customizable — from themes and panels to keyboard shortcuts and power settings. You can use the Settings Manager or modify files directly.

---

## 🗂️ Configuration Files Location

Your XFCE4 configuration files are stored at:

```sh
~/.config/xfce4
```

These files are backed by XFCE4 components and apply **globally** across all the installed dotfiles and any window manager you use.

To make edits via chezmoi:

```sh
chezmoi edit ~/.config/xfce4 --source ~/.dotfiles
```

Apply your changes with:

```sh
chezmoi apply
```

> [!TIP]
> Use `chezmoi diff` to preview changes before applying.

---

## 🌍 Global Configurations

All changes to XFCE4 will reflect globally across any window manager integrated in your dotfiles setup (such as Openbox or i3). This allows for a consistent and seamless experience across sessions.

---

## 🛠️ Using XFCE4 Settings Manager

You can visually manage most XFCE4 settings through the built-in **XFCE4 Settings Manager** (`xfce4-settings-manager`).

### How to Launch

1. Open the application menu (click the icon in the panel or press the Super key)
2. Search for **"Settings Manager"** and click to open

![Settings Manager](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/settings-manager-open.gif?raw=true)

Once opened, you'll see options like:

- Keyboard shortcuts
- Mouse and touchpad settings
- Default applications (browser, terminal, file manager, etc.)
- Power manager settings
- Appearance (themes, icons, fonts)

![Settings](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/settings.jpg?raw=true)

Any changes here are written to the configuration files managed by chezmoi and apply globally to all dotfiles.

---

## 🔧 What You Can Customize

- **Panel layout and plugins**
- **Autostart applications**
- **Desktop background and display settings**
- **Keybindings and workspace navigation**
- **Compositor settings** (like transparency and shadows)

Make changes either through the GUI or directly by editing files in `~/.config/xfce4`.

> [!TIP]
> Don’t forget to apply changes with `chezmoi apply`.

---

## 🧪 Tips & Tricks

- Use `picom` for smooth compositing and transparency
- Combine XFCE4 with tools like `Polybar`, `Rofi`, and `Zsh` for a more powerful environment
- Replace `xfce4-terminal` with `kitty` or `alacritty` for improved terminal performance

---

## 🆘 Need Help?

- [XFCE Wiki](https://wiki.xfce.org/)
- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

XFCE4 offers the stability of a traditional desktop with the flexibility of modern customization. Explore, tweak, and make it your own! 🎨
