# 🚀 Rofi: Apps Launcher Guide

We use **Rofi** as our highly customizable and visually pleasing Apps Launcher — inspired by macOS Launchpad aesthetics. It’s lightweight, fast, and integrates seamlessly into your setup.

> [!TIP]
> Everything in this setup is configurable — from layout, fonts, colors, to behavior. It’s all versioned in your dotfiles and powered by chezmoi.

---

## 🗂️ Configuration Files Location

Your launcher configuration lives here:

```sh
~/.config/rofi/apps.rasi
```

To edit it with chezmoi:

```sh
chezmoi edit ~/.config/rofi/apps.rasi
```

Apply with:

```sh
chezmoi apply
```

---

## 🔧 What You Can Customize

- **Fonts** (e.g., Hack Nerd Font Mono)
- **Color Scheme**
- **Transparency**
- **Width / Height / Positioning**
- **Prompt, search behavior, icons**

> [!TIP]
> Use `rofi -show drun` to preview your launcher and test changes live.

---

## ✨ Visual and Theming

Our configuration uses:

- **Font**: `Hack Nerd Font Mono 10`
- **Mode**: Fullscreen with center alignment
- **Transparency**: Real transparency (Hyprland compositor handles this automatically)
- **Dynamic Theming**: Integrated with [`pywal`](https://github.com/dylanaraps/pywal) to match your wallpaper

### Dynamic Color with Pywal

After setting a wallpaper and running `wal`, your launcher will update to match the generated color palette:

```sh
wal -i /path/to/image.jpg
```

Your Rofi theme then inherits these styles automatically.

---

## 🖼️ Preview

![Rofi Launcher Preview](path/to/preview/image.png)

---

## 🧪 Testing and Launching

To run Rofi and test your setup:

```sh
rofi -show drun
```

Or bind a custom keybinding in Hyprland configuration.

---

## 🆘 Need Help?

- [Rofi GitHub Documentation](https://github.com/davatorium/rofi)
- [chezmoi docs](https://www.chezmoi.io/)

Customize your launcher to be fast, beautiful, and fully yours. Happy launching! 🚀
