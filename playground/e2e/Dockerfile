FROM archlinux:base-devel

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

RUN mkdir -p /workspace /vm /artifacts /ssh
WORKDIR /workspace
