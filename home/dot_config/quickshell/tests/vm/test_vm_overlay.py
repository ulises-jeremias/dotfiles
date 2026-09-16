"""Overlay-boot regression tests (issue #12).

The verified base image must stay pristine: QEMU boots an ephemeral qcow2
overlay (backing file = base) so guest writes never dirty the cache and
every run is reproducible. Verification stays fail-closed on the base.

Everything here runs without QEMU, KVM, or network access: the harness
scripts are exercised through --dry-run plus static assertions on the
boot path.
"""

import subprocess
from pathlib import Path

VM_DIR = Path(__file__).resolve().parent
LIB_DIR = VM_DIR / "lib"
BOOT = LIB_DIR / "boot.sh"
ENV = LIB_DIR / "env.sh"


def _read_boot():
    return BOOT.read_text()


def _dry_run():
    proc = subprocess.run(
        ["bash", str(BOOT), "--dry-run"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert proc.returncode == 0, proc.stderr
    return proc.stdout


def test_overlay_default_is_exported_under_cache():
    proc = subprocess.run(
        ["bash", "-c", "source lib/env.sh && echo \"${VM_OVERLAY}\""],
        capture_output=True,
        text=True,
        check=False,
        cwd=VM_DIR,
    )
    assert proc.returncode == 0, proc.stderr
    overlay = proc.stdout.strip()
    assert overlay.endswith("cache/vm-overlay.qcow2"), overlay
    exported = subprocess.run(
        ["bash", "-c", "source lib/env.sh && export -p | grep -E '^declare -x VM_OVERLAY='"],
        capture_output=True,
        text=True,
        check=False,
        cwd=VM_DIR,
    )
    assert exported.returncode == 0, "VM_OVERLAY must be exported from env.sh"


def test_dry_run_creates_overlay_from_base():
    out = _dry_run()
    assert "would verify" in out
    assert "would create overlay" in out
    assert "with backing file" in out


def test_dry_run_grows_overlay_not_base():
    proc = subprocess.run(
        ["bash", "-c", "source lib/env.sh && bash lib/boot.sh --dry-run"],
        capture_output=True,
        text=True,
        check=False,
        cwd=VM_DIR,
        env={"PATH": "/usr/bin:/bin", "VM_OVERLAY": "/tmp/ovl-test.qcow2",
             "VM_CLOUD_IMAGE": "/tmp/base-test.qcow2"},
    )
    assert proc.returncode == 0, proc.stderr
    assert "would grow /tmp/ovl-test.qcow2" in proc.stdout
    assert "would grow /tmp/base-test.qcow2" not in proc.stdout


def test_dry_run_boots_overlay():
    out = _dry_run()
    assert "would start qemu with overlay" in out


def test_qemu_drive_uses_overlay():
    body = _read_boot()
    assert "file=${VM_OVERLAY},format=qcow2,if=virtio" in body
    assert "file=${VM_CLOUD_IMAGE},format=qcow2,if=virtio" not in body


def test_base_is_never_resized():
    body = _read_boot()
    assert 'qemu-img resize "${VM_CLOUD_IMAGE}"' not in body
    assert 'qemu-img resize "${VM_OVERLAY}"' in body


def test_overlay_created_with_base_as_backing_file():
    body = _read_boot()
    assert "qemu-img create -f qcow2 -F qcow2" in body
    assert '-b "${VM_CLOUD_IMAGE}" "${VM_OVERLAY}"' in body


def test_overlay_rebuilt_when_stale():
    body = _read_boot()
    assert "backing-filename" in body
    assert '"${VM_CLOUD_IMAGE}" -nt "${VM_OVERLAY}"' in body


def test_verify_stays_fail_closed_on_base():
    body = _read_boot()
    assert '"${VM_LIB_DIR}/verify-image.sh" "${VM_CLOUD_IMAGE}"' in body
    assert "${VM_CLOUD_IMAGE_SHA256_URL}" in body
    # A failed verification must drop the untrusted base and its overlay.
    assert 'rm -f "${VM_CLOUD_IMAGE}" "${VM_OVERLAY}"' in body


def test_qemu_advertises_guest_dns_over_dhcp():
    # The guest must not depend on the host LAN resolver: slirp proxies
    # guest DNS to the host's first nameserver, which may be LAN-only.
    body = _read_boot()
    assert "dns=${VM_GUEST_DNS}" in body


def test_missing_overlay_probe_does_not_abort_boot():
    # First boot has no overlay yet: qemu-img info exits 1, and with
    # `set -euo pipefail` that probe must not kill boot.sh before the
    # overlay is created.
    body = _read_boot()
    for line in body.splitlines():
        if "backing-filename" in line and "qemu-img info" in line:
            assert "|| true" in line, line
            return
    raise AssertionError("overlay backing probe not found in boot.sh")
