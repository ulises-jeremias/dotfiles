# 🎨 Polybar Configuration Guide

Polybar is a **highly customizable status bar** that provides a sleek and elegant way to display system information such as date, CPU, memory, and more. It's modular, lightweight, and visually beautiful.

This dotfiles setup uses a **profile-based system** that allows different rice themes to use different polybar configurations seamlessly.

> [!TIP]
> Everything in this setup is fully customizable. Whether it's modules, colors, font, spacing, or interaction, you have total control. All configuration files are versioned in your dotfiles using chezmoi.

---

## 📁 Configuration Files Location

Your Polybar configuration is stored in:

```sh
~/.config/polybar
├── launch.sh              # Enhanced launch script with profile support
├── profiles/               # Profile definitions
│   ├── default.sh         # Default profile (2 bars)
│   └── minimal.sh         # Minimal profile (1 bar)
└── configs/                # Configuration files
    └── default/
        ├── config.ini     # Main polybar config
        ├── modules.conf   # Module definitions
        └── bars/          # Bar configurations
```

To edit it:

```sh
chezmoi edit ~/.config/polybar --source ~/.dotfiles
```

Apply changes with:

```sh
chezmoi apply
```

---

## 🎯 Profile System

### How It Works

1. **Rice Configurations** specify which polybar profile to use via `POLYBAR_PROFILE` variable
2. **Profiles** define which bars to launch and which config file to use
3. **Launch script** automatically loads the correct profile based on your current rice

### Available Profiles

- **`default`** - Full setup with top and bottom bars
- **`minimal`** - Minimal setup with only top bar

### Creating New Profiles

Create a new profile in `~/.config/polybar/profiles/`:

```bash
#!/usr/bin/env bash
#
# My Custom Profile
#

POLYBAR_PROFILE_NAME="custom"
POLYBAR_PROFILE_DESCRIPTION="My custom polybar setup"

# Bars to launch (window manager aware)
POLYBAR_PROFILE_BARS=("polybar-top")

WM=$(wmctrl -m | grep -oE 'Name: .*' | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]' 2>/dev/null || echo "unknown")
if [ "${WM}" = "i3" ]; then
    POLYBAR_PROFILE_BARS=("i3-polybar-top")
fi

# Config file to use
POLYBAR_PROFILE_CONFIG_FILE="$HOME/.config/polybar/configs/default/config.ini"
```

### Using Profiles in Rice Configs

In your rice's `config.sh` file:

```bash
#!/usr/bin/env bash

# Polybar profile to use for this rice
POLYBAR_PROFILE="minimal"  # or "default", "custom", etc.
```

---

## 🚀 Launch Script Commands

The enhanced launch script provides comprehensive polybar management:

```sh
~/.config/polybar/launch.sh [COMMAND]

# Commands:
start       # Start polybar with current rice profile
stop        # Stop all polybar processes  
restart     # Restart polybar (most common)
status      # Show current status
help        # Show help
```

### Examples

```sh
# Restart polybar (automatically uses current rice profile)
~/.config/polybar/launch.sh restart

# Show current status
~/.config/polybar/launch.sh status

# Force restart
~/.config/polybar/launch.sh restart --force
```

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
- `launch.sh`: Enhanced launch script with profile support

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

Make changes incrementally and restart the polybar:

```sh
~/.config/polybar/launch.sh restart
```

To check status:

```sh
~/.config/polybar/launch.sh status
```

---

## 🚫 Disabling Polybar for a Rice

If you want a rice that doesn't use polybar at all, you can either:

1. **Omit the `POLYBAR_PROFILE` variable** - the system will fall back to defaults
2. **Set an empty profile** - create a profile that launches no bars
3. **Use a different status bar** - the profile system is flexible

---

## 🆘 Need Help?

- [Polybar Wiki](https://github.com/polybar/polybar/wiki)
- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Design your own status bar and make your desktop truly yours. The profile system makes it easy to have different configurations for different themes! 🚀
