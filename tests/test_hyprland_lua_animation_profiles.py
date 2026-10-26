"""Keep Lua animation profiles equivalent to the frozen legacy Hyprland values."""
from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LUA = ROOT / "home/dot_config/hypr/hyprland.lua.d"
PROFILES = {
    "animations.conf": "animations.lua",
    "animations-cozy.conf": "animations-cozy.lua",
    "animations-cyberpunk.conf": "animations-cyberpunk.lua",
    "animations-minimal.conf": "animations-minimal.lua",
    "animations-nature.conf": "animations-nature.lua",
    "animations-vaporwave.conf": "animations-vaporwave.lua",
}

# Curves/animations frozen from the retired hyprland.conf.d/animations*.conf.
EXPECTED_PROFILES = {'animations-cozy.conf': {'animations': [('windows', True, 10.0, 'bounce', 'popin 75%'),
                                         ('windowsIn', True, 8.0, 'cuddle', 'popin 80%'),
                                         ('windowsOut', True, 8.0, 'gentle', 'popin 70%'),
                                         ('windowsMove', True, 10.0, 'float', 'slide'),
                                         ('border', True, 12.0, 'soft', None),
                                         ('borderangle', True, 60.0, 'float', 'loop'),
                                         ('fade', True, 8.0, 'gentle', None),
                                         ('fadeIn', True, 10.0, 'soft', None),
                                         ('fadeOut', True, 8.0, 'soft', None),
                                         ('fadeSwitch', True, 8.0, 'gentle', None),
                                         ('fadeShadow', True, 10.0, 'soft', None),
                                         ('fadeDim', True, 10.0, 'soft', None),
                                         ('workspaces', True, 12.0, 'float', 'slide'),
                                         ('specialWorkspace', True, 10.0, 'bounce', 'slidevert'),
                                         ('layers', True, 6.0, 'soft', 'slide'),
                                         ('layersIn', True, 8.0, 'gentle', 'slide'),
                                         ('layersOut', True, 6.0, 'gentle', 'fade')],
                          'curves': [('soft', (0.2, 0.8, 0.2, 1.0)),
                                     ('bounce', (0.2, 1.3, 0.3, 1.0)),
                                     ('gentle', (0.1, 0.8, 0.2, 1.0)),
                                     ('float', (0.3, 0.9, 0.4, 1.0)),
                                     ('cuddle', (0.15, 1.0, 0.25, 1.0))]},
 'animations-cyberpunk.conf': {'animations': [('windows', True, 4.0, 'cyber', 'popin 85%'),
                                              ('windowsIn', True, 3.0, 'neon', 'popin 90%'),
                                              ('windowsOut', True, 3.0, 'flash', 'popin 85%'),
                                              ('windowsMove', True, 4.0, 'glitch', 'slide'),
                                              ('border', True, 4.0, 'cyber', None),
                                              ('borderangle', True, 50.0, 'liner', 'loop'),
                                              ('fade', True, 3.0, 'flash', None),
                                              ('fadeIn', True, 2.0, 'flash', None),
                                              ('fadeOut', True, 2.0, 'flash', None),
                                              ('fadeSwitch', True, 3.0, 'cyber', None),
                                              ('fadeShadow', True, 4.0, 'cyber', None),
                                              ('fadeDim', True, 3.0, 'cyber', None),
                                              ('workspaces', True, 4.0, 'glitch', 'slide'),
                                              ('specialWorkspace', True, 4.0, 'neon', 'slidevert'),
                                              ('layers', True, 2.0, 'flash', 'fade'),
                                              ('layersIn', True, 2.0, 'flash', 'fade'),
                                              ('layersOut', True, 2.0, 'flash', 'fade')],
                               'curves': [('glitch', (0.7, 0.0, 0.3, 1.0)),
                                          ('neon', (0.2, 1.2, 0.3, 1.0)),
                                          ('cyber', (0.85, 0.0, 0.15, 1.0)),
                                          ('flash', (0.9, 0.0, 0.1, 1.0)),
                                          ('liner', (1.0, 1.0, 1.0, 1.0))]},
 'animations-minimal.conf': {'animations': [('windows', True, 2.0, 'snap', 'slide'),
                                            ('windowsIn', True, 2.0, 'linear', 'slide'),
                                            ('windowsOut', True, 1.0, 'linear', 'slide'),
                                            ('windowsMove', True, 2.0, 'direct', 'slide'),
                                            ('border', True, 2.0, 'linear', None),
                                            ('borderangle', False, 1.0, 'linear', None),
                                            ('fade', True, 2.0, 'linear', None),
                                            ('fadeIn', True, 1.0, 'linear', None),
                                            ('fadeOut', True, 1.0, 'linear', None),
                                            ('fadeSwitch', True, 2.0, 'linear', None),
                                            ('fadeShadow', True, 2.0, 'linear', None),
                                            ('fadeDim', True, 2.0, 'linear', None),
                                            ('workspaces', True, 2.0, 'snap', 'slide'),
                                            ('specialWorkspace', True, 2.0, 'snap', 'slidevert'),
                                            ('layers', True, 1.0, 'linear', 'fade'),
                                            ('layersIn', True, 1.0, 'linear', 'fade'),
                                            ('layersOut', True, 1.0, 'linear', 'fade')],
                             'curves': [('linear', (0.0, 0.0, 1.0, 1.0)),
                                        ('snap', (0.5, 0.0, 0.5, 1.0)),
                                        ('direct', (0.4, 0.0, 0.6, 1.0))]},
 'animations-nature.conf': {'animations': [('windows', True, 7.0, 'branch', 'popin 80%'),
                                           ('windowsIn', True, 6.0, 'breeze', 'popin 85%'),
                                           ('windowsOut', True, 5.0, 'settle', 'popin 75%'),
                                           ('windowsMove', True, 8.0, 'leaf', 'slide'),
                                           ('border', True, 10.0, 'settle', None),
                                           ('fade', True, 5.0, 'settle', None),
                                           ('fadeIn', True, 4.0, 'breeze', None),
                                           ('fadeOut', True, 4.0, 'leaf', None),
                                           ('fadeSwitch', True, 5.0, 'root', None),
                                           ('fadeShadow', True, 6.0, 'settle', None),
                                           ('fadeDim', True, 5.0, 'leaf', None),
                                           ('workspaces', True, 8.0, 'breeze', 'slide'),
                                           ('specialWorkspace', True, 7.0, 'root', 'slidevert'),
                                           ('layers', True, 5.0, 'breeze', 'fade'),
                                           ('layersIn', True, 4.0, 'breeze', 'fade'),
                                           ('layersOut', True, 4.0, 'settle', 'fade')],
                            'curves': [('leaf', (0.25, 0.46, 0.45, 0.94)),
                                       ('breeze', (0.16, 1.0, 0.3, 1.0)),
                                       ('root', (0.22, 1.0, 0.36, 1.0)),
                                       ('branch', (0.34, 1.56, 0.64, 1.0)),
                                       ('settle', (0.08, 0.82, 0.3, 1.0))]},
 'animations-vaporwave.conf': {'animations': [('windows', True, 8.0, 'dream', 'popin 80%'),
                                              ('windowsIn', True, 8.0, 'retro', 'popin 85%'),
                                              ('windowsOut', True, 6.0, 'sunset', 'popin 75%'),
                                              ('windowsMove', True, 8.0, 'retro', 'slide'),
                                              ('border', True, 10.0, 'retro', None),
                                              ('borderangle', True, 80.0, 'liner', 'loop'),
                                              ('fade', True, 8.0, 'vhs', None),
                                              ('fadeIn', True, 10.0, 'retro', None),
                                              ('fadeOut', True, 8.0, 'sunset', None),
                                              ('fadeSwitch', True, 8.0, 'retro', None),
                                              ('fadeShadow', True, 10.0, 'retro', None),
                                              ('fadeDim', True, 8.0, 'sunset', None),
                                              ('workspaces', True, 10.0, 'retro', 'slide'),
                                              ('specialWorkspace', True, 8.0, 'dream', 'slidevert'),
                                              ('layers', True, 6.0, 'retro', 'slide'),
                                              ('layersIn', True, 8.0, 'dream', 'slide'),
                                              ('layersOut', True, 6.0, 'sunset', 'fade')],
                               'curves': [('retro', (0.3, 0.8, 0.2, 1.0)),
                                          ('dream', (0.2, 1.1, 0.3, 1.0)),
                                          ('sunset', (0.4, 0.0, 0.2, 1.0)),
                                          ('vhs', (0.6, 0.0, 0.4, 1.0)),
                                          ('liner', (1.0, 1.0, 1.0, 1.0))]},
 'animations.conf': {'animations': [('windows', True, 6.0, 'wind', 'slide'),
                                    ('windowsIn', True, 6.0, 'winIn', 'slide'),
                                    ('windowsOut', True, 6.0, 'winOut', 'slide'),
                                    ('windowsMove', True, 6.0, 'wind', 'slide'),
                                    ('border', True, 6.0, 'easeInOut', None),
                                    ('borderangle', True, 30.0, 'liner', 'loop'),
                                    ('fade', True, 6.0, 'easeInOut', None),
                                    ('fadeIn', True, 6.0, 'easeOut', None),
                                    ('fadeOut', True, 6.0, 'easeOut', None),
                                    ('fadeSwitch', True, 6.0, 'easeInOut', None),
                                    ('fadeShadow', True, 6.0, 'easeInOut', None),
                                    ('fadeDim', True, 6.0, 'easeInOut', None),
                                    ('workspaces', True, 6.0, 'wind', 'slidevert'),
                                    ('specialWorkspace', True, 6.0, 'wind', 'slidevert'),
                                    ('windowsMove', True, 6.0, 'wind', 'slide'),
                                    ('layers', True, 4.0, 'easeOut', 'slide'),
                                    ('layersIn', True, 4.0, 'easeOut', 'slide'),
                                    ('layersOut', True, 4.0, 'easeOut', 'slide')],
                     'curves': [('wind', (0.05, 0.9, 0.1, 1.05)),
                                ('winIn', (0.1, 1.1, 0.1, 1.0)),
                                ('winOut', (0.3, -0.3, 0.0, 1.0)),
                                ('liner', (1.0, 1.0, 1.0, 1.0)),
                                ('linear', (0.0, 0.0, 1.0, 1.0)),
                                ('easeInOut', (0.42, 0.0, 0.58, 1.0)),
                                ('easeOut', (0.0, 0.0, 0.58, 1.0)),
                                ('focusPulse', (0.4, 0.0, 0.2, 1.0))]}}


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
                r'^\s*(leaf|enabled|speed|bezier|style)\s*=\s*(.+?),?$',
                block,
                re.MULTILINE,
            )
        )
        animations.append(
            (
                values["leaf"].strip('"'),
                values["enabled"] == "true",
                float(values["speed"]),
                values["bezier"].strip('"'),
                values.get("style", "").strip('"') or None,
            )
        )
    return curves, animations


def test_all_lua_animation_profiles_preserve_legacy_curves_and_animation_values():
    for legacy_name, lua_name in PROFILES.items():
        expected = EXPECTED_PROFILES[legacy_name]
        expected_curves = [tuple([name, tuple(points)]) for name, points in expected["curves"]]
        expected_animations = [tuple(a) for a in expected["animations"]]
        actual_curves, actual_animations = _lua_profile(LUA / lua_name)

        assert actual_curves == expected_curves, legacy_name
        assert [tuple(a) for a in actual_animations] == expected_animations, legacy_name
        assert {curve for _, _, _, curve, _ in actual_animations} <= {
            name for name, _ in actual_curves
        }, legacy_name


def test_lua_entrypoint_loads_animations_and_no_legacy_config_remains():
    entrypoint = (ROOT / "home/dot_config/hypr/hyprland.lua").read_text(encoding="utf-8")
    assert 'dofile(here .. "animations.lua")' in entrypoint
    assert not (ROOT / "home/dot_config/hypr/hyprland.conf").exists()
    assert not (ROOT / "home/dot_config/hypr/hyprland.conf.d").exists()
