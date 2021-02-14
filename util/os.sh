#!/usr/bin/env bash

is_darwin() {
	uname -a | grep Darwin > /dev/null;
}

if [ -z "${os}" ]; then
    # Find the current distribution
    if [ -f /etc/os-release ]; then
        if grep -q arch /etc/os-release; then
            os="arch-linux"
        elif grep -q debian /etc/os-release; then
            os="debian"
        elif grep -q void /etc/os-release; then
            os="void-linux"
        elif grep -q alpine /etc/os-release; then
            os="alpine"
        elif grep -q fedora /etc/os-release; then
            os="fedora"
        else
            echo "ERROR: I currently don't have support for your distro"
            exit 1
        fi
    else
        if is_darwin; then
            os="darwin"
        else
            echo "Error: cannot detect platform"
            exit 1
        fi
    fi
fi

oss=( arch-linux debian )

if [[ ! " ${oss[*]} " = *"${os}"* ]]; then
    echo "${os} is not supported"
    exit 1
fi
