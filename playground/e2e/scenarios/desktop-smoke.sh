#!/usr/bin/env bash
# desktop-smoke scenario: boot -> provision -> deploy -> session -> record -> assert.
# Produces screenshots, a desktop recording, and assertions.json in artifacts/.

set -euo pipefail

E2E_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
E2E_LIB_DIR="${E2E_ROOT}/lib"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

SCENARIO_DIR="${E2E_ARTIFACTS_DIR}/screenshots"
RECORDING="${E2E_ARTIFACTS_DIR}/recordings/desktop-recording.mp4"
mkdir -p "${SCENARIO_DIR}" "${E2E_ARTIFACTS_DIR}/recordings" "${E2E_ARTIFACTS_DIR}/logs"

fail() {
	echo "FAIL: $1" >&2
	jq -n --arg reason "$1" \
		'{ scenario: "desktop-smoke", result: "FAIL", reason: $reason }' \
		> "${E2E_ARTIFACTS_DIR}/assertions.json" 2> /dev/null || true
	exit 1
}

# 1. VM up ---------------------------------------------------------------------
bash "${E2E_LIB_DIR}/run.sh"
bash "${E2E_LIB_DIR}/wait-ssh.sh" 300 || fail "ssh not reachable"

# 2. Provision + real end-user install -----------------------------------------
bash "${E2E_LIB_DIR}/provision.sh" || fail "provisioning"
bash "${E2E_LIB_DIR}/install-dots.sh" || fail "dotfiles install"

# 3. Session -------------------------------------------------------------------
bash "${E2E_LIB_DIR}/start-session.sh" || fail "session start"

# 4. Assertions ----------------------------------------------------------------
echo "==> running assertions"
KERNEL="$(e2e_ssh 'uname -r')" || fail "uname"
e2e_ssh 'pgrep -x Hyprland > /dev/null' || fail "Hyprland running"
e2e_ssh 'pgrep -x qs > /dev/null 2>&1 || pgrep -x quickshell > /dev/null' || fail "Quickshell running"
MONITOR="$(e2e_ssh "$(e2e_hypr_env)
hyprctl -j monitors" | jq -r '.[0].name')" || fail "hyprctl monitors"
RESERVED="$(e2e_ssh "$(e2e_hypr_env)
hyprctl -j monitors" | jq -r '.[0].reserved | join(",")')" || fail "reserved"

# 5. Recording -----------------------------------------------------------------
echo "==> recording desktop interaction"
# wlr-screencopy hangs on virtio-vga when the ScrollOverview plugin hooks the
# render pass; probe first and fall back to QEMU framebuffer dumps.
if timeout 20 bash -c "source '${E2E_LIB_DIR}/env.sh' && e2e_ssh \"\$(e2e_hypr_env)
timeout 10 grim /tmp/e2e-probe.png\"" > /dev/null 2>&1; then
	bash "${E2E_LIB_DIR}/record.sh" start || fail "record start"
	sleep 5
	# Some real interaction: workspace switch round-trip.
	e2e_ssh "$(e2e_hypr_env)
hyprctl dispatch workspace 2 > /dev/null" || true
	sleep 2
	e2e_ssh "$(e2e_hypr_env)
hyprctl dispatch workspace 1 > /dev/null" || true
	sleep 2
	bash "${E2E_LIB_DIR}/record.sh" stop || fail "record stop"
	bash "${E2E_LIB_DIR}/record.sh" fetch "${RECORDING}" || fail "record fetch"
else
	echo "==> screencopy unavailable (plugin on virtio), using QEMU framebuffer"
	RECORDING=""
	bash "${E2E_LIB_DIR}/qemu-screenshot.sh" "${SCENARIO_DIR}/desktop-final.png" \
		|| fail "qemu screenshot"
fi

# 6. Screenshot ----------------------------------------------------------------
if [[ -z ${RECORDING} ]] || [[ ! -s ${RECORDING} ]]; then
	: # already captured via QEMU framebuffer in the recording fallback
else
	bash "${E2E_LIB_DIR}/screenshot.sh" "${SCENARIO_DIR}/desktop-final.png" \
		|| fail "screenshot"
fi

# 7. Logs ----------------------------------------------------------------------
e2e_ssh 'tail -n 200 /tmp/hypr.log' > "${E2E_ARTIFACTS_DIR}/logs/hyprland.log" 2> /dev/null || true
e2e_ssh 'cat /tmp/qs.log' > "${E2E_ARTIFACTS_DIR}/logs/quickshell.log" 2> /dev/null || true

# 8. Report --------------------------------------------------------------------
GIT_SHA="$(git -C "${DOTFILES_ROOT}" rev-parse --short HEAD 2> /dev/null || echo unknown)"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
REC_OK=false
[[ -n ${RECORDING} && -s ${RECORDING} ]] && REC_OK=true
jq -n \
	--arg ts "${TS}" \
	--arg sha "${GIT_SHA}" \
	--arg kernel "${KERNEL}" \
	--arg monitor "${MONITOR}" \
	--arg reserved "${RESERVED}" \
	--arg recording "$(basename "${RECORDING:-}")" \
	--argjson rec_ok "${REC_OK}" \
	'{
		timestamp: $ts,
		git_sha: $sha,
		scenario: "desktop-smoke",
		assertions: {
			vm_booted: true,
			ssh_accessible: true,
			kernel: $kernel,
			hyprland_running: true,
			quickshell_running: true,
			monitor: $monitor,
			reserved: $reserved,
			recording_captured: $rec_ok,
			screenshot_captured: true
		},
		result: "PASS"
	}' > "${E2E_ARTIFACTS_DIR}/assertions.json"

echo "==> desktop-smoke PASS"
echo "    screenshot: ${SCENARIO_DIR}/desktop-final.png"
[[ -n ${RECORDING} ]] && echo "    recording:  ${RECORDING}"
echo "    report:     ${E2E_ARTIFACTS_DIR}/assertions.json"
