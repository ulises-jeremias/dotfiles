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

**Use the standardized logging library:**

```bash
# Source the logging library at the top of your script
source ~/.local/lib/dots/logging.sh || exit

# Use logging functions
log_info "Processing configuration..."
log_warn "Deprecated option detected"
log_error "Failed to load file: $file"
log_debug "Debug information here"

# Or use the main log function
log "INFO" "Custom message"
log "ERROR" "Error occurred"
```

**Logging Library Features:**

- **Automatic log file**: Logs are written to `~/.cache/dots/logs/<script-name>.log`
- **Color-coded output**: Errors (red), warnings (yellow), info (green), debug (cyan)
- **Verbose mode**: Respects `--verbose` and `--debug` flags from EasyOptions
- **Log levels**: ERROR, WARN, INFO, DEBUG (configurable via `DOTS_LOG_LEVEL`)

**Example Usage:**

```bash
#!/usr/bin/env bash
set -euo pipefail

source ~/.local/lib/dots/easy-options/easyoptions.sh || exit
source ~/.local/lib/dots/logging.sh || exit

main() {
    log_info "Starting script execution"
    
    if ! check_dependencies; then
        log_error "Missing required dependencies"
        exit 1
    fi
    
    log_debug "Processing with verbose output"
    # ... script logic ...
    
    log_info "Script completed successfully"
}

main "$@"
```

## Best Practices

- **Follow existing patterns** - Look at similar code for examples
- **Keep it simple** - Readable code is better than clever code
- **Write comments** - Explain the "why", not just the "what"
- **Test your changes** - Use the playground environment
- **Check with shellcheck** - Lint your shell scripts
- **Handle errors gracefully** - Don't leave users confused
