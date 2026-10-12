import os
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLAY = ROOT / "bin/play"


def run_play(tmp_path: Path, *args: str, window_manager: str | None = None):
    fake_bin = tmp_path / "bin"
    fake_bin.mkdir()
    docker = fake_bin / "docker"
    docker.write_text(
        "#!/usr/bin/env bash\n"
        "if [[ \"$1 $2\" == \"compose version\" ]]; then exit 0; fi\n"
        "printf '%s\\n' \"${WINDOW_MANAGER:-unset}\" > \"$PLAY_CAPTURE\"\n"
        "printf '%s\\n' \"$*\" > \"${PLAY_CAPTURE}.args\"\n",
        encoding="utf-8",
    )
    docker.chmod(0o755)
    capture = tmp_path / "capture.txt"
    env = os.environ.copy()
    env["PATH"] = f"{fake_bin}{os.pathsep}{env['PATH']}"
    env["PLAY_CAPTURE"] = str(capture)
    env["HOME"] = str(tmp_path)
    if window_manager is None:
        env.pop("WINDOW_MANAGER", None)
    else:
        env["WINDOW_MANAGER"] = window_manager

    result = subprocess.run(
        [str(PLAY), *args, f"--log-file={tmp_path / 'play.log'}"],
        cwd=ROOT,
        env=env,
        text=True,
        capture_output=True,
        check=False,
    )
    return result, capture


def test_play_passes_hyprland_default_into_compose(tmp_path):
    result, capture = run_play(tmp_path, "--provision")

    assert result.returncode == 0, result.stderr
    assert capture.read_text().strip() == "hyprland"
    assert (tmp_path / "capture.txt.args").read_text().strip() == (
        "compose run --rm vagrant vagrant provision"
    )


def test_play_passes_explicit_desktop_choice_into_compose(tmp_path):
    result, capture = run_play(tmp_path, "--wm=plasma", "--provision")

    assert result.returncode == 0, result.stderr
    assert capture.read_text().strip() == "plasma"


def test_play_rejects_unlisted_desktop_names(tmp_path):
    result, capture = run_play(tmp_path, "--wm=../../outside", "--provision")

    assert result.returncode == 2
    assert "Unsupported desktop" in result.stderr
    assert not capture.exists()


def test_vagrant_desktop_default_and_documentation_agree():
    vagrantfile = (ROOT / "playground/Vagrantfile").read_text()
    compose = (ROOT / "playground/compose.yml").read_text()
    guide = (ROOT / "playground/README.md").read_text()
    play = PLAY.read_text()

    assert "ENV['WINDOW_MANAGER'] || 'hyprland'" in vagrantfile
    assert "WINDOW_MANAGER" in compose
    assert 'wm="${wm:-${WINDOW_MANAGER:-hyprland}}"' in play
    assert "`hyprland` (default)" in guide
    assert "`plasma` (default)" not in guide
