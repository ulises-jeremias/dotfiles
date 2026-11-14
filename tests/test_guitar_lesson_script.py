"""Contract tests for the dots-guitar-lesson chezmoi sources.

Static checks only: they never touch PipeWire, the live desktop, or the
developer's account (per AGENTS.md). Live hardware verification is done on
the workstation with `dots-guitar-lesson doctor`.
"""

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "home/dot_local/bin/executable_dots-guitar-lesson"
PIPEWIRE_CONF = ROOT / "home/dot_config/pipewire/pipewire.conf.d/10-guitar-lesson.conf"
README = ROOT / "home/dot_config/guitar-lesson/README.md"


def test_script_source_exists_with_executable_chezmoi_name() -> None:
    assert SCRIPT.is_file()
    # chezmoi `executable_` prefix installs it as ~/.local/bin/dots-guitar-lesson
    assert SCRIPT.name == "executable_dots-guitar-lesson"
    assert SCRIPT.stat().st_mode & 0o111, "chezmoi source must keep the exec bit"


def test_script_is_valid_bash() -> None:
    result = subprocess.run(
        ["bash", "-n", str(SCRIPT)], capture_output=True, text=True, check=False
    )
    assert result.returncode == 0, result.stderr


def test_script_declares_graph_contract() -> None:
    text = SCRIPT.read_text(encoding="utf-8")
    for token in (
        "lesson.mix",  # virtual microphone for Discord
        "lesson.voicebus",  # independent voice gain bus
        "lesson.guitarbus",  # independent processed-guitar gain bus
        "gx_head_amp:in_0",  # Guitarix input (Scarlett Input 2 DI)
        "GUITAR_LESSON_PHONES",  # monitor sink override
        "set -euo pipefail",
    ):
        assert token in text, token
    for subcommand in ("start", "stop", "restart", "wire", "levels", "status", "doctor"):
        assert subcommand in text, subcommand


def test_script_uses_easy_options_house_style() -> None:
    """Historical dots-* convention: ## docs are the help, flags are easy."""
    text = SCRIPT.read_text(encoding="utf-8")
    assert "## Usage:" in text
    assert "## Options:" in text
    assert "@script.name" in text
    for flag in ("--help", "--start", "--stop", "--voice=", "--guitar=", "--quantum="):
        assert flag in text, flag


def test_help_runs_without_touching_audio(tmp_path: Path) -> None:
    env = {"HOME": str(tmp_path), "PATH": "/usr/bin:/bin"}
    result = subprocess.run(
        ["bash", str(SCRIPT), "--help"],
        capture_output=True, text=True, check=False, env=env,
    )
    assert result.returncode == 0, result.stderr
    assert "Usage:" in result.stdout
    assert "--start" in result.stdout


def test_pipewire_conf_prefers_48k_low_latency() -> None:
    text = PIPEWIRE_CONF.read_text(encoding="utf-8")
    assert "48000" in text
    assert "256" in text


def test_readme_documents_discord_contract() -> None:
    text = README.read_text(encoding="utf-8")
    assert "lesson.mix" in text
    assert "Direct Monitor" in text
