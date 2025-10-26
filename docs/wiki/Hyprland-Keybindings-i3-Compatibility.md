# Keybindings i3 → Hyprland Compatibility

## New Keybindings Added

### Applications and Utilities

| Keybinding | Function | i3 Equivalent |
|------------|----------|---------------|
| `Alt+Ctrl+C` | Clipboard manager (rofi) | `Alt+Ctrl+C` |
| `Super+Ctrl+Space` | IBus engine switcher (sgpt) | `Super+Ctrl+Space` |
| `Super+Shift+Tab` | Task switcher (rofi window) | `Super+Shift+Tab` (skippy-xd) |

### Window Management

| Keybinding | Function | i3 Equivalent |
|------------|----------|---------------|
| `Super+Shift+F` | Smart floating (toggle + center + resize) | `Super+Shift+F` |
| `Super+Shift+Space` | Focus toggle (floating ↔ tiled) | `Super+Shift+Space` |
| `Super+Ctrl+C` | Center window | `Super+Ctrl+C` |
| `Super+P` | Focus parent (group) | `Super+P` |
| `Super+C` | Focus child (group) | `Super+C` |

### Numpad Navigation

| Keybinding | Function | i3 Equivalent |
|------------|----------|---------------|
| `Super+KP_1-9,0` | Switch to workspace 1-10 | `Super+Mod2+KP_*` |
| `Super+Shift+KP_1-9,0` | Move window to workspace 1-10 | `Super+Shift+Mod2+KP_*` |

### Workspace Navigation

| Keybinding | Function | i3 Equivalent |
|------------|----------|---------------|
| `Super+Alt+Left` | Previous active workspace | `Super+Alt+Left` |
| `Super+Alt+Right` | Next active workspace | `Super+Alt+Right` |
| `Super+Ctrl+Left` | Previous existing workspace (dots) | `Super+Ctrl+Left` |
| `Super+Ctrl+Right` | Next existing workspace (dots) | `Super+Ctrl+Right` |

### Scratchpad

| Keybinding | Function | i3 Equivalent |
|------------|----------|---------------|
| `Super+Z` | Toggle scratchpad | `Super+Z` |
| `Super+Shift+Z` | Move to scratchpad | `Super+Shift+Z` |

### Layouts

| Keybinding | Function | i3 Equivalent |
|------------|----------|---------------|
| `Super+Alt+H` | Split horizontal hint | `Super+H` |
| `Super+Alt+V` | Split vertical hint | `Super+V` |
| `Super+V` | Toggle split direction | - |
| `Super+Shift+T` | Toggle group (tabbed mode) | `Super+Shift+T` |
| `Super+Shift+S` | Toggle group (stacking mode) | `Super+Shift+S` |
| `Super+Shift+H` | Toggle split | `Super+Shift+H` |
| `Alt+Tab` | Cycle next window | `Alt+Tab` |
| `Alt+Shift+Tab` | Cycle previous window | - |

### Gaps Management

| Keybinding | Function | i3 Equivalent |
|------------|----------|---------------|
| `Super+G` | Interactive gaps mode (rofi) | `Super+G` |
| `Super+Alt+=` | Increase inner gaps (+5) | `Super+G → I → +` |
| `Super+Alt+-` | Decrease inner gaps (-5) | `Super+G → I → -` |
| `Super+Alt+0` | Reset inner gaps (12) | `Super+G → I → 0` |
| `Super+Shift+Alt+=` | Increase outer gaps (+5) | `Super+G → O → +` |
| `Super+Shift+Alt+-` | Decrease outer gaps (-5) | `Super+G → O → -` |
| `Super+Shift+Alt+0` | Reset outer gaps (18) | `Super+G → O → 0` |

### Borders

| Keybinding | Function | i3 Equivalent |
|------------|----------|---------------|
| `Super+Shift+B` | Toggle border (0px ↔ 2px) | `Super+Shift+B` |
| `Super+N` | Normal border (2px) | `Super+N` |
| `Super+Y` | Thin border (1px) | `Super+Y` |
| `Super+U` | No border (0px) | `Super+U` |

### System

| Keybinding | Function | i3 Equivalent |
|------------|----------|---------------|
| `Super+Shift+C` | Reload config | `Super+Shift+C` |
| `Super+Ctrl+P` | Toggle waybar | `Super+Ctrl+P` (polybar) |

## Notes

### Differences with i3

1. **Gaps Mode**: In i3 you had an interactive mode with submenus. In Hyprland we use:
   - `Super+G` to open an interactive rofi menu
   - Direct shortcuts with `Super+Alt` for inner and `Super+Shift+Alt` for outer

2. **Focus Parent/Child**: In Hyprland there is no container hierarchy like i3. We use `changegroupactive` to navigate groups (tabs).

3. **Layout Toggle**: i3 has multiple layouts (tabbed, stacking, split). Hyprland uses:
   - **Groups** to simulate tabbed/stacking
   - **Split** to divide horizontal/vertical
   - Main layouts: `dwindle` (default) and `master`

4. **Smart Floating**: The `smart-float.sh` script from i3 is replicated with:

   ```bash
   hyprctl dispatch togglefloating && hyprctl dispatch centerwindow
   ```

5. **Scratchpad**: In Hyprland it's called "special workspace". It works similarly but is a full workspace.

6. **Volume Control**: Adjusted to 1% increment (matching i3) instead of the 5% default.

## Original Hyprland Keybindings (already present)

These were present before and remain:

- `Super+Return / Super+T`: Terminal
- `Ctrl+Space`: Rofi launcher
- `Super+W/F/D/X/L`: Browser/Files/Dashboard/Powermenu/Lock
- `Super+Shift+Q / Alt+Q / Alt+F4`: Close window
- `Super+Space`: Toggle floating
- `Super+M`: Fullscreen
- `Super+1-9,0`: Switch workspace
- `Super+Shift+1-9,0`: Move to workspace
- `Super+Arrow/HJKL`: Focus movement
- `Super+Shift+Arrow/HJKL`: Window movement
- `Super+R`: Resize mode
- `Super+Shift+R`: Reload Hyprland
- Media keys: Volume, brightness, player controls
- `Print / Shift+Print`: Screenshots

## Created Scripts

1. **`~/.config/hypr/scripts/gaps-interactive.sh`**
   - Interactive rofi menu to adjust gaps
   - Similar to i3's gaps mode
   - Shows current values
   - Notifications on change

## Testing

Test these new keybindings:

```bash
# Interactive gaps
Super+G

# Navigate workspaces with numpad
Super+KP_1  # workspace 1
Super+KP_2  # workspace 2

# Workspace prev/next
Super+Alt+Left/Right

# Smart floating
Super+Shift+F

# Scratchpad
Super+Z
Super+Shift+Z

# Borders
Super+N  # normal
Super+Y  # thin
Super+U  # none
Super+Shift+B  # toggle

# Clipboard manager
Alt+Ctrl+C
```

## Configuration File

The new keybindings are in:

```
~/.config/hypr/hyprland.conf.d/keybindings-i3-compat.conf
```

Sourced from `hyprland.conf` after `keybindings.conf`.
