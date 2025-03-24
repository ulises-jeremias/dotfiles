# 🎨 Polybar Configuration Guide

Polybar is a **highly customizable status bar** that provides a sleek and elegant way to display system information such as date, CPU, memory, and more. It’s modular, lightweight, and visually beautiful.

> [!TIP]
> Everything in this setup is fully customizable. Whether it's modules, colors, font, spacing, or interaction, you have total control. All configuration files are versioned in your dotfiles using chezmoi.

---

## 📁 Configuration Files Location

Your Polybar configuration is stored in:

```sh
~/.config/polybar
```

To edit it:

```sh
chezmoi edit ~/.config/polybar --source ~/.dotfiles
```

Apply changes with:

```sh
chezmoi apply
```

> [!TIP]
> Run `polybar-msg cmd restart` to reload Polybar without restarting your session.

---

## 🔧 What You Can Customize

- **Bars**: Define multiple bars for different monitors or purposes
- **Modules**: Choose what system info to display (CPU, memory, network, etc.)
- **Fonts & Colors**: Set font family, size, and colors (supports Nerd Fonts!)
- **Spacing & Alignment**: Adjust padding, margins, and alignment
- **Behavior**: Define click actions, scroll behavior, or auto-hide logic

### 🗂️ Main Files

- `config.ini`: Main config file defining bars and module layout
- `modules/`: Folder containing reusable and custom module logic
- `launch.sh`: Custom launch script for initializing Polybar

---

## 📦 Default Modules Available

Polybar supports a variety of built-in and custom modules. Some examples:

- `date` – current date/time
- `cpu` – CPU usage
- `memory` – RAM usage
- `battery` – battery status
- `network` – current IP, Wi-Fi, and signal
- `spotify` – current playing track
- `i3` – workspace info for i3 users
- `custom/` – your own shell scripts or output

Check the documentation we have for each module in the sidebar!

---

## 🎨 Visual Styling Tips

- Use `pywal` to dynamically theme your bar based on wallpaper
- Integrate with icon fonts like Material Design or Nerd Fonts for better visuals
- Adjust background transparency with a compositor like `picom`

---

## 🧪 Testing Your Setup

Make changes incrementally and restart only the bar:

```sh
polybar-msg cmd restart
```

If something crashes, run:

```sh
polybar your-bar-name -r
```

To test an individual bar defined in your `config.ini`

---

## 🆘 Need Help?

- [Polybar Wiki](https://github.com/polybar/polybar/wiki)
- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Design your own status bar and make your desktop truly yours. Polybar gives you the power — go wild! 🚀
