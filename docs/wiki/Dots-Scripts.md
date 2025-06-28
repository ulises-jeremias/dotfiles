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
- `feh-blur` – Blur your wallpaper background with `feh`
- `git-notify` – Send a notification after a Git commit
- `microphone` – Mute/unmute or control mic levels
- `monitor` – Display current monitor name
- `night-mode` – Toggle night mode for low light environments
- `openweathermap-detailed` – Show detailed weather info from OpenWeatherMap
- `popup-calendar` – Display a calendar in a popup window
- `rofi-bluetooth` – Manage Bluetooth devices using a Rofi menu
- `rofi-randr` – Change screen resolution using a Rofi menu
- `rofi-run` – Launch applications using a Rofi menu
- `rofi-xrandr` – Extended screen resolution manager using Rofi and charts
- `screenshooter` – Take screenshots or region captures
- `spotify` – Display current song info from Spotify
- `sysupdate` – Run a full system update
- `toggle` – Toggle the state of specific apps or modules (e.g., Polybar menus)
- `updates` – Check for software updates
- `weather` – Display current weather summary

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
