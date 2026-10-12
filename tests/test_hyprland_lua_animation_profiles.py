"""Keep staged Lua animation profiles equivalent to legacy Hyprland values."""
from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "home/dot_config/hypr/hyprland.conf.d"
LUA = ROOT / "home/dot_config/hypr/hyprland.lua.d"
PROFILES = {
    "animations.conf": "animations.lua",
    "animations-cozy.conf": "animations-cozy.lua",
    "animations-cyberpunk.conf": "animations-cyberpunk.lua",
    "animations-minimal.conf": "animations-minimal.lua",
    "animations-nature.conf": "animations-nature.lua",
    "animations-vaporwave.conf": "animations-vaporwave.lua",
}


def _legacy_profile(
    path: Path,
) -> tuple[list[tuple[str, tuple[float, ...]]], list[tuple]]:
    curves: list[tuple[str, tuple[float, ...]]] = []
    animations: list[tuple] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if line.startswith("bezier = "):
            name, *points = (
                field.strip()
                for field in line.removeprefix("bezier = ").split(",")
            )
            assert len(points) == 4
            curves.append((name, tuple(float(point) for point in points)))
        elif line.startswith("animation = "):
            fields = [
                field.strip()
                for field in line.removeprefix("animation = ").split(",", 4)
            ]
            assert len(fields) in (4, 5)
            leaf, enabled, speed, curve, *style = fields
            animations.append(
                (leaf, enabled == "1", float(speed), curve, style[0] if style else None)
            )
    return curves, animations


def _lua_profile(path: Path) -> tuple[list[tuple[str, tuple[float, ...]]], list[tuple]]:
    text = path.read_text(encoding="utf-8")
    curves = [
        (name, tuple(float(point) for point in (x1, y1, x2, y2)))
        for name, x1, y1, x2, y2 in re.findall(
            r'hl\.curve\("([^"]+)",\s*\{\s*type\s*=\s*"bezier",\s*'
            r'points\s*=\s*\{\s*\{\s*([^,]+),\s*([^}]+)\},\s*'
            r'\{\s*([^,]+),\s*([^}]+)\}\s*\},\s*\}\)',
            text,
            re.DOTALL,
        )
    ]
    animations: list[tuple] = []
    blocks = re.findall(r"hl\.animation\(\{(.*?)\n\}\)", text, re.DOTALL)
    for block in blocks:
        values = dict(
            re.findall(
                r'^\s*(leaf|enabled|speed|curve|style)\s*=\s*(.+?),?$',
                block,
                re.MULTILINE,
            )
        )
        animations.append(
            (
                values["leaf"].strip('"'),
                values["enabled"] == "true",
                float(values["speed"]),
                values["curve"].strip('"'),
                values.get("style", "").strip('"') or None,
            )
        )
    return curves, animations


def test_all_lua_animation_profiles_preserve_legacy_curves_and_animation_values():
    for legacy_name, lua_name in PROFILES.items():
        expected_curves, expected_animations = _legacy_profile(CONFIG / legacy_name)
        actual_curves, actual_animations = _lua_profile(LUA / lua_name)

        assert actual_curves == expected_curves, legacy_name
        assert actual_animations == expected_animations, legacy_name
        assert {curve for _, _, _, curve, _ in actual_animations} <= {
            name for name, _ in actual_curves
        }, legacy_name


def test_staged_animation_profiles_do_not_activate_partial_lua_configuration():
    assert not (ROOT / "home/dot_config/hypr/hyprland.lua").exists()
