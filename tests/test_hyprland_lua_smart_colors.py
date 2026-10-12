"""Keep the staged Lua Smart Colors module safe and aligned with Hornero."""
from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LUA = ROOT / "home/dot_config/hypr/hyprland.lua.d/smart-colors.lua"
LEGACY = ROOT / "home/dot_config/hypr/hyprland.conf.d/colors.conf"


def test_factory_colors_match_hornero_dark_legacy_defaults():
    legacy = LEGACY.read_text(encoding="utf-8")
    lua = LUA.read_text(encoding="utf-8")
    expected = {
        "active_border": ("e07856ee", "f2b749ee"),
        "inactive_border": ("6b4e3baa",),
        "border_active": ("e07856ee",),
        "border_inactive": ("6b4e3baa",),
        "border_locked_active": ("f2b749ee",),
        "border_locked_inactive": ("3c2c21aa",),
        "active =": ("e07856ee",),
        "inactive =": ("2b1f18ee",),
        "locked_active =": ("f2b749ee",),
        "locked_inactive =": ("3c2c21ee",),
    }
    for key, colors in expected.items():
        for color in colors:
            assert f"rgba({color})" in legacy, key
            assert f"rgba({color})" in lua, key


def test_generated_module_is_optional_and_uses_hornero_cache_contract():
    text = LUA.read_text(encoding="utf-8")
    assert 'os.getenv("HORNERO_SMART_COLORS_DIR")' in text
    assert 'os.getenv("XDG_CACHE_HOME")' in text
    assert '"/hornero/smart-colors"' in text
    assert 'pcall(require, cache .. "/colors-hyprland")' in text


def test_smart_colors_module_remains_staged_until_full_lua_entrypoint():
    assert not (ROOT / "home/dot_config/hypr/hyprland.lua").exists()


def test_factory_palette_keeps_all_expected_rgba_values():
    text = LUA.read_text(encoding="utf-8")
    values = re.findall(r'"rgba\(([0-9a-f]{8})\)"', text)
    assert len(values) >= 10
    assert all(len(value) == 8 for value in values)
