"""Static guarantees for the REAPER routing diagnostics (no audio devices needed).

Daily routing is native (PipeWire config + qpwgraph patchbay, see
test_music_studio_native.py). `reaper-studio` is diagnostics and recovery only;
live behaviour is checked on the workstation with `reaper-studio doctor`.
"""

from __future__ import annotations

import re
import shutil
import subprocess
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
BIN = ROOT / "home" / "dot_local" / "bin"
SHARE = ROOT / "home" / "dot_local" / "share" / "reaper-studio"
STUDIO = BIN / "executable_reaper-studio"
COMMON = SHARE / "common.sh"
SCRIPTS = [STUDIO, COMMON]


def test_routing_files_exist() -> None:
    for path in SCRIPTS:
        assert path.is_file(), f"missing {path.relative_to(ROOT)}"


@pytest.mark.parametrize("path", SCRIPTS, ids=lambda p: p.name)
def test_bash_syntax_is_valid(path: Path) -> None:
    subprocess.run(["bash", "-n", str(path)], check=True)


@pytest.mark.skipif(shutil.which("shellcheck") is None, reason="shellcheck not installed")
@pytest.mark.parametrize("path", SCRIPTS, ids=lambda p: p.name)
def test_shellcheck_is_clean(path: Path) -> None:
    subprocess.run(["shellcheck", "-x", str(path)], check=True)


def test_repo_naming_rule_avoids_the_retired_dots_token() -> None:
    # tests/test_hornero_source_contract.py bans this token in managed source.
    for path in SCRIPTS:
        assert "dots-" not in path.read_text(), path.name


def test_scripts_never_launch_or_depend_on_guitarix() -> None:
    # Comments may say Guitarix is not involved; executable lines must not use it.
    for path in SCRIPTS:
        code = "\n".join(line for line in path.read_text().splitlines() if not line.lstrip().startswith("#"))
        assert "guitarix" not in code.lower(), f"{path.name} must not run or reference Guitarix"
        assert "gx_head" not in code, f"{path.name} must not route through Guitarix ports"


def test_scripts_do_not_change_global_defaults_or_restart_services() -> None:
    for path in SCRIPTS:
        text = path.read_text()
        assert "set-default-sink" not in text and "set-default-source" not in text, path.name
        assert "systemctl" not in text, f"{path.name} must not restart services"
        assert "force-quantum" not in text, f"{path.name} must not change the global quantum"


def test_loopback_is_excluded_from_reaper_inputs() -> None:
    text = COMMON.read_text()
    assert "LOOPBACK_PORTS_RE='capture_AUX2|capture_AUX3'" in text
    assert 'MIC_IN="${SCARLETT_CARD}:capture_AUX0"' in text
    assert 'GUITAR_IN="${SCARLETT_CARD}:capture_AUX1"' in text


def test_doctor_checks_discord_bus_isolation_and_feedback() -> None:
    text = COMMON.read_text()
    assert "grep -Ev '^REAPER:out[34]$'" in text, "lesson mic may be fed only by REAPER out3/out4"
    assert "Discord Call output never reaches REAPER" in text
    for pair in ("out3 ${LESSON_IN}:input_FL", "out4 ${LESSON_IN}:input_FR",
                 "out5 ${PROGRAM_IN}:input_FL", "out6 ${PROGRAM_IN}:input_FR"):
        assert pair in text


def test_scripts_are_not_needed_for_daily_use() -> None:
    studio = STUDIO.read_text()
    assert not (BIN / "executable_reaper-lesson").exists(), "lesson mode is native now (REAPER Lesson Mic)"
    assert "pactl load-module" not in studio + COMMON.read_text(), "no runtime virtual devices"
    assert "-template" not in COMMON.read_text(), "REAPER opens its default template by itself"
    assert "doctor" in studio and "repair" in studio


def test_lesson_reascripts_never_record() -> None:
    on = (ROOT / "home/dot_config/REAPER/Scripts/Vocal Studio/Vocal Studio - Lesson monitoring on.lua").read_text()
    assert "Transport" not in on and "1013" not in on, "lesson must not start recording"
    assert "\"Backing Track\"" in on and "on = false" in on


def test_routing_scripts_never_save_a_project() -> None:
    text = STUDIO.read_text() + COMMON.read_text()
    assert re.search(r"Main_SaveProject", text) is None


def test_no_global_quantum_in_routing_scripts() -> None:
    text = COMMON.read_text()
    assert "PIPEWIRE_QUANTUM" not in text, "latency comes from the per-app jack.conf.d rule"
    assert "pipewire.conf.d" not in text
