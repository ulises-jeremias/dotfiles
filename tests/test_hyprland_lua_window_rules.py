"""Keep Hyprland Lua window rules in parity with the frozen legacy values."""
from __future__ import annotations

import ast
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
STAGED = ROOT / "home/dot_config/hypr/hyprland.lua.d/window-rules.lua"

# Values frozen from the retired hyprland.conf.d/window-rules.conf (44 rules).
EXPECTED_RULES = [{'effects': {'center': True, 'float': True},
  'match': {'class': '^org[.]quickshell$', 'title': '^Hornero Settings.*$'},
  'name': 'hornero-settings-float'},
 {'effects': {'center': True, 'float': True, 'size': '40% 50%'},
  'match': {'class': '.*pavucontrol.*'},
  'name': 'pavucontrol-float'},
 {'effects': {'center': True, 'float': True, 'size': '40% 50%'},
  'match': {'class': '.*pwvucontrol.*'},
  'name': 'pwvucontrol-float'},
 {'effects': {'center': True, 'float': True, 'size': '40% 50%'},
  'match': {'class': '.*blueman.*'},
  'name': 'blueman-float'},
 {'effects': {'center': True, 'float': True, 'size': '40% 50%'},
  'match': {'class': '.*nm-connection-editor.*'},
  'name': 'nm-connection-editor-float'},
 {'effects': {'center': True, 'float': True},
  'match': {'class': '.*calculator.*'},
  'name': 'calculator-float'},
 {'effects': {'center': True, 'float': True, 'size': '35% 50%', 'stay_focused': True},
  'match': {'class': '.*copyq.*'},
  'name': 'copyq-float'},
 {'effects': {'center': True, 'float': True, 'size': '40% 50%'},
  'match': {'class': '.*auto-cpufreq.*'},
  'name': 'auto-cpufreq-float'},
 {'effects': {'center': True, 'float': True, 'size': '50% 60%'},
  'match': {'class': '.*lxappearance.*'},
  'name': 'lxappearance-float'},
 {'effects': {'center': True, 'float': True, 'size': '60% 70%'},
  'match': {'class': '.*arandr.*'},
  'name': 'arandr-float'},
 {'effects': {'center': True, 'float': True, 'size': '60% 70%'},
  'match': {'class': '.*lxqt-config.*'},
  'name': 'lxqt-config-float'},
 {'effects': {'center': True, 'float': True, 'opacity': '0.95 0.90', 'size': '75% 80%'},
  'match': {'class': '^(yazi-popup|com\\.horneroos\\.yazi-popup)$'},
  'name': 'yazi-popup'},
 {'effects': {'center': True, 'float': True},
  'match': {'title': '^File Operation Progress$'},
  'name': 'file-operation-progress'},
 {'effects': {'center': True, 'float': True},
  'match': {'title': '^Confirm to replace files$'},
  'name': 'confirm-replace-files'},
 {'effects': {'center': True, 'float': True},
  'match': {'class': '^thunar$', 'title': '^Bulk Rename$'},
  'name': 'thunar-bulk-rename'},
 {'effects': {'center': True, 'float': True}, 'match': {'class': '^btop$'}, 'name': 'btop-float'},
 {'effects': {'center': True, 'float': True}, 'match': {'class': '^htop$'}, 'name': 'htop-float'},
 {'effects': {'float': True, 'move': '72% 72%', 'pin': True, 'size': '25% 25%'},
  'match': {'title': '^Picture-in-Picture$'},
  'name': 'pip-float'},
 {'effects': {'opacity': '0.95 0.85'}, 'match': {'class': '^kitty$'}, 'name': 'kitty-opacity'},
 {'effects': {'opacity': '0.95 0.85'},
  'match': {'class': '^Alacritty$'},
  'name': 'alacritty-opacity'},
 {'effects': {'opacity': '0.95 0.85'},
  'match': {'class': '^com[.]mitchellh[.]ghostty$'},
  'name': 'ghostty-opacity'},
 {'effects': {'opacity': '0.95 0.90'}, 'match': {'class': '^thunar$'}, 'name': 'thunar-opacity'},
 {'effects': {'opacity': '0.95 0.90'},
  'match': {'class': '^nautilus$'},
  'name': 'nautilus-opacity'},
 {'effects': {'opacity': '0.95 0.90'}, 'match': {'class': '^dolphin$'}, 'name': 'dolphin-opacity'},
 {'effects': {'opacity': '0.98 0.95'}, 'match': {'class': '^Code$'}, 'name': 'code-opacity'},
 {'effects': {'opacity': '0.98 0.95'},
  'match': {'class': '^code-url-handler$'},
  'name': 'code-url-handler-opacity'},
 {'effects': {'opacity': '0.95 0.90'}, 'match': {'class': '^discord$'}, 'name': 'discord-opacity'},
 {'effects': {'opacity': '0.95 0.90'}, 'match': {'class': '^vesktop$'}, 'name': 'vesktop-opacity'},
 {'effects': {'workspace': '1 silent'},
  'match': {'class': '^firefox$'},
  'name': 'firefox-workspace'},
 {'effects': {'workspace': '1 silent'},
  'match': {'class': '^chromium$'},
  'name': 'chromium-workspace'},
 {'effects': {'workspace': '1 silent'},
  'match': {'class': '^google-chrome$'},
  'name': 'google-chrome-workspace'},
 {'effects': {'workspace': '2 silent'}, 'match': {'class': '^Code$'}, 'name': 'code-workspace'},
 {'effects': {'workspace': '3 silent'},
  'match': {'class': '^discord$'},
  'name': 'discord-workspace'},
 {'effects': {'workspace': '3 silent'},
  'match': {'class': '^vesktop$'},
  'name': 'vesktop-workspace'},
 {'effects': {'workspace': '3 silent'}, 'match': {'class': '^Slack$'}, 'name': 'slack-workspace'},
 {'effects': {'workspace': '3 silent'},
  'match': {'class': '^telegram-desktop$'},
  'name': 'telegram-workspace'},
 {'effects': {'tile': True, 'workspace': '4 silent'},
  'match': {'class': '^[Ss]potify$'},
  'name': 'spotify-workspace'},
 {'effects': {'fullscreen': True,
              'immediate': True,
              'no_blur': True,
              'workspace': 'special:games silent'},
  'match': {'class': '^steam_app.*'},
  'name': 'steam-games'},
 {'effects': {'idle_inhibit': 'always'}, 'match': {'class': '^mpv$'}, 'name': 'mpv-idle'},
 {'effects': {'idle_inhibit': 'always'}, 'match': {'class': '^vlc$'}, 'name': 'vlc-idle'},
 {'effects': {'idle_inhibit': 'focus'},
  'match': {'class': '^firefox$', 'title': '.*YouTube.*'},
  'name': 'firefox-youtube-idle'},
 {'effects': {'border_size': 0,
              'float': True,
              'move': '0 0',
              'no_anim': True,
              'no_initial_focus': True,
              'no_shadow': True,
              'pin': True,
              'stay_focused': True},
  'match': {'class': '^peek$'},
  'name': 'peek-fix'},
 {'effects': {'no_anim': True,
              'no_focus': True,
              'no_initial_focus': True,
              'opacity': '0.0 override 0.0 override'},
  'match': {'class': '^xwaylandvideobridge$'},
  'name': 'xwayland-video-bridge'},
 {'effects': {'suppress_event': 'maximize'},
  'match': {'class': '.*'},
  'name': 'suppress-maximize-all'}]


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


def _lua_rules() -> list[dict[str, object]]:
    text = STAGED.read_text(encoding="utf-8")
    blocks = re.findall(
        r"^hl\.window_rule\(\{(.*?)^\}\)", text, re.MULTILINE | re.DOTALL
    )
    rules: list[dict[str, object]] = []
    for block in blocks:
        name = re.search(
            r'^\tname\s*=\s*("(?:\\.|[^"\\])*")\s*,?$', block, re.MULTILINE
        )
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
            for key, value in re.findall(
                r"^\t([a-z_]+)\s*=\s*(.+)$", block, re.MULTILINE
            )
            if key not in {"name", "match"}
        }
        assert name is not None, f"Lua rule is missing a name: {block}"
        rules.append(
            {
                "name": ast.literal_eval(name.group(1)),
                "match": matches,
                "effects": effects,
            }
        )
    return rules


def test_lua_preserves_every_legacy_window_rule_in_order():
    staged = _lua_rules()

    assert len(EXPECTED_RULES) == 44
    assert [rule["name"] for rule in staged] == [rule["name"] for rule in EXPECTED_RULES]
    assert [rule["match"] for rule in staged] == [rule["match"] for rule in EXPECTED_RULES]
    assert [rule["effects"] for rule in staged] == [rule["effects"] for rule in EXPECTED_RULES]


def test_lua_entrypoint_loads_window_rules_and_no_legacy_config_remains():
    entrypoint = (ROOT / "home/dot_config/hypr/hyprland.lua").read_text(encoding="utf-8")
    assert 'dofile(here .. "window-rules.lua")' in entrypoint
    assert not (ROOT / "home/dot_config/hypr/hyprland.conf").exists()
    assert not (ROOT / "home/dot_config/hypr/hyprland.conf.d").exists()


if __name__ == "__main__":
    test_staged_lua_preserves_every_legacy_window_rule_in_order()
    test_staged_window_rules_do_not_activate_partial_lua_configuration()
    print("PASS: staged Lua window rules match the legacy config and stay inactive")
