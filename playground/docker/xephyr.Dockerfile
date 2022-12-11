ARG UBUNTU_VERSION=latest

FROM ubuntu:${UBUNTU_VERSION} as base
# UBUNTU_VERSION is specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)

RUN apt-get update \
    && apt-get install -qqy xserver-xephyr \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
