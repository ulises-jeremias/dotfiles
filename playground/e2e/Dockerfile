FROM archlinux:base-devel

# GID of the host "kvm" group. Override at build time if the host uses a
# different GID: docker build --build-arg KVM_GID=$(getent group kvm | cut -d: -f3)
ARG KVM_GID=78

RUN pacman -Sy --noconfirm --needed \
		qemu-desktop \
		qemu-img \
		openssh \
		curl \
		jq \
		python3 \
		cdrtools \
		bash \
	&& rm -rf /var/cache/pacman/pkg/*

RUN groupadd -o -g "${KVM_GID}" kvm 2> /dev/null || true \
	&& useradd -m -u 1000 -G kvm -s /bin/bash runner

RUN mkdir -p /workspace /vm /artifacts /ssh \
	&& chown -R runner:runner /workspace /vm /artifacts /ssh

WORKDIR /workspace

USER 1000

# The container is healthy while the QEMU process is alive.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
	CMD ["pgrep", "-f", "qemu-system"]
