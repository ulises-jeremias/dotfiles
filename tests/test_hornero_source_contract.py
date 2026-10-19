from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]


def test_hornero_owns_theme_metadata_and_wallpapers_use_product_namespace():
    data = ROOT / "home/dot_local/share/hornero"
    wallpapers = data / "wallpapers"

    assert wallpapers.is_dir()
    assert not (ROOT / ("home/dot_local/share/" + "dots")).exists()
    assert not (ROOT / ("home/dot_local/lib/" + "dots")).exists()
    assert not (ROOT / "home/dot_local/lib/hornero/switcher-theme.sh").exists()
    assert not list(data.glob("themes/*/theme.json"))
    regional_product_defaults = (
        "buenos-aires-nocturno/buenos-aires-nocturno-01.jpg",
        "fin-del-mundo/beagle-blue-hour-01.jpg",
        "ibera/ibera-mist-01.jpg",
        "pampa/pampa-01.png",
        "patagonia/patagonia-glacier-01.jpg",
        "quebrada/quebrada-mineral-01.jpg",
    )
    assert all(not (wallpapers / item).exists() for item in regional_product_defaults)
    assert "hornero-config" in (wallpapers / "README.md").read_text()


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


def test_kitty_defaults_are_owned_by_the_hornero_config_package():
    # Kitty merges /etc/xdg/kitty/kitty.conf before user files, so a full
    # chezmoi copy would pin package defaults at the account level and make
    # future AUR updates ineffective. Personal overrides can be added later
    # when the workstation has a setting that actually differs from product
    # defaults.
    assert not (ROOT / "home/dot_config/kitty").exists()


def test_selected_terminal_association_is_not_overwritten_by_dotfiles():
    # horneroctl owns this mutable user preference. Keeping a static
    # TerminalEmulator entry here would reset a user's Ghostty/Alacritty
    # selection whenever chezmoi applies the workstation source.
    assert not (ROOT / "home/dot_config/xfce4/helpers.rc").exists()
    ignore = (ROOT / "home/.chezmoiignore.tmpl").read_text()
    assert ".config/xfce4/helpers.rc" in ignore


def test_yazi_launchers_use_the_configured_terminal():
    keybindings = (ROOT / "home/dot_config/hypr/hyprland.conf.d/keybindings.conf").read_text()
    thunar_actions = (ROOT / "home/dot_config/Thunar/uca.xml").read_text()
    window_rules = (
        ROOT / "home/dot_config/hypr/hyprland.conf.d/window-rules.conf"
    ).read_text()

    assert (
        "bind = $mainMod, E, exec, horneroctl apps terminal-file --new-window --last-dir"
        in keybindings
    )
    assert (
        'horneroctl apps terminal-file --new-window --path "%f"'
        in thunar_actions
    )
    assert "kitty --class yazi-popup" not in keybindings
    assert "kitty --class yazi-popup" not in thunar_actions
    assert (
        r"""windowrule {
    name = yazi-popup
    match:class = ^(yazi-popup|com\.horneroos\.yazi-popup)$
""" in window_rules
    )


def test_ghostty_receives_the_same_hyprland_terminal_opacity_as_other_terminals():
    window_rules = (
        ROOT / "home/dot_config/hypr/hyprland.conf.d/window-rules.conf"
    ).read_text()
    ghostty_rule = window_rules.split("name = ghostty-opacity", 1)[1].split("}", 1)[0]

    assert "match:class = ^com[.]mitchellh[.]ghostty$" in ghostty_rule
    assert "opacity = 0.95 0.85" in ghostty_rule


def test_hyprland_swallowing_covers_every_supported_terminal():
    expected = "^(kitty|Alacritty|com[.]mitchellh[.]ghostty)$"
    static_config = (ROOT / "home/dot_config/hypr/hyprland.conf").read_text()
    lua_config = (ROOT / "home/dot_config/hypr/hyprland.lua.d/static.lua").read_text()

    assert f"swallow_regex = {expected}" in static_config
    assert f'swallow_regex = "{expected}"' in lua_config

    # Window class strings match HorneroOS/config and Hyprland's actual class
    # contract; keep this in step with the system defaults if a backend adds
    # or changes an app ID.
    for window_class in ("kitty", "Alacritty", "com.mitchellh.ghostty"):
        assert re.fullmatch(expected, window_class), window_class
    assert not re.fullmatch(expected, "wev")

    guide = (ROOT / "docs/Hyprland-Setup.md").read_text()
    for terminal in ("Kitty", "Alacritty", "Ghostty"):
        assert terminal in guide
    assert "Window swallowing is enabled" in guide


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
    assert 'min_hornero_config_version="0.3.9-1"' in shell_install
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
        test_kitty_defaults_are_owned_by_the_hornero_config_package,
        test_selected_terminal_association_is_not_overwritten_by_dotfiles,
        test_yazi_launchers_use_the_configured_terminal,
        test_ghostty_receives_the_same_hyprland_terminal_opacity_as_other_terminals,
        test_hornero_runtime_comes_from_aur_packages,
        test_desktop_installs_external_styles_used_by_appearance_catalogue,
    ]
    for test in tests:
        test()
        print(f"PASS: {test.__name__}")
    print(f"{len(tests)} Hornero source contract tests passed")
