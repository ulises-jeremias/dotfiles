"""Verify Hyprland runtime calls select safe syntax for each config provider."""
from __future__ import annotations

import os
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "home/dot_local/bin/executable_hyprland-runtime"


def make_environment(root: Path, *, lua: bool) -> tuple[dict[str, str], Path]:
    config = root / "config"
    hypr = config / "hypr"
    hypr.mkdir(parents=True)
    if lua:
        (hypr / "hyprland.lua").write_text("-- staged test provider\n", encoding="utf-8")
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
    environment = os.environ.copy()
    environment.update(
        {
            "HOME": str(root / "home"),
            "XDG_CONFIG_HOME": str(config),
            "HYPRCTL_LOG": str(log),
            "PATH": os.pathsep.join((str(bindir), environment["PATH"])),
        }
    )
    return environment, log


def run(helper_args: list[str], environment: dict[str, str]) -> None:
    subprocess.run([str(HELPER), *helper_args], check=True, env=environment)


def test_runtime_adapter_uses_legacy_hyprlang_commands_without_lua_config():
    with tempfile.TemporaryDirectory(prefix="hyprland-runtime-legacy-") as directory:
        environment, log = make_environment(Path(directory), lua=False)

        run(["set-gap", "inner", "17"], environment)
        run(["toggle-float"], environment)
        run(["resize-active", "900", "700"], environment)
        run(["center"], environment)
        run(["focus-class", "discord"], environment)
        run(["dpms", "off"], environment)

        assert log.read_text(encoding="utf-8").splitlines() == [
            "<keyword><general:gaps_in><17>",
            "<dispatch><togglefloating>",
            "<dispatch><resizeactive><exact><900><700>",
            "<dispatch><centerwindow>",
            "<dispatch><focuswindow><class:discord>",
            "<dispatch><dpms><off>",
        ]


def test_runtime_adapter_uses_lua_eval_dispatch_and_dot_option_paths():
    with tempfile.TemporaryDirectory(prefix="hyprland-runtime-lua-") as directory:
        environment, log = make_environment(Path(directory), lua=True)

        run(["get-gap", "outer"], environment)
        run(["set-gap", "outer", "23"], environment)
        run(["toggle-float"], environment)
        run(["resize-active", "900", "700"], environment)
        run(["center"], environment)
        run(["focus-class", "discord"], environment)
        run(["dpms", "on"], environment)

        assert log.read_text(encoding="utf-8").splitlines() == [
            "<-j><getoption><general.gaps_out>",
            '<eval><hl.config({ general = { gaps_out = 23 } })>',
            '<dispatch><hl.dsp.window.float({ action = "toggle" })>',
            '<dispatch><hl.dsp.window.resize({ x = 900, y = 700, relative = false })>',
            '<dispatch><hl.dsp.window.center()>',
            '<dispatch><hl.dsp.focus({ window = "class:discord" })>',
            '<dispatch><hl.dsp.dpms({ action = "enable" })>',
        ]


def test_runtime_adapter_rejects_values_that_could_escape_lua_expressions():
    with tempfile.TemporaryDirectory(prefix="hyprland-runtime-reject-") as directory:
        environment, log = make_environment(Path(directory), lua=True)
        for command in (
            ["focus-class", 'discord"); os.execute("false") --'],
            ["set-gap", "inner", "1; os.execute('false')"],
            ["resize-active", "-1", "900"],
            ["set-gap", "inner", "18446744073709551617"],
            ["resize-active", "18446744073709551617", "900"],
        ):
            result = subprocess.run(
                [str(HELPER), *command], env=environment, capture_output=True, text=True
            )
            assert result.returncode == 2
        assert not log.exists() or log.read_text(encoding="utf-8") == ""


def test_runtime_adapter_clamps_gap_adjustments_at_both_boundaries():
    for lua in (False, True):
        for current, delta, expected in (("0 0", "-5", "0"), ("1000 1000", "5", "1000")):
            with tempfile.TemporaryDirectory(prefix="hyprland-runtime-gap-boundary-") as directory:
                environment, log = make_environment(Path(directory), lua=lua)
                environment["HYPRCTL_OPTION_VALUE"] = current
                run(["adjust-gap", "outer", delta], environment)

                if lua:
                    assert log.read_text(encoding="utf-8").splitlines() == [
                        "<-j><getoption><general.gaps_out>",
                        f"<eval><hl.config({{ general = {{ gaps_out = {expected} }} }})>",
                    ]
                else:
                    assert log.read_text(encoding="utf-8").splitlines() == [
                        "<-j><getoption><general:gaps_out>",
                        f"<keyword><general:gaps_out><{expected}>",
                    ]
