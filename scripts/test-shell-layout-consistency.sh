#!/usr/bin/env bash
# Shell layout preset and geometry contract checks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PYTHON_BIN=""
if command -v python3 > /dev/null 2>&1; then
	PYTHON_BIN="$(command -v python3)"
elif command -v python > /dev/null 2>&1; then
	PYTHON_BIN="$(command -v python)"
fi

if [[ -z $PYTHON_BIN ]]; then
	echo "  SKIP  test-shell-layout-consistency.sh (python not available)"
	exit 0
fi

PYTHONDONTWRITEBYTECODE=1 "$PYTHON_BIN" - \
	"${ROOT}/home/dot_local/lib/dots/apply-shell-preset.py" \
	"${ROOT}/home/dot_local/share/dots/shell-presets" \
	"${ROOT}/home/dot_config/quickshell/config/Config.qml" << 'PY'
import importlib.util
import json
import math
import sys
import tempfile
from pathlib import Path

merger_path = Path(sys.argv[1])
presets_dir = Path(sys.argv[2])
config_qml = Path(sys.argv[3])

spec = importlib.util.spec_from_file_location("shell_preset_merger", merger_path)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)

files = sorted(presets_dir.glob("*.json"))
assert len(files) == 11, f"expected 11 shell presets, found {len(files)}"
presets = {path.stem: json.loads(path.read_text(encoding="utf-8")) for path in files}

framed = {"hornero-left", "hornero-right"}
for name, preset in presets.items():
    module.validate_preset(preset, presets_dir / f"{name}.json")
    expected_frame = name in framed
    actual_frame = preset["border"]["frameEnabled"]
    assert actual_frame is expected_frame, f"{name}: frameEnabled must be {expected_frame}"

seed = {
    "unrelated": {"keep": True},
    "bar": {"sizes": {"innerWidth": 999}, "floatingMargin": 999},
    "appearance": {"transparency": {"enabled": True, "base": 0.1}},
}
for first_name, first in presets.items():
    first_result = module.apply_preset(seed, first, presets_dir / f"{first_name}.json")
    for second_name, second in presets.items():
        chained = module.apply_preset(first_result, second, presets_dir / f"{second_name}.json")
        direct = module.apply_preset(seed, second, presets_dir / f"{second_name}.json")
        assert chained == direct, f"preset leak: {first_name} -> {second_name}"

legacy = {
    "_name": "Legacy custom preset",
    "bar": {"entries": [{"id": "clock", "enabled": True}]},
}
legacy_result = module.apply_preset(seed, legacy, Path("legacy.json"))
assert legacy_result["bar"]["position"] == "left"
assert legacy_result["bar"]["style"] == "attached"
assert legacy_result["border"]["frameEnabled"] is True

invalid = [
    {"bar": {"floatingMargin": True}},
    {"bar": {"sizes": {"innerWidth": -1}}},
    {"appearance": {"rounding": {"scale": math.nan}}},
    {"appearance": {"padding": {"scale": math.inf}}},
]
for override in invalid:
    candidate = module.deep_merge(presets["hornero-left"], override)
    try:
        module.validate_preset(candidate, Path("invalid.json"))
    except ValueError:
        pass
    else:
        raise AssertionError(f"invalid preset accepted: {override}")

with tempfile.TemporaryDirectory() as temporary:
    directory = Path(temporary)
    config_path = directory / "shell.json"
    marker_path = directory / "current-preset"
    preset_path = directory / "preset.json"
    config_path.write_text(json.dumps(seed), encoding="utf-8")
    preset_path.write_text(json.dumps(presets["dock-bottom"]), encoding="utf-8")
    module.apply_preset_files(config_path, preset_path, marker_path, "dock-bottom")
    written = json.loads(config_path.read_text(encoding="utf-8"))
    assert written["bar"]["style"] == "dock"
    assert marker_path.read_text(encoding="utf-8") == "dock-bottom\n"

bar_config = (config_qml.parent / "BarConfig.qml").read_text(encoding="utf-8")
assert module.OWNED_DEFAULTS["bar"]["perScreen"] == []
assert "positionFor" in bar_config and "isFloatingFor" in bar_config
config_source_pos = config_qml.read_text(encoding="utf-8")
assert "perScreen: bar.perScreen" in config_source_pos
bar_wrapper = (config_qml.parent.parent / "modules/bar/BarWrapper.qml").read_text(encoding="utf-8")
exclusions = (config_qml.parent.parent / "modules/drawers/Exclusions.qml").read_text(encoding="utf-8")
assert 'return style !== "floating"' in bar_config
for field in ("reservedLeft", "reservedTop", "reservedRight", "reservedBottom"):
    assert field in bar_wrapper
    assert f"root.bar.{field}" in exclusions

# Classic reference bars expose the inline sliders; gaming owns the cava visualizer
classic_entries = presets["classic-top"]["bar"]["entries"]
for entry_id in ("audioSlider", "brightnessSlider"):
    assert any(e.get("id") == entry_id and e.get("enabled") for e in classic_entries), "classic-top missing inline sliders"
assert presets["gaming"]["background"]["visualiser"]["enabled"] is True
assert module.OWNED_DEFAULTS["background"]["visualiser"] == {"enabled": False, "autoHide": True}
assert module.OWNED_DEFAULTS["background"]["desktopClock"] == {"enabled": False}
assert presets["gaming"]["background"]["desktopClock"]["enabled"] is False

# Inline slider widget must exist and register both entry ids
bar_source = config_qml.parent.parent.joinpath("modules/bar/Bar.qml").read_text(encoding="utf-8")
for entry_id in ("audioSlider", "brightnessSlider"):
    assert f'roleValue: "{entry_id}"' in bar_source, f"Bar.qml missing DelegateChoice for {entry_id}"

config_source = config_qml.read_text(encoding="utf-8")
for field in (
    "position: bar.position",
    "style: bar.style",
    "floatingMargin: bar.floatingMargin",
    "frameEnabled: border.frameEnabled",
):
    assert field in config_source, f"Config serialization missing {field}"

print(f"PASS: {len(files)} deterministic shell presets")
PY
