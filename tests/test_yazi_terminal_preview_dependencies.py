"""Verify Yazi's Alacritty preview dependency without installing packages."""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PREVIEW_TEMPLATE = ROOT / "home/.chezmoiscripts/run_after_install-yazi-preview-helper.sh.tmpl"


def _render_script(destination: Path) -> Path:
    chezmoi = shutil.which("chezmoi") or str(Path.home() / ".local/bin/chezmoi")
    config = destination / "chezmoi.toml"
    config.write_text('[data]\nosid = "linux-arch"\n', encoding="utf-8")
    rendered = subprocess.run(
        [
            chezmoi,
            "execute-template",
            "--config",
            str(config),
            "--file",
            str(PREVIEW_TEMPLATE),
            "--source",
            str(ROOT),
            "--destination",
            str(destination / "home"),
        ],
        check=True,
        capture_output=True,
        text=True,
        timeout=30,
    ).stdout
    script = destination / "install-yazi-preview-helper.sh"
    script.write_text(rendered, encoding="utf-8")
    return script


def _run(script: Path, fake_bin: Path, base: Path, log: Path, **state: str) -> None:
    environment = os.environ.copy()
    environment.update(
        {
            "PATH": f"{fake_bin}:/usr/bin:/bin",
            "HOME": str(base / "home"),
            "TEST_SUDO_LOG": str(log),
            **state,
        }
    )
    subprocess.run(
        ["bash", str(script)],
        check=True,
        capture_output=True,
        text=True,
        env=environment,
        timeout=30,
    )


def _fake_commands(fake_bin: Path) -> None:
    fake_bin.mkdir()
    pacman = fake_bin / "pacman"
    pacman.write_text(
        "#!/bin/sh\n"
        'if [ "$1" = "-Qq" ] && [ "$2" = "alacritty" ]; then\n'
        '  [ "${ALACRITTY_INSTALLED:-0}" = "1" ] && exit 0\n'
        "  exit 1\n"
        "fi\n"
        'if [ "$1" = "-Qq" ] && [ "$2" = "ueberzugpp" ]; then\n'
        '  [ "${UEBERZUGPP_INSTALLED:-0}" = "1" ] && exit 0\n'
        "  exit 1\n"
        "fi\n"
        'printf "pacman %s\\n" "$*" >> "$TEST_SUDO_LOG"\n',
        encoding="utf-8",
    )
    sudo = fake_bin / "sudo"
    sudo.write_text(
        '#!/bin/sh\nprintf "%s\\n" "$*" >> "$TEST_SUDO_LOG"\n', encoding="utf-8"
    )
    for executable in (pacman, sudo):
        executable.chmod(0o755)


def test_later_alacritty_install_is_detected_on_the_next_apply():
    with tempfile.TemporaryDirectory(prefix="yazi-preview-deps-") as temp:
        base = Path(temp)
        fake_bin = base / "bin"
        _fake_commands(fake_bin)
        log = base / "sudo.log"
        script = _render_script(base)

        # First apply is Kitty/Ghostty-only: no optional helper is installed.
        _run(script, fake_bin, base, log, ALACRITTY_INSTALLED="0")
        assert not log.exists()

        # Alacritty is installed out of band; the unchanged run_after script
        # runs again on the next apply and adds the Wayland preview adapter.
        _run(
            script,
            fake_bin,
            base,
            log,
            ALACRITTY_INSTALLED="1",
            UEBERZUGPP_INSTALLED="0",
        )
        assert "pacman -S --noconfirm --needed ueberzugpp" in log.read_text(
            encoding="utf-8"
        )


def test_existing_ueberzugpp_does_not_prompt_for_install():
    with tempfile.TemporaryDirectory(prefix="yazi-preview-installed-") as temp:
        base = Path(temp)
        fake_bin = base / "bin"
        _fake_commands(fake_bin)
        log = base / "sudo.log"
        script = _render_script(base)

        _run(
            script,
            fake_bin,
            base,
            log,
            ALACRITTY_INSTALLED="1",
            UEBERZUGPP_INSTALLED="1",
        )
        assert not log.exists()
