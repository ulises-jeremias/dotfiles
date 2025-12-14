#!/usr/bin/env bash

## Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
## Licensed under MIT.
##
## Notification action handler for Mako
## Handles interactive notification actions (media controls, app launching, etc.)
##
## Check full documentation at: https://github.com/ulises-jeremias/dotfiles/wiki
##
## Usage:
##     @script.name [ACTION] [APP_NAME] [SUMMARY] [BODY]
##
## Actions:
##     middle       Handle middle button click
##     left         Handle left button click
##     right        Handle right button click
##
## Options:
##     -h, --help   Show this help message

set -euo pipefail

source ~/.local/lib/dots/easy-options/easyoptions.sh || exit

readonly ACTION="${arguments[0]:-}"
readonly APP_NAME="${arguments[1]:-}"
readonly SUMMARY="${arguments[2]:-}"
readonly BODY="${arguments[3]:-}"

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    case "$level" in
        ERROR) echo "[ERROR] $message" >&2 ;;
        WARN)  echo "[WARN] $message" >&2 ;;
        INFO)  echo "[INFO] $message" ;;
        *)     echo "$message" ;;
    esac
}

# Handle media player notifications
handle_media_notification() {
    local app_name="$1"
    local action="$2"
    
    case "$app_name" in
        Spotify|spotify|mpv|vlc|rhythmbox)
            case "$action" in
                middle)
                    if command -v playerctl >/dev/null 2>&1; then
                        playerctl play-pause
                        log "INFO" "Media play/pause toggled"
                    fi
                    ;;
                left)
                    if command -v playerctl >/dev/null 2>&1; then
                        playerctl previous
                        log "INFO" "Previous track"
                    fi
                    ;;
                right)
                    if command -v playerctl >/dev/null 2>&1; then
                        playerctl next
                        log "INFO" "Next track"
                    fi
                    ;;
            esac
            ;;
    esac
}

# Handle application-specific notifications
handle_app_notification() {
    local app_name="$1"
    local action="$2"
    local summary="$3"
    local body="$4"
    
    case "$app_name" in
        brave-browser|firefox|chromium)
            case "$action" in
                left)
                    # Open browser if notification is about something actionable
                    if [[ "$summary" =~ (http|https) ]]; then
                        xdg-open "$summary" 2>/dev/null || true
                    fi
                    ;;
            esac
            ;;
        discord|Slack|telegram-desktop)
            case "$action" in
                left)
                    # Focus or launch communication app
                    hyprctl dispatch focuswindow "class:$app_name" 2>/dev/null || \
                    exo-open --launch "$app_name" 2>/dev/null || true
                    ;;
            esac
            ;;
    esac
}

# Main handler
main() {
    if [[ -z "$ACTION" ]]; then
        log "ERROR" "No action specified"
        exit 1
    fi
    
    # Handle media notifications
    handle_media_notification "$APP_NAME" "$ACTION"
    
    # Handle app-specific notifications
    handle_app_notification "$APP_NAME" "$ACTION" "$SUMMARY" "$BODY"
}

main "$@"

