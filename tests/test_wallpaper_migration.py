"""Exercise the generated wallpaper migration in an isolated fake HOME."""
from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / "home/.chezmoiscripts/linux/run_onchange_after_link-wallpapers.sh.tmpl"
OLD_BA_HASH = "f8614f3a103bd45c7f3609c7ec46300fb141d6b71bb0cc25f0338dfec36ce222"


def test_wallpaper_migration_removes_only_known_old_asset_and_exact_stale_links():
    with tempfile.TemporaryDirectory(prefix="hornero-wallpaper-migration-") as temp:
        base = Path(temp)
        home = base / "home"
        source_root = home / ".local/share/hornero/wallpapers"
        pictures = home / "Pictures/Wallpapers"
        source_root.mkdir(parents=True)

        old_ba = source_root / "buenos-aires-nocturno/buenos-aires-nocturno-01.jpg"
        old_ba.parent.mkdir(parents=True)
        old_bytes = b"synthetic legacy file used only by the test"
        old_ba.write_bytes(old_bytes)
        fixture_hash = hashlib.sha256(old_bytes).hexdigest()

        changed_pampa = source_root / "pampa/pampa-01.png"
        changed_pampa.parent.mkdir(parents=True)
        changed_pampa.write_bytes(b"user-modified file must survive")
        custom_pampa = pictures / "pampa/pampa-01.png"
        custom_pampa.parent.mkdir(parents=True)
        custom_pampa.write_bytes(b"a regular user-owned file must not be replaced")

        stale_link = pictures / "buenos-aires-nocturno/buenos-aires-nocturno-01.jpg"
        stale_link.parent.mkdir(parents=True)
        stale_link.symlink_to(old_ba)
        already_stale = pictures / "fin-del-mundo/beagle-blue-hour-01.jpg"
        already_stale.parent.mkdir(parents=True)
        already_stale.symlink_to(source_root / "fin-del-mundo/beagle-blue-hour-01.jpg")
        unrelated = pictures / "curated/user.jpg"
        unrelated.parent.mkdir(parents=True)
        unrelated_target = base / "external.jpg"
        unrelated_target.write_bytes(b"unrelated")
        unrelated.symlink_to(unrelated_target)

        config = base / "chezmoi.toml"
        config.write_text("[data]\nephemeral = false\n", encoding="utf-8")
        rendered = subprocess.run(
            [
                shutil.which("chezmoi") or str(Path.home() / ".local/bin/chezmoi"),
                "execute-template",
                "--config",
                str(config),
                "--file",
                str(TEMPLATE),
                "--source",
                str(ROOT),
                "--destination",
                str(home),
            ],
            check=True,
            capture_output=True,
            text=True,
        ).stdout.replace(OLD_BA_HASH, fixture_hash)
        script = base / "wallpapers.sh"
        script.write_text(rendered)

        environment = os.environ.copy()
        environment["HOME"] = str(home)
        subprocess.run(["bash", str(script)], check=True, capture_output=True, text=True, env=environment)

        assert not old_ba.exists(), "the fixed-data template render must retire the matching legacy photo"
        assert not stale_link.is_symlink()
        assert not already_stale.is_symlink()
        assert changed_pampa.read_bytes() == b"user-modified file must survive"
        assert custom_pampa.read_bytes() == b"a regular user-owned file must not be replaced"
        assert unrelated.is_symlink() and unrelated.resolve() == unrelated_target


if __name__ == "__main__":
    test_wallpaper_migration_removes_only_known_old_asset_and_exact_stale_links()
    print("PASS: wallpaper migration is checksum-limited and preserves user files")
