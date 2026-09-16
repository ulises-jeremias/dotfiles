#!/usr/bin/env bash
# Welcome Center VM scenario: first login, repeat login, shell reload,
# opt-out, manual reopen, plus the dark/light/Pampa screenshot matrix.
#
# Drives the deployed shell over SSH the way a new user would: fresh state
# (as the installer would provision it), then IPC plus horneroctl, and a
# grim screenshot per step. Produces artifacts/assertions.json.
#
# Login sessions are simulated with XDG_SESSION_ID: the shell keys its
# once-per-session marker off that variable (fallback: WAYLAND_DISPLAY),
# so each flow exports a fresh id exactly like a new graphical login.
#
# Usage: vm-welcome.sh [--dry-run] [--skip-provision]
#   HX_MATERIALIZE_BIN and HX_HOREROCTL_BIN select the guest composition
#   (config checkout plus horneroctl binary); both are required here
#   because badges and opt-out need the real manifest and the real CLI.

set -euo pipefail

VM_ROOT_WELCOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VM_LIB_DIR="${VM_ROOT_WELCOME}/lib"
# shellcheck source=tests/vm/lib/env.sh
# shellcheck disable=SC1091 # path resolves at runtime; use shellcheck -x to follow it
source "${VM_LIB_DIR}/env.sh"

SKIP_PROVISION=0
for arg in "$@"; do
    case "${arg}" in
        --help)
            echo "usage: vm-welcome.sh [--dry-run] [--skip-provision]"
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
            echo "usage: vm-welcome.sh [--dry-run] [--skip-provision]" >&2
            exit 2
            ;;
    esac
done

SHOT_DIR="${VM_ARTIFACTS_DIR}/screenshots"
mkdir -p "${SHOT_DIR}" "${VM_ARTIFACTS_DIR}/logs"

fail() {
    echo "FAIL: $1" >&2
    jq -n --arg reason "$1" \
        '{ scenario: "vm-welcome", result: "FAIL", reason: $reason }' \
        > "${VM_ARTIFACTS_DIR}/assertions.json" 2> /dev/null || true
    exit 1
}

if vm_is_dry_run; then
    echo "dry-run: welcome plan (no hypervisor touched)"
    for stage in boot.sh wait-ssh.sh provision.sh deploy-shell.sh start-session.sh screenshot.sh; do
        [[ -x "${VM_LIB_DIR}/${stage}" ]] || fail "MISSING stage: lib/${stage}"
        echo "dry-run: stage present and executable: lib/${stage}"
    done
    [[ -n "${HX_MATERIALIZE_BIN:-}" ]] || echo "dry-run: warning: HX_MATERIALIZE_BIN unset (badges need the config pin)"
    [[ -n "${HX_HOREROCTL_BIN:-}" ]] || echo "dry-run: warning: HX_HOREROCTL_BIN unset (opt-out needs horneroctl)"
    echo "dry-run: welcome plan is coherent"
    exit 0
fi

[[ -n "${HX_MATERIALIZE_BIN:-}" ]] || fail "HX_MATERIALIZE_BIN is required (shortcuts.json manifest)"
[[ -x "${HX_MATERIALIZE_BIN:-}" ]] || fail "HX_MATERIALIZE_BIN is not executable"
[[ -n "${HX_HOREROCTL_BIN:-}" ]] || fail "HX_HOREROCTL_BIN is required (opt-out writes)"
[[ -x "${HX_HOREROCTL_BIN:-}" ]] || fail "HX_HOREROCTL_BIN is not executable"

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
bash "${VM_LIB_DIR}/start-session.sh" || fail "session start"

# Helpers (guest-side variables stay escaped; they expand inside the VM). -----
# shellcheck disable=SC2016
QS_CALL='$(command -v qs || command -v quickshell) ipc call'
HYPENV="$(vm_hypr_env)"

welcome_status() {
    vm_ssh "${HYPENV}
${QS_CALL} welcome status"
}

# Restart only the shell (Hyprland keeps running): the equivalent of a
# shell reload or a re-login into the same compositor session.
restart_shell() {
    local session_id="$1"
    # shellcheck disable=SC2016
    vm_ssh 'pkill -x qs 2> /dev/null; pkill -x quickshell 2> /dev/null; sleep 2' > /dev/null || true
    # shellcheck disable=SC2016 # remote $HOME must expand inside the guest
    guest_home="$(vm_ssh 'printf %s "$HOME"')"
    guest_qml_path="${VM_GUEST_PREFIX//\$HOME/${guest_home}}/lib/qt6/qml"
    # shellcheck disable=SC2016
    vm_ssh_bg "${HYPENV}
export XDG_SESSION_ID=${session_id}
export QML2_IMPORT_PATH=${guest_qml_path}:\$QML2_IMPORT_PATH
if command -v qs > /dev/null; then QS_BIN=qs; else QS_BIN=quickshell; fi
cd \$HOME/.config/quickshell && nohup env XDG_SESSION_ID=${session_id} \$QS_BIN > /tmp/qs.log 2>&1 < /dev/null & disown"
    sleep 12
    vm_shell_ready || fail "shell did not come back (session ${session_id})"
}

grab() {
    bash "${VM_LIB_DIR}/screenshot.sh" "${SHOT_DIR}/$1" || fail "screenshot $1"
    python3 "${VM_LIB_DIR}/check_screenshot.py" "${SHOT_DIR}/$1" || fail "blank screenshot $1"
}

# 3. Fresh-boot simulation ----------------------------------------------------
echo "==> wiping welcome state (installer factory state)"
# shellcheck disable=SC2016
vm_ssh 'rm -rf ~/.local/state/hornero/welcome ~/.local/state/hornero/scheme /run/user/$(id -u)/hornero-welcome-seen-* ~/.cache/hornero/smart-colors/scheme.json' || true
# shellcheck disable=SC2016
vm_ssh 'test -f ~/.local/share/hornero/shortcuts.json' || fail "shortcuts.json missing in guest"

# 4. Flow 1: first login auto-opens -------------------------------------------
echo "==> flow 1: first login"
restart_shell "welcome-flow-1"
STATUS="$(welcome_status)" || fail "welcome status (flow 1)"
echo "    status: ${STATUS}"
[[ "$(printf '%s' "${STATUS}" | jq -r '.open')" == "true" ]] || fail "first login did not auto-open"
[[ "$(printf '%s' "${STATUS}" | jq -r '.page')" == "start" ]] || fail "first login opened on wrong page"
grab "welcome-firstlogin-dark.png"

# 5. Theme matrix (live scheme swap, no restart) -------------------------------
echo "==> theme matrix: light"
python3 "${VM_LIB_DIR}/welcome-schemes.py" --mode light | vm_ssh 'mkdir -p ~/.cache/hornero/smart-colors && cat > ~/.cache/hornero/smart-colors/scheme.json'
sleep 3
grab "welcome-learn-light.png"
echo "==> theme matrix: pampa"
python3 "${VM_LIB_DIR}/welcome-schemes.py" --mode pampa | vm_ssh 'cat > ~/.cache/hornero/smart-colors/scheme.json'
sleep 3
grab "welcome-learn-pampa.png"
# shellcheck disable=SC2016
vm_ssh 'rm -f ~/.cache/hornero/smart-colors/scheme.json'
sleep 3

# 6. Flow 2: repeat login (new session) auto-opens again ----------------------
echo "==> flow 2: repeat login"
restart_shell "welcome-flow-2"
STATUS="$(welcome_status)" || fail "welcome status (flow 2)"
[[ "$(printf '%s' "${STATUS}" | jq -r '.open')" == "true" ]] || fail "repeat login did not auto-open"

# 7. Flow 3: shell reload in the same session stays silent --------------------
echo "==> flow 3: shell reload, same session"
# shellcheck disable=SC2016
vm_ssh "${HYPENV}
${QS_CALL} welcome close" > /dev/null || fail "welcome close"
restart_shell "welcome-flow-2"
STATUS="$(welcome_status)" || fail "welcome status (flow 3)"
[[ "$(printf '%s' "${STATUS}" | jq -r '.open')" == "false" ]] || fail "reload re-opened welcome in the same session"

# 8. Flow 4: opt-out survives a new login -------------------------------------
echo "==> flow 4: opt-out"
# shellcheck disable=SC2016 # remote $HOME must expand inside the guest
vm_ssh '$HOME/horneroctl welcome set-show-on-login false --yes > /dev/null' || fail "opt-out write"
# --json reports .data.show_on_login ("true"/"false" strings); fall back to
# the human rendering when jq is unavailable in the guest.
# shellcheck disable=SC2016 # remote $HOME must expand inside the guest
vm_ssh 'test "$($HOME/horneroctl welcome status --json 2> /dev/null | jq -r .data.show_on_login 2> /dev/null)" = "false" || $HOME/horneroctl welcome status | grep -qi "show on login: false"' || fail "opt-out not persisted"
restart_shell "welcome-flow-4"
STATUS="$(welcome_status)" || fail "welcome status (flow 4)"
[[ "$(printf '%s' "${STATUS}" | jq -r '.open')" == "false" ]] || fail "opted-out login still opened welcome"
grab "welcome-opted-out-desktop.png"

# 9. Flow 5: manual reopen as a reference center -------------------------------
echo "==> flow 5: manual reopen"
# shellcheck disable=SC2016
# `welcome open` shells out to `qs` in the guest; point it at whichever
# Quickshell binary provision installed.
# shellcheck disable=SC2016 # remote expansions must happen inside the guest
QS_BIN="$(vm_ssh 'command -v qs || command -v quickshell')" || fail "no quickshell binary in guest"
[[ -n "${QS_BIN}" ]] || fail "no quickshell binary in guest"
# shellcheck disable=SC2016 # remote $HOME must expand inside the guest
vm_ssh "HORNERO_QS_BIN=${QS_BIN} \$HOME/horneroctl welcome open learn > /dev/null" || fail "manual open"
sleep 3
STATUS="$(welcome_status)" || fail "welcome status (flow 5)"
[[ "$(printf '%s' "${STATUS}" | jq -r '.open')" == "true" ]] || fail "manual open did not open"
[[ "$(printf '%s' "${STATUS}" | jq -r '.page')" == "learn" ]] || fail "manual open landed on wrong page"
grab "welcome-manual-learn.png"
# shellcheck disable=SC2016
vm_ssh "${HYPENV}
${QS_CALL} welcome open personalize" > /dev/null || fail "ipc open personalize"
sleep 2
STATUS="$(welcome_status)" || fail "welcome status (ipc)"
[[ "$(printf '%s' "${STATUS}" | jq -r '.page')" == "personalize" ]] || fail "ipc open landed on wrong page"
grab "welcome-manual-personalize.png"

# 10. Logs --------------------------------------------------------------------
vm_ssh 'tail -n 200 /tmp/hypr.log' > "${VM_ARTIFACTS_DIR}/logs/hyprland.log" 2> /dev/null || true
vm_ssh 'cat /tmp/qs.log' > "${VM_ARTIFACTS_DIR}/logs/shell.log" 2> /dev/null || true

# 11. Report -------------------------------------------------------------------
GIT_SHA="$(git -C "${SHELL_ROOT}" rev-parse --short HEAD 2> /dev/null || echo unknown)"
GIT_SHA_FULL="$(git -C "${SHELL_ROOT}" rev-parse HEAD 2> /dev/null || echo unknown)"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
jq -n \
    --arg ts "${TS}" \
    --arg sha "${GIT_SHA}" \
    --arg shell_full "${GIT_SHA_FULL}" \
    --arg kernel "$(vm_ssh 'uname -r')" \
    '{
        timestamp: $ts,
        git_sha: $sha,
        scenario: "vm-welcome",
        composition: {
            manifest: "config-pin",
            shell_sha: $shell_full
        },
        assertions: {
            first_login_auto_open: true,
            first_login_page_start: true,
            repeat_login_auto_open: true,
            reload_same_session_silent: true,
            optout_write_persisted: true,
            optout_login_silent: true,
            manual_open_learn: true,
            ipc_open_personalize: true,
            screenshots_nonblank: true,
            kernel: $kernel
        },
        result: "PASS"
    }' > "${VM_ARTIFACTS_DIR}/assertions.json"

echo "==> vm-welcome PASS"
echo "    shots:  ${SHOT_DIR}/welcome-*.png"
echo "    report: ${VM_ARTIFACTS_DIR}/assertions.json"
