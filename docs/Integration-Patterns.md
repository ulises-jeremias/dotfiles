# Integration Patterns

## Chezmoi Integration

**Understanding Chezmoi's Role:**

- Source directory: `~/.dotfiles/home/` (version controlled)
- Target directory: `~/` (applied configurations)
- Template processing: `.tmpl` files support Go templating
- Encryption: Built-in secrets management

**File Naming Conventions:**

- `dot_` prefix → `.` (e.g., `dot_zshrc` → `.zshrc`)
- `private_` prefix → 600 permissions
- `executable_` prefix → 755 permissions
- `.tmpl` suffix → Template processing

**When Making Changes:**

1. Edit source files in `~/.dotfiles/home/`
2. Test changes: `chezmoi diff`
3. Apply changes: `chezmoi apply --force`
4. Commit to version control

**Template Variables:**

- `{{ .chezmoi.hostname }}` - Current hostname
- `{{ .chezmoi.os }}` - Operating system
- `{{ .chezmoi.arch }}` - Architecture
- Custom data from `~/.config/chezmoi/chezmoi.toml`

## Window Manager Detection

**Always detect dynamically:**

```bash
detect_wm() {
    if pgrep -x "Hyprland" &>/dev/null; then
        echo "hyprland"
    elif pgrep -x "i3" &>/dev/null; then
        echo "i3"
    elif pgrep -x "openbox" &>/dev/null; then
        echo "openbox"
    elif pgrep -x "xfce4-session" &>/dev/null; then
        echo "xfce4"
    else
        echo "unknown"
    fi
}
```

**WM-Specific Configuration:**

- Check window manager before loading config
- Provide WM-specific implementations
- Fallback to generic approaches when possible

## Daemon Management

**Pattern for service management:**

```bash
manage_daemon() {
    local action="$1"
    local daemon="$2"
    local daemon_opts="${3:-}"

    case "$action" in
        start)
            if pgrep -x "$daemon" &>/dev/null; then
                log "INFO" "$daemon already running"
                return 0
            fi

            "$daemon" $daemon_opts &
            sleep 2

            if pgrep -x "$daemon" &>/dev/null; then
                log "INFO" "$daemon started successfully"
            else
                log "ERROR" "Failed to start $daemon"
                return 1
            fi
            ;;

        stop)
            if pgrep -x "$daemon" &>/dev/null; then
                pkill -x "$daemon"
                log "INFO" "$daemon stopped"
            else
                log "INFO" "$daemon not running"
            fi
            ;;

        restart)
            manage_daemon stop "$daemon"
            sleep 1
            manage_daemon start "$daemon" "$daemon_opts"
            ;;
    esac
}
```

## Lock File Pattern

**Prevent concurrent execution:**

```bash
LOCK_FILE="/tmp/${SCRIPT_NAME}.lock"

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(<"$LOCK_FILE")

        if kill -0 "$pid" 2>/dev/null; then
            log "ERROR" "Script already running (PID: $pid)"
            return 1
        else
            log "WARN" "Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi

    echo $$ > "$LOCK_FILE"
    return 0
}

release_lock() {
    rm -f "$LOCK_FILE"
}

# Ensure cleanup on exit
trap release_lock EXIT
```

## Configuration Loading

**Hierarchical configuration pattern:**

```bash
load_config() {
    local config_name="$1"
    local config_paths=(
        "$HOME/.config/dots/${config_name}"
        "$HOME/.config/dots/default.conf"
        "/etc/dots/${config_name}"
    )

    for config_path in "${config_paths[@]}"; do
        if [[ -f "$config_path" ]]; then
            log "DEBUG" "Loading config: $config_path"
            source "$config_path"
            return 0
        fi
    done

    log "WARN" "No configuration found for: $config_name"
    return 1
}
```

## Color System Integration

### Smart Colors Philosophy

**Semantic Over Aesthetic:**

- Colors represent meaning, not just appearance
- Error colors must suggest danger/caution
- Success colors must suggest completion/safety
- Info colors must be neutral and clear
- Warning colors must be attention-grabbing but not alarming

**Theme Adaptivity:**

- Light themes require darker, more muted colors
- Dark themes require brighter, more saturated colors
- Foreground colors adjust based on background luminance
- Contrast ratios meet accessibility standards (WCAG AA minimum)

### Integration Requirements

**When creating themed components:**

1. **Never hardcode colors** - Always reference smart colors or xrdb
2. **Provide fallbacks** - Define defaults if smart colors unavailable
3. **Test both themes** - Verify appearance in light and dark modes
4. **Use semantic names** - Prefer `$error` over `$red` when representing errors
5. **Cache appropriately** - Generate once, reuse multiple times

**Color Reference Priority:**

1. Smart colors (semantic, theme-adaptive)
2. xrdb colors (base16 palette)
3. Hardcoded fallbacks (last resort)

Note: For Quickshell components, use M3 tokens from scheme.json instead of smart colors or xrdb.

### Material Design 3 Integration (Quickshell)

Quickshell uses Material Design 3 (M3) color palettes generated from wallpaper analysis:

**Pipeline:**
1. Wallpaper change triggers `dots-smart-colors --m3`
2. `generate-m3-colors.py` extracts M3 palette using `materialyoucolor`
3. Palette saved to `~/.cache/dots/smart-colors/scheme.json`
4. Quickshell `Colours` service watches the file and reloads automatically

**Color Reference Priority (Quickshell):**
1. M3 scheme.json (primary, surface, onSurface, etc.)
2. Smart colors (semantic fallback)
3. Hardcoded defaults (last resort)

**Key M3 Tokens:**
- `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`
- `secondary`, `tertiary`, `error`
- `surface`, `onSurface`, `surfaceVariant`
- `outline`, `shadow`
