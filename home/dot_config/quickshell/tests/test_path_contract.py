"""Path contract: utils/Paths.qml must expose env-override-first resolution
with XDG/$HOME fallbacks, and QML must not hardcode /home/ literals."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PATHS = ROOT / "utils" / "Paths.qml"

REQUIRED_PROPS = [
    "wallpaperPointer", "imagecache", "wallsdir", "recsdir", "libdir",
    "data", "state", "cache", "config",
]
REQUIRED_ENVS = [
    "DOTS_DATA_DIR", "DOTS_STATE_DIR", "DOTS_CACHE_DIR", "DOTS_CONFIG_DIR",
    "XDG_DATA_HOME", "XDG_STATE_HOME", "XDG_CACHE_HOME", "XDG_CONFIG_HOME",
    "HORNERO_WALLPAPERS_DIR", "HORNERO_RECORDINGS_DIR", "HORNERO_LIB_DIR",
]


def test_paths_singleton_contract():
    text = PATHS.read_text()
    for prop in REQUIRED_PROPS:
        assert prop in text, f"Paths.qml missing property {prop}"
    for env in REQUIRED_ENVS:
        assert env in text, f"Paths.qml missing env override {env}"


def test_no_hardcoded_home_in_qml():
    hits = []
    for dirname in ("modules", "services", "config", "utils", "components"):
        for path in (ROOT / dirname).rglob("*.qml"):
            if "/home/" in path.read_text():
                hits.append(str(path.relative_to(ROOT)))
    assert not hits, f"hardcoded /home/ literals in: {hits}"


def test_presets_installed_by_cmake():
    cmake = (ROOT / "CMakeLists.txt").read_text()
    assert "presets" in cmake, "CMakeLists.txt must install presets/"
    assert (ROOT / "presets").is_dir()
    assert len(list((ROOT / "presets").glob("*.json"))) == 11


# Path-contract conformance (binding interface: HorneroOS/hornero
# docs/PATH_CONTRACT.md, shell checklist row): canonical hornero/*-first
# resolution with dots/* fallback (reads only), keeping the DOTS_*_DIR env
# overrides on the legacy roots.

CANONICAL_ROOTS = [
    "`${dataHome}/hornero`",
    "`${stateHome}/hornero`",
    "`${cacheHome}/hornero`",
]

FALLBACK_PROPS = [
    "dataFallback",
    "stateFallback",
    "cacheFallback",
    "wallpaperPointerFallback",
    "imagecacheFallback",
    "notifimagecacheFallback",
]


def test_paths_canonical_hornero_first():
    text = PATHS.read_text()
    for root in CANONICAL_ROOTS:
        assert root in text, f"Paths.qml missing canonical root {root}"
    assert "PATH_CONTRACT" in text, "Paths.qml must cite the binding contract"


def test_paths_dots_fallback_kept():
    text = PATHS.read_text()
    for prop in FALLBACK_PROPS:
        assert prop in text, f"Paths.qml missing fallback property {prop}"
    assert text.count("/dots") >= 3, "Paths.qml must keep dots/* fallback roots"
    for env in ("DOTS_DATA_DIR", "DOTS_STATE_DIR", "DOTS_CACHE_DIR"):
        assert env in text, f"Paths.qml missing legacy override {env}"


def test_consumers_read_canonical_first_with_fallback():
    pipeline = (ROOT / "services" / "ThemePipeline.qml").read_text()
    for prop in ("themesDirFallback", "wallpapersDirFallback", "schemeJsonFallback"):
        assert prop in pipeline, f"ThemePipeline.qml missing {prop}"
    assert "themeFileViewFallback" in pipeline, "ThemePipeline theme.json fallback view missing"
    colours = (ROOT / "services" / "Colours.qml").read_text()
    assert "cacheFallback" in colours, "Colours.qml missing scheme.json fallback"
    assert "schemeFileViewFallback" in colours, "Colours fallback FileView missing"
    notifs = (ROOT / "services" / "Notifs.qml").read_text()
    assert "stateFallback" in notifs, "Notifs.qml missing notifs.json fallback"
    assert "storageFallback" in notifs, "Notifs fallback FileView missing"
    grid = (ROOT / "modules" / "controlcenter" / "components" / "WallpaperGrid.qml").read_text()
    assert "scopeDataPathFallback" in grid, "WallpaperGrid.qml missing wallpapers fallback (row 11)"


def test_fallbacks_never_written():
    for rel in ("services/ThemePipeline.qml", "services/Notifs.qml",
                "components/images/CachingImage.qml"):
        for i, line in enumerate((ROOT / rel).read_text().splitlines(), 1):
            writes = ("setText(", "--output", "cacheDir", "DOTS_WALLPAPER_PTR")
            if any(w in line for w in writes):
                assert "Fallback" not in line, f"{rel}:{i} writes to a fallback path"


def test_config_shell_json_canonical_no_fallback():
    text = (ROOT / "config" / "Config.qml").read_text()
    assert "${Paths.config}/shell.json" in text, "Config.qml must read shell.json via Paths.config"
    assert "Fallback" not in text, "Config.qml must not add a dots fallback (contract row 6)"
    assert "/dots/shell.json" not in text


def test_arch_documents_path_contract():
    text = (ROOT / "docs" / "ARCHITECTURE.md").read_text()
    assert "PATH_CONTRACT" in text, "ARCHITECTURE.md must cite the binding contract"
    assert "hornero/*" in text and "dots/*" in text
    assert "dataFallback" in text and "stateFallback" in text and "cacheFallback" in text


# Namespace audit (Preview 1 Worker B): every remaining dots/DOTS reference in
# QML classifies as path (canonical hornero/*-first + dots/* fallback, asserted
# above), binary-name (dots-* executable names stay, out of scope), or
# third-party (quickshell namespace stays as-is). No QML may point users at a
# legacy-only path literal: user-facing hints must name the canonical
# hornero/* location first.

LEGACY_PATH_LITERAL_RES = [
    "share/dots",
    "state/dots",
    "cache/dots",
    "config/dots",
]


def _all_qml():
    files = []
    for dirname in ("modules", "services", "config", "utils", "components"):
        files.extend((ROOT / dirname).rglob("*.qml"))
    return files


def test_no_legacy_only_path_literals_in_qml():
    hits = []
    for path in _all_qml():
        # utils/Paths.qml builds fallbacks from XDG vars ("${dataHome}/dots");
        # it carries no legacy-root literal and is the single exemption.
        if path.name == "Paths.qml":
            continue
        text = path.read_text()
        for lit in LEGACY_PATH_LITERAL_RES:
            if lit in text:
                hits.append(f"{path.relative_to(ROOT)}: {lit}")
    assert not hits, f"legacy-only path literals in QML: {hits}"


def test_preset_empty_state_names_canonical_path():
    text = (ROOT / "modules" / "layoutpicker" / "PresetGrid.qml").read_text()
    assert "hornero/shell-presets" in text, \
        "PresetGrid empty state must point at the canonical presets dir (row 2)"
    assert "share/dots" not in text
