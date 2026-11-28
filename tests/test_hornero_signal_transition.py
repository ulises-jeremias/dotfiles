"""Keep the personal source aligned with the Hornero Signal releases."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = (
    ROOT / "home/.chezmoiscripts/linux/run_onchange_before_install-hornero-desktop.sh.tmpl"
)
HYPR_USER = ROOT / "home/dot_config/hypr/hyprland.lua.d"


def test_signal_font_is_installed_and_retired_fonts_are_conditional():
    script = INSTALLER.read_text()

    assert "ttf-ibm-plex" in script
    # The pre-Signal fonts may only be installed behind the shell-version gate.
    gate = script.index('vercmp "$installed_hornero_shell_version" "1.3.0-1"')
    for font in ("ttf-material-symbols-variable-git", "ttf-rubik-vf"):
        installs = [m.start() for m in re.finditer(rf"^\s+{font}\b", script, re.M)]
        assert installs, font
        assert all(pos > gate for pos in installs), font


def test_signal_release_versions_are_advisory_until_published():
    script = INSTALLER.read_text()

    assert 'readonly signal_config_version="0.6.0-1"' in script
    assert 'readonly signal_shell_version="1.6.0-1"' in script
    assert 'readonly signal_horneroctl_version="0.2.0_preview62-1"' in script
    # Advisory only: the note goes to stderr and never exits non-zero.
    note = script[script.index("if (( signal_ready == 0 ))") :]
    block = note.split("\nfi", 1)[0]
    assert ">&2" in block
    assert "exit" not in block


def test_user_hyprland_overrides_use_only_stable_personal_apis():
    allowed = re.compile(r"\bhl\.(monitor|bind|unbind|dsp\.exec_cmd)\b")
    for path in sorted(HYPR_USER.glob("*-user.lua")):
        for line in path.read_text().splitlines():
            code = line.split("--", 1)[0]
            for api in re.findall(r"\bhl\.[A-Za-z_.]+", code):
                assert allowed.fullmatch(api) or allowed.match(api), (path.name, api)
        assert "layers_hog_keyboard_focus" not in path.read_text()


def test_user_terminal_and_font_files_match_signal_defaults():
    fonts = (ROOT / "home/dot_config/fontconfig/fonts.conf").read_text()
    assert "IBM Plex Sans" in fonts and "IBM Plex Mono" in fonts
    fastfetch = (ROOT / "home/dot_config/fastfetch/config.jsonc").read_text()
    assert "HORNERO OS" in fastfetch
    assert "hornero-emblem.png" in fastfetch
    ff_dir = ROOT / "home/dot_config/fastfetch"
    for name in ("hornero-emblem.png", "art/hornero-nest-emblem-original.png"):
        assert (ff_dir / name).is_file(), name


def test_readme_has_no_retired_material_terminology():
    readme = (ROOT / "README.md").read_text()

    assert "Material Design 3" not in readme
    assert "`dots " not in readme
    assert "home/dot_config/quickshell/LICENSE" not in readme
