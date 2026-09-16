#!/usr/bin/env bash
# Verify a VM image against its published SHA256 sidecar.
# Usage: verify-image.sh [--dry-run] <image> <sha256-url>
#
# Downloads the sidecar (sha256sum format, first field wins) to a temp file
# and compares it with the local image digest. The cached image is verified
# on every run, so a swapped or bitrotted cache is caught before boot.
# Exit 0 match; 1 mismatch/unreadable/unfetchable; 2 usage.
set -euo pipefail

VM_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/vm/lib/env.sh
# shellcheck disable=SC1091 # path resolves at runtime; use shellcheck -x to follow it
source "${VM_LIB_DIR}/env.sh"

if [[ "${1:-}" == "--help" ]]; then
    echo "usage: verify-image.sh [--dry-run] <image> <sha256-url>"
    exit 0
fi
if [[ "${1:-}" == "--dry-run" ]]; then
    echo "dry-run: would fetch ${2:-<sha256-url>} and compare with sha256sum of ${3:-<image>}"
    exit 0
fi
if [[ "$#" -ne 2 ]]; then
    vm_usage_error "expected <image> <sha256-url>" "verify-image.sh [--dry-run] <image> <sha256-url>"
fi

image="$1"
sidecar_url="$2"

[[ -f "${image}" ]] || {
    echo "error: image not found: ${image}" >&2
    exit 1
}
command -v sha256sum > /dev/null || {
    echo "error: sha256sum is required for image verification" >&2
    exit 1
}

sidecar="$(mktemp)"
trap 'rm -f "${sidecar}"' EXIT
curl -fSL --retry 3 -o "${sidecar}" "${sidecar_url}" || {
    echo "error: could not fetch checksum sidecar: ${sidecar_url}" >&2
    exit 1
}

expected="$(awk '{ print $1; exit }' "${sidecar}")"
[[ "${expected}" =~ ^[0-9a-fA-F]{64}$ ]] || {
    echo "error: sidecar has no valid SHA256 digest: ${sidecar_url}" >&2
    exit 1
}
actual="$(sha256sum "${image}" | awk '{ print $1 }')"
if [[ "${actual,,}" != "${expected,,}" ]]; then
    echo "error: checksum mismatch for ${image}" >&2
    echo "  expected: ${expected}" >&2
    echo "  actual:   ${actual}" >&2
    exit 1
fi
echo "verified: ${image} matches ${sidecar_url}"
