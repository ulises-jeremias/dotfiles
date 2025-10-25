# Keybindings i3 → Hyprland Compatibility

## Nuevos Keybindings Agregados

### Aplicaciones y Utilidades
| Keybinding | Función | Equivalente i3 |
|------------|---------|----------------|
| `Alt+Ctrl+C` | Clipboard manager (rofi) | `Alt+Ctrl+C` |
| `Super+Ctrl+Space` | IBus engine switcher (sgpt) | `Super+Ctrl+Space` |
| `Super+Shift+Tab` | Task switcher (rofi window) | `Super+Shift+Tab` (skippy-xd) |

### Gestión de Ventanas
| Keybinding | Función | Equivalente i3 |
|------------|---------|----------------|
| `Super+Shift+F` | Smart floating (toggle + center + resize) | `Super+Shift+F` |
| `Super+Shift+Space` | Focus toggle (floating ↔ tiled) | `Super+Shift+Space` |
| `Super+Ctrl+C` | Center window | `Super+Ctrl+C` |
| `Super+P` | Focus parent (group) | `Super+P` |
| `Super+C` | Focus child (group) | `Super+C` |

### Navegación con Numpad
| Keybinding | Función | Equivalente i3 |
|------------|---------|----------------|
| `Super+KP_1-9,0` | Switch to workspace 1-10 | `Super+Mod2+KP_*` |
| `Super+Shift+KP_1-9,0` | Move window to workspace 1-10 | `Super+Shift+Mod2+KP_*` |

### Navegación de Workspaces
| Keybinding | Función | Equivalente i3 |
|------------|---------|----------------|
| `Super+Alt+Left` | Previous active workspace | `Super+Alt+Left` |
| `Super+Alt+Right` | Next active workspace | `Super+Alt+Right` |
| `Super+Ctrl+Left` | Previous existing workspace (dots) | `Super+Ctrl+Left` |
| `Super+Ctrl+Right` | Next existing workspace (dots) | `Super+Ctrl+Right` |

### Scratchpad
| Keybinding | Función | Equivalente i3 |
|------------|---------|----------------|
| `Super+Z` | Toggle scratchpad | `Super+Z` |
| `Super+Shift+Z` | Move to scratchpad | `Super+Shift+Z` |

### Layouts
| Keybinding | Función | Equivalente i3 |
|------------|---------|----------------|
| `Super+Alt+H` | Split horizontal hint | `Super+H` |
| `Super+Alt+V` | Split vertical hint | `Super+V` |
| `Super+V` | Toggle split direction | - |
| `Super+Shift+T` | Toggle group (tabbed mode) | `Super+Shift+T` |
| `Super+Shift+S` | Toggle group (stacking mode) | `Super+Shift+S` |
| `Super+Shift+H` | Toggle split | `Super+Shift+H` |
| `Alt+Tab` | Cycle next window | `Alt+Tab` |
| `Alt+Shift+Tab` | Cycle previous window | - |

### Gaps Management
| Keybinding | Función | Equivalente i3 |
|------------|---------|----------------|
| `Super+G` | Interactive gaps mode (rofi) | `Super+G` |
| `Super+Alt+=` | Increase inner gaps (+5) | `Super+G → I → +` |
| `Super+Alt+-` | Decrease inner gaps (-5) | `Super+G → I → -` |
| `Super+Alt+0` | Reset inner gaps (12) | `Super+G → I → 0` |
| `Super+Shift+Alt+=` | Increase outer gaps (+5) | `Super+G → O → +` |
| `Super+Shift+Alt+-` | Decrease outer gaps (-5) | `Super+G → O → -` |
| `Super+Shift+Alt+0` | Reset outer gaps (18) | `Super+G → O → 0` |

### Borders
| Keybinding | Función | Equivalente i3 |
|------------|---------|----------------|
| `Super+Shift+B` | Toggle border (0px ↔ 2px) | `Super+Shift+B` |
| `Super+N` | Normal border (2px) | `Super+N` |
| `Super+Y` | Thin border (1px) | `Super+Y` |
| `Super+U` | No border (0px) | `Super+U` |

### Sistema
| Keybinding | Función | Equivalente i3 |
|------------|---------|----------------|
| `Super+Shift+C` | Reload config | `Super+Shift+C` |
| `Super+Ctrl+P` | Toggle waybar | `Super+Ctrl+P` (polybar) |

## Notas

### Diferencias con i3

1. **Gaps Mode**: En i3 tenías un modo interactivo con submenús. En Hyprland usamos:
   - `Super+G` para abrir un menú rofi interactivo
   - Atajos directos con `Super+Alt` para inner y `Super+Shift+Alt` para outer

2. **Focus Parent/Child**: En Hyprland no hay jerarquía de contenedores como i3. Usamos `changegroupactive` para navegar grupos (tabs).

3. **Layout Toggle**: i3 tiene múltiples layouts (tabbed, stacking, split). Hyprland usa:
   - **Groups** para simular tabbed/stacking
   - **Split** para dividir horizontal/vertical
   - Layouts principales: `dwindle` (default) y `master`

4. **Smart Floating**: El script `smart-float.sh` de i3 se replica con:
   ```bash
   hyprctl dispatch togglefloating && hyprctl dispatch centerwindow
   ```

5. **Scratchpad**: En Hyprland se llama "special workspace". Funciona similar pero es un workspace completo.

6. **Volume Control**: Ajustado a 1% de incremento (matching i3) en lugar de 5% default.

## Keybindings Originales de Hyprland (ya existentes)

Estos estaban antes y se mantienen:

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

## Scripts Creados

1. **`~/.config/hypr/scripts/gaps-interactive.sh`**
   - Menú rofi interactivo para ajustar gaps
   - Similar al modo gaps de i3
   - Muestra valores actuales
   - Notificaciones al cambiar

## Testing

Prueba estos nuevos keybindings:

```bash
# Gaps interactivo
Super+G

# Navegar workspaces con numpad
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

## Archivo de Configuración

Los nuevos keybindings están en:
```
~/.config/hypr/hyprland.conf.d/keybindings-i3-compat.conf
```

Sourced desde `hyprland.conf` después de `keybindings.conf`.
