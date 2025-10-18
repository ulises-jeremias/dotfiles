#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Universal EWW Widget Manager
## Provides centralized management for all EWW components
##
## Check full documentation at: https://github.com/ulises-jeremias/dotfiles/wiki
##
## Usage:
##     @script.name [OPTIONS] [COMMAND] [COMPONENT] [WIDGETS...]
##
## Commands:
##     toggle          Toggle component widgets (default)
##     open            Open component widgets
##     close           Close component widgets
##     restart         Restart EWW daemon and reopen widgets
##     status          Show component status
##     list            List all components and widgets
##     daemon          Manage EWW daemon (start|stop|restart)
##     cleanup         Clean up orphaned processes and files
##
## Options:
##     -h, --help      Show this help message.
##     -d, --debug     Enable debug logging.
##     -q, --quiet     Suppress all output except errors.
##     -f, --force     Force operation even if already running.
##     -a, --all       Operate on all components.
##
## Components:
##     dashboard       Dashboard component with system info, weather, music, etc.
##     powermenu       Power management interface (lock, logout, sleep, reboot, shutdown)
##
## Examples:
##     @script.name status                 # Show all component status
##     @script.name list                   # List all components and widgets
##     @script.name toggle dashboard       # Toggle dashboard
##     @script.name open powermenu         # Open powermenu
##     @script.name -a toggle              # Toggle all components
##     @script.name daemon restart         # Restart EWW daemon
##     @script.name cleanup                # Clean up all processes

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

  # Only log to file if not in quiet mode, but always log errors to stderr
  if [[ ${quiet:-} != "yes" ]] || [[ $level == "ERROR" ]]; then
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
  else
    echo "[$timestamp] [$level] $message" >>"$LOG_FILE"
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
  if [[ -f $LOG_FILE ]] && [[ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) -gt 1048576 ]]; then
    mv "$LOG_FILE" "${LOG_FILE}.old"
    log "INFO" "Log rotated"
  fi
}

# Cleanup function
cleanup_on_exit() {
  [[ -f $LOCK_FILE ]] && rm -f "$LOCK_FILE"
}

# Lock management
acquire_lock() {
  if [[ -f $LOCK_FILE ]]; then
    local pid
    pid="$(cat "$LOCK_FILE")"
    if kill -0 "$pid" 2>/dev/null; then
      error_exit "Another instance is already running (PID: $pid)" 2
    else
      log "WARN" "Stale lock file found, removing..."
      rm -f "$LOCK_FILE"
    fi
  fi

  echo $$ >"$LOCK_FILE"
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
  if [[ -z ${EWW_COMPONENTS[$component]:-} ]]; then
    log "ERROR" "Invalid component: $component"
    log "INFO" "Available components: ${!EWW_COMPONENTS[*]}"
    return 1
  fi

  if [[ ! -d ${EWW_COMPONENTS[$component]} ]]; then
    log "ERROR" "Component directory not found: ${EWW_COMPONENTS[$component]}"
    return 1
  fi

  return 0
}

# Component operations
component_operation() {
  local operation="$1"
  local component="$2"
  shift 2
  local widgets=("$@")

  # If no specific widgets provided, use all widgets for the component
  if [[ ${#widgets[@]} -eq 0 ]]; then
    local component_widget_string="${COMPONENT_WIDGETS[$component]}"
    read -ra widgets <<<"$component_widget_string"
  fi

  local config_dir="${EWW_COMPONENTS[$component]}"

  # Validate widgets exist in config
  for widget in "${widgets[@]}"; do
    if ! eww --config "$config_dir" windows | grep -q "^$widget" 2>/dev/null; then
      log "WARN" "Widget '$widget' not found in $component config"
    fi
  done

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

# Status display
show_status() {
  echo "=== Universal EWW Manager Status ==="
  echo

  # Daemon status
  if eww ping >/dev/null 2>&1; then
    echo "Daemon: Running ✅"
  else
    echo "Daemon: Not running ❌"
  fi

  echo
  echo "Component Status:"
  echo "-----------------"

  for component in "${!EWW_COMPONENTS[@]}"; do
    echo
    echo "📦 $component (${EWW_COMPONENTS[$component]})"
    echo "   Status: $(validate_component "$component" && echo "Available ✅" || echo "Unavailable ❌")"

    if validate_component "$component"; then
      local config_dir="${EWW_COMPONENTS[$component]}"
      local open_widgets
      open_widgets="$(eww --config "$config_dir" windows 2>/dev/null || echo "")"

      local component_widget_string="${COMPONENT_WIDGETS[$component]}"
      read -ra component_widgets <<<"$component_widget_string"

      echo "   Widgets:"
      for widget in "${component_widgets[@]}"; do
        if echo "$open_widgets" | grep -q "^$widget"; then
          echo "     $widget: Open ✅"
        else
          echo "     $widget: Closed ❌"
        fi
      done
    fi
  done

  echo
  echo "Log File: $LOG_FILE"
}

# List components and widgets
list_components() {
  echo "=== Available EWW Components ==="
  echo

  for component in "${!EWW_COMPONENTS[@]}"; do
    echo "📦 $component"
    echo "   Config: ${EWW_COMPONENTS[$component]}"
    echo "   Widgets:"

    local component_widget_string="${COMPONENT_WIDGETS[$component]}"
    read -ra component_widgets <<<"$component_widget_string"

    for widget in "${component_widgets[@]}"; do
      echo "     - $widget"
    done
    echo
  done
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
  local component=""
  local widgets=()
  local daemon_action="start"

  # Process positional arguments for commands, components and widgets
  for arg in "${arguments[@]:-}"; do
    # Skip empty arguments
    [[ -z $arg ]] && continue

    case "$arg" in
      toggle | open | close | restart | cleanup)
        command="$arg"
        ;;
      status | list | daemon)
        command="$arg"
        ;;
      start | stop)
        if [[ $command == "daemon" ]]; then
          daemon_action="$arg"
        else
          error_exit "Invalid argument: $arg"
        fi
        ;;
      dashboard | powermenu)
        component="$arg"
        ;;
      dashboard-* | powermenu-*)
        widgets+=("$arg")
        ;;
      *)
        error_exit "Unknown argument: $arg"
        ;;
    esac
  done

  # Enable debug mode if requested
  if [[ ${debug:-} == "yes" ]]; then
    set -x
    log "INFO" "Debug mode enabled"
  fi

  # Quiet mode setup - redirect stdout to null but keep stderr
  if [[ ${quiet:-} == "yes" ]]; then
    exec 1>/dev/null
  fi

  # Acquire lock unless it's a status or list command
  if [[ $command != "status" && $command != "list" && $command != "cleanup" ]]; then
    if [[ ${force:-} != "yes" ]]; then
      acquire_lock
    fi
  fi

  log "INFO" "Starting $SCRIPT_NAME with command: $command"

  # Check EWW installation for most commands
  if [[ $command != "list" ]]; then
    check_eww_installed
  fi

  # Execute command
  case "$command" in
    toggle | open | close)
      manage_eww_daemon "start"

      if [[ ${all:-} == "yes" ]]; then
        for comp in "${!EWW_COMPONENTS[@]}"; do
          if validate_component "$comp"; then
            component_operation "$command" "$comp"
            log "INFO" "Operation '$command' completed for $comp"
          fi
        done
      elif [[ -n $component ]]; then
        if validate_component "$component"; then
          component_operation "$command" "$component" "${widgets[@]}"
          log "INFO" "Operation '$command' completed for $component"
        fi
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
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  main "$@"
fi
