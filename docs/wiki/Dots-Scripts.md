# 💥 Dots Scripts Utility Guide

As part of this dotfiles installation, we provide a curated collection of utility scripts that help automate and enhance your desktop experience. These scripts handle everything from brightness control to network checks, and they’re neatly organized under a single command: `dots`.

> [!TIP]
> All scripts are fully customizable. You can modify them, add your own, or extend existing ones — and manage them with `chezmoi` just like any other part of your dotfiles.

---

## 🚀 What is `dots`?

`dots` is a wrapper utility that exposes various helpful scripts for configuring modules and interacting with your system.

You can use it directly from the terminal to:

- Run scripts individually
- Discover available helpers
- Simplify your workflow

---

## 📦 Usage

```sh
dots --help     # Show help menu
dots --list     # List all available scripts
dots <script>   # Run a specific script (with optional flags)
```

> 🔍 Pro Tip: You can use `chezmoi edit ~/.local/bin/dots` to customize the wrapper script if needed.

---

## 📜 Available Scripts

> 📝 This list may evolve. To check the current list on your system, run: `dots --list`

- `brightness` – Adjust screen brightness via `xbacklight`, `brightnessctl`, `blight`, or `xrandr`
- `check-network` – Check if you’re connected to the internet
- `checkupdates` – Query available package updates
- `config-manager` – Manage configuration snapshots and backups
- `dependencies` – Check and install required system dependencies
- `feh-blur` – Blur the background when using feh to set wallpaper
- `git-notify` – Send notifications when git commits are made
- `i3-resurrect-rofi` – Manage i3-resurrect workspace profiles via Rofi menu
- `jgmenu` – Launch jgmenu application launcher
- `microphone` – Monitor and toggle microphone mute status with visual indicators
- `monitor` – Get the name of the currently active monitor
- `next-workspace` – Switch to the next existing i3 workspace
- `night-mode` – Toggle night mode/blue light filter
- `performance` – Monitor system performance and run benchmarks
- `popup-calendar` – Display a calendar in a popup window
- `rofi-bluetooth` – Manage Bluetooth device connections via Rofi menu
- `rofi-randr` – Display resolution management via Rofi menu
- `rofi-rice-selector` – Select and apply desktop rice themes via Rofi menu
- `rofi-run` – Enhanced Rofi application and command launcher
- `rofi-xrandr` – Advanced display configuration with charts via Rofi
- `screenshooter` – Take screenshots with various options and formats
- `scripts` – Interactive menu to browse and launch available dots scripts
- `security-audit` – Run comprehensive security audits and apply security fixes
- `sysupdate` – Perform comprehensive system updates
- `toggle` – Toggle state of applications like polybar, compositor, notifications
- `updates` – Check and display available package updates with notifications
- `wal-reload` – Reload pywal colorscheme and apply to i3, rofi, eww, betterlockscreen, discord
- `weather-info` – Display current weather information and forecasts

---

## 🧠 Customizing Scripts

All scripts can be found in your dotfiles repo (usually under `~/.local/bin/`). To customize:

```sh
chezmoi edit ~/.local/bin/<script-name>
chezmoi apply
```

You can also add your own scripts and link them via the `dots` interface for quick access.

---

## 🆘 Need Help?

- Explore the script source code: `chezmoi edit ~/.local/bin/dots`
- Join the [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Use the `dots` utility to take your workflow to the next level. Automate, simplify, and enjoy the full power of your environment! ⚡
