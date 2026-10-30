#!/usr/bin/env python3
"""One-time Kitty migration for native HorneroOS.

The Kitty configs retired in #347 are removed exactly once, only on
native HorneroOS, and only when the packaged replacement
(hornero-config >= 0.3.14) is actually installed. Exercises the real
script through `chezmoi apply` against a miniature source in a
temporary HOME with a stubbed `pacman`.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "home/.chezmoiscripts/linux/run_once_after_remove-retired-kitty.sh.tmpl"
REMOVE = ROOT / "home/.chezmoiremove"
TOML_TMPL = ROOT / "home/.chezmoi.toml.tmpl"

KITTY_FILES = ("kitty.conf", "hornero-dark.conf", "hornero-light.conf", "pampa.conf")


def chezmoi() -> str:
    return shutil.which("chezmoi") or str(Path.home() / ".local/bin/chezmoi")


def test_static_contracts() -> None:
    assert SCRIPT.exists(), "migration script missing"
    assert SCRIPT.name.startswith("run_once_after_"), \
        "migration must be one-time (run_once), not a persistent removal"
    text = SCRIPT.read_text(encoding="utf-8")
    assert 'get . "horneroNative"' in text
    assert '"linux-arch"' in text
    assert "hornero-config" in text and "0.3.14" in text, \
        "removal must be gated on the packaged replacement version"
    assert "vercmp" in text
    assert "[ ! -L " in text, "must never delete through a symlink"
    for name in KITTY_FILES:
        assert name in text, name

    entries = [
        line.strip()
        for line in REMOVE.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.strip().startswith("#")
    ]
    assert not any("kitty" in entry for entry in entries), \
        "kitty must not be a persistent .chezmoiremove entry"

    toml = TOML_TMPL.read_text(encoding="utf-8")
    assert 'eq (env "HORNERO_NATIVE") "1"' in toml, \
        "native opt-in must require the exact value 1 (not any non-empty value)"


def write_config(path: Path, native: bool) -> Path:
    path.write_text(
        "[data]\n"
        f"    horneroNative = {str(native).lower()}\n"
        '    osid = "linux-arch"\n',
        encoding="utf-8",
    )
    return path


def make_pacman_stub(stub_dir: Path, version: str | None) -> None:
    stub_dir.mkdir(parents=True, exist_ok=True)
    if version is None:
        body = "#!/bin/sh\nexit 1\n"
    else:
        body = f'#!/bin/sh\necho "hornero-config {version}"\n'
    stub = stub_dir / "pacman"
    stub.write_text(body, encoding="utf-8")
    stub.chmod(0o755)


def apply(source: Path, dest: Path, config: Path, stub_dir: Path) -> None:
    env = dict(
        os.environ,
        HOME=str(dest),
        XDG_CONFIG_HOME=str(dest / ".config"),
        PATH=f"{stub_dir}:{os.environ['PATH']}",
    )
    subprocess.run(
        [chezmoi(), "apply", "--source", str(source),
         "--destination", str(dest), "--config", str(config), "--force"],
        capture_output=True, text=True, check=True, env=env,
    )


def seed_kitty(dest: Path) -> Path:
    kitty_dir = dest / ".config/kitty"
    kitty_dir.mkdir(parents=True, exist_ok=True)
    for name in KITTY_FILES:
        (kitty_dir / name).write_text("stale override\n", encoding="utf-8")
    personal = kitty_dir / "personal-notes.txt"
    personal.write_text("mine\n", encoding="utf-8")
    return personal


def test_apply_behaviour() -> None:
    with tempfile.TemporaryDirectory(prefix="kitty-migration-") as temp:
        base = Path(temp)
        source = base / "source"
        script_dest = source / ".chezmoiscripts/linux"
        script_dest.mkdir(parents=True)
        shutil.copy(SCRIPT, script_dest / SCRIPT.name)

        # Native + replacement installed: removed once, then never again.
        dest = base / "home-native"
        personal = seed_kitty(dest)
        stub = base / "stub-new"
        make_pacman_stub(stub, "0.3.14-1")
        config = write_config(base / "native.toml", True)
        apply(source, dest, config, stub)
        for name in KITTY_FILES:
            assert not (dest / ".config/kitty" / name).exists(), name
        assert personal.read_text(encoding="utf-8") == "mine\n"
        recreated = dest / ".config/kitty/kitty.conf"
        recreated.write_text("my own config now\n", encoding="utf-8")
        apply(source, dest, config, stub)
        assert recreated.read_text(encoding="utf-8") == "my own config now\n", \
            "one-time migration must not delete a later personal kitty.conf"

        # Native but replacement missing: nothing removed.
        dest = base / "home-native-nopkg"
        seed_kitty(dest)
        stub = base / "stub-none"
        make_pacman_stub(stub, None)
        apply(source, dest, config, stub)
        for name in KITTY_FILES:
            assert (dest / ".config/kitty" / name).exists(), name

        # Legacy host with the package present: guard keeps the files.
        dest = base / "home-legacy"
        seed_kitty(dest)
        legacy_config = write_config(base / "legacy.toml", False)
        apply(source, dest, legacy_config, base / "stub-new")
        for name in KITTY_FILES:
            assert (dest / ".config/kitty" / name).exists(), name


def main() -> None:
    test_static_contracts()
    test_apply_behaviour()
    print("kitty native migration OK")


if __name__ == "__main__":
    main()
