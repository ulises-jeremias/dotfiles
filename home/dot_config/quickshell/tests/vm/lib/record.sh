#!/usr/bin/env bash
# Record the VM desktop with wf-recorder (Wayland screencopy).
# Usage: record.sh {start [output.mp4] | stop | status | fetch [output.mp4]} [--dry-run]
#
# The recorder must be stopped with SIGINT so it finalizes the file;
# SIGTERM leaves a truncated recording.

set -euo pipefail

VM_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/vm/lib/env.sh
# shellcheck disable=SC1091 # path resolves at runtime; use shellcheck -x to follow it
source "${VM_LIB_DIR}/env.sh"

CMD="status"
OUT=""
for arg in "$@"; do
    case "${arg}" in
        --help)
            echo "usage: record.sh {start [output.mp4] | stop | status | fetch [output.mp4]} [--dry-run]"
            exit 0
            ;;
        --dry-run)
            export VM_DRY_RUN=1
            ;;
        start | stop | status | fetch)
            CMD="${arg}"
            ;;
        *)
            OUT="${arg}"
            ;;
    esac
done

if vm_is_dry_run; then
    echo "dry-run: would run recorder command '${CMD}' ${OUT}"
    exit 0
fi

vm_ssh_ready || {
    echo "error: VM SSH is not up" >&2
    exit 1
}

case "${CMD}" in
    start)
        OUT="${OUT:-${VM_ARTIFACTS_DIR}/recordings/desktop-recording.mp4}"
        mkdir -p "$(dirname "${OUT}")"
        # Virtual-1 is the virtio-vga output inside the VM.
        vm_ssh_bg "$(vm_hypr_env)
nohup wf-recorder -o Virtual-1 -r ${VM_FPS} -f ${VM_RECORDING_REMOTE} \
> /tmp/wf-recorder.log 2>&1 < /dev/null & disown"
        echo "==> recording started (${VM_FPS} fps, remote: ${VM_RECORDING_REMOTE})"
        ;;
    stop)
        # shellcheck disable=SC2016
        vm_ssh 'pkill -INT wf-recorder > /dev/null 2>&1 || true; sleep 2' > /dev/null
        echo "==> recording stopped"
        ;;
    status)
        if vm_ssh 'pgrep -x wf-recorder > /dev/null' > /dev/null 2>&1; then
            echo "recording"
        else
            echo "stopped"
        fi
        ;;
    fetch)
        OUT="${OUT:-${VM_ARTIFACTS_DIR}/recordings/desktop-recording.mp4}"
        mkdir -p "$(dirname "${OUT}")"
        vm_scp "${VM_SSH_USER}@127.0.0.1:${VM_RECORDING_REMOTE}" "${OUT}"
        echo "==> recording saved to ${OUT}"
        ;;
esac
