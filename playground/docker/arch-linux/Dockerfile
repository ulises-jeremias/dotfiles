ARG ARCHLINUX_VERSION=latest

FROM archlinux:${ARCHLINUX_VERSION} as base
# ARCHLINUX_VERSION is specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)

ARG ARCHLINUX_VERSION
ARG WINDOW_MANAGER
ARG USER=test

# Needed for string substitution
SHELL ["/bin/bash", "-c"]

RUN \
    # Check for mandatory build arguments: WINDOW_MANAGER
    : "${WINDOW_MANAGER:?Build argument `WINDOW_MANAGER` needs to be set and non-empty.}"

# Add [multilib] to mirrolist since some deps come from that mirror
RUN echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" > /tmp/multilib \
    && cat /etc/pacman.conf /tmp/multilib > /tmp/pacman.conf \
    && mv /tmp/pacman.conf /etc/pacman.conf

# Install base deps for development
RUN pacman -Syyu --noconfirm \
    && pacman -S --noconfirm \
        base-devel \
        git \
        sudo \
        neovim \
        xorg-server \
        xorg-xinit \
    && rm -rf /tmp/* /var/tmp/*

ENV EDITOR nvim

RUN useradd -m ${USER} \
    && passwd -d ${USER} \
    && sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers \
    && echo "${USER} ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} \
    && usermod -a -G wheel ${USER} \
    && rm -rf /home/${USER}/.bashrc

# Install yay - https://github.com/Jguer/yay
ARG YAY_VERSION=10.0.4
ENV YAY_FOLDER=yay_${YAY_VERSION}_x86_64
RUN cd /tmp \
    && curl -L https://github.com/Jguer/yay/releases/download/v${YAY_VERSION}/${YAY_FOLDER}.tar.gz | tar zx \
    && install -Dm755 ${YAY_FOLDER}/yay /usr/bin/yay \
    && install -Dm644 ${YAY_FOLDER}/yay.8 /usr/share/man/man8/yay.8

# Install and setup given window manager
COPY docker/arch-linux/wm/${WINDOW_MANAGER}.sh /tmp/wm-setup.sh
RUN chmod a+rwx /tmp/wm-setup.sh && /tmp/wm-setup.sh

# Set correct locale
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "LANG=en_US.UTF-8" > /etc/locale.conf

RUN locale-gen en_US.UTF-8
ENV LC_CTYPE 'en_US.UTF-8'
ENV LANG C.UTF-8

COPY docker/arch-linux/.bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
