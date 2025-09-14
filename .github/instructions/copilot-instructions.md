# HorneroConfig GitHub Copilot Instructions

## Project Overview

You are working on **HorneroConfig**, a comprehensive Linux dotfiles framework named after the hornero bird. The project transforms Linux desktops into functional and beautiful environments using a modular, theme-adaptive approach.

## Key Technologies

- **Dotfiles Manager**: Chezmoi for cross-machine portability
- **Status Bar**: Polybar with 20+ modular components
- **Widgets**: EWW (dashboard, powermenu, sidebar)
- **Launcher**: Rofi with custom themes
- **Terminal**: Kitty (GPU-accelerated)
- **Shell**: Zsh + Powerlevel10k
- **Theming**: wpg/pywal + smart colors system
- **Window Managers**: i3, Openbox, XFCE4
- **Argument Parsing**: EasyOptions library (mandatory for all scripts)

## File Structure Context

- `home/` → Chezmoi-managed dotfiles (becomes `~/.config/`, `~/.local/`, etc.)
- `home/dot_config/` → Maps to `~/.config/`
- `home/dot_local/bin/` → Maps to `~/.local/bin/` (executables)
- `home/dot_local/lib/dots/` → Shared libraries and utilities
- `home/dot_local/share/dots/rices/` → Theme configurations
- `docs/` → Documentation (wiki + ADRs)
- `playground/` → Vagrant/Docker testing environment

## Coding Standards

### Shell Scripts (Mandatory)

**Always use this exact template for new scripts:**

```bash
#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Brief description of script functionality
##
## Check full documentation at: https://github.com/ulises-jeremias/dotfiles/wiki
##
## Usage:
##     @script.name [OPTIONS] [ARGUMENTS...]
##
## Options:
##     -h, --help      Show this help message.
##     -v, --verbose   Enable verbose output.
##     -d, --debug     Enable debug mode.
##     -q, --quiet     Suppress output.

set -euo pipefail

# Source EasyOptions for argument parsing
source ~/.local/lib/dots/easy-options/easyoptions.sh || exit

# Script logic using variables: ${verbose}, ${debug}, ${arguments[@]}
```

### Bash Best Practices

- **Strict mode**: Always use `set -euo pipefail`
- **Shebang**: Use `#!/usr/bin/env bash` (never `/bin/bash`)
- **Variables**: Quote all variables `"${variable}"`, never `$variable`
- **Conditionals**: Use `[[ ]]` instead of `[ ]`
- **Functions**: Use `snake_case` naming
- **Constants**: Use `UPPER_CASE` with `readonly`
- **Arrays**: Initialize as `items=()`, append with `items+=("value")`

### EasyOptions Integration

**For ALL user-facing scripts:**

1. **Documentation comments** with `##` define the CLI interface
2. **Options parsing** is automatic from documentation
3. **Variables** are auto-generated: `--debug` becomes `${debug}`
4. **Help text** is auto-generated from documentation
5. **Arguments** available in `${arguments[@]}` array

### Variable Naming

```bash
# Local variables and functions
config_file="/path/to/config"
rice_name="gruvbox-dark"
process_data() { ... }

# Constants and environment variables  
readonly CONFIG_DIR="$HOME/.config"
readonly RICE_DIR="$HOME/.local/share/dots/rices"
export POLYBAR_PROFILE="default"

# Arrays
selected_bars=()
selected_bars+=("top-bar")
selected_bars+=("bottom-bar")
```

## Architecture Patterns

### Smart Colors System

The project uses an intelligent color system that adapts to themes:

```bash
# Load smart colors (automatic in most scripts)
source ~/.local/lib/dots/smart-colors.sh

# Use semantic colors
echo -e "${COLOR_SUCCESS}Operation completed${COLOR_RESET}"
echo -e "${COLOR_ERROR}Error occurred${COLOR_RESET}"
echo -e "${COLOR_INFO}Information${COLOR_RESET}"
```

### Rice Theme System

Each rice theme follows this structure:
```
rices/theme-name/
├── config.sh          # Theme configuration
├── apply.sh           # Application script
├── backgrounds/       # Wallpaper images
└── preview.png        # Theme preview
```

### Polybar Integration

```bash
# Load profile-based configuration
POLYBAR_PROFILE="minimal"  # or "default"
~/.config/polybar/launch.sh --profile="${POLYBAR_PROFILE}"

# Module structure
~/.config/polybar/configs/default/modules/
├── audio.conf
├── bluetooth.conf
├── cpu.conf
└── ...
```

## Script Development Rules

### New Scripts Checklist

1. ✅ **Must use EasyOptions** for argument parsing
2. ✅ **Include copyright header** and documentation
3. ✅ **Follow error handling patterns**
4. ✅ **Add to `dots-scripts.sh` registry** if user-facing
5. ✅ **Test in playground environment**

### File Naming Conventions

- **User scripts**: `dots-*` (e.g., `dots-backup`, `dots-rice-apply`)
- **EWW scripts**: `launch.sh` or `eww-manager.sh`
- **Polybar scripts**: Use descriptive names (e.g., `weather-info`, `player`)
- **Rice scripts**: `apply.sh` in each rice directory

### Error Handling Pattern

```bash
# Function-level error handling
process_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        log "ERROR" "Config file not found: $config_file"
        return 1
    fi
    
    if ! process_file "$config_file"; then
        log "ERROR" "Failed to process config file"
        return 1
    fi
    
    log "INFO" "Config processed successfully"
}

# Script-level error handling
main() {
    if ! process_config "$config_file"; then
        exit 1
    fi
}
```

## Testing Guidelines

### Playground Environment

```bash
# Use playground for testing
./bin/play                    # Start development environment
cd /workspace                 # Inside container/VM
chezmoi apply --source=.      # Apply changes
```

### Testing Checklist

- ✅ **Test with multiple window managers** (i3, openbox, xfce4)
- ✅ **Verify rice theme switching** works correctly
- ✅ **Check smart colors integration**
- ✅ **Validate EasyOptions parsing**
- ✅ **Test error handling scenarios**

## Integration Points

### Chezmoi Integration

```bash
# Apply changes after script modifications
chezmoi apply --source=. --force

# Check differences before applying
chezmoi diff

# Template variables in chezmoi files
{{ .chezmoi.hostname }}       # Current hostname
{{ .personal.email }}         # User email from data
```

### Window Manager Awareness

```bash
# Detect current window manager
detect_wm() {
    if pgrep -x "i3" > /dev/null; then
        echo "i3"
    elif pgrep -x "openbox" > /dev/null; then
        echo "openbox"
    elif pgrep -x "xfce4-session" > /dev/null; then
        echo "xfce4"
    fi
}
```

## Common Patterns

### Logging Pattern

```bash
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    if [[ "${quiet:-}" != "yes" ]] || [[ "$level" == "ERROR" ]]; then
        echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
    else
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}
```

### Configuration Loading

```bash
# Load configuration with fallbacks
load_config() {
    local config_file="$1"
    local default_config="$2"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    elif [[ -f "$default_config" ]]; then
        source "$default_config"
    else
        log "ERROR" "No configuration file found"
        return 1
    fi
}
```

### Service Management

```bash
# Robust daemon management
manage_daemon() {
    local action="$1"
    local service="$2"
    
    case "$action" in
        start)
            if ! pgrep -x "$service" > /dev/null; then
                "$service" daemon &
                sleep 2
                if pgrep -x "$service" > /dev/null; then
                    log "INFO" "$service started successfully"
                else
                    log "ERROR" "Failed to start $service"
                    return 1
                fi
            fi
            ;;
        stop)
            if pgrep -x "$service" > /dev/null; then
                pkill -x "$service"
                log "INFO" "$service stopped"
            fi
            ;;
    esac
}
```

## Development Commands

### Essential Commands

```bash
# List all available scripts
dots --list

# Apply dotfiles changes
chezmoi apply --source=. --force

# Test in safe environment
./bin/play

# Check script syntax
shellcheck script.sh

# Validate dots scripts registry
./scripts/validate-dots-scripts.sh
```

### Debugging

```bash
# Enable debug mode for any script
script-name --debug command

# Check logs
tail -f ~/.cache/dots/script-name.log

# View smart colors
dots-smart-colors analyze ~/.wallpaper.jpg
```

## Security Notes

- **Never hardcode secrets** in version control
- **Use chezmoi templates** for sensitive data
- **Validate all user inputs** before processing
- **Set appropriate file permissions** (755 for executables, 644 for configs)
- **Use secure temp files** with proper cleanup

## Performance Guidelines

- **Lazy load modules** only when needed
- **Cache expensive operations** (color analysis, font detection)
- **Use background processes** for non-blocking operations
- **Implement timeout mechanisms** for external commands
- **Clean up resources** in trap handlers

Remember: Follow the hornero bird philosophy - build robust, functional environments that adapt beautifully to their surroundings. 
