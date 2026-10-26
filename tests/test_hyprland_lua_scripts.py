"""Contract tests for the Lua ports of the Hyprland helper scripts."""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HYPR = ROOT / "home/dot_config/hypr"
SCRIPTS = HYPR / "scripts"
LUA = shutil.which("lua") or shutil.which("lua5.4")

MIGRATED = {
    "gaps-interactive": SCRIPTS / "executable_gaps-interactive.lua",
    "smart-float": SCRIPTS / "executable_smart-float.lua",
    "notification-handler": SCRIPTS / "executable_notification-handler.lua",
    "hyprland-runtime": ROOT / "home/dot_local/bin/executable_hyprland-runtime.lua",
    "start-gnome-keyring": ROOT / "home/dot_local/bin/executable_start-gnome-keyring.lua",
}
RETIRED = (
    SCRIPTS / "executable_gaps-interactive.sh",
    SCRIPTS / "executable_smart-float.sh",
    SCRIPTS / "executable_notification-handler.sh",
    ROOT / "home/dot_local/bin/executable_hyprland-runtime",
    ROOT / "home/dot_local/bin/executable_start-gnome-keyring.sh",
)


def test_no_shell_scripts_remain_in_hypr_tree():
    for retired in RETIRED:
        assert not retired.exists(), retired
    assert not list(HYPR.rglob("*.sh"))
    assert not list(HYPR.rglob("*.py"))


def test_every_migrated_script_parses_as_lua():
    assert LUA, "lua interpreter required"
    for path in MIGRATED.values():
        assert path.exists(), path
        subprocess.run(["luac", "-p", str(path)], check=True)


def test_binds_reference_lua_scripts_and_keep_bind_parity():
    keybindings = (HYPR / "hyprland.lua.d/keybindings.lua").read_text(encoding="utf-8")
    assert keybindings.count("hl.bind(") == 139
    assert "lua ~/.config/hypr/scripts/gaps-interactive.lua" in keybindings
    assert "lua ~/.config/hypr/scripts/smart-float.lua" in keybindings
    assert ".sh" not in keybindings


def test_callers_reference_lua_versions():
    autostart = (HYPR / "hyprland.lua.d/autostart.lua").read_text(encoding="utf-8")
    hypridle = (HYPR / "hypridle.conf").read_text(encoding="utf-8")
    assert "lua $HOME/.local/bin/start-gnome-keyring.lua" in autostart
    assert 'lua "$HOME/.local/bin/hyprland-runtime.lua" dpms off' in hypridle
    remove = (ROOT / "home/.chezmoiremove").read_text(encoding="utf-8")
    for entry in (
        ".config/hypr/scripts/gaps-interactive.sh",
        ".config/hypr/scripts/smart-float.sh",
        ".config/hypr/scripts/notification-handler.sh",
        ".local/bin/hyprland-runtime",
        ".local/bin/start-gnome-keyring.sh",
    ):
        assert entry in remove


def _stage(tmp: Path) -> dict[str, str]:
    """Stage fake hyprctl/playerctl/notify-send and the Lua helper."""
    bindir = tmp / "bin"
    bindir.mkdir()
    home = tmp / "home"
    local_bin = home / ".local/bin"
    local_bin.mkdir(parents=True)
    shutil.copy(MIGRATED["hyprland-runtime"], local_bin / "hyprland-runtime.lua")
    log = tmp / "calls"
    fake = bindir / "hyprctl"
    fake.write_text(
        "#!/usr/bin/env bash\n"
        'printf "<%s>" "$@" >> "$CALLS_LOG"\n'
        'case "$*" in\n'
        '  "activewindow -j") printf \'{"floating":false,"address":"0x1"}\\n\' ;;\n'
        '  "monitors -j") printf \'[{"width":1920,"height":1080}]\\n\' ;;\n'
        '  "-j getoption "*) printf \'{"custom":"10 10"}\\n\' ;;\n'
        "esac\n",
        encoding="utf-8",
    )
    fake.chmod(0o755)
    for name in ("playerctl", "notify-send"):
        stub = bindir / name
        stub.write_text(
            '#!/usr/bin/env bash\nprintf "<%s>" "$@" >> "$CALLS_LOG"\nprintf "\\n" >> "$CALLS_LOG"\n',
            encoding="utf-8",
        )
        stub.chmod(0o755)
    env = os.environ.copy()
    env.update(
        {
            "HOME": str(home),
            "XDG_CONFIG_HOME": str(tmp / "config"),
            "CALLS_LOG": str(log),
            "HYPRCTL_LOG": str(log),
            "PATH": os.pathsep.join((str(bindir), env["PATH"])),
        }
    )
    (tmp / "config/hypr").mkdir(parents=True)
    (tmp / "config/hypr/hyprland.lua").write_text("-- lua provider\n", encoding="utf-8")
    return env


def test_smart_float_uses_runtime_helper():
    with tempfile.TemporaryDirectory(prefix="smart-float-") as directory:
        tmp = Path(directory)
        env = _stage(tmp)
        subprocess.run(
            [LUA, str(MIGRATED["smart-float"])], check=True, env=env, capture_output=True, text=True
        )
        calls = (tmp / "calls").read_text(encoding="utf-8")
        assert '<dispatch><hl.dsp.window.float({ action = "toggle" })>' in calls
        assert '<dispatch><hl.dsp.window.resize({ x = 1400, y = 864, relative = false })>' in calls
        assert "<dispatch><hl.dsp.window.center()>" in calls


def test_gaps_interactive_drives_runtime_helper():
    with tempfile.TemporaryDirectory(prefix="gaps-") as directory:
        tmp = Path(directory)
        env = _stage(tmp)
        result = subprocess.run(
            [LUA, str(MIGRATED["gaps-interactive"])],
            check=True,
            env=env,
            input="1\n1\n",
            capture_output=True,
            text=True,
        )
        assert "Inner Gaps (current: 10)" in result.stdout
        calls = (tmp / "calls").read_text(encoding="utf-8")
        assert '<eval><hl.config({ general = { gaps_in = 15 } })>' in calls


def test_notification_handler_media_and_errors():
    with tempfile.TemporaryDirectory(prefix="notif-") as directory:
        tmp = Path(directory)
        env = _stage(tmp)
        result = subprocess.run(
            [LUA, str(MIGRATED["notification-handler"]), "middle", "spotify"],
            check=True,
            env=env,
            capture_output=True,
            text=True,
        )
        assert "[INFO] Media play/pause toggled" in result.stdout
        assert "<play-pause>" in (tmp / "calls").read_text(encoding="utf-8")
        missing = subprocess.run(
            [LUA, str(MIGRATED["notification-handler"])],
            env=env,
            capture_output=True,
            text=True,
        )
        assert missing.returncode == 1
        assert "[ERROR] No action specified" in missing.stderr
