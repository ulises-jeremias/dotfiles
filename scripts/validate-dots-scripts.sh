#!/usr/bin/env bash

# Script to validate dots utilities follow conventions
# Copyright (C) 2024 Ulises Jeremias Cornejo Fandos
# Licensed under MIT

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOTS_BIN_DIR="${DOTFILES_ROOT}/home/dot_local/bin"
ENTRYPOINT_SCRIPTS=(
  "${DOTFILES_ROOT}/home/dot_local/bin/executable_dots"
  "${DOTFILES_ROOT}/home/dot_config/waybar/executable_launch.sh"
  "${DOTFILES_ROOT}/home/dot_config/eww/executable_eww-manager.sh"
)

# Scripts to exclude from validation (third-party or special cases)
EXCLUDED_SCRIPTS=(
  "executable_dots-checkupdates"       # Third-party script from pacman-contrib
  "executable_dots-git-notify"         # Third-party script with custom argument parsing
)

errors=0

echo "🔍 Validating dots scripts..."

# Check if script should be excluded
is_excluded() {
  local script_name="$1"
  for excluded in "${EXCLUDED_SCRIPTS[@]}"; do
    if [[ $script_name == "$excluded" ]]; then
      return 0
    fi
  done
  return 1
}

# Check if all scripts have proper headers
for script in "${DOTS_BIN_DIR}"/executable_dots-*; do
  if [[ -f $script ]]; then
    script_name=$(basename "$script")

    # Skip excluded scripts
    if is_excluded "$script_name"; then
      continue
    fi

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

    # Check for set -euo pipefail (required for robustness)
    if ! grep -q "^set -euo pipefail" "$script"; then
      echo "❌ Missing 'set -euo pipefail': $script_name"
      ((errors++))
    fi

    # Check for easyoptions usage (warning only, not error for simple scripts)
    # Skip check for scripts that don't need argument parsing
    if ! grep -q "easyoptions.sh" "$script"; then
      # Check if script has any argument parsing (getopt, case statements with $1, etc.)
      if grep -qE "(getopt|case.*\$1|parse_cmd_args|usage\(\))" "$script"; then
        echo "⚠️  Script has argument parsing but doesn't use easyoptions: $script_name"
      fi
    fi

    # Note: Script executability is handled by chezmoi when applied
    # No need to check executable bit in source directory
  fi
done

# Validate critical entrypoint scripts (strict mode + EasyOptions)
for script in "${ENTRYPOINT_SCRIPTS[@]}"; do
  if [[ ! -f $script ]]; then
    echo "❌ Missing critical entrypoint script: $script"
    ((errors++))
    continue
  fi

  script_name=$(basename "$script")

  if ! grep -q "^set -euo pipefail" "$script"; then
    echo "❌ Missing 'set -euo pipefail' in entrypoint: $script_name"
    ((errors++))
  fi

  if ! grep -q "easyoptions.sh" "$script"; then
    echo "❌ Missing EasyOptions usage in entrypoint: $script_name"
    ((errors++))
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
