#!/usr/bin/env bash

# Script to validate dots utilities follow conventions
# Copyright (C) 2024 Ulises Jeremias Cornejo Fandos
# Licensed under MIT

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOTS_BIN_DIR="${DOTFILES_ROOT}/home/dot_local/bin"

errors=0

echo "🔍 Validating dots scripts..."

# Check if all scripts have proper headers
for script in "${DOTS_BIN_DIR}"/executable_dots-*; do
  if [[ -f $script ]]; then
    script_name=$(basename "$script")

    # Check for copyright header
    if ! head -n 10 "$script" | grep -q "Copyright"; then
      echo "❌ Missing copyright header: $script_name"
      ((errors++))
    fi

    # Check for license header
    if ! head -n 15 "$script" | grep -q -E "(Licensed under MIT|GNU General Public License)"; then
      echo "❌ Missing license header: $script_name"
      ((errors++))
    fi

    # Check for easyoptions usage (warning only, not error)
    if ! grep -q "easyoptions.sh" "$script"; then
      echo "⚠️  Script doesn't use easyoptions: $script_name"
    fi

    # Note: Script executability is handled by chezmoi when applied
    # No need to check executable bit in source directory
  fi
done

# Validate dots-scripts.sh is up to date
scripts_in_dir=$(find "${DOTS_BIN_DIR}" -name "executable_dots-*" -printf "%f\n" | sed 's/executable_dots-//' | sort)
scripts_in_list=$(grep -o '[a-zA-Z0-9-]*:' "${DOTFILES_ROOT}/home/dot_local/lib/dots/dots-scripts.sh" | sed 's/://' | sort)

if ! diff -q <(echo "$scripts_in_dir") <(echo "$scripts_in_list") >/dev/null; then
  echo "❌ dots-scripts.sh is out of sync with actual scripts"
  echo "Scripts in directory but not in list:"
  comm -23 <(echo "$scripts_in_dir") <(echo "$scripts_in_list")
  echo "Scripts in list but not in directory:"
  comm -13 <(echo "$scripts_in_dir") <(echo "$scripts_in_list")
  ((errors++))
fi

if [[ $errors -eq 0 ]]; then
  echo "✅ All dots scripts validation passed!"
  exit 0
else
  echo "❌ Found $errors validation errors"
  exit 1
fi
