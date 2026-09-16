#!/usr/bin/env bash
# Install the desktop stack inside the harness VM (idempotent: skipped when
# the guest marker file exists, so repeat runs only re-provision explicitly).
# Usage: provision.sh [--dry-run]
#
# Quickshell ships through the AUR, so provisioning bootstraps yay first and
# then installs quickshell plus the Qt6 modules the shell needs. This is the
# slowest harness stage on first boot; afterwards the marker makes it instant.

set -euo pipefail

VM_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/vm/lib/env.sh
# shellcheck disable=SC1091 # path resolves at runtime; use shellcheck -x to follow it
source "${VM_LIB_DIR}/env.sh"

if [[ "${1:-}" == "--help" ]]; then
    echo "usage: provision.sh [--dry-run]"
    exit 0
fi
if [[ "${1:-}" == "--dry-run" ]]; then
    export VM_DRY_RUN=1
fi

if vm_is_dry_run; then
    echo "dry-run: would pin guest DNS to ${VM_GUEST_DNS} when DHCP DNS does not resolve"
    echo "dry-run: would check guest free disk space (fail fast below ${VM_MIN_GUEST_FREE_GB} GB)"
    echo "dry-run: would install guest packages (pacman incl. cmake, libqalculate + AUR quickshell)"
    echo "dry-run: would enable seatd and grant seat/video/render groups"
    echo "dry-run: would write the provision marker when done"
    exit 0
fi

vm_ssh_ready || {
    echo "error: VM SSH is not up. Run lib/boot.sh + lib/wait-ssh.sh first." >&2
    exit 1
}

echo "==> ensuring guest DNS resolves (needs ${VM_GUEST_DNS} when DHCP DNS is LAN-only)"
if vm_ssh 'getent hosts archlinux.org > /dev/null 2>&1'; then
    echo "==> guest DNS already resolves"
else
    echo "==> guest DNS broken, pinning ${VM_GUEST_DNS} (runtime plus persistent)"
    # Remote expansions below must happen on the guest, except VM_GUEST_DNS
    # which is a host-side harness knob baked into the drop-in. Persistence
    # is a .d/ override on the .network file that actually manages eth0
    # (cloud-init's 10-cloud-init-eth0.network outranks any standalone
    # file we could add, so a standalone file would be silently ignored).
    # Applied with `networkctl reload`, never a networkd restart: a full
    # restart drops the DHCP lease and never recovers under QEMU slirp,
    # while reload re-reads the drop-in on the live link.
    # The pin itself is retried: right after SSH comes up resolved may
    # not be ready yet, so a single-shot pin can miss and the probe loop
    # alone would never recover (proven: no drop-in written, retries
    # failed against the still-broken link DNS).
    pinned=0
    for _ in $(seq 1 6); do
        # shellcheck disable=SC2016
        vm_ssh "sudo resolvectl dns eth0 ${VM_GUEST_DNS} && \
            sudo rm -f /etc/systemd/network/10-harness-dns.network && \
            netfile=\$(networkctl status eth0 --no-pager 2>/dev/null | awk -F': ' '/Network File:/{ print \$2 }' | xargs -r basename) && \
            if [ -n \"\$netfile\" ]; then \
                sudo mkdir -p /etc/systemd/network/\"\${netfile}.d\" && \
                printf '[Network]\nDNS=${VM_GUEST_DNS}\n\n[DHCPv4]\nUseDNS=no\n' | \
                sudo tee /etc/systemd/network/\"\${netfile}.d\"/10-harness-dns-override.conf > /dev/null; \
            else \
                sudo mkdir -p /etc/systemd/network && \
                printf '[Match]\nName=eth0\n\n[Network]\nDHCP=yes\nDNS=${VM_GUEST_DNS}\n\n[DHCPv4]\nUseDNS=no\n' | \
                sudo tee /etc/systemd/network/05-harness-dns.network > /dev/null; \
            fi && \
            sudo networkctl reload" || true
        sleep 5
        # shellcheck disable=SC2016
        if vm_ssh 'getent hosts archlinux.org > /dev/null 2>&1'; then pinned=1; break; fi
        sleep 5
    done
    if [[ "${pinned}" != 1 ]]; then
        echo "error: guest DNS still broken after pinning ${VM_GUEST_DNS}" >&2
        exit 1
    fi
    echo "==> guest DNS resolves via ${VM_GUEST_DNS}"
fi

echo "==> checking guest free disk space (need ${VM_MIN_GUEST_FREE_GB} GB)"
# shellcheck disable=SC2016
guest_free_kb="$(vm_ssh 'df --output=avail -k / | tail -n 1' | tr -d '[:space:]')"
if [[ "${guest_free_kb}" -lt "$((VM_MIN_GUEST_FREE_GB * 1024 * 1024))" ]]; then
    echo "error: guest has only $((guest_free_kb / 1024)) MB free, need ${VM_MIN_GUEST_FREE_GB} GB." >&2
    echo "hint: enlarge the image with: qemu-img resize <image> +12G (see boot.sh capacity step)" >&2
    exit 1
fi

if vm_ssh 'test -f ~/.cache/vm-harness-provisioned' > /dev/null 2>&1; then
    echo "==> VM already provisioned"
    exit 0
fi

echo "==> installing guest desktop stack (this takes a while on first boot)"
# Remote script on purpose: every expansion below must happen on the guest.
# shellcheck disable=SC2016
vm_ssh 'sudo pacman -Sy --noconfirm --needed --overwrite "/usr/lib/*" \
    hyprland xdg-desktop-portal-hyprland \
    pipewire wireplumber pipewire-pulse \
    seatd polkit \
    grim slurp wf-recorder \
    kitty qt6-base qt6-declarative qt6-svg qt6-multimedia qt6-wayland \
    base-devel cmake git curl jq \
    pipewire-jack aubio libqalculate \
    noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-material-symbols-variable'

echo "==> bootstrapping yay for AUR packages (quickshell)"
# shellcheck disable=SC2016
vm_ssh 'if ! command -v yay > /dev/null; then \
    rm -rf /tmp/yay-bin && git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && \
    (cd /tmp/yay-bin && makepkg -si --noconfirm) && rm -rf /tmp/yay-bin; fi'

echo "==> installing quickshell from the AUR"
# shellcheck disable=SC2016
vm_ssh 'yay -S --noconfirm --needed quickshell-git'

echo "==> granting DRM and seat access"
# SSH sessions have no logind seat, so seatd handles DRM device access.
# shellcheck disable=SC2016
vm_ssh 'sudo systemctl enable --now seatd && \
    sudo gpasswd -a "$USER" seat > /dev/null && \
    sudo gpasswd -a "$USER" video > /dev/null && \
    sudo gpasswd -a "$USER" render > /dev/null'

vm_ssh 'mkdir -p ~/.cache && touch ~/.cache/vm-harness-provisioned'
echo "==> provisioned"
