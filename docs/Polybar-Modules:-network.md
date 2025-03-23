# 🌐 Polybar Module: Network Connection

The **Network Connection module** displays the current state of your network and gives you quick access to manage connections via a simple menu interface.

> [!TIP]
> Built for convenience — view your connection status and switch networks with just one click.

---

## 📶 Functionality

- **Status Indicator**: Shows an icon reflecting the current network state (e.g., connected, disconnected)
- **Left-click**: Opens `networkmanager-dmenu` — a minimal and efficient menu to manage available connections

---

## ⚙️ Configuration Example

```ini
[module/network]
type = custom/script
exec = dots check-network
click-left = networkmanager_dmenu
interval = 5
```

> [!TIP]
> The `dots check-network` script prints a visual indicator (icon or label) depending on your connection status.

---

## ✅ Requirements

- [networkmanager-dmenu](https://github.com/firecat53/networkmanager-dmenu) installed
- `dots check-network` script (part of the dotfiles)
- NetworkManager service running and managing your network connections

---

## 🎨 Customization Tips

- Adjust the icon output in the `dots check-network` script to match your style or status bar theme
- You can replace `networkmanager_dmenu` with any other script or launcher (like `nm-connection-editor` or `nmtui`)

---

A lightweight, intuitive way to manage your connection status — always a click away! 📡
