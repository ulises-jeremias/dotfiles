#!/usr/bin/env bash
# Wait until SSH answers inside the E2E VM (first boot takes a few minutes).

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

TIMEOUT="${1:-300}"
DEADLINE=$((SECONDS + TIMEOUT))

echo "==> waiting up to ${TIMEOUT}s for SSH on localhost:${E2E_SSH_PORT}"
while ((SECONDS < DEADLINE)); do
	if e2e_ssh_ready; then
		echo "==> SSH ready"
		exit 0
	fi
	sleep 5
done

echo "error: SSH did not come up within ${TIMEOUT}s" >&2
echo "check ${E2E_ARTIFACTS_DIR}/console.log for boot output" >&2
exit 1
