"""Verify the in-config Hyprland actions (former hyprland-runtime helper).

The runtime helper no longer exists as a standalone script: its operations
live in hyprland.lua.d/actions.lua and are exercised here through an hl
stub, with a fake hyprctl serving gap reads.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

from test_hyprland_lua_scripts import HL_STUB


ROOT = Path(__file__).resolve().parents[1]
ACTIONS = ROOT / "home/dot_config/hypr/hyprland.lua.d/actions.lua"
LUA = shutil.which("lua") or shutil.which("lua5.4")


def make_environment(root: Path) -> tuple[dict[str, str], Path]:
    bindir = root / "bin"
    bindir.mkdir()
    log = root / "calls"
    fake_hyprctl = bindir / "hyprctl"
    fake_hyprctl.write_text(
        '#!/usr/bin/env bash\nprintf "<%s>" "$@" >> "$HYPRCTL_LOG"\n'
        'printf "\\n" >> "$HYPRCTL_LOG"\n'
        'if [[ $2 == getoption ]]; then printf \'{"custom":"%s"}\\n\' "${HYPRCTL_OPTION_VALUE:-12 12}"; fi\n',
        encoding="utf-8",
    )
    fake_hyprctl.chmod(0o755)
    (root / "hl_stub.lua").write_text(
        HL_STUB.replace('os.getenv("CALLS_LOG")', 'os.getenv("HYPRCTL_LOG")'), encoding="utf-8"
    )
    environment = os.environ.copy()
    environment.update(
        {
            "HYPRCTL_LOG": str(log),
            "PATH": os.pathsep.join((str(bindir), environment["PATH"])),
        }
    )
    return environment, log


def run(root: Path, snippet: str, environment: dict[str, str]) -> subprocess.CompletedProcess:
    runner = root / "runner.lua"
    runner.write_text(
        f'dofile("{root}/hl_stub.lua")\nlocal actions = dofile("{ACTIONS}")\n{snippet}\n',
        encoding="utf-8",
    )
    return subprocess.run([LUA, str(runner)], env=environment, capture_output=True, text=True)


def test_actions_use_lua_config_dispatch_and_dot_option_paths():
    with tempfile.TemporaryDirectory(prefix="hyprland-actions-") as directory:
        root = Path(directory)
        environment, log = make_environment(root)

        result = run(
            root,
            """
            assert(actions.get_gap("outer") == "12")
            assert(actions.set_gap("outer", "23"))
            assert(actions.toggle_float())
            assert(actions.resize_active("900", "700"))
            assert(actions.center())
            assert(actions.focus_class("discord"))
            assert(actions.dpms("on"))
            """,
            environment,
        )
        assert result.returncode == 0, result.stderr
        lines = [line for line in log.read_text(encoding="utf-8").splitlines() if "getoption" not in line]
        assert lines == [
            '<eval><hl.config({ general = { gaps_out = 23 } })>',
            '<dispatch><hl.dsp.window.float({ action = "toggle" })>',
            '<dispatch><hl.dsp.window.resize({ x = 900, y = 700, relative = false })>',
            '<dispatch><hl.dsp.window.center()>',
            '<dispatch><hl.dsp.focus({ window = "class:discord" })>',
            '<dispatch><hl.dsp.dpms({ action = "enable" })>',
        ]
        assert "<-j><getoption><general.gaps_out>" in log.read_text(encoding="utf-8")


def test_actions_reject_values_that_could_escape_lua_expressions():
    with tempfile.TemporaryDirectory(prefix="hyprland-actions-reject-") as directory:
        root = Path(directory)
        environment, log = make_environment(root)
        result = run(
            root,
            """
            assert(not actions.focus_class('discord"); os.execute("false") --'))
            assert(not actions.set_gap("inner", "1; os.execute('false')"))
            assert(not actions.resize_active("-1", "900"))
            assert(not actions.set_gap("inner", "18446744073709551617"))
            assert(not actions.resize_active("18446744073709551617", "900"))
            assert(not actions.dpms("sideways"))
            """,
            environment,
        )
        assert result.returncode == 0, result.stderr
        assert not log.exists() or log.read_text(encoding="utf-8") == ""


def test_actions_clamp_gap_adjustments_at_both_boundaries():
    for current, delta, expected in (("0 0", "-5", "0"), ("1000 1000", "5", "1000")):
        with tempfile.TemporaryDirectory(prefix="hyprland-actions-gap-") as directory:
            root = Path(directory)
            environment, log = make_environment(root)
            environment["HYPRCTL_OPTION_VALUE"] = current
            result = run(root, f'assert(actions.adjust_gap("outer", "{delta}"))', environment)
            assert result.returncode == 0, result.stderr
            assert log.read_text(encoding="utf-8").splitlines() == [
                "<-j><getoption><general.gaps_out>",
                f"<eval><hl.config({{ general = {{ gaps_out = {expected} }} }})>",
            ]
