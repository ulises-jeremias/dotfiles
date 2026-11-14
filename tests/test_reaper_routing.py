"""Static guarantees for the REAPER studio and lesson routing (no audio devices needed).

Live behaviour is checked on the workstation with `reaper-studio doctor` and
`reaper-lesson doctor`. These tests keep the safety rules from being edited away.
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
LESSON = BIN / "executable_reaper-lesson"
COMMON = SHARE / "common.sh"
SCRIPTS = [STUDIO, LESSON, COMMON]


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


def test_lesson_mic_is_fed_only_by_reaper_outputs() -> None:
    text = LESSON.read_text()
    # The feeder rule must reject everything except REAPER out1/out2.
    assert "grep -Ev '^REAPER:out[12]$'" in text
    assert "monitor|Discord|discord|Line4|capture_AUX|alsa_input|Line2" in text


def test_lesson_start_is_idempotent_and_stop_only_removes_its_own_modules() -> None:
    text = LESSON.read_text()
    assert "grep -qx \"$LESSON_SINK\"" in text, "bus creation must check before loading"
    assert "grep -qx \"$LESSON_MIC\"" in text, "virtual mic creation must check before loading"
    assert "pactl unload-module" in text
    # Stop matches modules by their names, never by numeric id.
    assert "awk -v s=\"$LESSON_MIC\"" in text


def test_lesson_arms_and_disarms_through_reascripts_without_recording() -> None:
    text = LESSON.read_text()
    assert "Lesson monitoring on.lua" in text and "Lesson monitoring off.lua" in text
    on = (ROOT / "home/dot_config/REAPER/Scripts/Vocal Studio/Vocal Studio - Lesson monitoring on.lua").read_text()
    assert "Transport" not in on and "1013" not in on and "1013," not in on, "lesson must not start recording"
    assert "\"Backing Track\"" in on and "on = false" in on


def test_reaper_scripts_refuse_to_touch_the_template_file() -> None:
    text = LESSON.read_text() + STUDIO.read_text() + COMMON.read_text()
    assert "reaper -nosplash -template" in COMMON.read_text(), "REAPER must open the template, not the file"
    assert re.search(r"Main_SaveProject", text) is None, "routing scripts must never save a project"


def test_reaper_is_launched_with_a_per_process_low_latency_quantum() -> None:
    text = COMMON.read_text()
    assert 'PIPEWIRE_QUANTUM="${REAPER_QUANTUM:-256}/48000"' in text
    assert "pipewire.conf.d" not in text, "no persistent PipeWire configuration"
