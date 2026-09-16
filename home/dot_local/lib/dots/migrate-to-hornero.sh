#!/usr/bin/env bash
# migrate-to-hornero.sh - one-shot dots/* -> hornero/* migration backend.
# Usage: lib/dots/migrate-to-hornero.sh --dry-run | --yes
#
# Migrates Hornero-owned state ONLY (HorneroOS/hornero docs/PATH_CONTRACT.md
# rows 1-5,9-11, restricted to the Hornero-owned set below). Readers keep
# their dots/* fallbacks; this script only copies, never deletes dots/*.
#
# Migrated rows (copy-if-canonical-absent, never overwrites canonical):
#   row 1:  theme packs        $XDG_DATA_HOME/dots/themes/<id>/theme.json
#                              -> $XDG_DATA_HOME/hornero/themes/<id>/theme.json
#   row 2:  shell presets      $XDG_DATA_HOME/dots/shell-presets/*.json
#                              -> $XDG_DATA_HOME/hornero/shell-presets/
#   row 3:  active-preset pointer (shell-presets domain)
#           $XDG_STATE_HOME/dots/current-shell-preset
#                              -> $XDG_STATE_HOME/hornero/current-shell-preset
#   row 4:  scheme runtime     $XDG_CACHE_HOME/dots/smart-colors/scheme.json
#                              -> $XDG_CACHE_HOME/hornero/smart-colors/scheme.json
#   row 5:  scheme state       $XDG_STATE_HOME/dots/scheme/state.json
#                              -> $XDG_STATE_HOME/hornero/scheme/state.json
#   row 9:  wallpaper pointer  $XDG_STATE_HOME/dots/wallpaper/path
#                              -> $XDG_STATE_HOME/hornero/wallpaper/path
#   row 10: notifications      $XDG_STATE_HOME/dots/notifs.json
#                              -> $XDG_STATE_HOME/hornero/notifs.json
#
# Explicitly NOT migrated (reported as skip with reason, never touched):
#   row 7 snapshots ($XDG_CACHE_HOME/dots/snapshots/): regenerable cache.
#   row 6 shell.json ($XDG_CONFIG_HOME/hornero/shell.json): already
#     canonical; the user file is owned by the shell runtime.
#   row 11 wallpaper binaries ($XDG_DATA_HOME/dots/wallpapers/): open
#     contract question 1; wallpapers.manifest.json abstracts the location.
#   row 10 image caches ($XDG_CACHE_HOME/dots/imagecache[/notifs]):
#     regenerable cache.
#   personal files (identity, credentials, machine layouts): never in scope.
#
# Semantics: copy-if-canonical-absent (a present canonical file always wins,
# even when older); --dry-run previews per-row actions without writing;
# --yes performs the copies; re-runs are idempotent; dots/* is never
# deleted, moved, or overwritten (non-destructive).
#
# Output is machine-readable, one line per row plus a summary:
#   MIGRATE-ROW domain=<domain> src=<src> dst=<dst> action=<copy|skip> reason=<reason>
#   MIGRATE-SUMMARY mode=<dry-run|migrate> copied=<N> skipped=<M>
# Actions: copy (would copy / copied), skip with reason dots-absent,
# canonical-exists, same-file (dots/* is a back-compat symlink to
# hornero/*), or excluded-<what> for the NOT list above.
set -euo pipefail

MODE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) MODE="dry-run"; shift ;;
    --yes) MODE="migrate"; shift ;;
    -h|--help) sed -n '2,42p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "error: unknown argument: $1 (want --dry-run or --yes)" >&2; exit 2 ;;
  esac
done

if [[ -z $MODE ]]; then
  echo "error: pass --dry-run to preview or --yes to migrate" >&2
  exit 2
fi

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

DOTS_DATA="$DATA_HOME/dots"
HORNERO_DATA="$DATA_HOME/hornero"
DOTS_STATE="$STATE_HOME/dots"
HORNERO_STATE="$STATE_HOME/hornero"
DOTS_CACHE="$CACHE_HOME/dots"
HORNERO_CACHE="$CACHE_HOME/hornero"

COPIED=0
SKIPPED=0

report() {
  local domain="$1" src="$2" dst="$3" action="$4" reason="$5"
  printf 'MIGRATE-ROW domain=%s src=%s dst=%s action=%s reason=%s\n' \
    "$domain" "$src" "$dst" "$action" "$reason"
  if [[ $action == "copy" ]]; then
    COPIED=$((COPIED + 1))
  else
    SKIPPED=$((SKIPPED + 1))
  fi
}

# same_file <a> <b>: 0 when both paths resolve to the same file (covers the
# materialize.sh back-compat case where dots/* is a symlink to hornero/*).
same_file() {
  local a="$1" b="$2"
  local ra rb
  ra="$(readlink -m "$a")"
  rb="$(readlink -m "$b")"
  [[ $ra == "$rb" ]]
}

# migrate_file <domain> <src> <dst>: copy-if-canonical-absent.
migrate_file() {
  local domain="$1" src="$2" dst="$3"
  if [[ ! -e $src && ! -L $src ]]; then
    report "$domain" "$src" "$dst" "skip" "dots-absent"
    return 0
  fi
  if same_file "$src" "$dst"; then
    report "$domain" "$src" "$dst" "skip" "same-file"
    return 0
  fi
  if [[ -e $dst || -L $dst ]]; then
    report "$domain" "$src" "$dst" "skip" "canonical-exists"
    return 0
  fi
  if [[ $MODE == "dry-run" ]]; then
    report "$domain" "$src" "$dst" "copy" "dry-run"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  chmod 644 "$dst"
  report "$domain" "$src" "$dst" "copy" "migrated"
}

# --- row 1: theme packs (theme.json recipes only; previews/binaries stay) ---
if [[ -d $DOTS_DATA/themes ]]; then
  shopt -s nullglob
  for src in "$DOTS_DATA"/themes/*/theme.json; do
    id="$(basename "$(dirname "$src")")"
    migrate_file "theme-pack" "$src" "$HORNERO_DATA/themes/$id/theme.json"
  done
  shopt -u nullglob
else
  report "theme-pack" "$DOTS_DATA/themes/<id>/theme.json" \
    "$HORNERO_DATA/themes/<id>/theme.json" "skip" "dots-absent"
fi

# --- row 2: shell presets catalogue ----------------------------------------
if [[ -d $DOTS_DATA/shell-presets ]]; then
  shopt -s nullglob
  for src in "$DOTS_DATA"/shell-presets/*.json; do
    base="$(basename "$src")"
    migrate_file "shell-preset" "$src" "$HORNERO_DATA/shell-presets/$base"
  done
  shopt -u nullglob
else
  report "shell-preset" "$DOTS_DATA/shell-presets/*.json" \
    "$HORNERO_DATA/shell-presets/*.json" "skip" "dots-absent"
fi

# --- row 3: active-preset pointer (shell-presets domain) --------------------
migrate_file "preset-pointer" \
  "$DOTS_STATE/current-shell-preset" "$HORNERO_STATE/current-shell-preset"

# --- row 4: scheme runtime ---------------------------------------------------
migrate_file "scheme" \
  "$DOTS_CACHE/smart-colors/scheme.json" "$HORNERO_CACHE/smart-colors/scheme.json"

# --- row 5: scheme state ------------------------------------------------------
migrate_file "scheme-state" \
  "$DOTS_STATE/scheme/state.json" "$HORNERO_STATE/scheme/state.json"

# --- row 9: wallpaper pointer --------------------------------------------------
migrate_file "wallpaper-pointer" \
  "$DOTS_STATE/wallpaper/path" "$HORNERO_STATE/wallpaper/path"

# --- row 10: notifications (notifs.json only; image caches are excluded) -----
migrate_file "notifs" \
  "$DOTS_STATE/notifs.json" "$HORNERO_STATE/notifs.json"

# --- explicit NOTs: reported as skips with reason, never touched ------------
if [[ -e $DOTS_CACHE/snapshots ]]; then
  report "snapshots" "$DOTS_CACHE/snapshots" "$HORNERO_CACHE/snapshots" \
    "skip" "excluded-snapshots-regenerable"
fi
if [[ -e $DOTS_DATA/wallpapers ]]; then
  report "wallpapers" "$DOTS_DATA/wallpapers" "$HORNERO_DATA/wallpapers" \
    "skip" "excluded-wallpapers-open-question"
fi
if [[ -e $DOTS_CACHE/imagecache ]]; then
  report "imagecache" "$DOTS_CACHE/imagecache" "$HORNERO_CACHE/imagecache" \
    "skip" "excluded-imagecache-regenerable"
fi

printf 'MIGRATE-SUMMARY mode=%s copied=%d skipped=%d\n' "$MODE" "$COPIED" "$SKIPPED"
