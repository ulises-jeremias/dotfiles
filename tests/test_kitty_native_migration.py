#!/usr/bin/env python3
"""One-shot Kitty migration for native HorneroOS.

The Kitty configs retired in #347 are removed exactly once, only on
native HorneroOS, and only when the packaged replacement
(hornero-config >= 0.3.14) is actually installed. The migration stays
pending while the replacement is missing, records a marker when done,
and never touches files the user creates afterwards. Exercises the
real script through `chezmoi apply` against a miniature source in a
temporary destination with a stubbed `pacman`.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "home/.chezmoiscripts/linux/run_after_remove-retired-kitty.sh.tmpl"
REMOVE = ROOT / "home/.chezmoiremove"
TOML_TMPL = ROOT / "home/.chezmoi.toml.tmpl"

KITTY_FILES = ("kitty.conf", "hornero-dark.conf", "hornero-light.conf", "pampa.conf")


def chezmoi() -> str:
    return shutil.which("chezmoi") or str(Path.home() / ".local/bin/chezmoi")


def test_static_contracts() -> None:
    assert SCRIPT.exists(), "migration script missing"
    assert SCRIPT.name.startswith("run_after_"), \
        "migration must re-run until it succeeds (run_once would be consumed early)"
    text = SCRIPT.read_text(encoding="utf-8")
    assert 'get . "horneroNative"' in text
    assert '"linux-arch"' in text and '"linux-horneroos"' in text, \
        "detected native hosts report osid linux-horneroos, not linux-arch"
    assert "hornero-config" in text and "0.3.14" in text, \
        "removal must be gated on the packaged replacement version"
    assert "vercmp" in text
    assert ".chezmoi.destDir" in text, \
        "paths must resolve against chezmoi's destination, not $HOME"
    assert 'kitty-migration-done' in text, "completion marker missing"
    assert '[ -L "$kitty_dir" ]' in text, "must reject a symlinked parent directory"
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


def write_config(path: Path, native: bool, osid: str = "linux-horneroos") -> Path:
    path.write_text(
        "[data]\n"
        f"    horneroNative = {str(native).lower()}\n"
        f'    osid = "{osid}"\n',
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


def marker(dest: Path) -> Path:
    return dest / ".local/state/hornero/kitty-migration-done"


def test_apply_behaviour() -> None:
    with tempfile.TemporaryDirectory(prefix="kitty-migration-") as temp:
        base = Path(temp)
        source = base / "source"
        script_dest = source / ".chezmoiscripts/linux"
        script_dest.mkdir(parents=True)
        shutil.copy(SCRIPT, script_dest / SCRIPT.name)
        config = write_config(base / "native.toml", True)
        stub_new = base / "stub-new"
        make_pacman_stub(stub_new, "0.3.14-1")
        stub_none = base / "stub-none"
        make_pacman_stub(stub_none, None)

        # Replacement missing: pending, nothing removed, no marker.
        dest = base / "home-pending"
        personal = seed_kitty(dest)
        apply(source, dest, config, stub_none)
        for name in KITTY_FILES:
            assert (dest / ".config/kitty" / name).exists(), name
        assert not marker(dest).exists()

        # Replacement installed later: migration now runs, once.
        apply(source, dest, config, stub_new)
        for name in KITTY_FILES:
            assert not (dest / ".config/kitty" / name).exists(), name
        assert personal.read_text(encoding="utf-8") == "mine\n"
        assert marker(dest).exists()

        # A kitty.conf created afterwards is personal: it survives.
        recreated = dest / ".config/kitty/kitty.conf"
        recreated.write_text("my own config now\n", encoding="utf-8")
        apply(source, dest, config, stub_new)
        assert recreated.read_text(encoding="utf-8") == "my own config now\n"

        # Legacy host with the package present: guard keeps the files.
        dest = base / "home-legacy"
        seed_kitty(dest)
        legacy_config = write_config(base / "legacy.toml", False, osid="linux-arch")
        apply(source, dest, legacy_config, stub_new)
        for name in KITTY_FILES:
            assert (dest / ".config/kitty" / name).exists(), name
        assert not marker(dest).exists()

        # Symlinked kitty directory: nothing behind it is deleted.
        dest = base / "home-symlink"
        dest.mkdir()
        elsewhere = base / "elsewhere"
        elsewhere.mkdir()
        (elsewhere / "kitty.conf").write_text("behind symlink\n", encoding="utf-8")
        (dest / ".config").mkdir()
        (dest / ".config/kitty").symlink_to(elsewhere, target_is_directory=True)
        apply(source, dest, config, stub_new)
        assert (elsewhere / "kitty.conf").read_text(encoding="utf-8") == "behind symlink\n"
        assert not marker(dest).exists()

        # Outdated replacement: gated only where vercmp exists.
        if shutil.which("vercmp"):
            dest = base / "home-oldpkg"
            seed_kitty(dest)
            stub_old = base / "stub-old"
            make_pacman_stub(stub_old, "0.3.11-1")
            apply(source, dest, config, stub_old)
            for name in KITTY_FILES:
                assert (dest / ".config/kitty" / name).exists(), name
            assert not marker(dest).exists()


def main() -> None:
    test_static_contracts()
    test_apply_behaviour()
    print("kitty native migration OK")


if __name__ == "__main__":
    main()
