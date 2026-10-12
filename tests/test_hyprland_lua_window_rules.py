"""Keep staged Hyprland Lua rules in parity with the active legacy source."""
from __future__ import annotations

import ast
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LEGACY = ROOT / "home/dot_config/hypr/hyprland.conf.d/window-rules.conf"
STAGED = ROOT / "home/dot_config/hypr/hyprland.lua.d/window-rules.lua"


def _value(raw: str, *, lua: bool) -> object:
    value = raw.strip().removesuffix(",")
    if lua and value.startswith('"'):
        return ast.literal_eval(value)
    if value in {"true", "false"}:
        return value == "true"
    try:
        return int(value)
    except ValueError:
        try:
            return float(value)
        except ValueError:
            return value


def _legacy_rules() -> list[dict[str, object]]:
    text = LEGACY.read_text(encoding="utf-8")
    blocks = re.findall(r"^windowrule\s*\{(.*?)^\}", text, re.MULTILINE | re.DOTALL)
    rules: list[dict[str, object]] = []
    for block in blocks:
        name = re.search(r"^\s+name\s*=\s*(.+)$", block, re.MULTILINE)
        matches = {
            key: value.strip()
            for key, value in re.findall(
                r"^\s+match:(class|title)\s*=\s*(.+)$", block, re.MULTILINE
            )
        }
        effects = {
            key: _value(value, lua=False)
            for key, value in re.findall(
                r"^\s{4}([a-z_]+)\s*=\s*(.+)$", block, re.MULTILINE
            )
            if key not in {"name"}
        }
        assert name is not None, f"legacy rule is missing a name: {block}"
        rules.append({"name": name.group(1).strip(), "match": matches, "effects": effects})
    return rules


def _lua_rules() -> list[dict[str, object]]:
    text = STAGED.read_text(encoding="utf-8")
    blocks = re.findall(
        r"^hl\.window_rule\(\{(.*?)^\}\)", text, re.MULTILINE | re.DOTALL
    )
    rules: list[dict[str, object]] = []
    for block in blocks:
        name = re.search(r'^\tname\s*=\s*("(?:\\.|[^"\\])*")\s*,?$', block, re.MULTILINE)
        matches_block = re.search(
            r"^\tmatch\s*=\s*\{(.*?)\}\s*,?$", block, re.MULTILINE | re.DOTALL
        )
        matches: dict[str, object] = {}
        if matches_block:
            matches = {
                key: _value(value, lua=True)
                for key, value in re.findall(
                    r'\b(class|title)\s*=\s*("(?:\\.|[^"\\])*")',
                    matches_block.group(1),
                    re.MULTILINE,
                )
            }
        effects = {
            key: _value(value, lua=True)
            for key, value in re.findall(r"^\t([a-z_]+)\s*=\s*(.+)$", block, re.MULTILINE)
            if key not in {"name", "match"}
        }
        assert name is not None, f"Lua rule is missing a name: {block}"
        rules.append(
            {"name": ast.literal_eval(name.group(1)), "match": matches, "effects": effects}
        )
    return rules


def test_staged_lua_preserves_every_legacy_window_rule_in_order():
    legacy = _legacy_rules()
    staged = _lua_rules()

    assert len(legacy) == 43
    assert [rule["name"] for rule in staged] == [rule["name"] for rule in legacy]
    assert [rule["match"] for rule in staged] == [rule["match"] for rule in legacy]
    assert [rule["effects"] for rule in staged] == [rule["effects"] for rule in legacy]


def test_staged_window_rules_do_not_activate_partial_lua_configuration():
    assert not (ROOT / "home/dot_config/hypr/hyprland.lua").exists()
