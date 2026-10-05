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


def test_shell_package_floor_includes_single_owner_preset_fix():
    script = (
        ROOT
        / "home/.chezmoiscripts/linux/run_onchange_before_install-hornero-desktop.sh.tmpl"
    ).read_text()

    assert 'readonly min_hornero_shell_version="1.2.2-1"' in script


def test_e2e_provisioner_uses_arch_cava_without_broad_overwrite():
    script = (ROOT / "playground/e2e/lib/provision.sh").read_text()
    readme = (ROOT / "playground/e2e/README.md").read_text()

    assert "pacman -Qq lib-cava" in script
    assert "sudo pacman -R --noconfirm ${packages}" in script
    assert 'e2e_ssh "sudo pacman -Syu --noconfirm --needed ${PACMAN_PKGS}"' in script
    assert "--overwrite" not in script
    assert "libcava'" not in script
    assert "chaotic.cx" not in script
    assert "chaotic-mirrorlist" not in script
    assert "Chaotic-AUR" not in readme
