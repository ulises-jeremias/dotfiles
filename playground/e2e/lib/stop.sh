#!/usr/bin/env bash
# Stop the E2E VM and remove the container (disk image is cached).

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

if docker ps -a --format '{{.Names}}' | grep -q "^${E2E_CONTAINER_NAME}$"; then
	echo "==> removing container ${E2E_CONTAINER_NAME}"
	docker rm -f "${E2E_CONTAINER_NAME}" > /dev/null
else
	echo "==> no container to remove"
fi
