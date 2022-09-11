ARG DEBIAN_VERSION=latest

FROM debian:${DEBIAN_VERSION} as base
# DEBIAN_VERSION is specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)

ARG DEBIAN_VERSION
ARG WINDOW_MANAGER
ARG USER=test

# Needed for string substitution
SHELL ["/bin/bash", "-c"]

RUN \
    # Check for mandatory build arguments: WINDOW_MANAGER
    : "${WINDOW_MANAGER:?Build argument `WINDOW_MANAGER` needs to be set and non-empty.}"

# Install base deps for development
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install \
        build-essential \
        git \
        net-tools \
        sudo \
        neovim \
        apt-utils \
        locales \
        git \
        g++ \
        libgtk-3-dev \
        gtk-doc-tools \
        gnutls-bin \
        valac \
        intltool \
        libpcre2-dev \
        libglib3.0-cil-dev \
        libgnutls28-dev \
        libgirepository1.0-dev \
        libxml2-utils \
        gperf \
        software-properties-common \
        xserver-xorg \
        xinit \
    && rm -rf /tmp/* /var/tmp/*

ENV EDITOR nvim

RUN useradd -m ${USER} \
    && passwd -d ${USER} \
    && sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers \
    && echo "${USER} ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} \
    && usermod -a -G sudo ${USER} \
    && rm -rf /home/${USER}/.bashrc

# Install and setup given window manager
COPY docker/debian/wm/${WINDOW_MANAGER}.sh /tmp/wm-setup.sh
RUN chmod a+rwx /tmp/wm-setup.sh && /tmp/wm-setup.sh

# Set correct locale
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "LANG=en_US.UTF-8" > /etc/locale.conf

RUN locale-gen en_US.UTF-8
ENV LC_CTYPE 'en_US.UTF-8'
ENV LANG C.UTF-8

ENV PATH=$PATH:$GOPATH/bin

COPY docker/debian/.bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
