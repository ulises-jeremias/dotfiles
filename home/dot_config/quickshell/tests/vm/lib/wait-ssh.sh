#!/usr/bin/env bash
# Wait until SSH answers inside the harness VM (first boot takes a while
# because cloud-init provisions the guest on first start).
# Usage: wait-ssh.sh [timeout-seconds] [--dry-run]

set -euo pipefail

VM_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/vm/lib/env.sh
# shellcheck disable=SC1091 # path resolves at runtime; use shellcheck -x to follow it
source "${VM_LIB_DIR}/env.sh"

TIMEOUT=300
for arg in "$@"; do
    case "${arg}" in
        --help)
            echo "usage: wait-ssh.sh [timeout-seconds] [--dry-run]"
            exit 0
            ;;
        --dry-run)
            export VM_DRY_RUN=1
            ;;
        *)
            TIMEOUT="${arg}"
            ;;
    esac
done

if vm_is_dry_run; then
    echo "dry-run: would wait up to ${TIMEOUT}s for SSH on localhost:${VM_SSH_PORT}"
    exit 0
fi

echo "==> waiting up to ${TIMEOUT}s for SSH on localhost:${VM_SSH_PORT}"
DEADLINE=$((SECONDS + TIMEOUT))
while ((SECONDS < DEADLINE)); do
    if vm_ssh_ready; then
        echo "==> SSH ready"
        exit 0
    fi
    sleep 5
done

echo "error: SSH did not come up within ${TIMEOUT}s" >&2
echo "check ${VM_ARTIFACTS_DIR}/console.log for boot output" >&2
exit 1
