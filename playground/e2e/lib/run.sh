#!/usr/bin/env bash
# Start the E2E VM (QEMU/KVM inside a Docker container).
# Idempotent: skips work that is already done (image, seed, container).

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

mkdir -p "${E2E_SSH_DIR}" "${E2E_ARTIFACTS_DIR}" "${E2E_CACHE_DIR}" "${E2E_SHARED_DIR}"

if ! command -v docker > /dev/null 2>&1; then
	echo "error: docker is required" >&2
	exit 1
fi

# --- ephemeral SSH key -------------------------------------------------------
if [[ ! -f ${E2E_SSH_KEY} ]]; then
	echo "==> generating ephemeral SSH key"
	ssh-keygen -t ed25519 -N '' -C dotfiles-e2e -f "${E2E_SSH_KEY}" > /dev/null
fi
E2E_SSH_PUBKEY="$(cat "${E2E_SSH_KEY}.pub")"

# --- container image ---------------------------------------------------------
if ! docker image inspect "${E2E_IMAGE}" > /dev/null 2>&1; then
	echo "==> building ${E2E_IMAGE}"
	docker build \
		--build-arg "KVM_GID=$(getent group kvm | cut -d: -f3)" \
		-t "${E2E_IMAGE}" "${E2E_ROOT}"
fi

# --- cloud image -------------------------------------------------------------
if [[ ! -f ${E2E_CLOUD_IMAGE} ]]; then
	echo "==> downloading Arch cloud image (cached after first run)"
	curl -fSL --retry 3 -o "${E2E_CLOUD_IMAGE}" "${E2E_CLOUD_IMAGE_URL}"
fi

# --- cloud-init seed (binds the current SSH key into the VM) -----------------
SEED_ISO="${E2E_CACHE_DIR}/seed.iso"
if [[ ! -f ${SEED_ISO} || ${SEED_ISO} -ot "${E2E_ROOT}/user-data.tmpl" ]]; then
	echo "==> building cloud-init seed ISO"
	sed "s|__E2E_SSH_PUBKEY__|${E2E_SSH_PUBKEY}|" \
		"${E2E_ROOT}/user-data.tmpl" > "${E2E_CACHE_DIR}/user-data"
	cp "${E2E_ROOT}/meta-data" "${E2E_CACHE_DIR}/meta-data"
	docker run --rm \
		-v "${E2E_CACHE_DIR}:/vm" \
		--entrypoint mkisofs \
		"${E2E_IMAGE}" \
		-output /vm/seed.iso \
		-volid cidata \
		-joliet -rock \
		/vm/user-data /vm/meta-data
fi

# --- VM container ------------------------------------------------------------
if e2e_vm_running; then
	echo "==> VM container already running"
	exit 0
fi
docker rm -f "${E2E_CONTAINER_NAME}" > /dev/null 2>&1 || true

# KVM acceleration when available, TCG fallback otherwise.
KVM_ARGS=(-enable-kvm -cpu host)
if [[ ! -w /dev/kvm ]]; then
	echo "warning: /dev/kvm not available, falling back to TCG (slow)" >&2
	KVM_ARGS=(-cpu max)
fi

echo "==> starting VM (mem=${E2E_VM_MEM}MB smp=${E2E_VM_SMP})"
docker run -d \
	--name "${E2E_CONTAINER_NAME}" \
	--network host \
	--device /dev/kvm \
	--group-add "$(getent group kvm | cut -d: -f3)" \
	-v "${E2E_CACHE_DIR}:/vm" \
	-v "${E2E_SSH_DIR}:/ssh" \
	-v "${E2E_ARTIFACTS_DIR}:/artifacts" \
	-v "${E2E_SHARED_DIR}:/shared" \
	"${E2E_IMAGE}" \
	qemu-system-x86_64 \
	"${KVM_ARGS[@]}" \
	-machine q35 \
	-smp "${E2E_VM_SMP}" \
	-m "${E2E_VM_MEM}" \
	-device virtio-vga \
	-drive "file=/vm/arch-cloudimg.qcow2,format=qcow2,if=virtio" \
	-drive "file=/vm/seed.iso,format=raw,if=virtio,media=cdrom,read-only=on" \
	-netdev "user,id=net0,hostfwd=tcp::${E2E_SSH_PORT}-:22" \
	-device virtio-net-pci,netdev=net0 \
	-display vnc=:0 \
	-serial "file:/artifacts/console.log" \
	-usb -device qemu-xhci -device usb-tablet > /dev/null

echo "==> VM started. VNC :0, SSH localhost:${E2E_SSH_PORT}, console: ${E2E_ARTIFACTS_DIR}/console.log"
