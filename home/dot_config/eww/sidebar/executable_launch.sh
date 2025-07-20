#!/usr/bin/env bash
#
# Enhanced EWW Sidebar Launch Script
# Provides robust widget management with comprehensive error handling and logging
#

set -euo pipefail

# =============================================================================
# Configuration & Constants
# =============================================================================

readonly SCRIPT_NAME
readonly SCRIPT_DIR
SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
readonly EWW_CONFIG_DIR="$HOME/.config/eww/sidebar"
readonly LOG_DIR="$HOME/.cache/eww"
readonly LOG_FILE="$LOG_DIR/sidebar.log"
readonly LOCK_FILE="/tmp/eww-sidebar.lock"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=2

# Sidebar widgets list (customize based on your actual sidebar widgets)
readonly SIDEBAR_WIDGETS=(
    "sidebar-main"
    "sidebar-toggle"
    "sidebar-calendar"
    "sidebar-weather"
    "sidebar-system-info"
    "sidebar-shortcuts"
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
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
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

# Check if sidebar config exists
check_sidebar_config() {
    if [[ ! -d "$EWW_CONFIG_DIR" ]]; then
        error_exit "Sidebar config directory not found: $EWW_CONFIG_DIR"
    fi

    if [[ ! -f "$EWW_CONFIG_DIR/eww.yuck" ]]; then
        log "WARN" "No eww.yuck found in $EWW_CONFIG_DIR"
        log "INFO" "Sidebar component appears to be under development"
        exit 0
    fi
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
    local available_widgets
    available_widgets="$(eww --config "$EWW_CONFIG_DIR" windows 2>/dev/null || echo "")"

    for widget in "${widgets[@]}"; do
        if ! echo "$available_widgets" | grep -q "^$widget" 2>/dev/null; then
            log "WARN" "Widget '$widget' not found in config"
        fi
    done

    case "$operation" in
        toggle)
            log "INFO" "Toggling ${#widgets[@]} sidebar widgets"
            eww --config "$EWW_CONFIG_DIR" open-many --toggle "${widgets[@]}" 2>/dev/null || {
                error_exit "Failed to toggle widgets: ${widgets[*]}"
            }
            ;;
        open)
            log "INFO" "Opening ${#widgets[@]} sidebar widgets"
            eww --config "$EWW_CONFIG_DIR" open-many "${widgets[@]}" 2>/dev/null || {
                error_exit "Failed to open widgets: ${widgets[*]}"
            }
            ;;
        close)
            log "INFO" "Closing ${#widgets[@]} sidebar widgets"
            eww --config "$EWW_CONFIG_DIR" close-many "${widgets[@]}" 2>/dev/null || {
                error_exit "Failed to close widgets: ${widgets[*]}"
            }
            ;;
    esac
}

# Display help information
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] [COMMAND] [WIDGETS...]

Enhanced EWW Sidebar Management Script

COMMANDS:
    toggle          Toggle sidebar widgets (default)
    open            Open sidebar widgets
    close           Close sidebar widgets
    restart         Restart EWW daemon and reopen widgets
    status          Show widget status
    daemon          Manage EWW daemon (start|stop|restart)
    cleanup         Clean up orphaned processes and files

OPTIONS:
    -h, --help      Show this help message
    -d, --debug     Enable debug logging
    -q, --quiet     Suppress all output except errors
    -f, --force     Force operation even if already running
    -l, --list      List available widgets

WIDGETS:
    If no widgets specified, operates on all sidebar widgets.
    Otherwise, operates only on specified widgets.

EXAMPLES:
    $SCRIPT_NAME                             # Toggle all sidebar widgets
    $SCRIPT_NAME open sidebar-main           # Open only the main widget
    $SCRIPT_NAME close sidebar-calendar      # Close only the calendar widget
    $SCRIPT_NAME daemon restart              # Restart the EWW daemon
    $SCRIPT_NAME status                      # Show status of all widgets
    $SCRIPT_NAME cleanup                     # Clean up orphaned processes

LOG FILE: $LOG_FILE
EOF
}

# Status display
show_status() {
    echo "=== EWW Sidebar Status ==="
    echo

    # Check if config exists
    if [[ ! -f "$EWW_CONFIG_DIR/eww.yuck" ]]; then
        echo "Status: Not configured ⚙️"
        echo "The sidebar component is available but not yet configured."
        echo "Please create $EWW_CONFIG_DIR/eww.yuck to get started."
        return
    fi

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

    for widget in "${SIDEBAR_WIDGETS[@]}"; do
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

# Cleanup function
cleanup_system() {
    log "INFO" "Performing system cleanup..."

    # Kill orphaned EWW processes
    local orphaned_pids
    orphaned_pids="$(pgrep -f "eww.*sidebar" | grep -v $$ || true)"

    if [[ -n "$orphaned_pids" ]]; then
        log "INFO" "Killing orphaned EWW processes: $orphaned_pids"
        echo "$orphaned_pids" | xargs kill -TERM 2>/dev/null || true
        sleep 2
        echo "$orphaned_pids" | xargs kill -KILL 2>/dev/null || true
    fi

    # Remove stale lock files
    find /tmp -name "eww-*.lock" -mtime +1 -delete 2>/dev/null || true

    # Clean old log files
    find "$LOG_DIR" -name "*.log.old" -mtime +7 -delete 2>/dev/null || true

    log "INFO" "Cleanup completed"
}

# =============================================================================
# Main Function
# =============================================================================

main() {
    local debug=false
    local quiet=false
    local force=false
    local command="toggle"
    local widgets=()
    local daemon_action="start"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--debug)
                debug=true
                set -x
                shift
                ;;
            -q|--quiet)
                quiet=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -l|--list)
                echo "Available widgets:"
                printf '%s\n' "${SIDEBAR_WIDGETS[@]}"
                exit 0
                ;;
            toggle|open|close|status|daemon|cleanup)
                command="$1"
                shift
                ;;
            restart)
                command="$1"
                shift
                ;;
            start|stop)
                if [[ "$command" == "daemon" ]]; then
                    daemon_action="$1"
                    shift
                else
                    error_exit "Unknown command: $1"
                fi
                ;;
            sidebar-*)
                widgets+=("$1")
                shift
                ;;
            *)
                error_exit "Unknown option: $1"
                ;;
        esac
    done

    # Setup logging
    setup_logging

    # Quiet mode setup
    if [[ "$quiet" == "true" ]]; then
        exec 1>/dev/null
    fi

    # Check sidebar config for non-status commands
    if [[ "$command" != "status" ]]; then
        check_sidebar_config
    fi

    # Acquire lock unless it's a status command
    if [[ "$command" != "status" && "$command" != "cleanup" ]]; then
        if [[ "$force" != "true" ]]; then
            acquire_lock
        fi
    fi

    log "INFO" "Starting $SCRIPT_NAME with command: $command"

    # Use all widgets if none specified (except for daemon commands)
    if [[ ${#widgets[@]} -eq 0 && "$command" != "daemon" && "$command" != "status" && "$command" != "cleanup" ]]; then
        widgets=("${SIDEBAR_WIDGETS[@]}")
    fi

    # Check EWW installation
    if [[ "$command" != "status" ]]; then
        check_eww_installed
    fi

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
