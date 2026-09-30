#!/usr/bin/env bash
# Hornero shell source-of-truth contract check (HorneroOS/hornero#81, option C).
# Copyright (C) 2019-2026 Ulises Jeremias Cornejo Fandos
# Licensed under MIT.
#
# HorneroOS/shell is the authoritative product implementation; the installed
# ~/.config/quickshell tree is the runtime; this repo keeps personal
# overrides only (none today). This gate fails when:
#   1. a quickshell implementation mirror reappears under home/dot_config/,
#   2. the .chezmoiignore guard that keeps chezmoi out of the installed
#      tree is missing or narrowed.
#
# Usage:
#   ./scripts/check-shell-contract.sh   # exit 1 on contract violation
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail=0

# 1. No implementation mirror may live in the source tree. A marker file
# would be fine; any .qml/.v/CMakeLists.txt means the mirror is back.
if [[ -d home/dot_config/quickshell ]]; then
	mirror_files="$(find home/dot_config/quickshell -type f \
		\( -name '*.qml' -o -name '*.v' -o -name 'CMakeLists.txt' \) | head -n 5)"
	if [[ -n $mirror_files ]]; then
		echo "FAIL: quickshell implementation mirror present in dotfiles source:" >&2
		echo "$mirror_files" >&2
		fail=1
	else
		echo "PASS: home/dot_config/quickshell holds no implementation files"
	fi
else
	echo "PASS: no home/dot_config/quickshell mirror in source"
fi

# 2. The ignore guard must cover the whole installed tree.
if grep -Eq '^[[:space:]]*\.config/quickshell/\*\*$' home/.chezmoiignore.tmpl; then
	echo "PASS: .chezmoiignore covers .config/quickshell/**"
else
	echo "FAIL: home/.chezmoiignore.tmpl lacks the '.config/quickshell/**' guard" >&2
	fail=1
fi

exit "$fail"
