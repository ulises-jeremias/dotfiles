#!/usr/bin/env bash

# This file assumes that it is being executed at ../scripts
# and there is a ROOT variable pointing to it

pkg_install() {
  if [ -f "${ROOT}/../debian/pkgs/$1" ]; then
    bash "${ROOT}"/../debian/pkgs/"$1"
    return $?
  fi
  sudo apt install "$1" -y
  return $?
}

pkg_exists() {
  [ -f "${ROOT}/../debian/pkgs/$1" ] || apt search "$1"
  return $?
}

update_db() {
  sudo apt update
  return $?
}
