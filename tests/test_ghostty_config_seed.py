from pathlib import Path
import os
import subprocess
from tempfile import TemporaryDirectory


ROOT = Path(__file__).resolve().parents[1]
SEED_SCRIPT = ROOT / "scripts/seed-ghostty-config.sh"


def run_seed(source: Path, home: Path) -> None:
    env = os.environ.copy()
    env["HOME"] = str(home)
    env["XDG_CONFIG_HOME"] = str(home / ".config")
    env["HORNEROS_GHOSTTY_DEFAULT_CONFIG"] = str(source)
    subprocess.run([str(SEED_SCRIPT)], check=True, env=env, timeout=10)


def test_seeds_packaged_theme_only_when_user_config_is_missing_or_empty():
    packaged_default = "theme = Hornero Dynamic\nbackground-opacity = 0.88\n"
    with TemporaryDirectory(prefix="dotfiles-ghostty-seed-") as temporary:
        root = Path(temporary)
        source = root / "package-default.ghostty"
        source.write_text(packaged_default, encoding="utf-8")

        home = root / "home"
        run_seed(source, home)
        destination = home / ".config/ghostty/config.ghostty"
        assert destination.read_text(encoding="utf-8") == packaged_default

        destination.write_text("", encoding="utf-8")
        run_seed(source, home)
        assert destination.read_text(encoding="utf-8") == packaged_default

        personal_config = "theme = Catppuccin Mocha\n"
        destination.write_text(personal_config, encoding="utf-8")
        run_seed(source, home)
        assert destination.read_text(encoding="utf-8") == personal_config


def test_does_not_replace_an_existing_symlink():
    with TemporaryDirectory(prefix="dotfiles-ghostty-link-") as temporary:
        root = Path(temporary)
        source = root / "package-default.ghostty"
        source.write_text("theme = Hornero Dynamic\n", encoding="utf-8")
        home = root / "home"
        home.mkdir()
        target = root / "personal-config.ghostty"
        target.write_text("theme = Custom\n", encoding="utf-8")
        destination = home / ".config/ghostty/config.ghostty"
        destination.parent.mkdir(parents=True)
        destination.symlink_to(target)

        run_seed(source, home)

        assert destination.is_symlink()
        assert target.read_text(encoding="utf-8") == "theme = Custom\n"
