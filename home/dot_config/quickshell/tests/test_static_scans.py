"""Static scans: no template markers, no chezmoi coupling, licensing intact."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CODE_DIRS = ["modules", "services", "config", "utils", "components",
             "plugin", "extras", "presets", "nix"]
CODE_GLOBS = ("*.qml", "*.js", "*.cpp", "*.hpp", "*.cmake", "*.nix",
              "*.json", "*.txt", "CMakeLists.txt")


def _code_files():
    files = []
    for d in CODE_DIRS:
        base = ROOT / d
        if base.is_dir():
            for pat in CODE_GLOBS:
                files.extend(base.rglob(pat))
    for extra in ("shell.qml", "CMakeLists.txt", "flake.nix"):
        if (ROOT / extra).exists():
            files.append(ROOT / extra)
    return files


def test_no_template_markers():
    hits = [str(p.relative_to(ROOT)) for p in _code_files()
            if "{{" in p.read_text(errors="ignore")]
    assert not hits, f"template markers in: {hits}"


def test_no_chezmoi_in_code():
    hits = [str(p.relative_to(ROOT)) for p in _code_files()
            if "chezmoi" in p.read_text(errors="ignore").lower()]
    assert not hits, f"chezmoi references in: {hits}"


def test_licensing_intact():
    gpl = (ROOT / "LICENSE.GPL-3.0").read_text(errors="ignore")
    assert "caelestia-dots/shell" in gpl, "Caelestia attribution missing"
    assert "GNU GENERAL PUBLIC LICENSE" in gpl, "GPL text missing"
    assert (ROOT / "LICENSE").read_text().startswith("MIT License")
    notice = (ROOT / "NOTICE").read_text()
    assert "caelestia-dots/shell" in notice
    assert "HorneroOS modifications" in notice or "HorneroOS" in notice
    assert (ROOT / "docs" / "MIGRATION.md").exists()
