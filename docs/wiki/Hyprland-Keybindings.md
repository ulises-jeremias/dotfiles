# Hyprland Keybindings

Complete reference for all keybindings in HorneroConfig's Hyprland setup.

## Applications and Utilities

| Keybinding             | Function                                               |
|------------------------|--------------------------------------------------------|
| `Super+Return`         | Terminal (`exo-open --launch TerminalEmulator`)        |
| `Super+T`              | Terminal                                               |
| `Ctrl+Space`           | Application launcher (`dots-launcher`)                 |
| `Super+V`              | Clipboard manager (`dots-clipboard`)                   |
| `Super+?` or `Super+/` | Keyboard shortcuts help overlay (`dots-keyboard-help`) |
| `Super+D`              | Dashboard (Quickshell IPC)                             |
| `Super+Shift+Tab`      | Task switcher (`dots-snappy-switcher prev`)            |
| `Alt+Tab`              | Task switcher (`dots-snappy-switcher next`)            |
| `Super+E`              | Terminal file manager (`yazi` in a kitty popup)        |
| `Super+F`              | GUI file manager (`exo-open --launch FileManager`)     |
| `Super+W`              | Web browser (`exo-open --launch WebBrowser`)           |
| `Print`                | Screenshot of the current screen (`dots screenshooter`)|
| `Shift+Print`          | Screenshot with region selection (`dots screenshooter -r`) |

## Window Management

| Keybinding           | Function                                                    |
|----------------------|-------------------------------------------------------------|
| `Super+Shift+Q`      | Close focused window                                        |
| `Alt+Q`              | Close focused window                                        |
| `Alt+F4`             | Close focused window                                        |
| `Super+F`            | Smart floating (toggle + center + resize)                   |
| `Super+M`            | Toggle fullscreen                                           |
| `Super+Shift+M`      | Toggle maximize (fullscreen, mode 1)                        |
| `Super+Shift+Space`  | Focus toggle (floating <-> tiled)                           |
| `Super+Space`        | Toggle tiling/floating                                      |
| `Super+P`            | Focus parent (group)                                        |
| `Super+C`            | Focus child (group)                                         |
| `Super+U`            | Promote focused window to its own column (scrolling layout) |
| `Super+'`            | Toggle focus fit mode (center <-> fit)                      |
| `Super+Shift+P`      | Pin window to all workspaces                                |
| `Super+Ctrl+W`       | Toggle layout profile (scrolling <-> dwindle)               |
| `Super+Ctrl+Shift+W` | Force scrolling profile                                     |
| `Super+Ctrl+Alt+W`   | Force dwindle profile                                       |

## Window Focus

| Keybinding                | Function           |
|---------------------------|--------------------|
| `Super+H` / `Super+Left`  | Focus window left  |
| `Super+J` / `Super+Down`  | Focus window down  |
| `Super+K` / `Super+Up`    | Focus window up    |
| `Super+L` / `Super+Right` | Focus window right |

## Window Movement

| Keybinding                            | Function          |
|---------------------------------------|-------------------|
| `Super+Shift+H` / `Super+Shift+Left`  | Move window left  |
| `Super+Shift+J` / `Super+Shift+Down`  | Move window down  |
| `Super+Shift+K` / `Super+Shift+Up`    | Move window up    |
| `Super+Shift+L` / `Super+Shift+Right` | Move window right |

## Window Resizing

| Keybinding     | Function             |
|----------------|----------------------|
| `Super+R`      | Enter resize mode    |
| `Super+Ctrl+H` | Resize shrink width  |
| `Super+Ctrl+J` | Resize grow height   |
| `Super+Ctrl+K` | Resize shrink height |
| `Super+Ctrl+L` | Resize grow width    |

## Workspace Navigation

| Keybinding                    | Function                                    |
|-------------------------------|---------------------------------------------|
| `Super+1-9,0`                 | Switch to workspace 1-10                    |
| `Super+KP_1-9,0`              | Switch to workspace 1-10 (numpad)           |
| `Super+Tab`                   | Cycle forward through workspaces            |
| `Super+Shift+Tab`             | Cycle backward through workspaces           |
| `Super+Mouse Wheel Down/Up`   | Next / previous workspace                   |

## Window to Workspace

| Keybinding             | Function                               |
|------------------------|----------------------------------------|
| `Super+Shift+1-9,0`    | Move window to workspace 1-10          |
| `Super+Shift+KP_1-9,0` | Move window to workspace 1-10 (numpad) |
| `Super+Ctrl+Shift+1-9,0` | Move window silently (no switch)     |

## Scratchpad (Special Workspace)

| Keybinding      | Function                             |
|-----------------|--------------------------------------|
| `Super+S`       | Toggle special workspace (`magic`)   |
| `Super+Shift+S` | Move window to special workspace     |

## Scrolling Layout (Niri-style)

| Keybinding                                | Function                                     |
|-------------------------------------------|----------------------------------------------|
| `Super+Alt+H`                             | Move layout viewport one column to the left  |
| `Super+Alt+L`                             | Move layout viewport one column to the right |
| `Super+Alt+,`                             | Swap active column with left neighbor        |
| `Super+Alt+.`                             | Swap active column with right neighbor       |
| `Super+Alt+-` / `Super+Alt+=`             | Decrease/increase column width preset        |
| `Super+Alt+Shift+-` / `Super+Alt+Shift+=` | Fine resize column width                     |
| `Super+Alt+F`                             | Fit active column into view                  |
| `Super+Alt+Shift+F`                       | Fit visible columns into view                |

## Group Management

| Keybinding       | Function                          |
|------------------|-----------------------------------|
| `Super+G`        | Toggle group                      |
| `Super+,`        | Focus previous member in group    |
| `Super+.`        | Focus next member in group        |
| `Super+Shift+O`  | Lock/unlock active group          |

## Gaps Control

| Keybinding       | Function                                            |
|------------------|-----------------------------------------------------|
| `Super+Shift+G`  | Interactive gaps adjustment (`gaps-interactive.sh`) |

The interactive script walks you through increasing, decreasing, resetting,
and removing gaps without memorizing separate keys.

## System Controls

| Keybinding      | Function                                  |
|-----------------|-------------------------------------------|
| `Super+Ctrl+B`  | Toggle Bar (Quickshell)                   |
| `Super+Ctrl+P`  | Dashboard (Quickshell IPC)                |
| `Super+X`       | Power menu (`dots-power-menu`)            |
| `Super+L`       | Lock screen (Quickshell IPC lock)         |
| `Super+Shift+R` | Reload Hyprland configuration             |
| `Super+Shift+E` | Exit Hyprland                             |

## Media Controls

| Keybinding       | Function         |
|------------------|------------------|
| `XF86AudioPlay`  | Play/pause media |
| `XF86AudioPause` | Pause media      |
| `XF86AudioNext`  | Next track       |
| `XF86AudioPrev`  | Previous track   |
| `XF86AudioStop`  | Stop playback    |

## Volume Controls

| Keybinding             | Function               |
|------------------------|------------------------|
| `XF86AudioRaiseVolume` | Increase volume (+5%)  |
| `XF86AudioLowerVolume` | Decrease volume (-5%)  |
| `XF86AudioMute`        | Toggle mute            |
| `XF86AudioMicMute`     | Toggle microphone mute |

## Brightness Controls

| Keybinding              | Function                       |
|-------------------------|--------------------------------|
| `XF86MonBrightnessUp`   | Increase brightness (+10%)     |
| `XF86MonBrightnessDown` | Decrease brightness (-10%)     |
| `Shift+XF86MonBrightnessUp`   | Increase brightness (+1%) |
| `Shift+XF86MonBrightnessDown` | Decrease brightness (-1%) |

## Mouse Bindings

| Action              | Function      |
|---------------------|---------------|
| `Super+Left Click`  | Move window   |
| `Super+Right Click` | Resize window |

## Touchpad Gestures

Three-finger horizontal swipes switch workspaces (see `gestures` block in
`hyprland.conf`). There is currently no gesture bound to the ScrollOverview;
toggle it with `Super+O`.

## ScrollOverview (niri-style overview)

Toggle a bird's-eye view of all workspaces and windows, powered by the
[hyprland-scroll-overview](https://github.com/yayuuu/hyprland-scroll-overview)
plugin.

| Keybinding | Function                                  |
|------------|-------------------------------------------|
| `Super+O`  | Toggle the overview on the active monitor |

### ScrollOverview submap

While the overview is open, the `scrolloverview` submap provides keyboard
navigation. Normal Hyprland binds outside this submap are not handled unless
they use the `submap_universal` flag.

| Keybinding                       | Function                                                                  |
|----------------------------------|---------------------------------------------------------------------------|
| `Left` / `Right` / `Up` / `Down` | Move selection between windows (and across workspaces at the layout edge) |
| `Return`                         | Select the workspace under the cursor                                     |
| `Escape`                         | Close the overview                                                        |

## Special Modes

### Resize Mode (`Super+R`)

Once in resize mode:

- `H` / `Left` - Shrink width
- `J` / `Down` - Grow height
- `K` / `Up` - Shrink height
- `L` / `Right` - Grow width
- `Escape` / `Return` - Exit resize mode

## Configuration Files

Keybindings live in:

```bash
~/.config/hypr/hyprland.conf.d/keybindings.conf
```

Hyprland does not hot-reload custom files that do not exist, so add your own
bindings directly at the end of this file or create a new file and source it
from `hyprland.conf`.

## Customization

To add custom keybindings, edit:

```bash
~/.config/hypr/hyprland.conf.d/keybindings.conf
```

Example:

```conf
# Custom application launcher
bind = $Mod, B, exec, firefox

# Custom window manipulation
bind = $Mod SHIFT, M, togglesplit
```

## Tips

- **Modkey**: `Super` (Windows key) is the primary modifier
- **Consistent with Vim**: `H J K L` for directional movement
- **Arrow keys work**: All directional bindings have arrow key alternatives
- **Numpad support**: Full numpad support for workspace switching
- **Adaptive**: Smart floating automatically centers and resizes windows appropriately
