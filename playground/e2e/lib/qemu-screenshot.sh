#!/usr/bin/env bash
# Capture the VM framebuffer straight from QEMU (HMP screendump).
# Works even when Wayland screencopy clients (grim / wf-recorder) hang,
# e.g. with render-hooking plugins loaded on virtio-vga.
# Usage: qemu-screenshot.sh [output.png]

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

out="${1:-${E2E_ARTIFACTS_DIR}/screenshots/qemu-desktop.png}"
mkdir -p "$(dirname "${out}")"

MONITOR="${E2E_ARTIFACTS_DIR}/monitor.sock"
PPM="/tmp/e2e-qemu-frame.ppm"

[[ -S ${MONITOR} ]] || {
	echo "error: QEMU monitor socket not found at ${MONITOR}" >&2
	exit 1
}

python3 - "$MONITOR" "$PPM" << 'PYEOF'
import socket, sys, time

sock_path, ppm_path = sys.argv[1], sys.argv[2]
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(10)
s.connect(sock_path)
time.sleep(0.5)
s.recv(65536)  # banner
s.sendall(b'screendump ' + ppm_path.encode() + b'\n')
time.sleep(1.5)
s.close()
PYEOF

[[ -s ${PPM} ]] || {
	echo "error: QEMU did not produce the screendump" >&2
	exit 1
}
magick "${PPM}" "${out}"
rm -f "${PPM}"
echo "==> QEMU screenshot saved to ${out}"
