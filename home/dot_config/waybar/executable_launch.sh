#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Waybar Launch Script
## Launch Waybar with profile support and rice integration
##
## Usage:
##     @script.name [OPTIONS] [ACTION]
##
## Options:
##     -h, --help              Show this help message
##     -v, --verbose           Enable verbose output
##         --profile=NAME      Use specific profile (default: from rice config or 'default')
##     -l, --list-profiles     List available Waybar profiles
##     -k, --kill              Kill running Waybar instances and exit
##     -r, --reload            Reload Waybar (kill and restart)
##
## Actions:
##     start                   Start Waybar (default action)
##     stop                    Stop Waybar instances
##     restart                 Restart Waybar
##     toggle                  Toggle Waybar visibility
##     status                  Show Waybar status
##     profiles                List available profiles (same as --list-profiles)
##
## Examples:
##     @script.name                           # Start with rice profile (or default)
##     @script.name --profile=vertical-left          # Start with vertical-left profile
##     @script.name --profile=default start          # Explicitly start with default profile
##     @script.name toggle                    # Toggle visibility
##     @script.name --reload                  # Reload waybar
##     @script.name status                    # Check if running
##     @script.name --verbose restart         # Restart with verbose output
##     @script.name --list-profiles          # List available profiles
##     @script.name profiles                  # List available profiles (alternative)

set -euo pipefail

source ~/.local/lib/dots/easy-options/easyoptions.sh || exit

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
readonly SCRIPT_NAME
readonly SCRIPT_DIR
readonly WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
readonly WAYBAR_PROFILES_DIR="$WAYBAR_CONFIG_DIR/profiles"
readonly LOG_DIR="$HOME/.cache/waybar"
readonly LOG_FILE="$LOG_DIR/waybar.log"
readonly PID_FILE="$LOG_DIR/waybar.pid"

mkdir -p "$LOG_DIR"
export DOTS_LOG_FILE="$LOG_FILE"
source ~/.local/lib/dots/logging.sh || exit

# Load rice configuration
load_rice_config() {
  local rice_config_loader="$HOME/.local/lib/dots/dots-rice-config.sh"

  if [[ ! -f $rice_config_loader ]]; then
    return 1
  fi

  export RICE_CONFIG_LOADER="$rice_config_loader"
  return 0
}

# Load waybar profile
load_waybar_profile() {
  local profile_name="${1:-default}"
  local profile_file="$WAYBAR_PROFILES_DIR/${profile_name}.sh"

  if [[ ! -f $profile_file ]]; then
    log "WARN" "Waybar profile not found: $profile_file, using default"
    profile_name="default"
    profile_file="$WAYBAR_PROFILES_DIR/default.sh"
  fi

  if [[ -f $profile_file ]]; then
    # shellcheck source=/dev/null
    source "$profile_file"
    log "INFO" "Loaded waybar profile: $profile_name"

    # Initialize profile if function exists
    if declare -f waybar_profile_init >/dev/null 2>&1; then
      waybar_profile_init
    fi

    return 0
  fi

  return 1
}

# Kill existing waybar instances
kill_waybar() {
  log "INFO" "Stopping Waybar instances"
  killall -q waybar 2>/dev/null || true
  while pgrep -x waybar >/dev/null; do sleep 0.1; done
  rm -f "$PID_FILE"
  log "INFO" "Waybar stopped"
}

# Check if waybar is running
is_waybar_running() {
  pgrep -x waybar >/dev/null
}

# Get waybar status
get_waybar_status() {
  if is_waybar_running; then
    local pid_count
    pid_count=$(pgrep -x waybar | wc -l)
    echo "Waybar is running ($pid_count instance(s))"
    pgrep -x waybar | while read -r pid; do
      echo "  PID: $pid"
    done
    return 0
  else
    echo "Waybar is not running"
    return 1
  fi
}

# Toggle waybar visibility
toggle_waybar() {
  if is_waybar_running; then
    kill_waybar
  else
    start_waybar
  fi
}

# List available profiles
list_profiles() {
  local current_rice_profile=""

  # Try to get current rice profile
  if load_rice_config; then
    current_rice_profile="$(source "$RICE_CONFIG_LOADER" 2>/dev/null && echo "${WAYBAR_PROFILE:-}" || echo "")"
  fi

  echo "Available Waybar Profiles:"
  echo "=========================="
  echo ""

  if [[ ! -d $WAYBAR_PROFILES_DIR ]]; then
    echo "❌ Profiles directory not found: $WAYBAR_PROFILES_DIR"
    return 1
  fi

  local profile_count=0
  local profiles=()

  # Collect profiles
  while IFS= read -r -d '' profile_file; do
    local profile_name
    profile_name="$(basename "$profile_file" .sh)"
    profiles+=("$profile_name")
  done < <(find "$WAYBAR_PROFILES_DIR" -maxdepth 1 -name "*.sh" -type f -print0 | sort -z)

  # Display profiles
  for profile_name in "${profiles[@]}"; do
    profile_count=$((profile_count + 1))
    local profile_file="$WAYBAR_PROFILES_DIR/${profile_name}.sh"
    local marker=""

    # Mark current rice profile
    if [[ -n $current_rice_profile && $profile_name == "$current_rice_profile" ]]; then
      marker=" 🌾 (rice)"
    elif [[ $profile_name == "default" ]]; then
      marker=" ⭐ (default)"
    fi

    # Extract description from profile file
    local description=""
    if [[ -f $profile_file ]]; then
      # Try to source and get WAYBAR_PROFILE_DESCRIPTION
      description=$(
        unset WAYBAR_PROFILE_DESCRIPTION
        # shellcheck source=/dev/null
        source "$profile_file" 2>/dev/null
        echo "${WAYBAR_PROFILE_DESCRIPTION:-}"
      )
    fi

    if [[ -n $description ]]; then
      echo "  📊 $profile_name${marker}"
      echo "      $description"
    else
      echo "  📊 $profile_name${marker}"
    fi
    echo ""
  done

  echo "Total: $profile_count profile(s)"
  echo ""
  echo "Usage: $SCRIPT_NAME --profile PROFILE_NAME start"

  if [[ -n $current_rice_profile ]]; then
    echo "Current rice profile: $current_rice_profile"
  fi

  return 0
}

# Start waybar
start_waybar() {
  # Kill any existing instances first
  killall -q waybar 2>/dev/null || true
  while pgrep -x waybar >/dev/null; do sleep 0.1; done

  log "INFO" "Starting Waybar"

  # Determine profile to use
  local profile_name="default"

  # Priority 1: Command-line argument
  if [[ -n ${profile:-} ]]; then
    profile_name="$profile"
    log "INFO" "Using profile from command line: $profile_name"
  # Priority 2: Rice configuration
  elif load_rice_config; then
    profile_name="$(source "$RICE_CONFIG_LOADER" 2>/dev/null && echo "${WAYBAR_PROFILE:-default}" || echo "default")"
    log "INFO" "Using profile from rice config: $profile_name"
  else
    log "INFO" "Using default profile"
  fi

  if load_waybar_profile "$profile_name"; then
    # Profile loaded successfully
    # Set style file (required for all modes)
    style_file="${WAYBAR_PROFILE_STYLE_FILE:-$WAYBAR_CONFIG_DIR/configs/default/style.css}"

    # Check if dual-bar mode
    if [[ ${WAYBAR_PROFILE_DUAL_BAR:-false} == "true" ]]; then
      # Dual-bar mode uses top/bottom configs
      config_file="$WAYBAR_CONFIG_DIR/config" # Fallback (not used in dual-bar)
    elif [[ -n ${WAYBAR_PROFILE_CONFIG_FILE:-} && -f ${WAYBAR_PROFILE_CONFIG_FILE:-} ]]; then
      # Single-bar mode with custom config
      config_file="$WAYBAR_PROFILE_CONFIG_FILE"
    else
      # Fallback to default
      config_file="$WAYBAR_CONFIG_DIR/config"
    fi
  else
    # Fallback
    config_file="$WAYBAR_CONFIG_DIR/config"
    style_file="$WAYBAR_CONFIG_DIR/style.css"
  fi

  log "INFO" "Using config: $config_file"
  log "INFO" "Using style: $style_file"

  # Ensure Wayland backend for GTK (required for Waybar)
  export GDK_BACKEND=wayland

  # Launch Waybar (single or dual-bar mode)
  if [[ ${WAYBAR_PROFILE_DUAL_BAR:-false} == "true" && -n ${WAYBAR_PROFILE_CONFIG_TOP:-} && -n ${WAYBAR_PROFILE_CONFIG_BOTTOM:-} ]]; then
    # Dual-bar mode (top + bottom)
    log "INFO" "Using dual-bar mode"
    log "INFO" "Top bar config: $WAYBAR_PROFILE_CONFIG_TOP"
    log "INFO" "Bottom bar config: $WAYBAR_PROFILE_CONFIG_BOTTOM"

    if [[ -f $WAYBAR_PROFILE_CONFIG_TOP && -f $WAYBAR_PROFILE_CONFIG_BOTTOM ]]; then
      waybar -c "$WAYBAR_PROFILE_CONFIG_TOP" -s "$style_file" >>"$LOG_FILE" 2>&1 &
      echo $! >>"$PID_FILE"
      log "INFO" "Waybar top bar started (PID: $!)"

      waybar -c "$WAYBAR_PROFILE_CONFIG_BOTTOM" -s "$style_file" >>"$LOG_FILE" 2>&1 &
      echo $! >>"$PID_FILE"
      log "INFO" "Waybar bottom bar started (PID: $!)"
    else
      log "ERROR" "Dual-bar config files not found"
      exit 1
    fi
  else
    # Single-bar mode
    log "INFO" "Using single-bar mode"
    log "INFO" "Using config: $config_file"

    if [[ -f $config_file ]]; then
      waybar -c "$config_file" -s "$style_file" >>"$LOG_FILE" 2>&1 &
      echo $! >>"$PID_FILE"
      log "INFO" "Waybar started (PID: $!)"
    else
      log "ERROR" "Config file not found: $config_file"
      exit 1
    fi
  fi
}

# Main logic
main() {
  # Handle --list-profiles flag
  if [[ ${list_profiles:-no} == yes ]]; then
    list_profiles
    exit 0
  fi

  # Handle --kill flag
  if [[ ${kill:-no} == yes ]]; then
    kill_waybar
    exit 0
  fi

  # Handle --reload flag
  if [[ ${reload:-no} == yes ]]; then
    kill_waybar
    start_waybar
    exit 0
  fi

  # Get action from arguments (default: start)
  local action="${arguments[0]:-start}"

  case "$action" in
    start)
      start_waybar
      ;;
    stop)
      kill_waybar
      ;;
    restart)
      kill_waybar
      start_waybar
      ;;
    toggle)
      toggle_waybar
      ;;
    status)
      get_waybar_status
      ;;
    profiles | list)
      list_profiles
      ;;
    *)
      log "ERROR" "Unknown action: $action"
      echo "Valid actions: start, stop, restart, toggle, status, profiles"
      exit 1
      ;;
  esac
}

main
