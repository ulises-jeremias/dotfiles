#!/usr/bin/env bash
# QML/import validation: Qt6 qmllint over the runtime tree.
# [import]/[unqualified] warnings are idiomatic here (quickshell singletons
# resolve at runtime); syntax errors and hard errors fail the check.
# Skips gracefully when qmllint is unavailable (CI installs it when apt is).
set -euo pipefail
cd "$(dirname "$0")/.."

QMLLINT=""
for cand in /usr/lib/qt6/bin/qmllint "$(command -v qmllint || true)"; do
    if [ -n "$cand" ] && [ -x "$cand" ]; then
        QMLLINT="$cand"
        break
    fi
done

if [ -z "$QMLLINT" ]; then
    echo "lint-qml: SKIP (qmllint not found)"
    exit 0
fi

# Qt5-era qmllint (reports version 1.0) cannot parse Qt6 QML; skip it.
if "$QMLLINT" --version 2>/dev/null | grep -q '^qmllint 1\.0$'; then
    echo "lint-qml: SKIP (Qt5 qmllint cannot validate Qt6 QML)"
    exit 0
fi

echo "lint-qml: using $QMLLINT"
out="$(mktemp)"
mapfile -t files < <(find shell.qml modules services config utils components -name '*.qml')
"$QMLLINT" "${files[@]}" >"$out" 2>&1 || true

fail=0
# Only qmllint diagnostic lines count (source echoes contain words like
# Toast.Error / m3onError and must not trip the check).
if grep -nE '^Error:|\[syntax\]' "$out"; then
    echo "lint-qml: FAIL (errors above)" >&2
    fail=1
fi
rm -f "$out"
if [ "$fail" -ne 0 ]; then
    exit 1
fi
echo "lint-qml: PASS (${#files[@]} files, no errors)"
