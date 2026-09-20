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
if command -v python3 > /dev/null 2>&1; then
	PYTHON_BIN="$(command -v python3)"
elif command -v python > /dev/null 2>&1; then
	PYTHON_BIN="$(command -v python)"
fi

validate_theme_json() {
	local theme_json="$1"
	local expected_id="$2"
	local key

	if [[ -n $PYTHON_BIN ]]; then
		"$PYTHON_BIN" - "$theme_json" "$expected_id" << 'PY'
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

	if command -v jq > /dev/null 2>&1; then
		local id_val
		id_val="$(jq -r '.id // empty' "$theme_json")"
		[[ $id_val == "$expected_id" ]] || return 1
		for key in schemaVersion id name darkMode schemeType gtkTheme iconTheme defaultWallpaper wallpaperDir; do
			jq -e --arg k "$key" 'has($k)' "$theme_json" > /dev/null || return 1
		done
		jq -e '(.tags == null) or ((.tags | type) == "array")' "$theme_json" > /dev/null || return 1
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
		"$PYTHON_BIN" "$LIST_THEMES" "$THEMES_SRC" > /tmp/dots-themes-test.json 2> /tmp/dots-themes-test.err; then
		if "$PYTHON_BIN" - << 'PY'; then
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
		fail "list-themes.py failed: $(head -c 200 /tmp/dots-themes-test.err 2> /dev/null || true)"
	fi
else
	fail "list-themes.py missing"
fi

# No stale rice IPC / sticky current writers in QS appearance path
if grep -REn 'target:[[:space:]]*"rice"|IpcHandler.*rice|dots-rice|nwg-look' "$QS_PIPE" \
	"${ROOT}/home/dot_config/quickshell/modules/controlcenter/appearance" > /dev/null 2>&1; then
	fail "stale rice/nwg-look references in appearance QS"
else
	pass "no stale rice IPC in appearance QS"
fi

if grep -REn 'CAELESTIA_' \
	"${ROOT}/home/dot_config/quickshell/utils" \
	"${ROOT}/home/dot_config/quickshell/services" \
	"${ROOT}/home/dot_config/quickshell/modules" \
	"${ROOT}/home/dot_config/quickshell/nix" \
	"${ROOT}/home/dot_config/hypr/hyprland.conf.d/environment.conf" > /dev/null 2>&1; then
	fail "CAELESTIA_ identifiers still present in Hornero runtime/packaging"
else
	pass "no CAELESTIA_ identifiers in Hornero runtime/packaging"
fi

if command -v horneroctl > /dev/null 2>&1 \
	&& horneroctl shell restart --help > /dev/null 2>&1; then
	pass "native shell restart verb present (plugin rebuild is manual cmake)"
else
	fail "native shell restart verb missing"
fi

# Scoped exception (HorneroOS cutover): services/GtkSettings.qml carries the
# upstream native-first fallback (HorneroOS native appearance migration,
# issue #2 step a) that writes gtk-theme/icon-theme via gsettings when the
# dots-gtk-theme CLI compat path cannot run. Allowed ONLY in that file;
# raw writes anywhere else in the shell still fail this check.
if grep -REn 'gsettings set org\.gnome\.desktop\.interface (gtk-theme|icon-theme)' \
	"${ROOT}/home/dot_config/quickshell" --exclude=GtkSettings.qml > /dev/null 2>&1; then
	fail "raw gsettings GTK/icon writes in Quickshell (outside GtkSettings.qml)"
else
	pass "Quickshell does not write GTK/icons via gsettings (except GtkSettings.qml native fallback)"
fi

if grep -En 'gtk-theme-manager\.sh' "${ROOT}/home/dot_config/quickshell/services/ThemePipeline.qml" > /dev/null 2>&1; then
	fail "ThemePipeline still sources gtk-theme-manager.sh"
else
	pass "ThemePipeline uses native GTK verbs"
fi

M3_LIB="${ROOT}/home/dot_local/lib/dots/python-m3.sh"

if command -v horneroctl > /dev/null 2>&1 \
	&& horneroctl appearance colors m3 --help > /dev/null 2>&1 \
	&& [[ -f $M3_LIB ]]; then
	pass "native M3 verb + python-m3.sh present"
else
	fail "missing native M3 verb and/or python-m3.sh"
fi

if { grep -En 'dots-m3-colors|m3Bin' "$QS_PIPE" > /dev/null 2>&1 \
	|| grep -En 'horneroctl", "appearance", "colors", "m3"|horneroctl appearance colors m3' "$QS_PIPE" > /dev/null 2>&1; } \
	&& ! grep -En '["'\'']python3["'\''].*generate-m3-colors|generate-m3-colors\.py' "$QS_PIPE" > /dev/null 2>&1; then
	pass "ThemePipeline uses a pinned M3 backend (not bare python3)"
else
	fail "ThemePipeline still invokes generate-m3-colors via bare python3"
fi

if command -v horneroctl > /dev/null 2>&1 \
	&& horneroctl appearance scheme regenerate --dry-run > /dev/null 2>&1; then
	pass "native scheme regenerate resolves"
else
	fail "native scheme regenerate missing (must exist with --dry-run)"
fi

if grep -En 'normalize_gtk_color_scheme|follow \| default \| prefer-light' "$GTK_MGR" > /dev/null 2>&1 \
	&& grep -En 'write_live_gtk_color_scheme' "$GTK_MGR" > /dev/null 2>&1; then
	pass "gtk-theme-manager has gtkColorScheme policy helpers"
else
	fail "gtk-theme-manager missing gtkColorScheme policy helpers"
fi

if command -v horneroctl > /dev/null 2>&1 \
	&& horneroctl appearance gtk color-scheme prefer-light --dry-run 2>&1 | grep -q 'scheme/state.json'; then
	pass "native color-scheme persists policy (not shell mode)"
else
	fail "native color-scheme must persist policy to scheme/state.json"
fi

if command -v horneroctl > /dev/null 2>&1 \
	&& horneroctl appearance gtk color-scheme --help > /dev/null 2>&1; then
	pass "native color-scheme verb documented"
else
	fail "native color-scheme verb missing"
fi

if [ ! -e "${ROOT}/home/dot_local/bin/executable_dots-wal-reload" ] \
	&& grep -En 'sync-color-scheme' "${ROOT}/home/dot_local/lib/dots/apply-appearance.sh" > /dev/null 2>&1; then
	pass "wallpaper reload is native (wrapper retired), GTK policy preserved in lib"
else
	fail "wallpaper reload wrapper still present or GTK policy lost"
fi

if grep -En 'function setGtkColorScheme' "$QS_PIPE" > /dev/null 2>&1 \
	&& [[ -f ${ROOT}/home/dot_config/quickshell/modules/controlcenter/appearance/sections/GtkColorSchemeSection.qml ]]; then
	pass "ThemePipeline + Appearance pane expose GTK color scheme"
else
	fail "missing setGtkColorScheme IPC or GtkColorSchemeSection"
fi

if grep -En 'gtkColorScheme' "$LIST_THEMES" > /dev/null 2>&1; then
	pass "list-themes.py exposes gtkColorScheme"
else
	fail "list-themes.py missing gtkColorScheme"
fi

if grep -En 'fontFamilyClock' "${ROOT}/home/dot_config/quickshell/modules/controlcenter/appearance/sections/FontsSection.qml" > /dev/null 2>&1; then
	pass "FontsSection exposes clock font"
else
	fail "FontsSection missing clock font"
fi

# Intentional: match the literal shell source pattern containing $HOME.
# shellcheck disable=SC2016
if grep -En 'readlink -f "\$HOME/\.cache/wal/wal"|readlink -f \$HOME/\.cache/wal/wal' \
	"$GTK_MGR" "${ROOT}/home/dot_local/lib/dots/apply-appearance.sh" > /dev/null 2>&1; then
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
if ! command -v horneroctl > /dev/null 2>&1; then
	skip "horneroctl not on PATH (live checks)"
else
	if out="$(horneroctl appearance gtk current 2> /dev/null)" && [[ -n $out && $out != "Unknown" ]]; then
		pass "native gtk current: $out"
	else
		fail "native gtk current"
	fi
	if out="$(horneroctl appearance gtk current-icon 2> /dev/null)" && [[ -n $out && $out != "Unknown" ]]; then
		pass "native gtk current-icon: $out"
	else
		fail "native gtk current-icon"
	fi
	if mapfile -t themes < <(horneroctl appearance gtk list 2> /dev/null); then
		if [[ ${#themes[@]} -gt 0 ]]; then
			pass "native gtk list (${#themes[@]} themes)"
		else
			fail "native gtk list empty"
		fi
	else
		fail "native gtk list"
	fi
fi

if command -v horneroctl > /dev/null 2>&1; then
	if horneroctl appearance doctor > /tmp/horneroctl-appearance-doctor.txt 2>&1; then
		pass "native appearance doctor OK"
	else
		fail "native appearance doctor exited nonzero"
		cat /tmp/horneroctl-appearance-doctor.txt >&2 || true
	fi
else
	skip "horneroctl not on PATH"
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
