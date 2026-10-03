#!/usr/bin/env bash
# Smoke-test the installed Hornero layout catalogue through its public CLI.
# Preset data and validation belong to HorneroOS/config, shell and horneroctl;
# this personal dotfiles repository intentionally carries no second catalogue.

set -euo pipefail

if ! command -v horneroctl >/dev/null 2>&1; then
	echo "  SKIP  test-shell-layout-consistency.sh (horneroctl is not installed)"
	exit 0
fi

output="$(horneroctl shell preset list --full --json)"
python3 -c '
import json
import sys

try:
    response = json.loads(sys.stdin.read())
    if not response.get("ok"):
        raise ValueError(response.get("error") or "horneroctl returned an error")
    presets = json.loads(response["message"])
except (KeyError, TypeError, json.JSONDecodeError, ValueError) as error:
    raise SystemExit(f"invalid horneroctl preset response: {error}")

if not isinstance(presets, list) or not presets:
    raise SystemExit("Hornero returned an empty layout catalogue")

names = [preset.get("name") for preset in presets]
if any(not isinstance(name, str) or not name for name in names):
    raise SystemExit("Hornero returned a layout without a valid name")
if len(names) != len(set(names)):
    raise SystemExit("Hornero returned duplicate layout names")
if any(not isinstance(preset.get("bars"), list) for preset in presets):
    raise SystemExit("Hornero returned a layout without resolved bar topology")

print(f"  PASS  Hornero layout catalogue ({len(presets)} layouts, unique IDs, resolved topology)")
' <<<"$output"
