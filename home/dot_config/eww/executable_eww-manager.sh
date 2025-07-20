#!/usr/bin/env bash
#
# Universal EWW Widget Manager
# Provides centralized management for all EWW components
#

set -euo pipefail

# =============================================================================
# Configuration & Constants
# =============================================================================

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
readonly SCRIPT_NAME
readonly SCRIPT_DIR
readonly EWW_BASE_DIR="$HOME/.config/eww"
readonly LOG_DIR="$HOME/.cache/eww"
readonly LOG_FILE="$LOG_DIR/manager.log"
readonly LOCK_FILE="/tmp/eww-manager.lock"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=2

# Available EWW components and their configurations
declare -A EWW_COMPONENTS=(
    ["dashboard"]="$EWW_BASE_DIR/dashboard"
    ["powermenu"]="$EWW_BASE_DIR/powermenu"
)

# Component widget mappings
declare -A COMPONENT_WIDGETS=(
    ["dashboard"]="dashboard-background dashboard-profile dashboard-system dashboard-clock dashboard-uptime dashboard-music dashboard-github dashboard-youtube dashboard-weather dashboard-mail dashboard-lock dashboard-logout dashboard-sleep dashboard-reboot dashboard-poweroff dashboard-folders dashboard-placeholder"
    ["powermenu"]="powermenu-background powermenu-clock powermenu-uptime powermenu-lock powermenu-logout powermenu-sleep powermenu-reboot powermenu-poweroff powermenu-placeholder"
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

# Component validation
validate_component() {
    local component="$1"
    
    if [[ ! -v "EWW_COMPONENTS[$component]" ]]; then
        error_exit "Unknown component: $component"
    fi
    
    local config_dir="${EWW_COMPONENTS[$component]}"
    if [[ ! -d "$config_dir" ]]; then
        log "WARN" "Config directory not found: $config_dir"
        return 1
    fi
    
    if [[ ! -f "$config_dir/eww.yuck" ]]; then
        log "WARN" "eww.yuck not found in: $config_dir"
        return 1
    fi
    
    return 0
}

# Enhanced widget operations
component_operation() {
    local operation="$1"
    local component="$2"
    shift 2
    local widgets=("$@")
    
    # Validate component
    if ! validate_component "$component"; then
        return 1
    fi
    
    local config_dir="${EWW_COMPONENTS[$component]}"
    
    # Use all component widgets if none specified
    if [[ ${#widgets[@]} -eq 0 ]]; then
        # Convert space-separated string to array
        IFS=' ' read -ra widgets <<< "${COMPONENT_WIDGETS[$component]:-}"
    fi
    
    if [[ ${#widgets[@]} -eq 0 ]]; then
        log "WARN" "No widgets specified for component: $component"
        return 1
    fi
    
    case "$operation" in
        toggle)
            log "INFO" "Toggling ${#widgets[@]} widgets in $component"
            if ! eww --config "$config_dir" open-many --toggle "${widgets[@]}" >/dev/null 2>&1; then
                log "WARN" "Some widgets may not have toggled successfully in $component: ${widgets[*]}"
            fi
            ;;
        open)
            log "INFO" "Opening ${#widgets[@]} widgets in $component"
            if [[ ${#widgets[@]} -eq 1 ]]; then
                if ! eww --config "$config_dir" open "${widgets[0]}" >/dev/null 2>&1; then
                    log "WARN" "Widget may not have opened successfully in $component: ${widgets[0]}"
                fi
            else
                if ! eww --config "$config_dir" open-many "${widgets[@]}" >/dev/null 2>&1; then
                    log "WARN" "Some widgets may not have opened successfully in $component: ${widgets[*]}"
                fi
            fi
            ;;
        close)
            log "INFO" "Closing ${#widgets[@]} widgets in $component"
            for widget in "${widgets[@]}"; do
                if ! eww --config "$config_dir" close "$widget" >/dev/null 2>&1; then
                    log "WARN" "Widget may not have closed successfully in $component: $widget"
                fi
            done
            ;;
    esac
}

# Get component status
get_component_status() {
    local component="$1"
    local config_dir="${EWW_COMPONENTS[$component]}"
    
    if [[ ! -d "$config_dir" ]]; then
        echo "❌ Not available"
        return
    fi
    
    local open_widgets
    open_widgets="$(eww --config "$config_dir" windows 2>/dev/null || echo "")"
    local widget_count
    widget_count="$(echo "${COMPONENT_WIDGETS[$component]:-}" | wc -w)"
    local open_count
    open_count="$(echo "$open_widgets" | wc -l)"
    
    if [[ -n "$open_widgets" ]]; then
        echo "✅ Active ($open_count/$widget_count widgets)"
    else
        echo "❌ Inactive (0/$widget_count widgets)"
    fi
}

# Display help information
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] [COMMAND] [COMPONENT] [WIDGETS...]

Universal EWW Widget Manager

COMMANDS:
    toggle          Toggle component widgets (default)
    open            Open component widgets
    close           Close component widgets
    restart         Restart EWW daemon and reopen widgets
    status          Show all components status
    daemon          Manage EWW daemon (start|stop|restart)
    cleanup         Clean up orphaned processes and files
    list            List available components and widgets

COMPONENTS:
    dashboard       Main dashboard interface
    powermenu       Power management menu

OPTIONS:
    -h, --help      Show this help message
    -d, --debug     Enable debug logging
    -q, --quiet     Suppress all output except errors
    -f, --force     Force operation even if already running
    -a, --all       Operate on all components

EXAMPLES:
    $SCRIPT_NAME toggle dashboard                      # Toggle dashboard
    $SCRIPT_NAME open powermenu                        # Open powermenu
    $SCRIPT_NAME close dashboard                       # Close dashboard
    $SCRIPT_NAME open dashboard dashboard-clock        # Open specific widget
    $SCRIPT_NAME daemon restart                        # Restart EWW daemon
    $SCRIPT_NAME status                                # Show all status
    $SCRIPT_NAME cleanup                               # Clean up processes

LOG FILE: $LOG_FILE
EOF
}

# List components and widgets
list_components() {
    echo "=== Available EWW Components ==="
    echo
    
    for component in "${!EWW_COMPONENTS[@]}"; do
        local config_dir="${EWW_COMPONENTS[$component]}"
        echo "📦 $component"
        echo "   Config: $config_dir"
        echo "   Status: $(get_component_status "$component")"
        echo "   Widgets: ${COMPONENT_WIDGETS[$component]:-none}"
        echo
    done
}

# Status display
show_status() {
    echo "=== EWW System Status ==="
    echo
    
    # Daemon status
    if eww ping >/dev/null 2>&1; then
        echo "🔄 Daemon: Running ✅"
    else
        echo "🔄 Daemon: Not running ❌"
    fi
    
    echo
    echo "📦 Components:"
    echo "--------------"
    
    for component in "${!EWW_COMPONENTS[@]}"; do
        printf "%-12s %s\n" "$component:" "$(get_component_status "$component")"
    done
    
    echo
    echo "📁 Base Directory: $EWW_BASE_DIR"
    echo "📝 Log File: $LOG_FILE"
}

# Cleanup function
cleanup_system() {
    log "INFO" "Performing system cleanup..."
    
    # Kill orphaned EWW processes
    local orphaned_pids
    orphaned_pids="$(pgrep -f "eww" | grep -v $$ || true)"
    
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
    local all_components=false
    local command="toggle"
    local component=""
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
            -a|--all)
                all_components=true
                shift
                ;;
            toggle|open|close|restart|cleanup)
                command="$1"
                shift
                ;;
            status|list|daemon)
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
            dashboard|powermenu)
                component="$1"
                shift
                ;;
            dashboard-*|powermenu-*)
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
    
    # Acquire lock unless it's a status or list command
    if [[ "$command" != "status" && "$command" != "list" && "$command" != "cleanup" ]]; then
        if [[ "$force" != "true" ]]; then
            acquire_lock
        fi
    fi
    
    log "INFO" "Starting $SCRIPT_NAME with command: $command"
    
    # Check EWW installation for most commands
    if [[ "$command" != "list" ]]; then
        check_eww_installed
    fi
    
    # Execute command
    case "$command" in
        toggle|open|close)
            manage_eww_daemon "start"
            
            if [[ "$all_components" == "true" ]]; then
                for comp in "${!EWW_COMPONENTS[@]}"; do
                    if validate_component "$comp"; then
                        component_operation "$command" "$comp"
                        log "INFO" "Operation '$command' completed for $comp"
                    fi
                done
            elif [[ -n "$component" ]]; then
                component_operation "$command" "$component" "${widgets[@]}"
                log "INFO" "Operation '$command' completed for $component"
            else
                error_exit "No component specified. Use -a for all components or specify a component."
            fi
            ;;
        restart)
            manage_eww_daemon "restart"
            log "INFO" "Restart completed successfully"
            ;;
        daemon)
            manage_eww_daemon "$daemon_action"
            ;;
        status)
            show_status
            ;;
        list)
            list_components
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
