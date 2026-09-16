#!/usr/bin/env bash
# Shared environment and helpers for the HorneroOS/shell graphical VM harness.
# Source this file from other scripts:
#   source "$(dirname "${BASH_SOURCE[0]}")/env.sh"
#
# Every knob below is overridable through the environment. The harness boots
# a throwaway Arch Linux VM with QEMU/KVM, deploys this repo checkout as the
# Quickshell config under test, starts Hyprland plus the shell, and captures
# screenshots and recordings as artifacts. See docs/VM_TESTING.md.

# Harness root (tests/vm) and repo checkout under test.
# Exported: sourced scripts, dry-run probes, and helpers such as
# check_screenshot.py read these knobs from the environment.
VM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHELL_ROOT="$(cd "${VM_DIR}/../.." && pwd)"

# Guest access.
VM_SSH_PORT="${VM_SSH_PORT:-2222}"
VM_SSH_USER="${VM_SSH_USER:-hornero}"
VM_SSH_DIR="${VM_SSH_DIR:-${VM_DIR}/ssh}"
VM_SSH_KEY="${VM_SSH_KEY:-${VM_SSH_DIR}/id_ed25519}"

# Host-side state directories (gitignored, see tests/vm/.gitignore).
VM_ARTIFACTS_DIR="${VM_ARTIFACTS_DIR:-${VM_DIR}/artifacts}"
VM_CACHE_DIR="${VM_CACHE_DIR:-${VM_DIR}/cache}"
VM_SHARED_DIR="${VM_SHARED_DIR:-${VM_DIR}/shared}"
VM_PID_FILE="${VM_CACHE_DIR}/qemu.pid"

# VM sizing. Keep modest so the harness can run next to a full desktop.
VM_MEM="${VM_MEM:-3072}"
VM_SMP="${VM_SMP:-2}"
# Minimum virtual disk size (GiB) for the boot overlay; boot.sh grows the
# overlay (never the verified base) when qemu-img reports less. Minimum
# guest free space (GiB) required by provision.sh before the package
# install starts.
VM_MIN_IMAGE_GB="${VM_MIN_IMAGE_GB:-14}"
VM_MIN_GUEST_FREE_GB="${VM_MIN_GUEST_FREE_GB:-6}"
# User-local install prefix for the shell's native QML plugin in the guest.
# The default is guest-relative: $HOME must expand inside the guest, not on
# the host (the guest user differs from the operator).
if [[ -z "${VM_GUEST_PREFIX:-}" ]]; then
    # shellcheck disable=SC2016 # literal $HOME: expands inside the guest
    VM_GUEST_PREFIX='$HOME/.local'
fi
VM_CLOUD_IMAGE_URL="${VM_CLOUD_IMAGE_URL:-https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2}"
# Pristine verified base image (read-only after download: never resized,
# never attached to QEMU). Every boot runs through VM_OVERLAY below so the
# cache stays clean and runs are reproducible (see docs/VM_TESTING.md).
VM_CLOUD_IMAGE="${VM_CLOUD_IMAGE:-${VM_CACHE_DIR}/arch-cloudimg.qcow2}"
# Ephemeral qcow2 overlay with the base image as its backing file. All guest
# writes land here; delete it to reset the VM without re-downloading.
VM_OVERLAY="${VM_OVERLAY:-${VM_CACHE_DIR}/vm-overlay.qcow2}"
# Checksum sidecar (sha256sum format) published next to the image. Verified on
# every run, including cached images. The mirror also publishes a GPG .sig
# next to the image; see docs/VM_TESTING.md for optional manual verification.
VM_CLOUD_IMAGE_SHA256_URL="${VM_CLOUD_IMAGE_SHA256_URL:-${VM_CLOUD_IMAGE_URL}.SHA256}"
# Set to 1 to boot with a failed verification (loud warning, not recommended).
VM_ALLOW_UNVERIFIED_IMAGE="${VM_ALLOW_UNVERIFIED_IMAGE:-0}"
VM_SEED_ISO="${VM_SEED_ISO:-${VM_CACHE_DIR}/seed.iso}"

# Recording knobs (mirror the dotfiles e2e defaults the harness is based on).
VM_FPS="${VM_FPS:-10}"
VM_RECORDING_REMOTE="${VM_RECORDING_REMOTE:-/tmp/vm-recording.mp4}"

# DNS server advertised to the guest over DHCP (QEMU user-net `dns=`).
# QEMU slirp proxies guest DNS to the host's first nameserver, which may be
# a LAN-only resolver that answers the host (via fallbacks) but never the
# guest. A public default keeps provisioning deterministic; override for
# offline or filtered networks.
VM_GUEST_DNS="${VM_GUEST_DNS:-1.1.1.1}"

# Set to 1 to print what a script would do without touching the VM.
VM_DRY_RUN="${VM_DRY_RUN:-0}"

export VM_DIR SHELL_ROOT
export VM_SSH_PORT VM_SSH_USER VM_SSH_DIR VM_SSH_KEY
export VM_ARTIFACTS_DIR VM_CACHE_DIR VM_SHARED_DIR VM_PID_FILE
export VM_MEM VM_SMP VM_CLOUD_IMAGE_URL VM_CLOUD_IMAGE VM_OVERLAY VM_SEED_ISO
export VM_MIN_IMAGE_GB VM_MIN_GUEST_FREE_GB VM_GUEST_PREFIX
export VM_CLOUD_IMAGE_SHA256_URL VM_ALLOW_UNVERIFIED_IMAGE
# Pinned composition (opt-in; empty by default keeps shell-local behavior).
# HX_CONFIG_PIN is "<repo-url> <full-sha>" for the HorneroOS/config pin,
# fetched with the same discipline as hornero scripts/compose.sh (a shallow
# fetch at the exact SHA into the harness cache). HX_MATERIALIZE_BIN points
# at a materialize.sh directly (default: the fetched pin's script) and
# HX_HOREROCTL_BIN at a horneroctl binary used to validate the materialized
# root in the guest (when unset, deploy materializes via the script and
# skips horneroctl validation with a warning). HX_MANIFEST names the
# composition manifest recorded in the assertions report.
HX_CONFIG_PIN="${HX_CONFIG_PIN:-}"
HX_MATERIALIZE_BIN="${HX_MATERIALIZE_BIN:-}"
HX_HOREROCTL_BIN="${HX_HOREROCTL_BIN:-}"
HX_MANIFEST="${HX_MANIFEST:-shell-local}"

export VM_FPS VM_RECORDING_REMOTE VM_DRY_RUN VM_GUEST_DNS
export HX_CONFIG_PIN HX_MATERIALIZE_BIN HX_HOREROCTL_BIN HX_MANIFEST

vm_is_dry_run() {
    [[ "${VM_DRY_RUN}" == "1" ]]
}

vm_usage_error() {
    echo "error: $1" >&2
    echo "usage: $2" >&2
    exit 2
}

# SSH into the harness VM.
vm_ssh() {
    ssh -4 \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR \
        -o ConnectTimeout=5 \
        -i "${VM_SSH_KEY}" \
        -p "${VM_SSH_PORT}" \
        "${VM_SSH_USER}@127.0.0.1" "$@"
}

# SSH that detaches immediately after auth. Use it for launching long-lived
# graphical processes (compositor, shell, recorder) whose file descriptors
# would otherwise keep the session open. Output is discarded so backgrounded
# handles never keep caller pipes open.
vm_ssh_bg() {
    ssh -4 -f \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR \
        -o ConnectTimeout=5 \
        -i "${VM_SSH_KEY}" \
        -p "${VM_SSH_PORT}" \
        "${VM_SSH_USER}@127.0.0.1" "$@" > /dev/null 2>&1
}

# Copy files to or from the harness VM.
vm_scp() {
    scp -4 -O \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o LogLevel=ERROR \
        -i "${VM_SSH_KEY}" \
        -P "${VM_SSH_PORT}" \
        "$@"
}

# True when the QEMU process recorded in the pid file is still alive.
vm_running() {
    [[ -f "${VM_PID_FILE}" ]] && kill -0 "$(cat "${VM_PID_FILE}")" 2> /dev/null
}

# True when SSH is answering inside the VM.
vm_ssh_ready() {
    vm_ssh 'echo ok' > /dev/null 2>&1
}

# True when the Hyprland session is up inside the VM.
vm_session_ready() {
    vm_ssh 'pgrep -x Hyprland > /dev/null' > /dev/null 2>&1
}

# True when the shell (quickshell) process is up inside the VM.
vm_shell_ready() {
    vm_ssh 'pgrep -x qs > /dev/null 2>&1 || pgrep -x quickshell > /dev/null' > /dev/null 2>&1
}

# Environment exports needed before talking to the guest compositor session.
# The command substitution must expand on the guest, not locally.
# shellcheck disable=SC2016
vm_hypr_env() {
    echo 'export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t $XDG_RUNTIME_DIR/hypr/ | grep -v ".lock" | head -1)
export WAYLAND_DISPLAY=wayland-1
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_CONFIG_HOME=$HOME/.config
export QT_QPA_PLATFORM=wayland'
}
