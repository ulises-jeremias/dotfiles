#!/usr/bin/env bash
# Personal-data guard: fail if emails, tokens, keys, or hardcoded home
# literals appear in tracked code. Run: ./scripts/check_personal_data.sh
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
report() { echo "personal-data HIT: $1" >&2; fail=1; }

# Email addresses (excludes generic field names like ssid which match nothing here).
if grep -rniE --exclude-dir=.git --exclude-dir=build \
    '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' \
    --include='*.qml' --include='*.js' --include='*.cpp' --include='*.hpp' \
    --include='*.nix' --include='*.json' --include='*.sh' --include='*.yaml' \
    --include='*.yml' --include='*.cmake' --include='CMakeLists.txt' .; then
    report "email-like string in code"
fi

# Tokens / secrets / private keys.
if grep -rniE --exclude-dir=.git --exclude-dir=build \
    -e 'ghp_[A-Za-z0-9]+' -e 'gho_[A-Za-z0-9]+' -e 'github_pat_[A-Za-z0-9_]+' \
    -e 'AKIA[0-9A-Z]+' -e 'BEGIN [A-Z ]*PRIVATE KEY' -e 'api[_-]?key[[:space:]]*[:=]' \
    --include='*.qml' --include='*.js' --include='*.cpp' --include='*.hpp' \
    --include='*.nix' --include='*.json' --include='*.sh' --include='*.yaml' \
    --include='*.yml' --include='*.cmake' --include='CMakeLists.txt' .; then
    report "token/secret-like string in code"
fi

# Hardcoded /home/<user> literals in code (env/$HOME forms are fine).
if grep -rn --exclude-dir=.git --exclude-dir=build \
    -e '/home/[a-zA-Z]' \
    --include='*.qml' --include='*.js' --include='*.cpp' --include='*.hpp' \
    --include='*.nix' --include='*.json' --include='*.sh' .; then
    report "hardcoded /home/ path in code"
fi

if [ "$fail" -ne 0 ]; then
    echo "personal-data guard: FAIL" >&2
    exit 1
fi
echo "personal-data guard: PASS (zero hits)"
