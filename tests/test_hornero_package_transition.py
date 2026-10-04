from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_aur_transition_removes_only_conflicting_legacy_packages():
    script = (
        ROOT
        / "home/.chezmoiscripts/linux/run_onchange_before_install-hornero-desktop.sh.tmpl"
    ).read_text()

    assert "pacman -Qq quickshell-git" in script
    assert "yay -R --noconfirm quickshell-git" in script
    assert "pacman -Qq lib-cava" in script
    assert "yay -R --noconfirm lib-cava" in script
    assert script.index("yay -R --noconfirm lib-cava") < script.index(
        "yay -S --noconfirm --needed"
    )
