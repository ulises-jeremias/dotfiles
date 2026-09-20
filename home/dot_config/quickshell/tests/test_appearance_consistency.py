"""Appearance consistency: QML applies theming through native layers first
— GtkSettings (gsettings) for GTK application and the ImageAnalyser plugin
for wallpaper tone analysis — plus `horneroctl appearance …` verbs. QML
must never call gtk-theme-manager.sh directly, never run bare
`python3 generate-m3-colors`, and never spawn bare `python3` for theme
listing (theme packs list via `horneroctl appearance theme list --full`)."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
QML_DIRS = [ROOT / d for d in ("modules", "services", "config", "utils", "components")]


def _qml_files():
    for d in QML_DIRS:
        yield from d.rglob("*.qml")


def _hits(needle):
    return [p for p in _qml_files() if needle in p.read_text()]


def _read_all():
    return "\n".join(p.read_text() for p in _qml_files())


def _read_qml(rel):
    return (ROOT / rel).read_text()


def test_no_direct_gtk_theme_manager():
    hits = _hits("gtk-theme-manager.sh")
    assert not hits, f"direct gtk-theme-manager.sh calls in: {hits}"


def test_no_bare_generate_m3_colors():
    hits = _hits("generate-m3-colors")
    assert not hits, f"bare generate-m3-colors calls in: {hits}"


def test_canonical_cli_calls_present():
    text = _read_all()
    assert "horneroctl" in text, "expected canonical horneroctl calls in QML"
    for leaf in ("appearance", "gtk", "colors", "scheme"):
        assert leaf in text, f"missing native leaf: {leaf}"


def test_no_bare_python_theme_loader():
    py_hits = [p for p in _qml_files()
               if '"python3"' in p.read_text() or "'python3'" in p.read_text()]
    assert not py_hits, f"bare python3 spawn in QML: {py_hits}"
    loader_hits = _hits("list-themes")
    assert not loader_hits, f"list-themes.py references in QML: {loader_hits}"


def test_theme_listing_uses_cli():
    text = _read_qml("modules/launcher/services/Themes.qml")
    for token in ('"appearance"', '"theme"', '"list"', '"--full"'):
        assert token in text, f"Themes.qml must invoke the native theme list: {token}"


def test_native_gtk_layer_present():
    layer = ROOT / "services" / "GtkSettings.qml"
    assert layer.exists(), "services/GtkSettings.qml native layer missing"
    text = layer.read_text()
    assert "gsettings" in text, "GtkSettings must drive gsettings natively"
    assert "toGsettingsScheme" in text, "GtkSettings must map policy deterministically"
    pipeline = (ROOT / "services" / "ThemePipeline.qml").read_text()
    assert "GtkSettings.applyFull" in pipeline, "ThemePipeline finalize must use GtkSettings"
    assert "GtkSettings.applyGtkTheme" in pipeline, "ThemePipeline setGtk must use GtkSettings"
    assert "GtkSettings.applyColorScheme" in pipeline, "ThemePipeline color-scheme must use GtkSettings"
    assert "GtkSettings.applyIconTheme" in pipeline, "ThemePipeline setIcons must use GtkSettings"


def test_native_analyser_layer_present():
    layer = ROOT / "services" / "WallpaperAnalysis.qml"
    assert layer.exists(), "services/WallpaperAnalysis.qml native layer missing"
    text = layer.read_text()
    assert "ImageAnalyser" in text, "WallpaperAnalysis must wrap ImageAnalyser"
    assert "dominantColour" in text, "WallpaperAnalysis must expose dominantColour"
    assert "luminance" in text, "WallpaperAnalysis must expose luminance"
    colours = (ROOT / "services" / "Colours.qml").read_text()
    assert "wallDominantColour" in colours, "Colours must expose native dominant colour"
    assert "wallLuminance" in colours, "Colours must keep native luminance"
    pane = (ROOT / "modules" / "controlcenter" / "appearance" / "AppearancePane.qml").read_text()
    assert "previewAnalyser" in pane, "AppearancePane must analyse previews natively"


def test_compat_fallbacks_marked_debt():
    unmarked = []
    for path in _qml_files():
        text = path.read_text()
        if ("dots-gtk-theme" in text or "dots-m3-colors" in text
                or "dots-color-scheme" in text
                or "dots-appearance" in text) and "TODO(hornero-compat)" not in text:
            unmarked.append(str(path.relative_to(ROOT)))
    assert not unmarked, f"compat call sites missing debt markers: {unmarked}"
