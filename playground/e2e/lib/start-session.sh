#!/usr/bin/env bash
# Start the Hyprland + Quickshell session inside the VM (DRM backend).

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

e2e_ssh_ready || {
	echo "error: VM SSH is not up. Run lib/run.sh + lib/wait-ssh.sh first." >&2
	exit 1
}

echo "==> restarting session cleanly (deterministic state)"
e2e_ssh 'pkill -x qs 2> /dev/null; pkill -x wf-recorder 2> /dev/null; \
	pkill -x Hyprland 2> /dev/null; sleep 3' > /dev/null || true

echo "==> starting Hyprland (DRM backend)"
# shellcheck disable=SC2016  # remote script, no local expansion wanted
e2e_ssh_bg 'export WLR_BACKENDS=drm && export WLR_RENDERER=gles2 && \
	export XDG_CONFIG_HOME=$HOME/.config && \
	nohup Hyprland > /tmp/hypr.log 2>&1 < /dev/null & disown'

if ! e2e_session_ready; then
	echo "error: Hyprland did not start. Check /tmp/hypr.log inside the VM." >&2
	e2e_ssh 'tail -n 20 /tmp/hypr.log' >&2 || true
	exit 1
fi

if e2e_ssh 'pgrep -x qs > /dev/null 2>&1 || pgrep -x quickshell > /dev/null' > /dev/null 2>&1; then
	echo "==> Quickshell already running"
else
	# shellcheck disable=SC2016  # remote script, no local expansion wanted
	echo "==> waiting for the Wayland socket (Hyprland creates it after pgrep shows up)"
	for _ in $(seq 1 30); do
		# shellcheck disable=SC2016  # remote script, no local expansion wanted
		e2e_ssh 'test -S $XDG_RUNTIME_DIR/wayland-1' > /dev/null 2>&1 && break
		sleep 1
	done
	# shellcheck disable=SC2016  # remote script, no local expansion wanted
	e2e_ssh 'test -S $XDG_RUNTIME_DIR/wayland-1' || {
		echo "error: Wayland socket never appeared" >&2
		exit 1
	}

	echo "==> starting Quickshell"
	# Use the user's launcher (sets QML paths + QT platform theme itself).
	e2e_ssh_bg "$(e2e_hypr_env)
nohup $HOME/.local/bin/dots-quickshell start > /tmp/dots-quickshell.log 2>&1 < /dev/null & disown"
	sleep 10
fi

if e2e_ssh 'pgrep -x qs > /dev/null 2>&1 || pgrep -x quickshell > /dev/null' > /dev/null 2>&1; then
	echo "==> session is up (Hyprland + Quickshell)"
else
	echo "error: Quickshell did not start. Check /tmp/qs.log inside the VM." >&2
	e2e_ssh 'tail -n 20 /tmp/qs.log' >&2 || true
	exit 1
fi
