#!/usr/bin/env bash

set -euo pipefail

# exit immediately if lastpass-cli is already in $PATH
type lpass >/dev/null 2>&1 && exit

case "$(uname -s)" in
Linux)
	if [ -f /etc/os-release ]; then
		if grep -q arch /etc/os-release; then
			sudo pacman -S lastpass-cli
		else
			echo "unsupported OS. Ignoring lastpass-cli installation"
			exit 0
		fi
	else
		echo "Ignoring lastpass-cli installation on Linux"
		exit 0
	fi
	;;
*)
	echo "unsupported OS. Ignoring lastpass-cli installation"
	exit 0
	;;
esac
