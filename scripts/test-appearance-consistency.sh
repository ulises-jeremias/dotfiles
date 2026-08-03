#!/usr/bin/env bash
# Appearance system consistency tests (theme packs + GTK + wal contract).
# Copyright (C) 2019-2026 Ulises Jeremias Cornejo Fandos
# Licensed under MIT.
#
# Usage:
#   ./scripts/test-appearance-consistency.sh           # live ($HOME)
#   ./scripts/test-appearance-consistency.sh --source  # validate repo tree only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_ONLY=false
[[ ${1:-} == "--source" ]] && SOURCE_ONLY=true

PASS=0
FAIL=0
SKIP=0

pass() {
  PASS=$((PASS + 1))
  printf '  PASS  %s\n' "$*"
}
fail() {
  FAIL=$((FAIL + 1))
  printf '  FAIL  %s\n' "$*" >&2
}
skip() {
  SKIP=$((SKIP + 1))
  printf '  SKIP  %s\n' "$*"
}

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python)"
fi

validate_theme_json() {
  local theme_json="$1"
  local expected_id="$2"
  local key

  if [[ -n $PYTHON_BIN ]]; then
    "$PYTHON_BIN" - "$theme_json" "$expected_id" <<'PY'
import json, sys
path, expected = sys.argv[1], sys.argv[2]
data = json.load(open(path, encoding="utf-8"))
required = ("schemaVersion", "id", "name", "darkMode", "schemeType", "gtkTheme", "iconTheme", "defaultWallpaper", "wallpaperDir")
missing = [k for k in required if k not in data]
if missing:
    raise SystemExit(f"missing keys {missing}")
if data.get("id") != expected:
    raise SystemExit(f"id mismatch: {data.get('id')!r} != {expected!r}")
if not isinstance(data.get("tags", []), list):
    raise SystemExit("tags must be a list")
PY
    return $?
  fi

  if command -v jq >/dev/null 2>&1; then
    local id_val
    id_val="$(jq -r '.id // empty' "$theme_json")"
    [[ $id_val == "$expected_id" ]] || return 1
    for key in schemaVersion id name darkMode schemeType gtkTheme iconTheme defaultWallpaper wallpaperDir; do
      jq -e --arg k "$key" 'has($k)' "$theme_json" >/dev/null || return 1
    done
    jq -e '(.tags == null) or ((.tags | type) == "array")' "$theme_json" >/dev/null || return 1
    return 0
  fi

  # Minimal grep fallback for CI images without Python/jq.
  for key in schemaVersion id name darkMode schemeType gtkTheme iconTheme defaultWallpaper wallpaperDir; do
    grep -q "\"$key\"" "$theme_json" || return 1
  done
  grep -Eq "\"id\"[[:space:]]*:[[:space:]]*\"${expected_id}\"" "$theme_json" || return 1
  return 0
}

echo "== appearance consistency =="

# ── Source tree ──────────────────────────────────────────────────────────────
THEMES_SRC="${ROOT}/home/dot_local/share/dots/themes"
LIST_THEMES="${ROOT}/home/dot_local/lib/dots/list-themes.py"
GTK_MGR="${ROOT}/home/dot_local/lib/dots/gtk-theme-manager.sh"
GTK_BIN="${ROOT}/home/dot_local/bin/executable_dots-gtk-theme"
QS_PIPE="${ROOT}/home/dot_config/quickshell/services/ThemePipeline.qml"

[[ -d $THEMES_SRC ]] || {
  echo "missing themes dir: $THEMES_SRC" >&2
  exit 1
}

theme_count=0
for theme_json in "$THEMES_SRC"/*/theme.json; do
  [[ -f $theme_json ]] || continue
  theme_count=$((theme_count + 1))
  dir="$(dirname "$theme_json")"
  id="$(basename "$dir")"
  if validate_theme_json "$theme_json" "$id"; then
    pass "theme.json valid: $id"
  else
    fail "theme.json invalid: $id"
  fi
  if [[ -f $dir/preview.jpg || -f $dir/preview.png || -f $dir/preview.webp ]]; then
    pass "preview asset: $id"
  else
    fail "missing preview for $id"
  fi
done
if [[ $theme_count -ge 1 ]]; then
  pass "found $theme_count theme packs"
else
  fail "no theme packs"
fi

if [[ -f $LIST_THEMES ]]; then
  if [[ -z $PYTHON_BIN ]]; then
    skip "list-themes.py check (python not available)"
  elif DOTS_THEMES_DIR="$THEMES_SRC" DOTS_WALLPAPERS_DIR="${ROOT}/home/dot_local/share/dots/wallpapers" \
    "$PYTHON_BIN" "$LIST_THEMES" "$THEMES_SRC" >/tmp/dots-themes-test.json 2>/tmp/dots-themes-test.err; then
    if "$PYTHON_BIN" - <<'PY'; then
import json
data = json.load(open("/tmp/dots-themes-test.json", encoding="utf-8"))
assert isinstance(data, list) and data, "empty theme list"
for t in data:
    assert "wallpaperPaths" in t, f"{t.get('id')}: missing wallpaperPaths"
    assert isinstance(t["wallpaperPaths"], dict)
    for name in t.get("wallpapers", []):
        assert name in t["wallpaperPaths"], f"{t.get('id')}: {name} missing from wallpaperPaths"
print("ok", len(data))
PY
      pass "list-themes.py JSON + wallpaperPaths"
    else
      fail "list-themes.py schema check"
    fi
  else
    fail "list-themes.py failed: $(head -c 200 /tmp/dots-themes-test.err 2>/dev/null || true)"
  fi
else
  fail "list-themes.py missing"
fi

# No stale rice IPC / sticky current writers in QS appearance path
if grep -REn 'target:[[:space:]]*"rice"|IpcHandler.*rice|dots-rice|nwg-look' "$QS_PIPE" \
  "${ROOT}/home/dot_config/quickshell/modules/controlcenter/appearance" >/dev/null 2>&1; then
  fail "stale rice/nwg-look references in appearance QS"
else
  pass "no stale rice IPC in appearance QS"
fi

if grep -REn 'gsettings set org\.gnome\.desktop\.interface (gtk-theme|icon-theme)' \
  "${ROOT}/home/dot_config/quickshell" >/dev/null 2>&1; then
  fail "raw gsettings GTK/icon writes in Quickshell"
else
  pass "Quickshell does not write GTK/icons via gsettings"
fi

if grep -En 'gtk-theme-manager\.sh' "${ROOT}/home/dot_config/quickshell/services/ThemePipeline.qml" >/dev/null 2>&1; then
  fail "ThemePipeline still sources gtk-theme-manager.sh"
else
  pass "ThemePipeline uses dots-gtk-theme CLI"
fi

# Intentional: match the literal shell source pattern containing $HOME.
# shellcheck disable=SC2016
if grep -En 'readlink -f "\$HOME/\.cache/wal/wal"|readlink -f \$HOME/\.cache/wal/wal' \
  "$GTK_MGR" "$GTK_BIN" "${ROOT}/home/dot_local/lib/dots/apply-appearance.sh" >/dev/null 2>&1; then
  fail "unsafe readlink on wal text pointer"
else
  pass "no unsafe wal readlink in GTK apply path"
fi

[[ $SOURCE_ONLY == true ]] && {
  echo
  echo "Results: $PASS pass, $FAIL fail, $SKIP skip (source-only)"
  [[ $FAIL -eq 0 ]]
  exit $?
}

# ── Live environment ─────────────────────────────────────────────────────────
if ! command -v dots-gtk-theme >/dev/null 2>&1; then
  skip "dots-gtk-theme not on PATH (live checks)"
else
  if out="$(dots-gtk-theme -q -p current 2>/dev/null)" && [[ -n $out && $out != "Unknown" ]]; then
    pass "dots-gtk-theme current: $out"
  else
    fail "dots-gtk-theme current"
  fi
  if out="$(dots-gtk-theme -q -p current-icon 2>/dev/null)" && [[ -n $out && $out != "Unknown" ]]; then
    pass "dots-gtk-theme current-icon: $out"
  else
    fail "dots-gtk-theme current-icon"
  fi
  if mapfile -t themes < <(dots-gtk-theme -q -p list 2>/dev/null); then
    if [[ ${#themes[@]} -gt 0 ]]; then
      pass "dots-gtk-theme list (${#themes[@]} themes)"
    else
      fail "dots-gtk-theme list empty"
    fi
  else
    fail "dots-gtk-theme list"
  fi
fi

if command -v dots-appearance >/dev/null 2>&1; then
  if dots appearance doctor >/tmp/dots-appearance-doctor.txt 2>&1; then
    if grep -q '^OK:' /tmp/dots-appearance-doctor.txt; then
      pass "dots appearance doctor OK"
    else
      fail "dots appearance doctor missing OK"
      cat /tmp/dots-appearance-doctor.txt >&2 || true
    fi
  else
    fail "dots appearance doctor exited nonzero"
    cat /tmp/dots-appearance-doctor.txt >&2 || true
  fi
else
  skip "dots-appearance not on PATH"
fi

wal="$HOME/.cache/wal/wal"
if [[ -L $wal ]]; then
  fail "$HOME/.cache/wal/wal is a symlink (must be text path file)"
elif [[ -f $wal ]]; then
  line="$(head -n 1 "$wal" | tr -d '\r')"
  if [[ -f $line ]]; then
    pass "wal pointer is text path -> image"
  else
    fail "wal pointer does not resolve to an image: $line"
  fi
else
  skip "wal pointer missing"
fi

echo
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[[ $FAIL -eq 0 ]]
