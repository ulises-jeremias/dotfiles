"""Contract tests for the Hyprland actions module (former helper scripts)."""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HYPR = ROOT / "home/dot_config/hypr"
ACTIONS = HYPR / "hyprland.lua.d/actions.lua"
LUA = shutil.which("lua") or shutil.which("lua5.4")

STANDALONE = (
    HYPR / "scripts/executable_gaps-interactive.lua",
    HYPR / "scripts/executable_smart-float.lua",
    HYPR / "scripts/executable_notification-handler.lua",
    ROOT / "home/dot_local/bin/executable_hyprland-runtime.lua",
    ROOT / "home/dot_local/bin/executable_start-gnome-keyring.lua",
)
RETIRED = STANDALONE + (
    HYPR / "scripts/executable_gaps-interactive.sh",
    HYPR / "scripts/executable_smart-float.sh",
    HYPR / "scripts/executable_notification-handler.sh",
    ROOT / "home/dot_local/bin/executable_hyprland-runtime",
    ROOT / "home/dot_local/bin/executable_start-gnome-keyring.sh",
)

HL_STUB = r"""
local log = os.getenv("CALLS_LOG")
local function record(line)
    local fh = assert(io.open(log, "a"))
    fh:write(line .. "\n")
    fh:close()
end
hl = {
    config = function(t)
        local g = t.general or {}
        if g.gaps_in ~= nil then
            record("<eval><hl.config({ general = { gaps_in = " .. g.gaps_in .. " } })>")
        end
        if g.gaps_out ~= nil then
            record("<eval><hl.config({ general = { gaps_out = " .. g.gaps_out .. " } })>")
        end
    end,
    dispatch = function(d) record("<dispatch><" .. d .. ">") end,
    dsp = {
        window = {
            float = function(o) return 'hl.dsp.window.float({ action = "' .. o.action .. '" })' end,
            resize = function(o)
                return string.format(
                    "hl.dsp.window.resize({ x = %d, y = %d, relative = %s })", o.x, o.y, tostring(o.relative))
            end,
            center = function() return "hl.dsp.window.center()" end,
        },
        focus = function(o) return 'hl.dsp.focus({ window = "' .. o.window .. '" })' end,
        dpms = function(o) return 'hl.dsp.dpms({ action = "' .. o.action .. '" })' end,
    },
}
"""


def test_no_standalone_scripts_remain():
    for retired in RETIRED:
        assert not retired.exists(), retired
    assert not (HYPR / "scripts").exists()
    assert not list(HYPR.rglob("*.sh"))
    assert ACTIONS.exists()


def test_actions_module_and_config_parse_as_lua():
    assert LUA, "lua interpreter required"
    for path in sorted(HYPR.rglob("*.lua")):
        subprocess.run(["luac", "-p", str(path)], check=True)


def test_binds_call_actions_functions_and_keep_bind_parity():
    keybindings = (HYPR / "hyprland.lua.d/keybindings.lua").read_text(encoding="utf-8")
    assert keybindings.count("hl.bind(") == 139
    assert 'hl.bind("SUPER + SHIFT + G", function()' in keybindings
    assert "actions.gaps_interactive()" in keybindings
    assert 'hl.bind("SUPER + SHIFT + F", function()' in keybindings
    assert "actions.smart_float()" in keybindings
    assert "scripts/" not in keybindings
    assert ".sh" not in keybindings


def test_callers_use_module_or_hyprctl_not_standalone_scripts():
    autostart = (HYPR / "hyprland.lua.d/autostart.lua").read_text(encoding="utf-8")
    hypridle = (HYPR / "hypridle.conf").read_text(encoding="utf-8")
    assert "actions.start_gnome_keyring()" in autostart
    assert "start-gnome-keyring" not in autostart
    assert 'hyprctl dispatch \'hl.dsp.dpms({ action = "disable" })\'' in hypridle
    assert 'hyprctl dispatch \'hl.dsp.dpms({ action = "enable" })\'' in hypridle
    assert "hyprland-runtime" not in hypridle
    remove = (ROOT / "home/.chezmoiremove.tmpl").read_text(encoding="utf-8")
    for entry in (
        ".config/hypr/scripts/gaps-interactive.sh",
        ".config/hypr/scripts/smart-float.sh",
        ".config/hypr/scripts/notification-handler.sh",
        ".local/bin/hyprland-runtime",
        ".local/bin/start-gnome-keyring.sh",
        ".config/hypr/scripts/gaps-interactive.lua",
        ".config/hypr/scripts/smart-float.lua",
        ".config/hypr/scripts/notification-handler.lua",
        ".local/bin/hyprland-runtime.lua",
        ".local/bin/start-gnome-keyring.lua",
    ):
        assert entry in remove


def _stage(tmp: Path) -> dict[str, str]:
    """Stage fake hyprctl/playerctl/notify-send plus an hl stub."""
    bindir = tmp / "bin"
    bindir.mkdir()
    log = tmp / "calls"
    fake = bindir / "hyprctl"
    fake.write_text(
        "#!/usr/bin/env bash\n"
        'printf "<%s>" "$@" >> "$CALLS_LOG"\n'
        'printf "\\n" >> "$CALLS_LOG"\n'
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
    (tmp / "hl_stub.lua").write_text(HL_STUB, encoding="utf-8")
    env = os.environ.copy()
    env.update(
        {
            "CALLS_LOG": str(log),
            "PATH": os.pathsep.join((str(bindir), env["PATH"])),
        }
    )
    return env


def _run_action(tmp: Path, env: dict[str, str], snippet: str, **kwargs) -> subprocess.CompletedProcess:
    runner = tmp / "runner.lua"
    runner.write_text(
        f'dofile("{tmp}/hl_stub.lua")\nlocal actions = dofile("{ACTIONS}")\n{snippet}\n',
        encoding="utf-8",
    )
    return subprocess.run([LUA, str(runner)], env=env, capture_output=True, text=True, **kwargs)


def test_smart_float_uses_actions_dispatchers():
    with tempfile.TemporaryDirectory(prefix="smart-float-") as directory:
        tmp = Path(directory)
        env = _stage(tmp)
        result = _run_action(tmp, env, "assert(actions.smart_float())")
        assert result.returncode == 0, result.stderr
        calls = (tmp / "calls").read_text(encoding="utf-8")
        assert '<dispatch><hl.dsp.window.float({ action = "toggle" })>' in calls
        assert '<dispatch><hl.dsp.window.resize({ x = 1400, y = 864, relative = false })>' in calls
        assert "<dispatch><hl.dsp.window.center()>" in calls


def test_gaps_interactive_drives_actions():
    with tempfile.TemporaryDirectory(prefix="gaps-") as directory:
        tmp = Path(directory)
        env = _stage(tmp)
        result = _run_action(tmp, env, "assert(actions.gaps_interactive())", input="1\n1\n")
        assert result.returncode == 0, result.stderr
        assert "Inner Gaps (current: 10)" in result.stdout
        calls = (tmp / "calls").read_text(encoding="utf-8")
        assert '<eval><hl.config({ general = { gaps_in = 15 } })>' in calls


def test_notification_action_media_and_errors():
    with tempfile.TemporaryDirectory(prefix="notif-") as directory:
        tmp = Path(directory)
        env = _stage(tmp)
        result = _run_action(tmp, env, 'assert(actions.notification("middle", "spotify", "", ""))')
        assert result.returncode == 0, result.stderr
        assert "[INFO] Media play/pause toggled" in result.stdout
        assert "<play-pause>" in (tmp / "calls").read_text(encoding="utf-8")
        missing = _run_action(tmp, env, 'assert(not actions.notification("", "spotify", "", ""))')
        assert missing.returncode == 0, missing.stderr
        assert "[ERROR] No action specified" in missing.stderr
