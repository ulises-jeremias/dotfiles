# 🌐 Network Manager Guide

This section provides guidance for managing and configuring your network setup using **NetworkManager**, with custom dotfiles support.

> [!TIP]
> Like everything else in this setup, the Network Manager integration is **fully customizable**. You can configure connections, UI tools, and even define shortcuts or scripts — all managed through your dotfiles and `chezmoi`.

---

## ⚙️ Tools You Can Use

Depending on your preference, you can use either graphical or terminal-based tools for managing networks:

### 1. **`nmtui`** – TUI interface (Text-based User Interface)

```sh
nmtui
```

Use this for:

- Activating or deactivating connections
- Connecting to Wi-Fi
- Setting static IP addresses

### 2. **`nmcli`** – Command-line Interface

```sh
nmcli device wifi list
nmcli device wifi connect <SSID> password <password>
```

Use this for scripting, automating, or managing networks programmatically.

### 3. **`network-manager-applet`** – GUI tray icon

If you're running a system tray (e.g., via Waybar), you can use the applet to manage Wi-Fi and VPNs.

Install:

```sh
sudo pacman -S network-manager-applet  # Arch-based
```

---

## 📁 Dotfiles Integration

While network configurations aren't typically stored directly in the dotfiles, you can:

- Create helper scripts to automate Wi-Fi/VPN switching
- Manage your tray applet visibility and behavior
- Bind hotkeys for toggling Wi-Fi, VPN, or Airplane Mode

You can version any helper script or autostart command using `chezmoi`:

```sh
chezmoi edit ~/.config/autostart/network-helper.sh
```

---

## ✨ Example: Quick Connect Script

Here’s an example `nmcli` script that you can store in `~/.local/bin/connect-home-wifi.sh`:

```sh
#!/bin/bash
nmcli device wifi connect "HomeWiFi" password "yourpassword"
```

Make it executable:

```sh
chmod +x ~/.local/bin/connect-home-wifi.sh
```

Add it to your `chezmoi` config or call it from a keybinding.

---

## 🧪 Debugging Network Issues

Useful `nmcli` commands:

```sh
nmcli general status
nmcli device
nmcli connection show
journalctl -u NetworkManager.service
```

---

## 🆘 Need Help?

- [NetworkManager Arch Wiki](https://wiki.archlinux.org/title/NetworkManager)
- [Official NetworkManager Docs](https://networkmanager.dev/)
- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Take control of your network configuration with tools that match your workflow — whether it's terminal, GUI, or automation! 📡
