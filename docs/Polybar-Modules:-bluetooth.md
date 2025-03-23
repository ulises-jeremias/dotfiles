# 📶 Polybar Module: Rofi Bluetooth

The **Rofi Bluetooth module** is a custom implementation built on top of the [`internal/script`](https://github.com/polybar/polybar/wiki/Module:-script) module. It provides real-time display of your Bluetooth status and offers a clean Rofi-powered interface for managing devices.

> [!TIP]
> This module integrates seamlessly with the `dots rofi-bluetooth` script and updates dynamically based on your Bluetooth state.

---

## 🔧 How It Works

The module executes:

```sh
dots rofi-bluetooth --status | cut -d " " -f 1
```

This prints the current Bluetooth state (e.g., `ON` or `OFF`) and updates as the state changes.

---

## 📦 Features

- **Bluetooth Status**: Displays whether Bluetooth is currently enabled or disabled
- **Live Updates**: Automatically listens for state changes
- **Rofi UI**: Launches a Rofi menu to enable/disable Bluetooth and manage paired devices

---

## 🖥️ Example Screenshot

Here’s how the Rofi Bluetooth UI looks in action:

![Rofi Bluetooth](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/rofi-bluetooth.gif?raw=true)

> [!TIP]
> You can assign a click action in Polybar to trigger the Rofi UI using `dots rofi-bluetooth`.

---

## ⚙️ Configuration Tips

This module uses `type = custom/script` in Polybar. Example snippet:

```ini
[module/rofi-bluetooth]
type = custom/script
exec = dots rofi-bluetooth --status | cut -d ' ' -f 1
click-left = dots rofi-bluetooth
interval = 5
```

Refer to the [Polybar script module documentation](https://github.com/polybar/polybar/wiki/Module:-script) for all available options.

---

## ✅ Requirements

- `bluetoothctl` or BlueZ installed and active
- Rofi installed and configured
- `dots rofi-bluetooth` script available in your path (included with this dotfiles setup)

---

Control your Bluetooth with style and speed — all from your Polybar. 🔵📡
