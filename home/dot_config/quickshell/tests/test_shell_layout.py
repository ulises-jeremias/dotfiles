"""Layout-preset consistency: every presets/*.json must satisfy the schema
consumed by modules/layoutpicker/PresetGrid.qml and config/BarConfig.qml."""
import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
PRESETS = sorted((ROOT / "presets").glob("*.json"))

POSITIONS = {"top", "bottom", "left", "right"}
STYLES = {"attached", "floating", "dock"}


def test_preset_count():
    assert len(PRESETS) == 11, f"expected 11 presets, found {len(PRESETS)}"


@pytest.mark.parametrize("path", PRESETS, ids=lambda p: p.stem)
def test_preset_layout(path):
    data = json.loads(path.read_text())
    assert data.get("_name"), f"{path.name}: missing _name"
    bar = data.get("bar")
    assert isinstance(bar, dict), f"{path.name}: missing bar object"
    assert bar.get("position") in POSITIONS, f"{path.name}: bad bar.position"
    assert bar.get("style") in STYLES, f"{path.name}: bad bar.style"
    entries = bar.get("entries")
    assert isinstance(entries, list) and entries, f"{path.name}: empty entries"
    for entry in entries:
        assert entry.get("id"), f"{path.name}: entry without id"
        assert isinstance(entry.get("enabled"), bool), (
            f"{path.name}: entry {entry.get('id')} needs bool enabled"
        )
    sizes = bar.get("sizes", {})
    assert isinstance(sizes.get("innerWidth"), (int, float)), (
        f"{path.name}: sizes.innerWidth must be numeric"
    )
    assert isinstance(bar.get("status", {}), dict), f"{path.name}: bad status"
    scroll = bar.get("scrollActions", {})
    assert isinstance(scroll, dict), f"{path.name}: bad scrollActions"
