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


def test_shell_package_floor_includes_terminal_settings_pane():
    script = (
        ROOT
        / "home/.chezmoiscripts/linux/run_onchange_before_install-hornero-desktop.sh.tmpl"
    ).read_text()

    assert 'readonly min_hornero_shell_version="1.2.13-1"' in script
    assert "required for Settings focus and terminal selection" in script


def test_horneroctl_floor_includes_terminal_inventory_for_settings():
    script = (
        ROOT
        / "home/.chezmoiscripts/linux/run_onchange_before_install-hornero-desktop.sh.tmpl"
    ).read_text()

    assert 'readonly min_horneroctl_version="0.2.0_preview17-1"' in script
    assert "required for Settings terminal inventory" in script


def test_dotfiles_do_not_override_hornero_gtk_appearance():
    gtk3 = (ROOT / "home/dot_config/gtk-3.0/settings.ini").read_text()
    gtk2 = (ROOT / "home/dot_gtkrc-2.0.tmpl").read_text()

    for contents in (gtk3, gtk2):
        assert "gtk-theme-name" not in contents
        assert "gtk-icon-theme-name" not in contents
    assert "gtk-application-prefer-dark-theme" not in gtk3
    assert "Orchis" not in gtk3 + gtk2
    assert '{{ .chezmoi.homeDir }}/.gtkrc-2.0.mine' in gtk2
    assert '/home/user/' not in gtk2


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
