"""Packaging validation: hornero-shell Arch PKGBUILD consistency.

Static checks run anywhere with stdlib only. Tool-backed checks skip
cleanly when makepkg/bash are unavailable (e.g. Ubuntu CI).
"""
import re
import shutil
import subprocess
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
PKGDIR = ROOT / "packaging"
PKGBUILD = PKGDIR / "PKGBUILD"
README = PKGDIR / "README.md"

REQUIRED_VARS = ("pkgname", "pkgver", "pkgrel", "pkgdesc", "arch", "url",
                 "license", "depends", "makedepends", "source", "sha256sums")


def test_pkgbuild_required_variables():
    text = PKGBUILD.read_text()
    missing = [v for v in REQUIRED_VARS
               if not re.search(rf"^{v}=", text, re.MULTILINE)]
    assert not missing, f"PKGBUILD missing variables: {missing}"


def test_pkgbuild_build_and_package_functions():
    text = PKGBUILD.read_text()
    assert re.search(r"^build\(\)", text, re.MULTILINE), "build() missing"
    assert re.search(r"^package\(\)", text, re.MULTILINE), "package() missing"


def test_pkgbuild_license_files_exist():
    text = PKGBUILD.read_text()
    for name in ("LICENSE.GPL-3.0", "NOTICE"):
        assert (ROOT / name).is_file(), f"{name} missing at repo root"
        assert name in text, f"{name} not installed by package()"


def test_documented_layout_matches_cmake():
    cmake = (ROOT / "CMakeLists.txt").read_text()
    readme = README.read_text()
    pairs = (("/etc/xdg/quickshell/hornero", "INSTALL_QSCONFDIR"),
             ("/usr/lib/hornero", "INSTALL_LIBDIR"),
             ("/usr/lib/qt6/qml", "INSTALL_QMLDIR"))
    for path, cmake_var in pairs:
        assert path in readme, f"{path} not documented in packaging/README.md"
        assert cmake_var in cmake, f"{cmake_var} missing from CMakeLists.txt"


def test_documented_qml_modules_exist():
    readme = README.read_text()
    for uri in ("Hornero", "Hornero.Internal", "Hornero.Models",
                "Hornero.Services"):
        assert uri in readme, f"{uri} not documented in packaging/README.md"


def test_quickshell_dependency_is_stable_release():
    # The shell must depend on the official Arch package, not the AUR VCS
    # package: only long-stable Quickshell QML modules are used and no
    # Quickshell C++ API is linked (verified against quickshell 0.3.1).
    text = PKGBUILD.read_text()
    match = re.search(r"^depends=\((.*?)\)", text, re.MULTILINE | re.DOTALL)
    assert match, "depends array not found"
    depends = match.group(1)
    assert "quickshell-git" not in depends, "must not force the VCS package"
    assert re.search(r"'quickshell>=[0-9.]+'", depends), (
        "must pin a minimum official quickshell version"
    )


def test_printsrcinfo_parses():
    if shutil.which("makepkg") is None:
        pytest.skip("makepkg not available")
    proc = subprocess.run(["makepkg", "--printsrcinfo"], cwd=PKGDIR,
                          capture_output=True, text=True, timeout=120)
    assert proc.returncode == 0, proc.stderr
    assert "pkgname = hornero-shell" in proc.stdout


def test_bash_syntax():
    if shutil.which("bash") is None:
        pytest.skip("bash not available")
    proc = subprocess.run(["bash", "-n", str(PKGBUILD)],
                          capture_output=True, text=True, timeout=60)
    assert proc.returncode == 0, proc.stderr


def test_no_nested_makepkg_checkout():
    # packaging/hornero-shell/ is the named git-source checkout dir
    # ($srcdir/<name> for "<name>::git+..."); it is gitignored and must
    # never be committed. Guard both the working tree and the index.
    nested = PKGDIR / "hornero-shell"
    tracked = []
    if shutil.which("git") is not None:
        proc = subprocess.run(["git", "ls-files", "packaging/hornero-shell"],
                              cwd=ROOT, capture_output=True, text=True,
                              timeout=60)
        if proc.returncode == 0:
            tracked = [l for l in proc.stdout.splitlines() if l.strip()]
    assert not tracked, f"nested checkout tracked in git: {tracked[:5]}"
    if nested.exists():
        assert any("hornero-shell" in line
                   for line in (PKGDIR / ".gitignore").read_text().splitlines()), (
            "packaging/hornero-shell/ exists on disk but is not gitignored"
        )


def test_welcome_desktop_entry_packaged():
    desktop = ROOT / "assets" / "hornero-welcome.desktop"
    assert desktop.is_file(), "assets/hornero-welcome.desktop missing"
    entries = {}
    for line in desktop.read_text().splitlines():
        if "=" in line and not line.startswith("["):
            key, _, value = line.partition("=")
            entries[key.strip()] = value.strip()
    assert entries.get("Type") == "Application"
    assert entries.get("Name") == "Hornero Welcome"
    assert entries.get("Exec") == "horneroctl welcome open"
    assert entries.get("NoDisplay") == "false"
    assert "Settings" in entries.get("Categories", "")
    cmake = (ROOT / "CMakeLists.txt").read_text()
    assert "assets/hornero-welcome.desktop" in cmake
    assert "share/applications" in cmake
