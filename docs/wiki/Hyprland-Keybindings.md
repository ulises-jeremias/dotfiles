# Hyprland Keybindings

Complete reference for all keybindings in HorneroConfig's Hyprland setup.

## Applications and Utilities

| Keybinding | Function |
|------------|----------|
| `Super+Return` | Terminal (Kitty) |
| `Super+D` | Application launcher (Quickshell) |
| `Alt+Ctrl+C` | Clipboard manager (`dots-clipboard`) |
| `Super+?` or `Super+/` | Keyboard shortcuts help overlay (`dots-keyboard-help`) |
| `Super+Ctrl+Space` | AI assistant (sgpt via IBus) |
| `Super+Shift+Tab` | Task switcher (`dots-snappy-switcher prev`) |
| `Super+E` | File manager (Thunar) |
| `Super+Shift+S` | Screenshot tool (grimblast/grim) |
| `Print` | Screenshot (area selection) |

## Window Management

| Keybinding | Function |
|------------|----------|
| `Super+Q` | Close focused window |
| `Super+Shift+Q` | Kill focused window (force) |
| `Super+F` | Toggle fullscreen |
| `Super+Shift+F` | Smart floating (toggle + center + resize) |
| `Super+Shift+Space` | Focus toggle (floating ↔ tiled) |
| `Super+Ctrl+C` | Center floating window |
| `Super+Space` | Toggle tiling/floating |
| `Super+P` | Focus parent (group) |
| `Super+C` | Focus child (group) |
| `Super+U` | Promote focused window to its own column (scrolling layout) |
| `Super+'` | Toggle focus fit mode (center ↔ fit) |

## Window Focus

| Keybinding | Function |
|------------|----------|
| `Super+H` / `Super+Left` | Focus window left |
| `Super+J` / `Super+Down` | Focus window down |
| `Super+K` / `Super+Up` | Focus window up |
| `Super+L` / `Super+Right` | Focus window right |

## Window Movement

| Keybinding | Function |
|------------|----------|
| `Super+Shift+H` / `Super+Shift+Left` | Move window left |
| `Super+Shift+J` / `Super+Shift+Down` | Move window down |
| `Super+Shift+K` / `Super+Shift+Up` | Move window up |
| `Super+Shift+L` / `Super+Shift+Right` | Move window right |

## Window Resizing

| Keybinding | Function |
|------------|----------|
| `Super+R` | Enter resize mode |
| `Super+Ctrl+H` | Resize shrink width |
| `Super+Ctrl+J` | Resize grow height |
| `Super+Ctrl+K` | Resize shrink height |
| `Super+Ctrl+L` | Resize grow width |

## Workspace Navigation

| Keybinding | Function |
|------------|----------|
| `Super+1-9,0` | Switch to workspace 1-10 |
| `Super+KP_1-9,0` | Switch to workspace 1-10 (numpad) |
| `Super+Alt+Left` | Previous active workspace |
| `Super+Alt+Right` | Next active workspace |
| `Super+Ctrl+Left` | Previous existing workspace |
| `Super+Ctrl+Right` | Next existing workspace |
| `Super+Tab` | Cycle through workspaces |

## Window to Workspace

| Keybinding | Function |
|------------|----------|
| `Super+Shift+1-9,0` | Move window to workspace 1-10 |
| `Super+Shift+KP_1-9,0` | Move window to workspace 1-10 (numpad) |

## Scratchpad

| Keybinding | Function |
|------------|----------|
| `Super+Z` | Toggle scratchpad visibility |
| `Super+Shift+Z` | Move window to scratchpad |

## Scrolling Layout (Niri-style)

| Keybinding | Function |
|------------|----------|
| `Super+Alt+H` | Move layout viewport one column to the left |
| `Super+Alt+L` | Move layout viewport one column to the right |
| `Super+Alt+,` | Swap active column with left neighbor |
| `Super+Alt+.` | Swap active column with right neighbor |
| `Super+Alt+-` / `Super+Alt+=` | Decrease/increase column width preset |
| `Super+Alt+Shift+-` / `Super+Alt+Shift+=` | Fine resize column width |
| `Super+Alt+F` | Fit active column into view |
| `Super+Alt+Shift+F` | Fit visible columns into view |

## Gaps Control

| Keybinding | Function |
|------------|----------|
| `Super+G, +` | Increase gaps |
| `Super+G, -` | Decrease gaps |
| `Super+G, 0` | Reset gaps to default |
| `Super+G, Shift+0` | Remove all gaps |

## System Controls

| Keybinding | Function |
|------------|----------|
| `Super+Ctrl+P` | Toggle Bar (Quickshell) |
| `Super+Ctrl+M` | Toggle Notification Center (Quickshell) |
| `Super+Shift+R` | Reload Hyprland configuration |
| `Super+Shift+E` | Exit Hyprland |
| `Super+X` | System power menu (Quickshell) |
| `Super+L` | Lock screen (Hyprlock) |

## Media Controls

| Keybinding | Function |
|------------|----------|
| `XF86AudioPlay` | Play/pause media |
| `XF86AudioPause` | Pause media |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `XF86AudioStop` | Stop playback |

## Volume Controls

| Keybinding | Function |
|------------|----------|
| `XF86AudioRaiseVolume` | Increase volume (+1%) |
| `XF86AudioLowerVolume` | Decrease volume (-1%) |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |

## Brightness Controls

| Keybinding | Function |
|------------|----------|
| `XF86MonBrightnessUp` | Increase brightness |
| `XF86MonBrightnessDown` | Decrease brightness |

## Mouse Bindings

| Action | Function |
|--------|----------|
| `Super+Left Click` | Move window |
| `Super+Right Click` | Resize window |
| `Super+Middle Click` | Toggle floating |

## Special Modes

### Resize Mode (`Super+R`)

Once in resize mode:

- `H` / `Left` - Shrink width
- `J` / `Down` - Grow height
- `K` / `Up` - Shrink height
- `L` / `Right` - Grow width
- `Escape` / `Return` - Exit resize mode

### Gaps Mode (`Super+G`)

Interactive gaps adjustment:

- `+` / `=` - Increase gaps
- `-` - Decrease gaps
- `0` - Reset to default
- `Shift+0` - Remove all gaps
- `Escape` / `Return` - Exit gaps mode

## Configuration Files

Keybindings are organized in:

```bash
~/.config/hypr/hyprland.conf.d/
├── keybindings.conf           # Core keybindings
├── keybindings-media.conf     # Media and volume controls
└── keybindings-custom.conf    # User customizations
```

## Customization

To add custom keybindings, edit:

```bash
~/.config/hypr/hyprland.conf.d/keybindings-custom.conf
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
