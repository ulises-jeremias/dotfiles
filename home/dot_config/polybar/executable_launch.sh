#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Enhanced Polybar Launch Script
## Provides robust bar management with comprehensive error handling and logging
##
## Check full documentation at: https://github.com/ulises-jeremias/dotfiles/wiki
##
## Usage:
##     @script.name [OPTIONS] [COMMAND] [BARS...]
##
## Commands:
##     start           Start Polybar bars (default)
##     stop            Stop all Polybar processes
##     restart         Restart Polybar (stop then start)
##     status          Show Polybar status
##     list            List available bars
##     detect          Detect and show all configured bars
##     cleanup         Clean up orphaned processes and logs
##     kill            Aggressively kill all polybar processes (pkill -9)
##
## Options:
##     -h, --help      Show this help message
##     -d, --debug     Enable debug logging
##     -q, --quiet     Suppress all output except errors
##     -f, --force     Force operation even if already running
##     -r, --reload    Reload bars (same as restart)
##         --rice      Use rice-configured bars
##         --all       Use all detected bars
##
## Examples:
##     @script.name                           # Start rice-configured bars
##     @script.name start polybar-top         # Start specific bar
##     @script.name restart                   # Restart all configured bars
##     @script.name --all restart             # Restart all available bars
##     @script.name stop                      # Stop all bars
##     @script.name status                    # Show bar status
##     @script.name list                      # List available bars
##     @script.name cleanup                   # Clean up processes
##     @script.name kill                      # Aggressively kill all polybar processes
##

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
readonly POLYBAR_CONFIG_DIR="$HOME/.config/polybar"
readonly POLYBAR_PROFILES_DIR="$POLYBAR_CONFIG_DIR/profiles"
readonly LOG_DIR="$HOME/.cache/polybar"
readonly LOG_FILE="$LOG_DIR/polybar.log"
readonly LOCK_FILE="/tmp/polybar-launch.lock"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=1
readonly DEFAULT_TERM="xterm-256color"

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
    # Clean up smart color environment variables (semantic + basic)
    unset SMART_COLOR_ERROR SMART_COLOR_WARNING SMART_COLOR_SUCCESS SMART_COLOR_INFO SMART_COLOR_ACCENT \
          SMART_COLOR_RED SMART_COLOR_GREEN SMART_COLOR_BLUE SMART_COLOR_YELLOW SMART_COLOR_CYAN \
          SMART_COLOR_MAGENTA SMART_COLOR_ORANGE SMART_COLOR_PINK SMART_COLOR_BROWN \
          SMART_COLOR_WHITE SMART_COLOR_BLACK SMART_COLOR_GRAY 2>/dev/null || true

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

            # Initialize the profile (this sets up smart colors and other profile-specific configs)
            if declare -f polybar_profile_init >/dev/null 2>&1; then
                log_quiet "INFO" "Initializing profile: $profile_name"
                polybar_profile_init || log_quiet "WARN" "Profile initialization failed for: $profile_name"
            else
                log_quiet "DEBUG" "No initialization function found for profile: $profile_name"
            fi

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

# Enhanced process management with aggressive cleanup
manage_polybar_processes() {
    local action="${1:-restart}"

    case "$action" in
        stop)
            log "INFO" "Stopping Polybar processes..."

            if pgrep -u "$UID" -x polybar >/dev/null 2>&1; then
                local initial_pids initial_count
                initial_pids="$(pgrep -u "$UID" -x polybar | tr '\n' ' ')"
                initial_count="$(pgrep -u "$UID" -x polybar | wc -l | tr -d '[:space:]')"
                log "INFO" "Found $initial_count Polybar processes: $initial_pids"

                # Be more aggressive - skip graceful termination for faster response
                log "INFO" "Using immediate SIGKILL for faster cleanup..."
                pkill -9 -u "$UID" -x polybar 2>/dev/null || true

                # Short wait for system cleanup
                sleep 0.3

                # Individual kill for any remaining processes
                while IFS= read -r pid; do
                    [[ -n "$pid" ]] && kill -9 "$pid" 2>/dev/null || true
                done < <(pgrep -u "$UID" -x polybar 2>/dev/null)

                # Clean up any polybar-related processes
                pkill -9 -u "$UID" -f "polybar.*config" 2>/dev/null || true

                # Brief final wait
                sleep 0.2

                # Final verification
                local final_count
                final_count="$(pgrep -u "$UID" -x polybar 2>/dev/null | wc -l 2>/dev/null | tr -d '[:space:]' || echo 0)"
                if [[ "$final_count" -eq 0 ]]; then
                    log "INFO" "All polybar processes successfully terminated"
                else
                    log "WARN" "$final_count processes still running but continuing..."
                fi
            else
                log "INFO" "No Polybar processes found"
            fi
            ;;

        start|restart)
            # Always ensure clean state before starting
            if [[ "$action" == "restart" ]]; then
                manage_polybar_processes "stop"
            else
                # Even for 'start', do a quick cleanup of any existing processes
                local existing_count
                existing_count="$(pgrep -u "$UID" -x polybar 2>/dev/null | wc -l 2>/dev/null | tr -d '[:space:]' || echo 0)"
                if [[ "$existing_count" -gt 0 ]]; then
                    log "WARN" "Found $existing_count existing polybar processes before start, cleaning up..."
                    manage_polybar_processes "stop"
                fi
            fi

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

# Status display
show_status() {
    echo "=== Polybar Status ==="
    echo

    # Process status
    if pgrep -u "$UID" -x polybar >/dev/null 2>&1; then
        local pids
        pids="$(pgrep -u "$UID" -x polybar | tr '\n' ' ')"
        local count
        count="$(pgrep -u "$UID" -x polybar | wc -l | tr -d '[:space:]')"
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
}

# Cleanup function with aggressive polybar process cleanup
cleanup_system() {
    log "INFO" "Performing system cleanup..."

    # Kill orphaned Polybar processes aggressively
    local orphaned_count
    orphaned_count="$(pgrep -u "$UID" -x polybar 2>/dev/null | wc -l 2>/dev/null | tr -d '[:space:]' || echo 0)"

    if [[ "$orphaned_count" -gt 0 ]]; then
        local orphaned_pids
        orphaned_pids="$(pgrep -u "$UID" -x polybar 2>/dev/null | tr '\n' ' ' || true)"
        log "INFO" "Found $orphaned_count orphaned Polybar processes: $orphaned_pids"

        # First try SIGTERM
        log "INFO" "Attempting graceful termination of orphaned processes..."
        pkill -TERM -u "$UID" -x polybar 2>/dev/null || true
        sleep 2

        # Then use SIGKILL if any remain
        local remaining_count
        remaining_count="$(pgrep -u "$UID" -x polybar 2>/dev/null | wc -l 2>/dev/null | tr -d '[:space:]' || echo 0)"
        if [[ "$remaining_count" -gt 0 ]]; then
            log "WARN" "Force killing $remaining_count remaining orphaned processes with SIGKILL..."
            pkill -9 -u "$UID" -x polybar 2>/dev/null || true
            sleep 1

            # Individual kill if still needed
            while IFS= read -r pid; do
                [[ -n "$pid" ]] && kill -9 "$pid" 2>/dev/null || true
            done < <(pgrep -u "$UID" -x polybar 2>/dev/null)
        fi

        # Final verification
        local final_count
        final_count="$(pgrep -u "$UID" -x polybar 2>/dev/null | wc -l 2>/dev/null | tr -d '[:space:]' || echo 0)"
        if [[ "$final_count" -eq 0 ]]; then
            log "INFO" "Successfully cleaned up all orphaned polybar processes"
        else
            log "ERROR" "Failed to clean up $final_count orphaned polybar processes"
        fi
    else
        log "INFO" "No orphaned polybar processes found"
    fi

    # Clean up any polybar-related processes by command line pattern
    log "INFO" "Cleaning up polybar-related processes by pattern..."
    pkill -9 -u "$UID" -f "polybar.*config" 2>/dev/null || true
    pkill -9 -u "$UID" -f "polybar --config" 2>/dev/null || true

    # Remove stale lock files
    find /tmp -name "polybar-*.lock" -user "$USER" -mtime +1 -delete 2>/dev/null || true
    [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"

    # Clean old log files
    find "$LOG_DIR" -name "*.log.old" -mtime +7 -delete 2>/dev/null || true
    find "$LOG_DIR" -name "*.log" -size +10M -mtime +1 -delete 2>/dev/null || true

    log "INFO" "Cleanup completed"
}

# =============================================================================
# Main Function
# =============================================================================

main() {
    # Parse command from arguments (first positional argument that matches a command)
    local command="start"
    local bars=()
    local use_rice_config=true
    local use_all_bars=false

    # Process arguments to extract command and bars
    for arg in "${arguments[@]}"; do
        case "$arg" in
            start|stop|restart|status|list|detect|cleanup|kill)
                command="$arg"
                ;;
            polybar-*|i3-polybar-*)
                bars+=("$arg")
                use_rice_config=false
                ;;
        esac
    done

    # Handle options from EasyOptions
    if [[ -n "${reload:-}" ]]; then
        command="restart"
    fi

    if [[ -n "${all:-}" ]]; then
        use_all_bars=true
        use_rice_config=false
    fi

    if [[ -n "${rice:-}" ]]; then
        use_rice_config=true
    fi

    # Setup logging
    setup_logging

    # Quiet mode setup
    if [[ -n "${quiet:-}" ]]; then
        exec 1>/dev/null
    fi

    # Debug mode setup
    if [[ -n "${debug:-}" ]]; then
        set -x
    fi

    # Acquire lock unless it's a status or list command
    if [[ "$command" != "status" && "$command" != "list" && "$command" != "detect" && "$command" != "cleanup" && "$command" != "kill" ]]; then
        if [[ -z "${force:-}" ]]; then
            acquire_lock
        fi
    fi

    log "INFO" "Starting $SCRIPT_NAME with command: $command"

    # Clear cache for fresh runs
    if [[ -n "${debug:-}" ]]; then
        unset CACHED_POLYBAR_PROFILE_BARS
        log "DEBUG" "Cleared polybar profile cache"
    fi

    # Setup environment and check installation
    if [[ "$command" != "list" && "$command" != "detect" && "$command" != "kill" ]]; then
        setup_environment
        check_polybar_installed
    fi

    # Determine which bars to use
    if [[ "$command" =~ ^(start|restart)$ ]]; then
        if [[ ${#bars[@]} -eq 0 ]]; then
            if [[ "$use_all_bars" == "true" ]]; then
                mapfile -t bars < <(detect_available_bars)
                [[ ${#bars[@]} -eq 0 ]] && bars=("polybar-top" "polybar-bottom")
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
        kill)
            log "INFO" "Performing aggressive polybar process termination..."
            local count_before
            count_before="$(pgrep -u "$UID" -x polybar 2>/dev/null | wc -l 2>/dev/null | tr -d '[:space:]' || echo 0)"

            if [[ "$count_before" -gt 0 ]]; then
                log "INFO" "Found $count_before polybar processes, killing with SIGKILL..."

                # Direct pkill -9 approach as you used before
                pkill -9 -u "$UID" -x polybar 2>/dev/null || true

                # Also kill by pattern to catch any variations
                pkill -9 -u "$UID" -f "polybar.*config" 2>/dev/null || true
                pkill -9 -u "$UID" -f "polybar --config" 2>/dev/null || true

                # Individual kill for any remaining
                while IFS= read -r pid; do
                    [[ -n "$pid" ]] && kill -9 "$pid" 2>/dev/null || true
                done < <(pgrep -u "$UID" -x polybar 2>/dev/null)

                sleep 1

                local count_after
                count_after="$(pgrep -u "$UID" -x polybar 2>/dev/null | wc -l 2>/dev/null | tr -d '[:space:]' || echo 0)"

                if [[ "$count_after" -eq 0 ]]; then
                    log "INFO" "Successfully killed all $count_before polybar processes"
                else
                    log "ERROR" "Could not kill all processes: $count_after still running"
                fi
            else
                log "INFO" "No polybar processes found to kill"
            fi
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
