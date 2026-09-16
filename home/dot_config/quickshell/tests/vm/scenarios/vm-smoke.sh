#!/usr/bin/env bash
# Graphical smoke scenario: boot, provision, deploy, session, capture, assert.
# Produces screenshots, an optional desktop recording, guest logs, and a
# machine-readable assertions.json report under the artifacts directory.
# Usage: vm-smoke.sh [--dry-run] [--skip-provision]
#
# A real run needs QEMU/KVM plus network access (see docs/VM_TESTING.md).
# --dry-run validates the harness locally without touching a hypervisor.

set -euo pipefail

VM_ROOT_SMOKE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VM_LIB_DIR="${VM_ROOT_SMOKE}/lib"
# shellcheck source=tests/vm/lib/env.sh
# shellcheck disable=SC1091 # path resolves at runtime; use shellcheck -x to follow it
source "${VM_LIB_DIR}/env.sh"

SKIP_PROVISION=0
for arg in "$@"; do
    case "${arg}" in
        --help)
            echo "usage: vm-smoke.sh [--dry-run] [--skip-provision]"
            exit 0
            ;;
        --dry-run)
            export VM_DRY_RUN=1
            ;;
        --skip-provision)
            SKIP_PROVISION=1
            ;;
        *)
            echo "error: unknown argument '${arg}'" >&2
            echo "usage: vm-smoke.sh [--dry-run] [--skip-provision]" >&2
            exit 2
            ;;
    esac
done

SCREENSHOT_DIR="${VM_ARTIFACTS_DIR}/screenshots"
RECORDING="${VM_ARTIFACTS_DIR}/recordings/desktop-recording.mp4"
mkdir -p "${SCREENSHOT_DIR}" "${VM_ARTIFACTS_DIR}/recordings" "${VM_ARTIFACTS_DIR}/logs"

fail() {
    echo "FAIL: $1" >&2
    jq -n --arg reason "$1" \
        '{ scenario: "vm-smoke", result: "FAIL", reason: $reason }' \
        > "${VM_ARTIFACTS_DIR}/assertions.json" 2> /dev/null || true
    exit 1
}

if vm_is_dry_run; then
    echo "dry-run: harness plan (no hypervisor touched)"
    for stage in boot.sh wait-ssh.sh provision.sh deploy-shell.sh start-session.sh screenshot.sh record.sh qemu-screenshot.sh; do
        if [[ -x "${VM_LIB_DIR}/${stage}" ]]; then
            echo "dry-run: stage present and executable: lib/${stage}"
        else
            echo "dry-run: MISSING stage: lib/${stage}" >&2
            exit 1
        fi
    done
    for guest in hyprland.conf user-data.tmpl meta-data; do
        if [[ -f "${VM_DIR}/guest/${guest}" ]]; then
            echo "dry-run: guest file present: guest/${guest}"
        else
            echo "dry-run: MISSING guest file: guest/${guest}" >&2
            exit 1
        fi
    done
    python3 "${VM_LIB_DIR}/check_screenshot.py" --help > /dev/null \
        || fail "check_screenshot.py is not runnable"
    echo "dry-run: check_screenshot.py is runnable"
    python3 "${VM_LIB_DIR}/ppm_to_png.py" --help > /dev/null \
        || fail "ppm_to_png.py is not runnable"
    echo "dry-run: ppm_to_png.py is runnable"
    bash "${VM_LIB_DIR}/boot.sh" --dry-run
    bash "${VM_LIB_DIR}/wait-ssh.sh" 300 --dry-run
    bash "${VM_LIB_DIR}/provision.sh" --dry-run
    bash "${VM_LIB_DIR}/deploy-shell.sh" --dry-run
    bash "${VM_LIB_DIR}/start-session.sh" --dry-run
    bash "${VM_LIB_DIR}/screenshot.sh" --dry-run
    echo "dry-run: harness plan is coherent"
    exit 0
fi

# 1. VM up --------------------------------------------------------------------
bash "${VM_LIB_DIR}/boot.sh"
bash "${VM_LIB_DIR}/wait-ssh.sh" 300 || fail "ssh not reachable"

# 2. Provision plus deploy ----------------------------------------------------
if [[ "${SKIP_PROVISION}" == "1" ]]; then
    echo "==> skipping provision (--skip-provision)"
else
    bash "${VM_LIB_DIR}/provision.sh" || fail "provisioning"
fi
bash "${VM_LIB_DIR}/deploy-shell.sh" || fail "shell deploy"

# 3. Session ------------------------------------------------------------------
bash "${VM_LIB_DIR}/start-session.sh" || fail "session start"

# 4. Assertions ----------------------------------------------------------------
echo "==> running assertions"
KERNEL="$(vm_ssh 'uname -r')" || fail "uname"
vm_ssh 'pgrep -x Hyprland > /dev/null' || fail "Hyprland running"
vm_shell_ready || fail "shell running"
MONITOR="$(vm_ssh "$(vm_hypr_env)
hyprctl -j monitors" | jq -r '.[0].name')" || fail "hyprctl monitors"
RESERVED="$(vm_ssh "$(vm_hypr_env)
hyprctl -j monitors" | jq -r '.[0].reserved | join(",")')" || fail "reserved"
# The shell answers over its own IPC: drawers list is read-only and safe.
IPC_DRAWERS="$(vm_ssh "$(vm_hypr_env)
QS_BIN=\$(command -v qs || command -v quickshell)
\$QS_BIN ipc call drawers list")" || fail "shell IPC responds"
[[ -n "${IPC_DRAWERS}" ]] || fail "shell IPC empty"

# 5. Capture -------------------------------------------------------------------
echo "==> capturing desktop output"
# wlr-screencopy can hang on virtio-vga, so probe grim first and fall back
# to the QEMU framebuffer dump when the compositor never answers.
if vm_ssh "$(vm_hypr_env)
timeout 10 grim /tmp/vm-probe.png" > /dev/null 2>&1; then
    bash "${VM_LIB_DIR}/record.sh" start || fail "record start"
    sleep 5
    # Real interaction while recording: workspace switch round-trip.
    vm_ssh "$(vm_hypr_env)
hyprctl dispatch workspace 2 > /dev/null" || true
    sleep 2
    vm_ssh "$(vm_hypr_env)
hyprctl dispatch workspace 1 > /dev/null" || true
    sleep 2
    bash "${VM_LIB_DIR}/record.sh" stop || fail "record stop"
    bash "${VM_LIB_DIR}/record.sh" fetch "${RECORDING}" || fail "record fetch"
else
    echo "==> screencopy unavailable, using QEMU framebuffer"
    RECORDING=""
    bash "${VM_LIB_DIR}/qemu-screenshot.sh" "${SCREENSHOT_DIR}/desktop-final.png" \
        || fail "qemu screenshot"
fi

# 6. Screenshot ----------------------------------------------------------------
if [[ -z "${RECORDING}" ]] || [[ ! -s "${RECORDING}" ]]; then
    : # already captured through the QEMU framebuffer fallback above
else
    bash "${VM_LIB_DIR}/screenshot.sh" "${SCREENSHOT_DIR}/desktop-final.png" \
        || fail "screenshot"
fi

# A blank capture means the compositor or shell rendered nothing: fail loudly
# instead of archiving an empty artifact as success.
python3 "${VM_LIB_DIR}/check_screenshot.py" "${SCREENSHOT_DIR}/desktop-final.png" \
    || fail "screenshot is blank or truncated"

# 7. Logs ----------------------------------------------------------------------
vm_ssh 'tail -n 200 /tmp/hypr.log' > "${VM_ARTIFACTS_DIR}/logs/hyprland.log" 2> /dev/null || true
vm_ssh 'cat /tmp/qs.log' > "${VM_ARTIFACTS_DIR}/logs/shell.log" 2> /dev/null || true

# 8. Report --------------------------------------------------------------------
GIT_SHA="$(git -C "${SHELL_ROOT}" rev-parse --short HEAD 2> /dev/null || echo unknown)"
GIT_SHA_FULL="$(git -C "${SHELL_ROOT}" rev-parse HEAD 2> /dev/null || echo unknown)"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
REC_OK=false
[[ -n "${RECORDING}" && -s "${RECORDING}" ]] && REC_OK=true
# Composition provenance (additive): shell-local runs record no manifest
# and no config pin; composed runs carry both for traceability.
HX_CONFIG_SHA="none"
if [[ -n "${HX_CONFIG_PIN:-}" ]]; then
    HX_CONFIG_SHA="${HX_CONFIG_PIN##* }"
elif [[ -n "${HX_MATERIALIZE_BIN:-}" ]]; then
    HX_CONFIG_SRC_REPORT="$(cd "$(dirname "${HX_MATERIALIZE_BIN}")/.." && pwd)"
    HX_CONFIG_SHA="$(git -C "${HX_CONFIG_SRC_REPORT}" rev-parse HEAD 2> /dev/null || echo unknown)"
fi
jq -n \
    --arg ts "${TS}" \
    --arg sha "${GIT_SHA}" \
    --arg shell_full "${GIT_SHA_FULL}" \
    --arg manifest "${HX_MANIFEST:-shell-local}" \
    --arg config_sha "${HX_CONFIG_SHA}" \
    --arg kernel "${KERNEL}" \
    --arg monitor "${MONITOR}" \
    --arg reserved "${RESERVED}" \
    --arg recording "$(basename "${RECORDING:-none}")" \
    --argjson rec_ok "${REC_OK}" \
    '{
        timestamp: $ts,
        git_sha: $sha,
        scenario: "vm-smoke",
        composition: {
            manifest: $manifest,
            shell_sha: $shell_full,
            config_sha: $config_sha
        },
        assertions: {
            vm_booted: true,
            ssh_accessible: true,
            kernel: $kernel,
            hyprland_running: true,
            shell_running: true,
            shell_ipc_responds: true,
            monitor: $monitor,
            reserved: $reserved,
            recording_captured: $rec_ok,
            screenshot_captured: true,
            screenshot_nonblank: true
        },
        result: "PASS"
    }' > "${VM_ARTIFACTS_DIR}/assertions.json"

echo "==> vm-smoke PASS"
echo "    screenshot: ${SCREENSHOT_DIR}/desktop-final.png"
[[ -n "${RECORDING}" ]] && echo "    recording:  ${RECORDING}"
echo "    report:     ${VM_ARTIFACTS_DIR}/assertions.json"
