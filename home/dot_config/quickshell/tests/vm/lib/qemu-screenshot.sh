#!/usr/bin/env bash
# Capture the VM framebuffer straight from QEMU (HMP screendump over the
# monitor socket). Works even when Wayland screencopy clients (grim,
# wf-recorder) hang on virtio-vga.
# Usage: qemu-screenshot.sh [output.png] [--dry-run]

set -euo pipefail

VM_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/vm/lib/env.sh
# shellcheck disable=SC1091 # path resolves at runtime; use shellcheck -x to follow it
source "${VM_LIB_DIR}/env.sh"

OUT=""
for arg in "$@"; do
    case "${arg}" in
        --help)
            echo "usage: qemu-screenshot.sh [output.png] [--dry-run]"
            exit 0
            ;;
        --dry-run)
            export VM_DRY_RUN=1
            ;;
        *)
            OUT="${arg}"
            ;;
    esac
done
OUT="${OUT:-${VM_ARTIFACTS_DIR}/screenshots/qemu-desktop.png}"

if vm_is_dry_run; then
    echo "dry-run: would dump the QEMU framebuffer to ${OUT}"
    exit 0
fi

MONITOR="${VM_ARTIFACTS_DIR}/monitor.sock"
[[ -S "${MONITOR}" ]] || {
    echo "error: QEMU monitor socket not found at ${MONITOR}" >&2
    exit 1
}

mkdir -p "$(dirname "${OUT}")"
PPM="$(mktemp)"
python3 - "${MONITOR}" "${PPM}" << 'PYEOF'
import socket, sys

sock_path, ppm_path = sys.argv[1], sys.argv[2]
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.settimeout(10)
sock.connect(sock_path)
sock.recv(65536)  # banner
sock.sendall(b"screendump " + ppm_path.encode() + b"\n")
sock.close()
PYEOF

[[ -s "${PPM}" ]] || {
    echo "error: QEMU did not produce the screendump" >&2
    rm -f "${PPM}"
    exit 1
}
python3 "${VM_LIB_DIR}/ppm_to_png.py" "${PPM}" "${OUT}"
rm -f "${PPM}"
echo "==> QEMU screenshot saved to ${OUT}"
