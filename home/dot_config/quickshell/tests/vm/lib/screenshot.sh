#!/usr/bin/env bash
# Capture a screenshot of the VM desktop with grim (Wayland screencopy).
# Usage: screenshot.sh [output.png] [--dry-run]

set -euo pipefail

VM_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/vm/lib/env.sh
# shellcheck disable=SC1091 # path resolves at runtime; use shellcheck -x to follow it
source "${VM_LIB_DIR}/env.sh"

OUT=""
for arg in "$@"; do
    case "${arg}" in
        --help)
            echo "usage: screenshot.sh [output.png] [--dry-run]"
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
OUT="${OUT:-${VM_ARTIFACTS_DIR}/screenshots/desktop.png}"

if vm_is_dry_run; then
    echo "dry-run: would capture grim screenshot to ${OUT}"
    exit 0
fi

vm_ssh_ready || {
    echo "error: VM SSH is not up" >&2
    exit 1
}

mkdir -p "$(dirname "${OUT}")"

# shellcheck disable=SC2016
vm_ssh "$(vm_hypr_env)
grim /tmp/vm-screenshot.png"
vm_scp "${VM_SSH_USER}@127.0.0.1:/tmp/vm-screenshot.png" "${OUT}"
echo "==> screenshot saved to ${OUT}"
