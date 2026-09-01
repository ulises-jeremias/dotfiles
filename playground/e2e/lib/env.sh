#!/usr/bin/env bash
# Shared environment and helpers for the E2E desktop testing harness.
# Source this file from other scripts: source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

E2E_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_ROOT="$(cd "${E2E_ROOT}/../.." && pwd)"

E2E_CONTAINER_NAME="${E2E_CONTAINER_NAME:-dotfiles-e2e-vm}"
E2E_IMAGE="${E2E_IMAGE:-dotfiles-e2e-qemu}"
E2E_SSH_PORT="${E2E_SSH_PORT:-2222}"
E2E_SSH_USER="${E2E_SSH_USER:-hornero}"
E2E_SSH_DIR="${E2E_SSH_DIR:-${E2E_ROOT}/ssh}"
E2E_SSH_KEY="${E2E_SSH_KEY:-${E2E_SSH_DIR}/id_ed25519}"
E2E_ARTIFACTS_DIR="${E2E_ARTIFACTS_DIR:-${E2E_ROOT}/artifacts}"
E2E_CACHE_DIR="${E2E_CACHE_DIR:-${E2E_ROOT}/cache}"
E2E_SHARED_DIR="${E2E_SHARED_DIR:-${E2E_ROOT}/shared}"

# VM sizing. Keep modest so the harness can run next to a full desktop.
E2E_VM_MEM="${E2E_VM_MEM:-3072}"
E2E_VM_SMP="${E2E_VM_SMP:-2}"
E2E_CLOUD_IMAGE_URL="${E2E_CLOUD_IMAGE_URL:-https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2}"
E2E_CLOUD_IMAGE="${E2E_CLOUD_IMAGE:-${E2E_CACHE_DIR}/arch-cloudimg.qcow2}"

# SSH into the E2E VM.
e2e_ssh() {
	ssh -4 \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-o LogLevel=ERROR \
		-o ConnectTimeout=5 \
		-i "${E2E_SSH_KEY}" \
		-p "${E2E_SSH_PORT}" \
		"${E2E_SSH_USER}@127.0.0.1" "$@"
}

# SSH that detaches immediately after auth — for launching long-lived
# graphical processes (compositor, shell, recorder) whose FDs would
# otherwise keep the session open. Output is discarded so backgrounded
# handles never keep caller pipes open.
e2e_ssh_bg() {
	ssh -4 -f \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-o LogLevel=ERROR \
		-o ConnectTimeout=5 \
		-i "${E2E_SSH_KEY}" \
		-p "${E2E_SSH_PORT}" \
		"${E2E_SSH_USER}@127.0.0.1" "$@" > /dev/null 2>&1
}

# Copy files to/from the E2E VM.
e2e_scp() {
	scp -4 -O \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-o LogLevel=ERROR \
		-i "${E2E_SSH_KEY}" \
		-P "${E2E_SSH_PORT}" \
		"$@"
}

# True when the VM container is up.
e2e_vm_running() {
	docker ps --filter "name=^/${E2E_CONTAINER_NAME}$" --format '{{.Names}}' | grep -q .
}

# True when SSH is answering.
e2e_ssh_ready() {
	e2e_ssh 'echo ok' > /dev/null 2>&1
}

# True when the Hyprland session is up inside the VM.
e2e_session_ready() {
	e2e_ssh 'pgrep -x Hyprland > /dev/null' > /dev/null 2>&1
}

# Resolve the Hyprland instance signature inside the VM.
# shellcheck disable=SC2016  # the $(...) must expand on the guest, not here
e2e_hypr_env() {
	echo 'export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t $XDG_RUNTIME_DIR/hypr/ | grep -v ".lock" | head -1)
export WAYLAND_DISPLAY=wayland-1
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export QML_IMPORT_PATH=$HOME/.local/lib/quickshell/qml
export QML2_IMPORT_PATH=$HOME/.local/lib/quickshell/qml
export QS_PLUGIN_PATH=$HOME/.local/lib/quickshell
export XDG_CONFIG_HOME=$HOME/.config
export QT_QPA_PLATFORMTHEME=gtk3'
}
