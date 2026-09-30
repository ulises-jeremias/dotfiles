#!/usr/bin/env bash
# Verify every file under home/ reaches a managed machine.
# Copyright (C) 2019-2026 Ulises Jeremias Cornejo Fandos
# Licensed under MIT.
#
# A repo file with no delivery path is a silent gap: it exists in git but
# never lands on a host (e.g. a dotfile-named source like `.editorconfig`
# that chezmoi ignores because it lacks the `dot_` prefix). This gate
# resolves each tracked file to its chezmoi target and fails on orphans.
#
# Usage:
#   ./scripts/verify-delivery.sh   # exit 1 on any undelivered file
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Source trees delivered by execution, not by file mapping; plus chezmoi's
# own machinery (.chezmoiignore and friends are consumed, never deployed).
EXCLUDE_RE='^home/\.chezmoiscripts/|^home/\.chezmoi'
# Mirror metadata: upstream repo scaffolding synced for reference that must
# never deploy to a host. (Empty since contract C, hornero#81: the
# quickshell mirror was removed from this repo; keep the array for the
# next such consumer.)
EXCLUDE_DIRS=(
)

# Intentional orphans: repo-hygiene files chezmoi never deploys —
# lint-only configs that must keep their literal names in the repo tree
# (renaming to dot_ form would break the linters discovering them here),
# and .gitignore files, which are repo-only by nature.
KNOWN_ORPHANS=(
)
ORPHAN_SUFFIXES=(
	'/.gitignore'
	'/.pre-commit-config.yaml'
	'/.yamllint.yaml'
	'/.markdownlint.yaml'
)

is_known_orphan() {
	local f="$1" o s
	for o in "${KNOWN_ORPHANS[@]}"; do
		[[ $f == "$o" ]] && return 0
	done
	for s in "${ORPHAN_SUFFIXES[@]}"; do
		[[ $f == *"$s" ]] && return 0
	done
	return 1
}

if ! command -v chezmoi > /dev/null 2>&1; then
	echo "SKIP: chezmoi not on PATH (delivery check)"
	exit 0
fi

# Run under the managed-host profile: private_* files deploy only when
# personal=true, and .chezmoiignore.tmpl needs the full data set. Prefer
# the operator's real config; otherwise synthesize the managed-host
# equivalent. Mapping-only queries (no secrets render for these).
if [[ -f "${HOME}/.config/chezmoi/dotfiles.toml" ]]; then
	CHEZMOI_CFG="${HOME}/.config/chezmoi/dotfiles.toml"
else
	CHEZMOI_CFG="$(mktemp)"
	printf '[data]\n  personal = true\n  ephemeral = false\n  headless = false\n  hostname = "generic"\n  osid = "linux-arch"\n' > "$CHEZMOI_CFG"
	trap 'rm -f "$CHEZMOI_CFG"' EXIT
fi

fail=0
while IFS= read -r src; do
	[[ $src =~ $EXCLUDE_RE ]] && continue
	excluded_dir=0
	for d in "${EXCLUDE_DIRS[@]}"; do
		if [[ $src == "$d"* ]]; then
			excluded_dir=1
			break
		fi
	done
	[[ $excluded_dir -eq 1 ]] && continue
	if is_known_orphan "$src"; then
		continue
	fi
	# Round-trip proof: source -> target -> source must land back here,
	# otherwise chezmoi never deploys this file to any host.
	target="$(chezmoi --source "$ROOT" --config "$CHEZMOI_CFG" target-path "${ROOT}/${src}" 2> /dev/null || true)"
	if [[ -z $target ]]; then
		echo "FAIL: undelivered file (no chezmoi target): $src" >&2
		fail=1
		continue
	fi
	back="$(chezmoi --source "$ROOT" --config "$CHEZMOI_CFG" source-path "$target" 2> /dev/null || true)"
	if [[ $back != "${ROOT}/${src}" ]]; then
		echo "FAIL: unmanaged target: $src -> $target" >&2
		fail=1
	fi
done < <(git -C "$ROOT" ls-files 'home/**' || true)

if [[ $fail -ne 0 ]]; then
	echo "❌ delivery verification failed" >&2
	exit 1
fi
echo "✅ every repo file has a delivery path"
