# 🧩 Polybar Module: i3 Workspace Icons

The **i3 Workspace Icon module** displays dynamic icons for your i3 workspaces and allows you to interactively switch between them via mouse actions.

> [!TIP]
> Useful for visually tracking your open workspaces and navigating across them quickly.

---

## 🧭 Functionality

This module supports multiple interactions:

- **Left-click** → Switch to a specific workspace using:

  ```sh
  i3-msg workspace <index>
  ```

- **Scroll Up** → Move to the previous workspace:

  ```sh
  i3-msg workspace prev
  ```

- **Scroll Down** → Move to the next workspace:

  ```sh
  i3-msg workspace next
  ```

These commands let you navigate through your i3 setup with ease, straight from your Polybar.

---

## ⚙️ Configuration Snippet

```ini
[module/i3]
type = internal/i3
format = <label-state>
label-focused =   %name%
label-unfocused =   %name%
click-left = i3-msg workspace %index%
scroll-up = i3-msg workspace prev
scroll-down = i3-msg workspace next
```

> [!TIP]
> You can replace icons (``, ``, etc.) and labels based on your icon font (e.g., Nerd Fonts).

---

## ✅ Requirements

- [i3 Window Manager](https://i3wm.org/)
- `i3-msg` installed and in your PATH
- Workspaces must be correctly defined in your i3 configuration

---

## 🎨 Customization Tips

- Map specific icons to workspace names for better visual cues (e.g.,  for terminal,  for browser)
- Adjust font and padding to align with your overall Polybar theme
- Combine with other modules like `rofi-run` or `eww` to enhance your window management setup

---

Enhance your workspace switching flow with this sleek and interactive module — right from the bar! 🖱️🖥️
