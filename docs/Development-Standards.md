# Development Standards

## Shell Script Requirements

### Script Template Structure

Every user-facing script must follow this structure:

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
##     -h, --help      Show this help message
##     -v, --verbose   Enable verbose output
##     -d, --debug     Enable debug mode

set -euo pipefail

source ~/.local/lib/dots/easy-options/easyoptions.sh || exit

# Script implementation
```

### Naming Conventions

**Variables:**

- Local variables: `snake_case` (e.g., `config_file`, `rice_name`)
- Constants: `UPPER_CASE` with `readonly` (e.g., `readonly CONFIG_DIR`)
- Environment exports: `UPPER_CASE` (e.g., `export WAYBAR_PROFILE`)

**Functions:**

- Use `snake_case` (e.g., `process_config`, `reload_daemon`)
- Prefix private functions with `_` (e.g., `_internal_helper`)
- Document parameters and return values in comments

**Files:**

- Executables: `executable_dots-<name>` (Chezmoi convention)
- Libraries: `<name>.sh` (e.g., `smart-colors.sh`)
- Configs: `<name>.conf` or `config.sh`

### Error Handling Pattern

**Function-level error handling:**

```bash
function_name() {
    local param="$1"

    # Validate inputs
    if [[ ! -f "$param" ]]; then
        log "ERROR" "File not found: $param"
        return 1
    fi

    # Process with error checking
    if ! process_file "$param"; then
        log "ERROR" "Processing failed: $param"
        return 1
    fi

    log "INFO" "Success: $param"
    return 0
}
```

**Script-level error handling:**

```bash
main() {
    # Validate environment
    check_dependencies || exit 1

    # Process with error propagation
    if ! function_name "$argument"; then
        log "ERROR" "Main process failed"
        exit 1
    fi

    log "INFO" "Script completed successfully"
    exit 0
}

main "$@"
```

### Dependency Management

**Check before use:**

```bash
check_dependencies() {
    local deps=("jq" "curl" "wmctrl")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log "ERROR" "Missing dependencies: ${missing[*]}"
        return 1
    fi

    return 0
}
```

**Provide fallbacks:**

```bash
get_brightness() {
    if command -v brightnessctl &>/dev/null; then
        brightnessctl g
    elif command -v xbacklight &>/dev/null; then
        xbacklight -get
    else
        log "WARN" "No brightness control available"
        echo "50"  # Default fallback
    fi
}
```

### Logging Standards

```bash
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # Color codes
    case "$level" in
        ERROR)   color="\033[0;31m" ;;  # Red
        WARN)    color="\033[0;33m" ;;  # Yellow
        INFO)    color="\033[0;32m" ;;  # Green
        DEBUG)   color="\033[0;36m" ;;  # Cyan
        *)       color="\033[0m" ;;     # Reset
    esac

    # Output to stderr for errors, stdout for others
    if [[ "$level" == "ERROR" ]]; then
        echo -e "${color}[$timestamp] [$level] $message\033[0m" >&2
    else
        echo -e "${color}[$timestamp] [$level] $message\033[0m"
    fi

    # Always log to file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}
```

## Best Practices

- **Follow existing patterns** - Look at similar code for examples
- **Keep it simple** - Readable code is better than clever code
- **Write comments** - Explain the "why", not just the "what"
- **Test your changes** - Use the playground environment
- **Check with shellcheck** - Lint your shell scripts
- **Handle errors gracefully** - Don't leave users confused
