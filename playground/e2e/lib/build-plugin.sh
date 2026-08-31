#!/usr/bin/env bash
# Build and install the Hornero Quickshell C++ plugin inside the VM.

set -euo pipefail

E2E_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "${E2E_LIB_DIR}/env.sh"

e2e_ssh_ready || {
	echo "error: VM SSH is not up. Run lib/run.sh + lib/wait-ssh.sh first." >&2
	exit 1
}

GIT_SHA="$(git -C "${DOTFILES_ROOT}" rev-parse HEAD 2> /dev/null || echo unknown)"

echo "==> building Hornero Quickshell plugin"
e2e_ssh "cmake -S ~/.config/quickshell \
	-B ~/.cache/dots/quickshell/build \
	-G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=~/.local/lib/quickshell \
	-DINSTALL_QMLDIR=~/.local/lib/quickshell/qml \
	-DVERSION=0.0.0 \
	-DGIT_REVISION=${GIT_SHA} \
	-Wno-dev" > /dev/null

e2e_ssh 'cmake --build ~/.cache/dots/quickshell/build -j' > /dev/null
e2e_ssh 'cmake --install ~/.cache/dots/quickshell/build' > /dev/null
e2e_ssh 'test -f ~/.local/lib/quickshell/qml/Hornero/qmldir' \
	|| {
		echo "error: plugin install did not produce the Hornero QML module" >&2
		exit 1
	}
echo "==> plugin installed"
