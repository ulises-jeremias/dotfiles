from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_hornero_owns_theme_metadata_and_wallpapers_use_product_namespace():
    data = ROOT / "home/dot_local/share/hornero"
    wallpapers = data / "wallpapers"

    assert wallpapers.is_dir()
    assert not (ROOT / ("home/dot_local/share/" + "dots")).exists()
    assert not (ROOT / ("home/dot_local/lib/" + "dots")).exists()
    assert not (ROOT / "home/dot_local/lib/hornero/switcher-theme.sh").exists()
    assert not list(data.glob("themes/*/theme.json"))
    assert (wallpapers / "patagonia/patagonia-glacier-01.jpg").is_file()
    assert (wallpapers / "fin-del-mundo/beagle-blue-hour-01.jpg").is_file()


def test_managed_source_has_no_retired_runtime_names_or_overrides():
    retired = (
        "do" + "ts-",
        "DO" + "TS_",
        ".local/share/" + "dots",
        ".local/lib/" + "dots",
        ".cache/" + "dots",
        "config " + "migrate",
    )
    files = [
        * (ROOT / "home").rglob("*"),
        ROOT / "README.md",
        ROOT / "AGENTS.md",
        ROOT / "CONTRIBUTING.md",
    ]
    text_suffixes = {".sh", ".tmpl", ".conf", ".json", ".toml", ".yaml", ".yml", ".md", ".ini", ".py", ".zsh", ".txt", ".scm", ".css"}
    sources = [
        path for path in files
        if path.is_file() and ".git" not in path.parts
        and (path.suffix in text_suffixes or path.name in {"README", "AGENTS.md", "CONTRIBUTING.md"})
    ]

    for path in sources:
        content = path.read_text(errors="ignore")
        for token in retired:
            assert token not in content, f"retired runtime marker {token!r} in {path.relative_to(ROOT)}"


def test_theme_helpers_are_not_duplicated_in_personal_source():
    bin_dir = ROOT / "home/dot_local/bin"
    assert not list(bin_dir.glob("*settings*shim*"))
    assert not list(bin_dir.glob("*switcher*shim*"))
