"""Appearance consistency: QML applies theming through native layers first —
GtkSettings (gsettings) for GTK application and the ImageAnalyser plugin
for wallpaper tone analysis — and reaches outside the repo only through
`horneroctl` verbs owned by HorneroOS/hornero. No `dots-*` wrapper may
remain in QML; QML must never call gtk-theme-manager.sh directly, never
run bare `python3 generate-m3-colors`, and never spawn bare `python3`
for theme listing (theme packs list via
`horneroctl appearance theme list --full`)."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
QML_DIRS = [ROOT / d for d in ("modules", "services", "config", "utils", "components")]

# Every dots-* wrapper the shell ever shelled out to. All retired: the
# native horneroctl verbs cover each one (see docs/MIGRATION.md).
RETIRED_WRAPPERS = [
    "dots-gtk-theme",
    "dots-m3-colors",
    "dots-color-scheme",
    "dots-appearance",
    "dots-accent-override",
    "dots-night-mode",
    "dots-wallpaper-current",
    "dots-wallpaper-set",
    "dots-recorder",
    "dots-screenshooter",
    "dots-settings-gui",
    "dots-snappy-switcher",
    "dots-hyprlock-theme",
    "dots-lockscreen",
    "dots-sysupdate",
    "dots-keyboard-help",
    "dots-theme-selector",
]


def _qml_files():
    for d in QML_DIRS:
        yield from d.rglob("*.qml")


def _hits(needle):
    return [p for p in _qml_files() if needle in p.read_text()]


def test_no_direct_gtk_theme_manager():
    hits = _hits("gtk-theme-manager.sh")
    assert not hits, f"direct gtk-theme-manager.sh calls in: {hits}"


def test_no_bare_generate_m3_colors():
    hits = _hits("generate-m3-colors")
    assert not hits, f"bare generate-m3-colors calls in: {hits}"


def test_no_retired_dots_wrappers_in_qml():
    hits = []
    for path in _qml_files():
        text = path.read_text()
        for dead in RETIRED_WRAPPERS:
            if dead in text:
                hits.append(f"{path.relative_to(ROOT)}: {dead}")
    assert not hits, f"retired wrappers referenced by QML:\n" + "\n".join(hits)


def test_canonical_cli_calls_present():
    # Only files that actually spawn processes count (AppList.qml routes a
    # "scheme" launcher keyword without spawning anything).
    def _spawning():
        for p in _qml_files():
            text = p.read_text()
            if "execDetached" in text or "command:" in text:
                yield p, text

    spawning = list(_spawning())
    gtk = [p for p, text in spawning if '"gtk"' in text]
    assert gtk, "expected horneroctl appearance gtk calls in QML"
    scheme = [p for p, text in spawning if '"scheme"' in text]
    assert scheme, "expected horneroctl scheme calls in QML"
    m3 = [p for p, text in spawning if '"m3"' in text]
    assert m3, "expected horneroctl appearance colors m3 calls in QML"
    for path in gtk + scheme + m3:
        assert '"horneroctl"' in path.read_text(), (
            f"{path.relative_to(ROOT)}: appearance calls must go through horneroctl"
        )


def test_no_bare_python_theme_loader():
    py_hits = [p for p in _qml_files()
               if '"python3"' in p.read_text() or "'python3'" in p.read_text()]
    assert not py_hits, f"bare python3 spawn in QML: {py_hits}"
    loader_hits = _hits("list-themes")
    assert not loader_hits, f"list-themes.py references in QML: {loader_hits}"


def test_theme_listing_uses_cli():
    hits = [p for p in _qml_files() if '"horneroctl"' in p.read_text()]
    assert hits, "expected horneroctl calls in QML"
    list_hits = [p for p in hits
                 if '"theme"' in p.read_text() and '"list"' in p.read_text()
                 and '"--full"' in p.read_text()]
    assert list_hits, (
        f"theme listing must use `horneroctl appearance theme list --full`: {hits}"
    )


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
