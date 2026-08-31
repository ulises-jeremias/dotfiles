#!/usr/bin/env bash
# Record the VM desktop with wf-recorder.
# Usage: record.sh start [output.mp4] | stop | status | fetch [output.mp4]

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

RECORDING_REMOTE="${RECORDING_REMOTE:-/tmp/e2e-recording.mp4}"
FPS="${E2E_FPS:-10}"

cmd="${1:-status}"
shift || true

e2e_ssh_ready || {
	echo "error: VM SSH is not up" >&2
	exit 1
}

case ${cmd} in
	start)
		out="${1:-${E2E_ARTIFACTS_DIR}/recordings/desktop-recording.mp4}"
		mkdir -p "$(dirname "${out}")"
		# -o Virtual-1 targets the virtio-vga output inside the VM.
		# SIGINT (not TERM) is what makes wf-recorder finalize the file.
		e2e_ssh_bg "$(e2e_hypr_env)
nohup wf-recorder -o Virtual-1 -r ${FPS} -f ${RECORDING_REMOTE} \
	> /tmp/wf-recorder.log 2>&1 < /dev/null & disown"
		echo "==> recording started (${FPS} fps, remote: ${RECORDING_REMOTE})"
		;;
	stop)
		e2e_ssh 'pkill -INT wf-recorder > /dev/null 2>&1 || true; sleep 2; \
			test -f /tmp/e2e-recording.mp4 && echo recording-finalized' > /dev/null
		echo "==> recording stopped"
		;;
	status)
		if e2e_ssh 'pgrep -x wf-recorder > /dev/null' > /dev/null 2>&1; then
			echo "recording"
		else
			echo "stopped"
		fi
		;;
	fetch)
		out="${1:-${E2E_ARTIFACTS_DIR}/recordings/desktop-recording.mp4}"
		mkdir -p "$(dirname "${out}")"
		e2e_scp "${E2E_SSH_USER}@127.0.0.1:${RECORDING_REMOTE}" "${out}"
		echo "==> recording saved to ${out}"
		;;
	*)
		echo "usage: $0 {start [output.mp4] | stop | status | fetch [output.mp4]}" >&2
		exit 1
		;;
esac
