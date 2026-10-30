#!/usr/bin/env python3
"""pelicano profile and native-HorneroOS ownership guards.

Static contract tests: they read the chezmoi source, never apply it.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HOME = ROOT / "home"


def main() -> None:
    toml = (HOME / ".chezmoi.toml.tmpl").read_text(encoding="utf-8")
    assert 'eq $hostname "pelicano"' in toml
    # pelicano is personal but Docker stays opt-in (production laptop).
    pelicano_block = toml.split('eq $hostname "pelicano"', 1)[1].split("}}", 2)[0]
    assert "$personal = true" in toml
    assert "$docker = false" in pelicano_block or "$docker = false" in toml.split(
        'eq $hostname "pelicano"', 1)[1][:400]
    assert "horneroNative" in toml
    assert 'HORNERO_NATIVE' in toml

    ssh = (HOME / "private_dot_ssh/executable_config").read_text(encoding="utf-8")
    for host in ("hornero", "colibri", "pelicano"):
        assert f"Host {host} {host}.local" in ssh, host

    guarded = [
        "run_onchange_after_hornero-os-identity.sh.tmpl",
        "run_onchange_before_install-hornero-desktop.sh.tmpl",
        "run_onchange_before_install-sddm-with-theme.sh.tmpl",
        "run_onchange_before_install-zsh.sh.tmpl",
        "run_onchange_after_chsh.sh.tmpl",
    ]
    scripts = HOME / ".chezmoiscripts/linux"
    for name in guarded:
        text = (scripts / name).read_text(encoding="utf-8")
        assert ".horneroNative" in text, name
    print("pelicano/native contracts OK")


if __name__ == "__main__":
    main()
