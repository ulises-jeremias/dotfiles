#!/usr/bin/env bash

## Logging Library for HorneroConfig Scripts
## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Provides standardized logging functions for dots scripts
## Usage: source ~/.local/lib/dots/logging.sh

# Initialize logging if not already initialized
if [[ -z "${DOTS_LOG_INITIALIZED:-}" ]]; then
  readonly DOTS_LOG_DIR="${DOTS_LOG_DIR:-$HOME/.cache/dots/logs}"
  readonly DOTS_LOG_FILE="${DOTS_LOG_FILE:-$DOTS_LOG_DIR/$(basename "${0:-dots-script}" .sh).log}"
  
  # Create log directory if it doesn't exist
  mkdir -p "$DOTS_LOG_DIR"
  
  export DOTS_LOG_INITIALIZED=1
fi

# Log levels
readonly LOG_LEVEL_ERROR=0
readonly LOG_LEVEL_WARN=1
readonly LOG_LEVEL_INFO=2
readonly LOG_LEVEL_DEBUG=3

# Default log level (can be overridden by script)
DOTS_LOG_LEVEL="${DOTS_LOG_LEVEL:-$LOG_LEVEL_INFO}"

# Check if verbose mode is enabled
_is_verbose() {
  [[ "${verbose:-no}" == "yes" ]] || [[ "${debug:-no}" == "yes" ]] || [[ "${DOTS_LOG_LEVEL}" -ge "$LOG_LEVEL_DEBUG" ]]
}

# Check if level should be logged
_should_log() {
  local level="$1"
  case "$level" in
    ERROR) [[ "$DOTS_LOG_LEVEL" -ge "$LOG_LEVEL_ERROR" ]] ;;
    WARN)  [[ "$DOTS_LOG_LEVEL" -ge "$LOG_LEVEL_WARN" ]] ;;
    INFO)  [[ "$DOTS_LOG_LEVEL" -ge "$LOG_LEVEL_INFO" ]] ;;
    DEBUG) [[ "$DOTS_LOG_LEVEL" -ge "$LOG_LEVEL_DEBUG" ]] ;;
    *)     true ;;
  esac
}

# Main logging function
log() {
  local level="${1:-INFO}"
  shift
  local message="$*"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  
  # Skip if level is below threshold
  if ! _should_log "$level"; then
    return 0
  fi
  
  # Color codes
  local color reset="\033[0m"
  case "$level" in
    ERROR) color="\033[0;31m" ;;  # Red
    WARN)  color="\033[0;33m" ;;  # Yellow
    INFO)  color="\033[0;32m" ;;  # Green
    DEBUG) color="\033[0;36m" ;;  # Cyan
    *)     color="\033[0m" ;;     # Reset
  esac
  
  # Format log entry
  local log_entry="[$timestamp] [$level] $message"
  
  # Output to stderr for errors, stdout for others
  if [[ "$level" == "ERROR" ]]; then
    echo -e "${color}${log_entry}${reset}" >&2
  elif _is_verbose || [[ "$level" == "INFO" ]] || [[ "$level" == "WARN" ]]; then
    echo -e "${color}${log_entry}${reset}"
  fi
  
  # Always log to file
  echo "$log_entry" >> "$DOTS_LOG_FILE" 2>/dev/null || true
}

# Convenience functions
log_error() {
  log "ERROR" "$@"
}

log_warn() {
  log "WARN" "$@"
}

log_info() {
  log "INFO" "$@"
}

log_debug() {
  log "DEBUG" "$@"
}

# Set log level
set_log_level() {
  case "${1:-INFO}" in
    ERROR) DOTS_LOG_LEVEL=$LOG_LEVEL_ERROR ;;
    WARN)  DOTS_LOG_LEVEL=$LOG_LEVEL_WARN ;;
    INFO)  DOTS_LOG_LEVEL=$LOG_LEVEL_INFO ;;
    DEBUG) DOTS_LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
    *)     DOTS_LOG_LEVEL=$LOG_LEVEL_INFO ;;
  esac
}

