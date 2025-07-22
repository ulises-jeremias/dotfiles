#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Enhanced EWW Powermenu Launch Script
## Provides robust widget management with comprehensive error handling and logging
##
## Check full documentation at: https://github.com/ulises-jeremias/dotfiles/wiki
##
## Usage:
##     @script.name [OPTIONS] [COMMAND] [WIDGETS...]
##
## Commands:
##     toggle          Toggle powermenu widgets (default)
##     open            Open powermenu widgets
##     close           Close powermenu widgets
##     restart         Restart EWW daemon and reopen widgets
##     status          Show widget status
##     daemon          Manage EWW daemon (start|stop|restart)
##     cleanup         Clean up orphaned processes and files
##
## Options:
##     -h, --help      Show this help message.
##     -d, --debug     Enable debug logging.
##     -q, --quiet     Suppress all output except errors.
##     -f, --force     Force operation even if already running.
##     -l, --list      List available widgets.
##
## Widgets:
##     If no widgets specified, operates on all powermenu widgets.
##     Otherwise, operates only on specified widgets.
##
## Examples:
##     @script.name                               # Toggle all powermenu widgets
##     @script.name open powermenu-clock          # Open only the clock widget
##     @script.name close powermenu-background    # Close only the background widget
##     @script.name daemon restart                # Restart the EWW daemon
##     @script.name status                        # Show status of all widgets
##     @script.name cleanup                       # Clean up orphaned processes

set -euo pipefail

# Source EasyOptions for argument parsing
source ~/.local/lib/dots/easy-options/easyoptions.sh || exit

# =============================================================================
# Configuration & Constants
# =============================================================================

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
readonly SCRIPT_NAME
readonly SCRIPT_DIR
readonly EWW_CONFIG_DIR="$HOME/.config/eww/powermenu"
readonly LOG_DIR="$HOME/.cache/eww"
readonly LOG_FILE="$LOG_DIR/powermenu.log"
readonly LOCK_FILE="/tmp/eww-powermenu.lock"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=2

# Powermenu widgets list
readonly POWERMENU_WIDGETS=(
    "powermenu-background"
    "powermenu-clock"
    "powermenu-uptime"
    "powermenu-lock"
    "powermenu-logout"
    "powermenu-sleep"
    "powermenu-reboot"
    "powermenu-poweroff"
    "powermenu-placeholder"
)

# =============================================================================
# Utility Functions
# =============================================================================

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # Only log to file if not in quiet mode, but always log errors to stderr
    if [[ "${quiet:-}" != "yes" ]] || [[ "$level" == "ERROR" ]]; then
        echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
    else
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# Error handling
error_exit() {
    local message="$1"
    local code="${2:-1}"
    log "ERROR" "$message"
    cleanup_on_exit
    exit "$code"
}

# Setup logging directory
setup_logging() {
    mkdir -p "$LOG_DIR"

    # Rotate log if it gets too large (>1MB)
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) -gt 1048576 ]]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        log "INFO" "Log rotated"
    fi
}

# Cleanup function
cleanup_on_exit() {
    [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"
}

# Lock management
acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid="$(cat "$LOCK_FILE")"
        if kill -0 "$pid" 2>/dev/null; then
            error_exit "Another instance is already running (PID: $pid)" 2
        else
            log "WARN" "Stale lock file found, removing..."
            rm -f "$LOCK_FILE"
        fi
    fi

    echo $$ > "$LOCK_FILE"
    trap cleanup_on_exit EXIT
}

# Check if EWW is installed
check_eww_installed() {
    if ! command -v eww >/dev/null 2>&1; then
        error_exit "EWW is not installed or not in PATH"
    fi

    local eww_version
    eww_version="$(eww --version 2>/dev/null | head -n1 || echo "unknown")"
    log "INFO" "EWW version: $eww_version"
}

# Enhanced daemon management
manage_eww_daemon() {
    local action="${1:-start}"
    local retries=0

    case "$action" in
        start)
            log "INFO" "Starting EWW daemon..."

            # Check if daemon is already running
            if eww ping >/dev/null 2>&1; then
                log "INFO" "EWW daemon already running"
                return 0
            fi

            # Start daemon with retries
            while [[ $retries -lt $MAX_RETRIES ]]; do
                eww daemon 2>/dev/null &
                local daemon_pid=$!

                # Wait for daemon to be ready
                sleep "$RETRY_DELAY"

                if eww ping >/dev/null 2>&1; then
                    log "INFO" "EWW daemon started successfully (PID: $daemon_pid)"
                    return 0
                fi

                ((retries++))
                log "WARN" "Daemon start attempt $retries failed, retrying..."

                # Kill the failed daemon process
                kill "$daemon_pid" 2>/dev/null || true
                wait "$daemon_pid" 2>/dev/null || true

                sleep "$RETRY_DELAY"
            done

            error_exit "Failed to start EWW daemon after $MAX_RETRIES attempts"
            ;;

        restart)
            log "INFO" "Restarting EWW daemon..."
            manage_eww_daemon "stop"
            sleep 1
            manage_eww_daemon "start"
            ;;

        stop)
            if eww ping >/dev/null 2>&1; then
                log "INFO" "Stopping EWW daemon..."
                eww kill
                sleep 1

                if eww ping >/dev/null 2>&1; then
                    log "WARN" "Daemon still running, forcing kill..."
                    pkill -f "eww daemon" || true
                fi

                log "INFO" "EWW daemon stopped"
            else
                log "INFO" "EWW daemon not running"
            fi
            ;;
    esac
}

# Enhanced widget operations
widget_operation() {
    local operation="$1"
    shift
    local widgets=("$@")

    # Validate widgets exist in config
    for widget in "${widgets[@]}"; do
        if ! eww --config "$EWW_CONFIG_DIR" windows | grep -q "^$widget" 2>/dev/null; then
            log "WARN" "Widget '$widget' not found in config"
        fi
    done

    case "$operation" in
        toggle)
            log "INFO" "Toggling ${#widgets[@]} powermenu widgets"
            if ! eww --config "$EWW_CONFIG_DIR" open-many --toggle "${widgets[@]}" >/dev/null 2>&1; then
                log "WARN" "Some widgets may not have toggled successfully: ${widgets[*]}"
            fi
            ;;
        open)
            log "INFO" "Opening ${#widgets[@]} powermenu widgets"
            if [[ ${#widgets[@]} -eq 1 ]]; then
                if ! eww --config "$EWW_CONFIG_DIR" open "${widgets[0]}" >/dev/null 2>&1; then
                    log "WARN" "Widget may not have opened successfully: ${widgets[0]}"
                fi
            else
                if ! eww --config "$EWW_CONFIG_DIR" open-many "${widgets[@]}" >/dev/null 2>&1; then
                    log "WARN" "Some widgets may not have opened successfully: ${widgets[*]}"
                fi
            fi
            ;;
        close)
            log "INFO" "Closing ${#widgets[@]} powermenu widgets"
            for widget in "${widgets[@]}"; do
                if ! eww --config "$EWW_CONFIG_DIR" close "$widget" >/dev/null 2>&1; then
                    log "WARN" "Widget may not have closed successfully: $widget"
                fi
            done
            ;;
    esac
}

# Status display
show_status() {
    echo "=== EWW Powermenu Status ==="
    echo

    # Daemon status
    if eww ping >/dev/null 2>&1; then
        echo "Daemon: Running ✅"
    else
        echo "Daemon: Not running ❌"
    fi

    echo
    echo "Widget Status:"
    echo "--------------"

    local open_widgets
    open_widgets="$(eww --config "$EWW_CONFIG_DIR" windows 2>/dev/null || echo "")"

    for widget in "${POWERMENU_WIDGETS[@]}"; do
        if echo "$open_widgets" | grep -q "^$widget"; then
            echo "$widget: Open ✅"
        else
            echo "$widget: Closed ❌"
        fi
    done

    echo
    echo "Config Directory: $EWW_CONFIG_DIR"
    echo "Log File: $LOG_FILE"
}

# List available widgets
list_widgets() {
    echo "Available widgets:"
    printf '%s\n' "${POWERMENU_WIDGETS[@]}"
}

# Cleanup function
cleanup_system() {
    log "INFO" "Starting system cleanup..."

    # Kill any orphaned eww processes
    if pgrep -f "eww" >/dev/null; then
        log "INFO" "Killing orphaned EWW processes..."
        pkill -f "eww" || true
    fi

    # Remove lock files
    rm -f /tmp/eww-*.lock 2>/dev/null || true

    # Clean old logs (older than 7 days)
    find "$LOG_DIR" -name "*.log.old" -mtime +7 -delete 2>/dev/null || true

    log "INFO" "System cleanup completed"
}

# =============================================================================
# Main Function
# =============================================================================

main() {
    # Setup logging first
    setup_logging

    # Parse command from arguments
    local command="toggle"
    local daemon_action="start"
    local widgets=()

    # Process positional arguments for commands and widgets
    for arg in "${arguments[@]:-}"; do
        # Skip empty arguments
        [[ -z "$arg" ]] && continue

        case "$arg" in
            toggle|open|close|restart|status|daemon|cleanup)
                command="$arg"
                ;;
            start|stop)
                if [[ "$command" == "daemon" ]]; then
                    daemon_action="$arg"
                else
                    error_exit "Invalid argument: $arg"
                fi
                ;;
            powermenu-*)
                widgets+=("$arg")
                ;;
            *)
                error_exit "Unknown argument: $arg"
                ;;
        esac
    done

    # Handle list option
    if [[ "${list:-}" == "yes" ]]; then
        list_widgets
        exit 0
    fi

    # Enable debug mode if requested
    if [[ "${debug:-}" == "yes" ]]; then
        set -x
        log "INFO" "Debug mode enabled"
    fi

    # Quiet mode setup - redirect stdout to null but keep stderr
    if [[ "${quiet:-}" == "yes" ]]; then
        exec 1>/dev/null
    fi

    # Acquire lock unless it's a status or list command
    if [[ "$command" != "status" && "$command" != "cleanup" ]]; then
        if [[ "${force:-}" != "yes" ]]; then
            acquire_lock
        fi
    fi

    log "INFO" "Starting $SCRIPT_NAME with command: $command"

    # Use all widgets if none specified (except for daemon commands)
    if [[ ${#widgets[@]} -eq 0 && "$command" != "daemon" && "$command" != "status" && "$command" != "cleanup" ]]; then
        widgets=("${POWERMENU_WIDGETS[@]}")
    fi

    # Check EWW installation
    check_eww_installed

    # Execute command
    case "$command" in
        toggle|open|close)
            manage_eww_daemon "start"
            widget_operation "$command" "${widgets[@]}"
            log "INFO" "Operation '$command' completed successfully"
            ;;
        restart)
            manage_eww_daemon "restart"
            if [[ ${#widgets[@]} -gt 0 ]]; then
                sleep 1
                widget_operation "open" "${widgets[@]}"
            fi
            log "INFO" "Restart completed successfully"
            ;;
        daemon)
            manage_eww_daemon "$daemon_action"
            ;;
        status)
            show_status
            ;;
        cleanup)
            cleanup_system
            ;;
        *)
            error_exit "Unknown command: $command"
            ;;
    esac

    log "INFO" "$SCRIPT_NAME completed successfully"
}

# =============================================================================
# Script Execution
# =============================================================================

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
