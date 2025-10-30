#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Waybar Launch Script
## Similar architecture to Polybar launch script

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
readonly SCRIPT_NAME
readonly SCRIPT_DIR
readonly WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
readonly WAYBAR_PROFILES_DIR="$WAYBAR_CONFIG_DIR/profiles"
readonly LOG_DIR="$HOME/.cache/waybar"
readonly LOG_FILE="$LOG_DIR/waybar.log"

# Setup logging
mkdir -p "$LOG_DIR"

log() {
  local level="$1"
  shift
  local message="$*"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

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
killall -q waybar 2>/dev/null || true
while pgrep -x waybar >/dev/null; do sleep 0.1; done

log "INFO" "Starting Waybar"

# Load rice configuration
if load_rice_config; then
  # Get waybar profile from rice config
  profile_name="$(source "$RICE_CONFIG_LOADER" 2>/dev/null && echo "${WAYBAR_PROFILE:-default}" || echo "default")"

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
else
  # Fallback when no rice system
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
    log "INFO" "Waybar top bar started (PID: $!)"

    waybar -c "$WAYBAR_PROFILE_CONFIG_BOTTOM" -s "$style_file" >>"$LOG_FILE" 2>&1 &
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
    log "INFO" "Waybar started (PID: $!)"
  else
    log "ERROR" "Config file not found: $config_file"
    exit 1
  fi
fi
