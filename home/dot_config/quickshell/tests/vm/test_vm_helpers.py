"""Unit tests for the graphical VM harness helpers.

Everything here runs without QEMU, KVM, or network access: PNG fixtures
are synthesized with the standard library and the harness scripts are
exercised through --dry-run and --help only.
"""

import hashlib
import os
import shutil
import struct
import subprocess
import sys
import zlib
from pathlib import Path

import pytest

VM_DIR = Path(__file__).resolve().parent
LIB_DIR = VM_DIR / "lib"
VERIFY_IMAGE = LIB_DIR / "verify-image.sh"
CHECK = LIB_DIR / "check_screenshot.py"
PPM_TO_PNG = LIB_DIR / "ppm_to_png.py"
SMOKE = VM_DIR / "scenarios" / "vm-smoke.sh"


def write_png(path, width, height, rows, color_type=2, filters=None):
    """Write an 8-bit non-interlaced PNG with selectable per-row filters."""

    def chunk(tag, data):
        body = struct.pack(">I", len(data)) + tag + data
        return body + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    assert filters is None or len(filters) == height
    raw = b"".join(
        bytes((filters[y] if filters else 0,)) + rows[y] for y in range(height)
    )
    header = struct.pack(">IIBBBBB", width, height, 8, color_type, 0, 0, 0)
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(raw))
        + chunk(b"IEND", b"")
    )


def gradient_rows(width, height):
    rows = []
    for y in range(height):
        rows.append(
            b"".join(
                bytes([(x * 255) // width, (y * 255) // height, 128])
                for x in range(width)
            )
        )
    return rows


def run_checker(*args):
    return subprocess.run(
        [sys.executable, str(CHECK), *args],
        capture_output=True,
        text=True,
        check=False,
    )


def test_blank_screenshot_fails(tmp_path):
    shot = tmp_path / "blank.png"
    write_png(shot, 64, 48, [bytes([30, 30, 30]) * 64] * 48)
    proc = run_checker("--min-bytes", "0", str(shot))
    assert proc.returncode == 1
    assert f"FAIL {shot}" in proc.stdout


def test_colorful_screenshot_passes(tmp_path):
    shot = tmp_path / "gradient.png"
    write_png(shot, 128, 72, gradient_rows(128, 72))
    proc = run_checker(str(shot))
    assert proc.returncode == 0
    assert f"PASS {shot}" in proc.stdout


def test_two_tone_screenshot_fails_color_floor(tmp_path):
    shot = tmp_path / "two.png"
    write_png(shot, 64, 48, [bytes([10, 10, 10]) * 32 + bytes([240, 240, 240]) * 32] * 48)
    proc = run_checker("--min-bytes", "0", str(shot))
    assert proc.returncode == 1
    assert "distinct colors" in proc.stdout


def test_color_floor_is_tunable(tmp_path):
    shot = tmp_path / "two.png"
    write_png(shot, 64, 48, [bytes([10, 10, 10]) * 32 + bytes([240, 240, 240]) * 32] * 48)
    proc = run_checker("--min-bytes", "0", "--min-colors", "2", str(shot))
    assert proc.returncode == 0


def test_sub_filtered_rows_decode(tmp_path):
    # grim-style encoders use Sub/Up/Paeth filters; a decoder that only
    # handles None rows would misread these as noise or stripes.
    width, height = 64, 48
    plain = [b"".join(bytes([x % 256, y % 256, 200]) for x in range(width)) for y in range(height)]
    encoded = []
    for row in plain:
        out, prev = bytearray(), (0, 0, 0)
        for i in range(0, len(row), 3):
            pixel = (row[i], row[i + 1], row[i + 2])
            out += bytes([(pixel[c] - prev[c]) & 0xFF for c in range(3)])
            prev = pixel
        encoded.append(bytes(out))
    shot = tmp_path / "sub.png"
    write_png(shot, width, height, encoded, filters=[1] * height)
    proc = run_checker("--min-bytes", "0", str(shot))
    assert proc.returncode == 0
    assert "colors=3072" in proc.stdout


def test_gray_screenshots_supported(tmp_path):
    shot = tmp_path / "gray.png"
    rows = [b"".join(bytes([(x * 255) // 64]) for x in range(64))] * 48
    write_png(shot, 64, 48, rows, color_type=0)
    proc = run_checker("--min-bytes", "0", str(shot))
    assert proc.returncode == 0


def test_truncated_file_is_an_error(tmp_path):
    good = tmp_path / "good.png"
    write_png(good, 32, 24, gradient_rows(32, 24))
    bad = tmp_path / "truncated.png"
    bad.write_bytes(good.read_bytes()[:100])
    proc = run_checker(str(bad))
    assert proc.returncode == 2
    assert f"ERROR {bad}" in proc.stdout


def test_missing_file_is_an_error(tmp_path):
    missing = tmp_path / "nope.png"
    proc = run_checker(str(missing))
    assert proc.returncode == 2


def test_non_png_is_an_error(tmp_path):
    text = tmp_path / "note.txt"
    text.write_text("not an image")
    proc = run_checker(str(text))
    assert proc.returncode == 2


def test_quiet_mode_suppresses_per_file_lines(tmp_path):
    shot = tmp_path / "gradient.png"
    write_png(shot, 64, 48, gradient_rows(64, 48))
    proc = run_checker("--quiet", str(shot))
    assert proc.returncode == 0
    assert proc.stdout == ""


def test_ppm_round_trip_passes_checker(tmp_path):
    width, height = 128, 72
    body = b"".join(
        b"".join(bytes([(x * 255) // width, (y * 255) // height, 128]) for x in range(width))
        for y in range(height)
    )
    source = tmp_path / "frame.ppm"
    source.write_bytes(b"P6\n128 72\n255\n" + body)
    converted = tmp_path / "frame.png"
    proc = subprocess.run(
        [sys.executable, str(PPM_TO_PNG), str(source), str(converted)],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0
    assert run_checker(str(converted)).returncode == 0


def test_ppm_rejects_bad_magic(tmp_path):
    source = tmp_path / "frame.ppm"
    source.write_bytes(b"P5\n4 4\n255\n" + bytes(16))
    proc = subprocess.run(
        [sys.executable, str(PPM_TO_PNG), str(source), str(tmp_path / "out.png")],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 1


def test_ppm_help_exits_zero():
    proc = subprocess.run(
        [sys.executable, str(PPM_TO_PNG), "--help"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0


def test_env_defaults_are_documented():
    script = (
        "source lib/env.sh && "
        "echo \"port=${VM_SSH_PORT} user=${VM_SSH_USER} mem=${VM_MEM} smp=${VM_SMP} fps=${VM_FPS}\" && "
        "type vm_ssh vm_ssh_bg vm_scp vm_running vm_ssh_ready vm_session_ready vm_shell_ready vm_hypr_env"
    )
    proc = subprocess.run(
        ["bash", "-c", f"cd {VM_DIR} && {script}"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "port=2222 user=hornero mem=3072 smp=2 fps=10" in proc.stdout


def test_env_overrides_are_honored():
    env = dict(os.environ, VM_SSH_PORT="2233", VM_MEM="1024")
    proc = subprocess.run(
        ["bash", "-c", "source lib/env.sh && echo \"${VM_SSH_PORT}/${VM_MEM}\""],
        capture_output=True,
        text=True,
        check=False,
        cwd=VM_DIR,
        env={**env, "PWD": str(VM_DIR)},
    )
    assert proc.returncode == 0, proc.stderr
    assert proc.stdout.strip() == "2233/1024"


def test_smoke_dry_run_is_coherent():
    proc = subprocess.run(
        ["bash", str(SMOKE), "--dry-run"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "dry-run: harness plan is coherent" in proc.stdout


def test_smoke_rejects_unknown_args():
    proc = subprocess.run(
        ["bash", str(SMOKE), "--boot-the-cloud"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 2


@pytest.mark.parametrize(
    "stage",
    ["boot.sh", "wait-ssh.sh", "provision.sh", "deploy-shell.sh",
     "start-session.sh", "screenshot.sh", "record.sh", "qemu-screenshot.sh"],
)
def test_stage_dry_runs_without_hypervisor(stage):
    proc = subprocess.run(
        ["bash", str(LIB_DIR / stage), "--dry-run"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "dry-run:" in proc.stdout


def _write_image_with_sidecar(tmp_path, payload):
    image = tmp_path / "image.qcow2"
    image.write_bytes(payload)
    digest = hashlib.sha256(payload).hexdigest()
    sidecar = tmp_path / "image.qcow2.SHA256"
    sidecar.write_text("%s  image.qcow2\n" % digest)
    return image, "file://%s" % sidecar


def _needs_verification_tools():
    return shutil.which("curl") and shutil.which("sha256sum")


def test_verify_image_accepts_matching_digest(tmp_path):
    if not _needs_verification_tools():
        pytest.skip("curl/sha256sum required")
    image, url = _write_image_with_sidecar(tmp_path, os.urandom(1024))
    proc = subprocess.run(
        ["bash", str(VERIFY_IMAGE), str(image), url],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "verified:" in proc.stdout


def test_verify_image_rejects_tampered_image(tmp_path):
    if not _needs_verification_tools():
        pytest.skip("curl/sha256sum required")
    image, url = _write_image_with_sidecar(tmp_path, os.urandom(1024))
    with image.open("ab") as handle:
        handle.write(b"tampered")
    proc = subprocess.run(
        ["bash", str(VERIFY_IMAGE), str(image), url],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 1
    assert "mismatch" in proc.stderr


def test_verify_image_fails_without_sidecar(tmp_path):
    if not _needs_verification_tools():
        pytest.skip("curl/sha256sum required")
    image = tmp_path / "image.qcow2"
    image.write_bytes(os.urandom(64))
    proc = subprocess.run(
        ["bash", str(VERIFY_IMAGE), str(image), "file:///nonexistent.SHA256"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 1


def test_verify_image_usage_is_exit_two():
    proc = subprocess.run(
        ["bash", str(VERIFY_IMAGE)],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 2


def test_boot_dry_run_mentions_verification():
    proc = subprocess.run(
        ["bash", str(LIB_DIR / "boot.sh"), "--dry-run"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "would verify" in proc.stdout
    assert "would grow" in proc.stdout


def test_provision_dry_run_mentions_disk_precheck():
    proc = subprocess.run(
        ["bash", str(LIB_DIR / "provision.sh"), "--dry-run"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "disk space" in proc.stdout
    assert "guest DNS" in proc.stdout


def test_deploy_dry_run_without_pin_stays_shell_local():
    proc = subprocess.run(
        ["bash", str(LIB_DIR / "deploy-shell.sh"), "--dry-run"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "working tree to guest" in proc.stdout
    assert "materialize the config pin" not in proc.stdout


def test_deploy_dry_run_with_pin_mentions_composition():
    env = dict(
        os.environ,
        HX_CONFIG_PIN="https://example.invalid/config 0123456789abcdef0123456789abcdef01234567",
    )
    proc = subprocess.run(
        ["bash", str(LIB_DIR / "deploy-shell.sh"), "--dry-run"],
        capture_output=True,
        text=True,
        check=False,
        env=env,
    )
    assert proc.returncode == 0, proc.stderr
    assert "materialize the config pin" in proc.stdout
    assert "validate the guest root with horneroctl" in proc.stdout
    assert "refuse a guest ulises-jeremias/dotfiles clone" in proc.stdout
    assert "factory defaults into the guest session" in proc.stdout
    assert "render factory wallpapers" in proc.stdout
    assert "harness Hyprland config over factory defaults" in proc.stdout


def test_harness_never_clones_dotfiles():
    # The guard in deploy-shell.sh names the repo in refusal messages;
    # what must never exist is a git operation pointing at it.
    for script in list(LIB_DIR.glob("*.sh")) + [SMOKE]:
        for line in script.read_text().splitlines():
            if "ulises-jeremias/dotfiles" in line:
                # Refusal messages may say "clone"; git operations may not.
                assert "git clone" not in line, (script.name, line)
                assert "fetch" not in line, (script.name, line)


def test_deploy_guards_guest_against_dotfiles_clone():
    body = (LIB_DIR / "deploy-shell.sh").read_text()
    assert ".git/config" in body
    assert "~/dotfiles" in body


def test_smoke_report_carries_composition_block():
    body = SMOKE.read_text()
    assert "composition" in body
    assert "shell_sha" in body
    assert "config_sha" in body
    assert "manifest" in body
    # Additive only: the existing report keys stay untouched.
    assert "git_sha" in body
    assert "screenshot_nonblank" in body


def test_provision_installs_native_plugin_deps():
    # deploy-shell.sh builds the QML plugin in the guest; its CMake
    # requires libqalculate, so provision.sh must install it.
    provision = (LIB_DIR / "provision.sh").read_text()
    assert "libqalculate" in provision


def test_provision_installs_shell_icon_font():
    # The shell's MaterialIcon ligatures need the Material Symbols font;
    # without it the guest renders icon names as text (proven in the
    # Preview 1 E2E: "sentiment_stressed" instead of the glyph).
    provision = (LIB_DIR / "provision.sh").read_text()
    assert "ttf-material-symbols-variable" in provision


def test_provision_repairs_guest_dns_when_broken():
    body = (LIB_DIR / "provision.sh").read_text()
    assert "getent hosts" in body
    assert "resolvectl dns eth0" in body
    # The repair must survive guest reboots (overlay reuse) as a .d/
    # override on the managing .network file: a standalone file loses to
    # cloud-init's 10-cloud-init-eth0.network and would be ignored.
    assert "Network File" in body
    assert "UseDNS=no" in body
    assert "10-harness-dns-override.conf" in body
    # The drop-in must apply via reload, never a networkd restart: a full
    # restart drops the slirp DHCP lease and never recovers (proven on a
    # filtered network: runtime pin resolves, post-restart probe fails).
    assert "networkctl reload" in body
    assert "restart systemd-networkd" not in body


def test_deploy_dry_run_mentions_plugin_build():
    proc = subprocess.run(
        ["bash", str(LIB_DIR / "deploy-shell.sh"), "--dry-run"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "native QML plugin" in proc.stdout


def test_session_dry_run_mentions_qml_import_path():
    proc = subprocess.run(
        ["bash", str(LIB_DIR / "start-session.sh"), "--dry-run"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    assert "QML2_IMPORT_PATH" in proc.stdout
