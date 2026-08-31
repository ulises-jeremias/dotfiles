#!/usr/bin/env bash
# Capture a screenshot of the VM desktop via grim.
# Usage: screenshot.sh [output.png]

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

out="${1:-${E2E_ARTIFACTS_DIR}/screenshots/desktop.png}"
mkdir -p "$(dirname "${out}")"

e2e_ssh_ready || {
	echo "error: VM SSH is not up" >&2
	exit 1
}

e2e_ssh "$(e2e_hypr_env)
grim /tmp/e2e-screenshot.png"
e2e_scp "${E2E_SSH_USER}@127.0.0.1:/tmp/e2e-screenshot.png" "${out}"
echo "==> screenshot saved to ${out}"
