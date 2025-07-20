# 🐱 Kitty Terminal Emulator Guide

[Kitty](https://sw.kovidgoyal.net/kitty/) is a modern, GPU-accelerated terminal emulator built for speed, flexibility, and customization. It’s ideal for developers, power users, and anyone who wants a fast, scriptable terminal experience.

> [!TIP]
> Like everything in this setup, Kitty is **fully customizable**. You can tweak appearance, behavior, keybindings, and even integrate with your theme manager.

---

## 🚀 Why Use Kitty?

- ⚡ GPU acceleration for smooth rendering
- 🧩 Layouts and tab support
- 🎨 Rich styling with font ligatures and emoji
- 📜 Scriptable with shell commands
- 📺 Inline graphics and image display support

---

## ⚙️ Configuration Basics

Kitty's configuration file is located at:

```sh
~/.config/kitty/kitty.conf
```

To edit it with chezmoi:

```sh
chezmoi edit ~/.config/kitty/kitty.conf
chezmoi apply
```

This file controls appearance, behavior, fonts, shortcuts, and more.

---

## 🎨 Installing and Applying Themes

Kitty supports full theme customization using its config system.

### Using `kitty-themes`

We recommend using [kitty-themes](https://github.com/dexpota/kitty-themes) for easier management of community-curated themes.

#### Installation

```sh
git clone https://github.com/dexpota/kitty-themes ~/.config/kitty/themes
```

To list and apply a theme:

```sh
cd ~/.config/kitty/themes
./theme_launcher.sh  # Follow the prompts
```

This tool automatically updates your Kitty config with the selected theme.

---

## 🎨 Color Integration

### Smart Colors & Pywal Integration

Your Kitty terminal automatically integrates with the **smart colors system**:

- **Automatic Updates**: Colors refresh when you change wallpapers via `wpg`
- **Smart Adaptation**: Colors are optimized for readability and theme consistency
- **Pywal Compatibility**: Works seamlessly with existing [`pywal`](https://github.com/dylanaraps/pywal) workflows

The terminal colors are automatically updated through the `wal-reload` script, ensuring perfect theme coordination across your entire desktop environment.

---

## 🧠 Tips for Customizing Kitty

- Use Nerd Fonts or JetBrainsMono for ligatures and icon support
- Bind shortcuts to control tabs or launch commands
- Use `background_opacity` for transparency
- Customize scrollback, padding, and cursor style

**Example snippet:**

```ini
font_family      Hack Nerd Font Mono
font_size        11
background_opacity 0.95
enable_audio_bell no
```

---

## 📦 Bonus: Integrate with Pywal

Use [`pywal`](https://github.com/dylanaraps/pywal) to generate a dynamic color scheme based on your wallpaper, and source the `kitty.conf` colors dynamically.

```sh
wal -i path/to/wallpaper.jpg
```

> Kitty will use the updated colors from your `~/.cache/wal/colors-kitty.conf` file.

---

## 🆘 Need Help?

- [Kitty Docs](https://sw.kovidgoyal.net/kitty/)
- [kitty-themes](https://github.com/dexpota/kitty-themes)
- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Kitty gives you the performance of a modern terminal with the aesthetic and control of a true power tool. Make it yours! 🐱💻
