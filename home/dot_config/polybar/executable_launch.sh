#!/usr/bin/env bash
#
# Enhanced Polybar Launch Script
# Provides robust bar management with comprehensive error handling and logging
#

set -euo pipefail

# =============================================================================
# Configuration & Constants
# =============================================================================

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
readonly SCRIPT_NAME
readonly SCRIPT_DIR
readonly POLYBAR_CONFIG_DIR="$HOME/.config/polybar"
readonly POLYBAR_PROFILES_DIR="$POLYBAR_CONFIG_DIR/profiles"
readonly LOG_DIR="$HOME/.cache/polybar"
readonly LOG_FILE="$LOG_DIR/polybar.log"
readonly LOCK_FILE="/tmp/polybar-launch.lock"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=1
readonly DEFAULT_TERM="xterm-256color"

# Available Polybar configurations (dynamically detected and from rice configs)
readonly AVAILABLE_BARS=(
    "polybar-top"
    "polybar-bottom"
    "i3-polybar-top"
    "i3-polybar-bottom"
    "i3-polybar-top-1"
    "i3-polybar-top-2"
    "i3-polybar-top-3"
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

# Log function that only writes to file (for use in command substitutions)
log_quiet() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
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

# Check if Polybar is installed
check_polybar_installed() {
    if ! command -v polybar >/dev/null 2>&1; then
        error_exit "Polybar is not installed or not in PATH"
    fi

    local polybar_version
    polybar_version="$(polybar --version 2>/dev/null | head -n1 || echo "unknown")"
    log "INFO" "Polybar version: $polybar_version"
}

# Load rice configuration
load_rice_config() {
    local rice_config_loader="$HOME/.local/lib/dots/dots-rice-config.sh"

    if [[ ! -f "$rice_config_loader" ]]; then
        log_quiet "WARN" "Rice config loader not found: $rice_config_loader"
        return 1
    fi

    # Source rice configuration in a subshell to avoid polluting current environment
    local current_rice
    current_rice="$(cat "$HOME/.local/share/dots/rices/.current_rice" 2>/dev/null || echo "gruvbox")"
    log_quiet "INFO" "Loading rice configuration: $current_rice"

    # Export rice config loader for later use
    export RICE_CONFIG_LOADER="$rice_config_loader"

    return 0
}

# Load polybar profile based on rice configuration
load_polybar_profile() {
    local profile_name="${1:-default}"

    # Clear any previously cached profile data
    unset CACHED_POLYBAR_PROFILE_BARS POLYBAR_PROFILE_BARS POLYBAR_PROFILE_CONFIG_FILE

    local profile_file="$POLYBAR_PROFILES_DIR/${profile_name}.sh"

    if [[ ! -f "$profile_file" ]]; then
        log_quiet "WARN" "Polybar profile not found: $profile_file, falling back to default"
        profile_name="default"
        profile_file="$POLYBAR_PROFILES_DIR/default.sh"

        if [[ ! -f "$profile_file" ]]; then
            log_quiet "ERROR" "Default polybar profile not found: $profile_file"
            return 1
        fi
    fi

    log_quiet "INFO" "Loading polybar profile: $profile_name"

    # Source the profile to get all variables
    if source "$profile_file" 2>/dev/null; then
        # Cache the bars and config file from the profile
        local profile_bars profile_config_file
        profile_bars="$(printf '%s\n' "${POLYBAR_PROFILE_BARS[@]}" 2>/dev/null || echo "")"
        profile_config_file="${POLYBAR_PROFILE_CONFIG_FILE:-}"

        if [[ -n "$profile_bars" ]]; then
            CACHED_POLYBAR_PROFILE_BARS="$profile_bars"

            # Use the config file from profile, or provide a fallback
            if [[ -n "$profile_config_file" ]]; then
                POLYBAR_PROFILE_CONFIG_FILE="$profile_config_file"
            else
                POLYBAR_PROFILE_CONFIG_FILE="$POLYBAR_CONFIG_DIR/configs/${profile_name}/config.ini"
            fi

            # Export the config file path for use in launch_bars
            export POLYBAR_PROFILE_CONFIG_FILE
            log_quiet "INFO" "Polybar profile loaded: $profile_name (bars: $(echo "$profile_bars" | tr '\n' ' '), config: ${POLYBAR_PROFILE_CONFIG_FILE:-default})"
            return 0
        else
            log_quiet "ERROR" "No bars defined in polybar profile: $profile_file"
            return 1
        fi
    else
        log_quiet "ERROR" "Failed to source polybar profile: $profile_file"
        return 1
    fi
}

get_configured_bars() {
    local bars=()

    # Check if we have cached bars from loaded profile
    if [[ -n "${CACHED_POLYBAR_PROFILE_BARS:-}" ]]; then
        echo "$CACHED_POLYBAR_PROFILE_BARS"
        return 0
    fi

    # Try to source rice configuration and load polybar profile
    if load_rice_config; then
        # Get the polybar profile name from rice config
        local profile_name
        profile_name="$(source "$RICE_CONFIG_LOADER" 2>/dev/null && echo "${POLYBAR_PROFILE:-default}" || echo "default")"

        # Load the polybar profile
        if load_polybar_profile "$profile_name"; then
            echo "$CACHED_POLYBAR_PROFILE_BARS"
        else
            log_quiet "WARN" "Failed to load profile '$profile_name', using default bars"
            echo "polybar-top polybar-bottom"
        fi
    else
        # Ultimate fallback when no rice config is available
        echo "polybar-top polybar-bottom"
    fi
}

# Detect available bars from config files
detect_available_bars() {
    local bars=()

    if [[ -d "$POLYBAR_CONFIG_DIR/bars" ]]; then
        while IFS= read -r -d '' file; do
            if [[ -f "$file" ]]; then
                local bar_names
                bar_names="$(grep -E '^\[bar/' "$file" | sed 's/^\[bar\///; s/\]$//' || true)"
                if [[ -n "$bar_names" ]]; then
                    while IFS= read -r bar; do
                        [[ -n "$bar" ]] && bars+=("$bar")
                    done <<< "$bar_names"
                fi
            fi
        done < <(find "$POLYBAR_CONFIG_DIR/bars" -name "*.conf" -print0 2>/dev/null)
    fi

    printf '%s\n' "${bars[@]}" | sort -u
}

# Enhanced process management
manage_polybar_processes() {
    local action="${1:-restart}"

    case "$action" in
        stop)
            log "INFO" "Stopping Polybar processes..."

            if pgrep -u "$UID" -x polybar >/dev/null 2>&1; then
                local pids
                pids="$(pgrep -u "$UID" -x polybar)"
                log "INFO" "Found Polybar processes: $pids"

                # Terminate gracefully first
                pkill -TERM -u "$UID" -x polybar 2>/dev/null || true

                # Wait for graceful shutdown
                local retries=0
                while [[ $retries -lt $MAX_RETRIES ]] && pgrep -u "$UID" -x polybar >/dev/null 2>&1; do
                    ((retries++))
                    log "INFO" "Waiting for Polybar processes to terminate... ($retries/$MAX_RETRIES)"
                    sleep "$RETRY_DELAY"
                done

                # Force kill if still running
                if pgrep -u "$UID" -x polybar >/dev/null 2>&1; then
                    log "WARN" "Force killing remaining Polybar processes"
                    pkill -KILL -u "$UID" -x polybar 2>/dev/null || true
                fi

                log "INFO" "All Polybar processes stopped"
            else
                log "INFO" "No Polybar processes found"
            fi
            ;;

        restart|start)
            [[ "$action" == "restart" ]] && manage_polybar_processes "stop"

            log "INFO" "Starting Polybar bars..."
            ;;
    esac
}

# Setup environment
setup_environment() {
    # Set TERM variable if not set
    if [[ -z "${TERM:-}" ]]; then
        export TERM="$DEFAULT_TERM"
        log "INFO" "Set TERM to $DEFAULT_TERM"
    else
        log "INFO" "Using existing TERM: $TERM"
    fi

    # Ensure log directory exists
    mkdir -p "$LOG_DIR"

    # Validate config directory
    if [[ ! -d "$POLYBAR_CONFIG_DIR" ]]; then
        error_exit "Polybar config directory not found: $POLYBAR_CONFIG_DIR"
    fi
}

# Launch specific bars
launch_bars() {
    # Temporarily disable strict error checking for background jobs
    set +e

    local bars=("$@")
    local launched=0
    local failed=0

    if [[ ${#bars[@]} -eq 0 ]]; then
        log "WARN" "No bars specified for launch"
        set -e
        return 1
    fi

    log "INFO" "Attempting to launch ${#bars[@]} bars: ${bars[*]}"

    for bar in "${bars[@]}"; do
        # Skip empty bar names
        [[ -z "$bar" ]] && continue

        log "INFO" "Launching bar: $bar"

        # Launch the bar with proper logging (skip validation as config.ini includes all bars)
        local bar_log_file="$LOG_DIR/${bar}.log"

        # Use profile-specific config file if available, otherwise use main config.ini
        local config_file="$POLYBAR_CONFIG_DIR/config.ini"

        if [[ -n "${POLYBAR_PROFILE_CONFIG_FILE:-}" && -f "${POLYBAR_PROFILE_CONFIG_FILE:-}" ]]; then
            config_file="$POLYBAR_PROFILE_CONFIG_FILE"
            log "INFO" "Using profile-specific config: $config_file"
        else
            log "INFO" "Using default config: $config_file (profile config not found or empty)"
        fi

        # Launch polybar with the appropriate config file
        polybar --config="$config_file" --reload "$bar" >"$bar_log_file" 2>&1 &
        local pid=$!

        # Give the process a moment to start
        sleep 0.5

        if kill -0 "$pid" 2>/dev/null; then
            log "INFO" "Successfully launched $bar (PID: $pid)"
            ((launched++))
        else
            log "ERROR" "Failed to launch bar: $bar (process died immediately)"
            # Log the error details
            if [[ -f "$bar_log_file" ]]; then
                log "ERROR" "Error output for $bar: $(tail -n 3 "$bar_log_file" | tr '\n' ' ')"
            fi
            ((failed++))
        fi

        # Small delay between launches
        sleep 0.2
    done

    # Re-enable strict error checking
    set -e

    log "INFO" "Launch summary: $launched succeeded, $failed failed"

    if [[ $launched -eq 0 ]]; then
        log "ERROR" "No bars were successfully launched"
        return 1
    fi

    return 0
}

# Display help information
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] [COMMAND] [BARS...]

Enhanced Polybar Management Script

COMMANDS:
    start           Start Polybar bars (default)
    stop            Stop all Polybar processes
    restart         Restart Polybar (stop then start)
    status          Show Polybar status
    list            List available bars
    detect          Detect and show all configured bars
    cleanup         Clean up orphaned processes and logs

OPTIONS:
    -h, --help      Show this help message
    -d, --debug     Enable debug logging
    -q, --quiet     Suppress all output except errors
    -f, --force     Force operation even if already running
    -r, --reload    Reload bars (same as restart)
    --rice          Use rice-configured bars
    --all           Use all detected bars

BARS:
    If no bars specified, uses rice-configured bars or defaults.
    Available bars: ${AVAILABLE_BARS[*]}

EXAMPLES:
    $SCRIPT_NAME                           # Start rice-configured bars
    $SCRIPT_NAME start polybar-top         # Start specific bar
    $SCRIPT_NAME restart                   # Restart all configured bars
    $SCRIPT_NAME --all restart             # Restart all available bars
    $SCRIPT_NAME stop                      # Stop all bars
    $SCRIPT_NAME status                    # Show bar status
    $SCRIPT_NAME list                      # List available bars
    $SCRIPT_NAME cleanup                   # Clean up processes

LOG FILE: $LOG_FILE
EOF
}

# Status display
show_status() {
    echo "=== Polybar Status ==="
    echo

    # Process status
    if pgrep -u "$UID" -x polybar >/dev/null 2>&1; then
        local pids
        pids="$(pgrep -u "$UID" -x polybar | tr '\n' ' ')"
        local count
        count="$(pgrep -u "$UID" -x polybar | wc -l)"
        echo "🔄 Processes: $count running ✅"
        echo "   PIDs: $pids"
    else
        echo "🔄 Processes: Not running ❌"
    fi

    echo
    echo "📊 Configured Bars:"
    echo "-------------------"

    # Clear cache before showing status
    unset CACHED_POLYBAR_PROFILE_BARS
    local configured_bars_string
    configured_bars_string="$(get_configured_bars)"

    while IFS= read -r bar; do
        [[ -n "$bar" ]] && echo "$bar: Configured ✅"
    done <<< "$configured_bars_string"

    echo
    echo "📁 Config Directory: $POLYBAR_CONFIG_DIR"
    echo "📝 Log Directory: $LOG_DIR"
    echo "📝 Main Log: $LOG_FILE"
}

# List available bars
list_bars() {
    echo "=== Available Polybar Bars ==="
    echo

    echo "🎯 Rice-Configured Bars:"
    local configured_bars
    mapfile -t configured_bars < <(get_configured_bars)
    printf '   %s\n' "${configured_bars[@]}"

    echo
    echo "🔍 Detected Bars:"
    local detected_bars
    mapfile -t detected_bars < <(detect_available_bars)
    if [[ ${#detected_bars[@]} -gt 0 ]]; then
        printf '   %s\n' "${detected_bars[@]}"
    else
        echo "   No bars detected in config files"
    fi

    echo
    echo "📦 Built-in Bars:"
    printf '   %s\n' "${AVAILABLE_BARS[@]}"
}

# Cleanup function
cleanup_system() {
    log "INFO" "Performing system cleanup..."

    # Kill orphaned Polybar processes
    local orphaned_pids
    orphaned_pids="$(pgrep -u "$UID" -x polybar 2>/dev/null | tr '\n' ' ' || true)"

    if [[ -n "$orphaned_pids" ]]; then
        log "INFO" "Killing orphaned Polybar processes: $orphaned_pids"
        pkill -TERM -u "$UID" -x polybar 2>/dev/null || true
        sleep 2
        pkill -KILL -u "$UID" -x polybar 2>/dev/null || true
    fi

    # Remove stale lock files
    find /tmp -name "polybar-*.lock" -mtime +1 -delete 2>/dev/null || true

    # Clean old log files
    find "$LOG_DIR" -name "*.log.old" -mtime +7 -delete 2>/dev/null || true
    find "$LOG_DIR" -name "*.log" -size +10M -mtime +1 -delete 2>/dev/null || true

    log "INFO" "Cleanup completed"
}

# =============================================================================
# Main Function
# =============================================================================

main() {
    local debug=false
    local quiet=false
    local force=false
    local use_rice_config=true
    local use_all_bars=false
    local command="start"
    local bars=()

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
            -r|--reload)
                command="restart"
                shift
                ;;
            --rice)
                use_rice_config=true
                shift
                ;;
            --all)
                use_all_bars=true
                use_rice_config=false
                shift
                ;;
            start|stop|restart|status|list|detect|cleanup)
                command="$1"
                shift
                ;;
            polybar-*|i3-polybar-*)
                bars+=("$1")
                use_rice_config=false
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
    if [[ "$command" != "status" && "$command" != "list" && "$command" != "detect" && "$command" != "cleanup" ]]; then
        if [[ "$force" != "true" ]]; then
            acquire_lock
        fi
    fi

    log "INFO" "Starting $SCRIPT_NAME with command: $command"

    # Clear cache for fresh runs
    if [[ "$debug" == "true" ]]; then
        unset CACHED_POLYBAR_PROFILE_BARS
        log "DEBUG" "Cleared polybar profile cache"
    fi

    # Setup environment and check installation
    if [[ "$command" != "list" && "$command" != "detect" ]]; then
        setup_environment
        check_polybar_installed
    fi

    # Determine which bars to use
    if [[ "$command" =~ ^(start|restart)$ ]]; then
        if [[ ${#bars[@]} -eq 0 ]]; then
            if [[ "$use_all_bars" == "true" ]]; then
                mapfile -t bars < <(detect_available_bars)
                [[ ${#bars[@]} -eq 0 ]] && bars=("${AVAILABLE_BARS[@]}")
            elif [[ "$use_rice_config" == "true" ]]; then
                # Load rice configuration and get bars directly
                if load_rice_config; then
                    # Get the polybar profile name from rice config
                    local profile_name
                    profile_name="$(source "$RICE_CONFIG_LOADER" 2>/dev/null && echo "${POLYBAR_PROFILE:-default}" || echo "default")"

                    # Load the polybar profile (this sets POLYBAR_PROFILE_CONFIG_FILE)
                    if load_polybar_profile "$profile_name"; then
                        local rice_bars_string="$CACHED_POLYBAR_PROFILE_BARS"
                        mapfile -t bars <<< "$rice_bars_string"
                    else
                        log "WARN" "Failed to load profile '$profile_name', using default bars"
                        bars=("polybar-top" "polybar-bottom")
                    fi
                else
                    # Ultimate fallback
                    bars=("polybar-top" "polybar-bottom")
                fi
            else
                bars=("polybar-top" "polybar-bottom")
            fi
        fi

        # Filter out empty entries
        local filtered_bars=()
        for bar in "${bars[@]}"; do
            [[ -n "$bar" ]] && filtered_bars+=("$bar")
        done
        bars=("${filtered_bars[@]}")

        log "INFO" "Selected bars for $command: ${bars[*]}"
    fi

    # Execute command
    case "$command" in
        start)
            manage_polybar_processes "start"
            launch_bars "${bars[@]}"
            log "INFO" "Polybar start completed"
            ;;
        stop)
            manage_polybar_processes "stop"
            log "INFO" "Polybar stop completed"
            ;;
        restart)
            manage_polybar_processes "restart"
            launch_bars "${bars[@]}"
            log "INFO" "Polybar restart completed"
            ;;
        status)
            show_status
            ;;
        list)
            list_bars
            ;;
        detect)
            echo "Rice-configured bars:"
            get_configured_bars
            echo
            echo "Detected bars:"
            detect_available_bars
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
