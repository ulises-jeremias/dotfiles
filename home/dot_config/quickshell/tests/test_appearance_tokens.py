"""P2 appearance tokens: hornero-dark + hornero-light are first-class
coherent themes with correct switching (no light/dark leakage).

Covers the canonical semantic token tables in services/Colours.qml, their
native apply path in services/ThemePipeline.qml, the factory default theme
key (config/AppearanceConfig.qml + Config.qml + config/shell.default.json),
the always-listed built-ins in the theme registry, and the audited
contrast/hover/focus/disabled/selection states of the shared controls.
"""
import json
import re
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
COLOURS = ROOT / "services" / "Colours.qml"
PIPELINE = ROOT / "services" / "ThemePipeline.qml"
APPEARANCE_CONFIG = ROOT / "config" / "AppearanceConfig.qml"
CONFIG_QML = ROOT / "config" / "Config.qml"
FACTORY = ROOT / "config" / "shell.default.json"
THEMES = ROOT / "modules" / "launcher" / "services" / "Themes.qml"

BUILT_INS = ("hornero-dark", "hornero-light")

# (foreground token, background token, minimum WCAG contrast)
TEXT_PAIRS = [
    ("onPrimary", "primary", 4.5),
    ("onSecondary", "secondary", 4.5),
    ("onTertiary", "tertiary", 4.5),
    ("onError", "error", 4.5),
    ("onSuccess", "success", 4.5),
    ("onPrimaryContainer", "primaryContainer", 4.5),
    ("onSecondaryContainer", "secondaryContainer", 4.5),
    ("onTertiaryContainer", "tertiaryContainer", 4.5),
    ("onErrorContainer", "errorContainer", 4.5),
    ("onSuccessContainer", "successContainer", 4.5),
    ("onBackground", "background", 4.5),
    ("onSurface", "surface", 4.5),
    ("onSurfaceVariant", "surfaceVariant", 4.5),
    ("inverseOnSurface", "inverseSurface", 4.5),
    ("outline", "background", 3.0),
]


def _table_region(text, name):
    start = text.index(f"readonly property var {name}")
    region = text[start:]
    entries = {}
    for line in region.splitlines()[1:]:
        if line.strip() == "})":
            break
        m = re.match(r'\s*"([^"]+)":\s*"(#[0-9a-fA-F]{6})"\s*,?\s*$', line)
        if m:
            entries[m.group(1)] = m.group(2)
    assert entries, f"{name} token table parsed empty"
    return entries


def _tables():
    text = COLOURS.read_text()
    return (_table_region(text, "_horneroDark"),
            _table_region(text, "_horneroLight"))


def _rel_luminance(hex_color):
    h = hex_color.lstrip("#")
    rgb = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    lin = [c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
           for c in rgb]
    return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2]


def _contrast(a, b):
    hi, lo = sorted([_rel_luminance(a), _rel_luminance(b)], reverse=True)
    return (hi + 0.05) / (lo + 0.05)


def test_builtin_tables_cover_same_tokens():
    dark, light = _tables()
    assert set(dark) == set(light), (
        f"token key mismatch: dark-only={sorted(set(dark) - set(light))} "
        f"light-only={sorted(set(light) - set(dark))}"
    )
    assert len(dark) >= 60, f"expected full M3 + term set, got {len(dark)} keys"


def test_dark_table_matches_palette_defaults():
    # No leakage at first run: the compiled M3Palette defaults must equal the
    # canonical hornero-dark table exactly.
    text = COLOURS.read_text()
    defaults = dict(re.findall(
        r'property color (m3\w+|term\d+):\s*"(#[0-9a-fA-F]{6})"', text))
    dark, _ = _tables()
    for name, colour in dark.items():
        prop = name if name.startswith("term") else f"m3{name}"
        assert prop in defaults, f"{prop} missing from M3Palette defaults"
        assert defaults[prop].lower() == colour.lower(), (
            f"{prop}: default {defaults[prop]} != hornero-dark {colour}")
    assert len(defaults) == len(dark), (
        f"M3Palette has {len(defaults)} defaults but table has {len(dark)}")


def test_mode_coherence_no_leakage():
    dark, light = _tables()
    assert _rel_luminance(dark["background"]) < 0.05, "dark bg must be dark"
    assert _rel_luminance(light["background"]) > 0.5, "light bg must be light"
    assert _rel_luminance(dark["surface"]) < 0.05, "dark surface must be dark"
    assert _rel_luminance(light["surface"]) > 0.5, "light surface must be light"
    for key in ("surfaceContainerLowest", "surfaceContainerLow",
                "surfaceContainer", "surfaceContainerHigh",
                "surfaceContainerHighest"):
        assert _rel_luminance(dark[key]) < _rel_luminance(light[key]), (
            f"{key}: dark {dark[key]} not darker than light {light[key]}")
    # Fixed colours are mode-independent per M3.
    for key in [k for k in dark if "Fixed" in k]:
        assert dark[key].lower() == light[key].lower(), (
            f"{key} must be mode-independent, dark={dark[key]} light={light[key]}")


def test_text_contrast_against_token_model():
    dark, light = _tables()
    for table, label in ((dark, "hornero-dark"), (light, "hornero-light")):
        for fg, bg, minimum in TEXT_PAIRS:
            ratio = _contrast(table[fg], table[bg])
            assert ratio >= minimum, (
                f"{label} {fg}/{bg}: {ratio:.2f} < {minimum} "
                f"({table[fg]} on {table[bg]})")


def test_colours_apply_path_sets_mode_and_theme():
    text = COLOURS.read_text()
    assert 'property string themeId: "hornero-dark"' in text
    assert "function isBuiltInTheme(id: string): bool" in text
    assert "function applyBuiltInTheme(id: string): void" in text
    for theme in BUILT_INS:
        assert f'"{theme}"' in text
    body = text[text.index("function applyBuiltInTheme"):text.index(
        "function applyBuiltInTheme") + 1200]
    assert "currentLight" in body, "apply must drive currentLight (no leakage)"
    assert "showPreview = false" in body, "built-in must clear previews"
    assert "themeId = id" in body, "apply must track the active theme id"
    assert "scheme = id" in body, "apply must label the scheme"
    load = text[text.index("function load("):text.index(
        "function load(") + 1200]
    assert "isBuiltInTheme" in load, "disk load must track built-in theme ids"


def test_pipeline_applies_builtins_natively():
    text = PIPELINE.read_text()
    assert "function _applyBuiltInTheme(id: string, wallpaper: string)" in text
    pump = text[text.index("function _pump()"):]
    intercept = pump.index("isBuiltInTheme")
    assert intercept < pump.index("themeLoader.themeId = job.themeId"), (
        "built-ins must short-circuit before the theme.json loader")
    native = text[text.index("function _applyBuiltInTheme"):]
    native = native[:native.index("function _finishJob")]
    assert "Colours.applyBuiltInTheme(id)" in native
    assert 'GtkSettings.applyFull("", "", "", ' in native, (
        "built-ins must stay off the dots-owned registry path (empty themeId)")
    assert '"dots-' not in native and "'dots-" not in native, (
        "built-in apply must not shell out to dots-* CLIs")
    for proc in ("walProc", "walPrepProc", "m3Proc", "themeLoader.running"):
        assert proc not in native, f"built-in apply must not use {proc}"
    assert "snappyProc" not in native, (
        "dots-owned switcher extras are skipped for built-ins")


def test_factory_theme_key_end_to_end():
    assert 'property string theme: "hornero-dark"' in APPEARANCE_CONFIG.read_text()
    assert "theme: appearance.theme" in CONFIG_QML.read_text(), (
        "serializeAppearance must persist the theme key")
    factory = json.loads(FACTORY.read_text())
    assert factory["appearance"]["theme"] == "hornero-dark"


def test_registry_lists_builtins_first():
    text = THEMES.read_text()
    assert "function _withBuiltIns(items: var)" in text
    dark_at = text.index('"hornero-dark"')
    light_at = text.index('"hornero-light"')
    assert dark_at < light_at, "hornero-dark must lead the built-in pair"
    assert '"darkMode": true' in text and '"darkMode": false' in text
    assert "themes.model = root._withBuiltIns(parsed)" in text, (
        "CLI results must merge over built-ins, never replace them")
    assert "themes.model = root._withBuiltIns([])" in text, (
        "built-ins must survive an empty/failed registry")


def _control(name):
    return (ROOT / "components" / "controls" / name).read_text()


def test_text_selection_states_use_tokens():
    text = _control("StyledTextField.qml")
    assert "selectionColor: Colours.palette.m3primary" in text
    assert "selectedTextColor: Colours.palette.m3onPrimary" in text
    assert "Qt.alpha(Colours.palette.m3onSurface, 0.38)" in text, (
        "disabled text must use the 38% on-surface token")


def test_search_focus_and_disabled_states():
    text = _control("SearchBar.qml")
    assert "root.activeFocus ? Colours.palette.m3primary" in text, (
        "search needs a primary focus ring")
    assert "opacity: root.enabled ? 1 : 0.5" in text


def test_disabled_states_use_token_dimming():
    for name in ("StyledSwitch.qml", "StyledSlider.qml",
                 "StyledRadioButton.qml", "FilledSlider.qml"):
        assert "root.enabled ? 1 : 0.5" in _control(name), (
            f"{name} must dim when disabled")
    for name in ("ButtonBase.qml", "TextButton.qml", "ToggleButton.qml"):
        text = _control(name)
        assert "property bool disabled" in text, f"{name} needs a disabled prop"
        assert "disabled: root.disabled" in text, (
            f"{name} must wire disabled into its StateLayer (no hover when off)")
        assert "opacity: root.disabled ? 0.5 : 1" in text


def test_state_colours_stay_on_tokens():
    # Hover/focus/disabled/selection colours must resolve through the token
    # model so both built-ins stay coherent; no literal hex in controls.
    offenders = []
    for path in (ROOT / "components" / "controls").glob("*.qml"):
        for i, line in enumerate(path.read_text().splitlines(), 1):
            if re.search(r"#[0-9a-fA-F]{3,8}", line):
                offenders.append(f"{path.name}:{i}:{line.strip()}")
    assert not offenders, f"literal colours in controls: {offenders}"


def test_gen_stability():
    # Flagship tables are generated from the config brand seeds
    # (scripts/gen-flagship-m3.py); committed tables must match, or the
    # cross-repo hue contract has drifted.
    import subprocess
    proc = subprocess.run(
        [sys.executable, str(ROOT / "scripts" / "gen-flagship-m3.py"),
         "--check"],
        capture_output=True, text=True, check=False)
    if "SKIP:" in proc.stdout:
        pytest.skip("materialyoucolor not installed")
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "OK:" in proc.stdout
