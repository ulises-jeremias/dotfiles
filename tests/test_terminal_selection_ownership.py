#!/usr/bin/env python3
"""Ensure chezmoi does not reset Hornero's selected terminal association."""

from pathlib import Path
import shutil
import subprocess
from tempfile import TemporaryDirectory


ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    chezmoi = shutil.which("chezmoi")
    if chezmoi is None:
        raise SystemExit("chezmoi is required for this integration test")

    for terminal in ("ghostty", "alacritty"):
        with TemporaryDirectory(prefix="dotfiles-terminal-selection-") as temp:
            base = Path(temp)
            destination = base / "home"
            helpers = destination / ".config/xfce4/helpers.rc"
            helpers.parent.mkdir(parents=True)
            helpers.write_text(
                f"TerminalEmulator={terminal}\n",
                encoding="utf-8",
            )
            config = base / "config.toml"
            config.write_text(
                """[data]
docker = false
e2e = false
ephemeral = false
headless = false
hostname = "fixture"
osid = "linux-arch"
personal = false
gitconfig = { user = { name = "Fixture", email = "fixture@example.invalid" } }
""",
                encoding="utf-8",
            )
            command = [
                chezmoi,
                "--source",
                str(ROOT),
                "--config",
                str(config),
                "--config-format",
                "toml",
                "--destination",
                str(destination),
                "--cache",
                str(base / "cache"),
                "--persistent-state",
                str(base / "state"),
                "apply",
                "--force",
                "--exclude=scripts",
            ]
            subprocess.run(
                command,
                cwd=base,
                check=True,
                capture_output=True,
                text=True,
                timeout=120,
            )
            expected = f"TerminalEmulator={terminal}\n"
            actual = helpers.read_text(encoding="utf-8")
            if actual != expected:
                raise AssertionError(
                    f"chezmoi changed {terminal} selection: {actual!r}"
                )
            print(f"PASS: chezmoi preserves {terminal} terminal selection")


if __name__ == "__main__":
    main()
