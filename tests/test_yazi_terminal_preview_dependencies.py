"""Verify Yazi's Alacritty preview dependency without installing packages."""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / "home/.chezmoiscripts/linux/run_onchange_before_install-yazi.sh.tmpl"


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
            str(TEMPLATE),
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
    script = destination / "install-yazi.sh"
    script.write_text(rendered, encoding="utf-8")
    return script


def test_alacritty_gets_ueberzugpp_but_native_terminals_do_not():
    with tempfile.TemporaryDirectory(prefix="yazi-preview-deps-") as temp:
        base = Path(temp)
        fake_bin = base / "bin"
        fake_bin.mkdir()
        log = base / "sudo.log"
        pacman = fake_bin / "pacman"
        pacman.write_text(
            "#!/bin/sh\n"
            'if [ "$1" = "-Qq" ] && [ "$2" = "alacritty" ]; then\n'
            '  [ "${ALACRITTY_INSTALLED:-0}" = "1" ] && exit 0\n'
            "  exit 1\n"
            "fi\n"
            'printf "pacman %s\\n" "$*" >> "$TEST_SUDO_LOG"\n',
            encoding="utf-8",
        )
        sudo = fake_bin / "sudo"
        sudo.write_text(
            '#!/bin/sh\nprintf "%s\\n" "$*" >> "$TEST_SUDO_LOG"\n',
            encoding="utf-8",
        )
        yay = fake_bin / "yay"
        yay.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
        ya = fake_bin / "ya"
        ya.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
        for executable in (pacman, sudo, yay, ya):
            executable.chmod(0o755)

        script = _render_script(base)
        for alacritty_installed in (False, True):
            log.unlink(missing_ok=True)
            environment = os.environ.copy()
            environment.update(
                {
                    "PATH": f"{fake_bin}:/usr/bin:/bin",
                    "HOME": str(base / "home"),
                    "TEST_SUDO_LOG": str(log),
                    "ALACRITTY_INSTALLED": "1" if alacritty_installed else "0",
                }
            )
            (base / "home").mkdir(exist_ok=True)
            subprocess.run(
                ["bash", str(script)],
                check=True,
                capture_output=True,
                text=True,
                env=environment,
                timeout=30,
            )
            calls = log.read_text(encoding="utf-8")
            assert ("ueberzugpp" in calls) is alacritty_installed

