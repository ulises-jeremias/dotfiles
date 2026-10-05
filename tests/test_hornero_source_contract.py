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


def test_hornero_runtime_comes_from_aur_packages():
    scripts = ROOT / "home/.chezmoiscripts/linux"
    shell_install = (scripts / "run_onchange_before_install-hornero-desktop.sh.tmpl").read_text()
    environment = (ROOT / "home/dot_config/hypr/hyprland.conf.d/environment.conf").read_text()

    for package in ("hornero-shell", "hornero-config", "horneroctl-bin"):
        assert package in shell_install
    assert "pacman -Qq quickshell-git" in shell_install
    assert "yay -R --noconfirm quickshell-git" in shell_install
    assert "CMAKE_BUILD_PARALLEL_LEVEL=\"${CMAKE_BUILD_PARALLEL_LEVEL:-2}\"" in shell_install
    assert shell_install.count("quickshell-git") == 2  # detect and remove the VCS package
    assert "min_hornero_config_version" in shell_install
    assert "min_hornero_shell_version" in shell_install
    assert "min_horneroctl_version" in shell_install
    assert not (ROOT / "home/dot_local/bin/executable_horneroctl").exists()
    assert not (scripts / "run_onchange_before_install-horneroctl.sh.tmpl").exists()
    assert not (scripts / "run_onchange_before_install-quickshell.sh.tmpl").exists()
    assert not (scripts / "run_before_install-hornero-shell.sh.tmpl").exists()
    assert not (scripts / "run_onchange_after_build-quickshell-plugin.sh.tmpl").exists()
    assert (ROOT / "home/dot_local/bin/remove_horneroctl").is_file()
    assert "QS_PLUGIN_PATH" not in environment
    assert "HORNERO_LIB_DIR" not in environment
    assert "QML2_IMPORT_PATH" not in environment

    for script in (
        ROOT / "playground/e2e/lib/env.sh",
        ROOT / "home/executable_dot_profile",
    ):
        content = script.read_text()
        assert ".local/lib/quickshell" not in content
        assert "QS_PLUGIN_PATH" not in content

    assert "QS_CONFIG_PATH=/etc/xdg/quickshell/hornero/shell.qml" in (
        ROOT / "playground/e2e/lib/env.sh"
    ).read_text()


def test_desktop_installs_external_styles_used_by_appearance_catalogue():
    script = (
        ROOT
        / "home/.chezmoiscripts/linux/run_onchange_before_install-hornero-desktop.sh.tmpl"
    ).read_text()

    assert "orchis-theme" in script
    assert "numix-circle-icon-theme-git" in script


if __name__ == "__main__":
    tests = [
        test_hornero_owns_theme_metadata_and_wallpapers_use_product_namespace,
        test_managed_source_has_no_retired_runtime_names_or_overrides,
        test_theme_helpers_are_not_duplicated_in_personal_source,
        test_hornero_runtime_comes_from_aur_packages,
        test_desktop_installs_external_styles_used_by_appearance_catalogue,
    ]
    for test in tests:
        test()
        print(f"PASS: {test.__name__}")
    print(f"{len(tests)} Hornero source contract tests passed")
