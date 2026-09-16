#!/usr/bin/env bash
# Forbidden-path scan: fail on chezmoi/template markers, personal remotes,
# or non-canonical appearance calls in the shell runtime tree.
# Run: ./scripts/check_forbidden_paths.sh
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
report() { echo "forbidden-path HIT: $1" >&2; fail=1; }

CODE=(shell.qml modules services config utils components plugin extras presets nix)

# chezmoi/template markers have no business in the runtime tree (docs may
# discuss the pattern, so docs/ are out of scope here).
if grep -rn '{{' "${CODE[@]}" 2>/dev/null; then
    report "template marker '{{' in runtime tree"
fi
if grep -rni 'chezmoi' "${CODE[@]}" 2>/dev/null; then
    report "chezmoi reference in runtime tree"
fi

# Personal provenance remotes must not linger in code (docs record them).
if grep -rn 'ulises-jeremias\|HorneroConfig' "${CODE[@]}" --include='*.qml' \
    --include='*.cpp' --include='*.hpp' --include='*.nix' --include='*.json' \
    --include='*.js' 2>/dev/null; then
    report "personal provenance string in code"
fi

# Appearance must go through dots-gtk-theme / dots-m3-colors only.
if grep -rn 'gtk-theme-manager\.sh' --include='*.qml' "${CODE[@]}" 2>/dev/null; then
    report "direct gtk-theme-manager.sh call in QML"
fi
if grep -rn 'generate-m3-colors' --include='*.qml' "${CODE[@]}" 2>/dev/null; then
    report "bare generate-m3-colors call in QML"
fi

if [ "$fail" -ne 0 ]; then
    echo "forbidden-path scan: FAIL" >&2
    exit 1
fi
echo "forbidden-path scan: PASS"
