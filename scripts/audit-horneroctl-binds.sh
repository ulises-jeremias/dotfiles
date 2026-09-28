#!/usr/bin/env bash
# Audit every `horneroctl ...` invocation in desktop configs resolves.
# Copyright (C) 2019-2026 Ulises Jeremias Cornejo Fandos
# Licensed under MIT.
#
# No silent no-op keybindings: each verb path fired by Hyprland binds,
# autostart entries, .desktop launchers, and installer scripts must exist
# in the installed horneroctl. The handled set is derived live from
# `horneroctl --help`, so a new verb is picked up with no manifest update.
#
# Usage:
#   ./scripts/audit-horneroctl-binds.sh   # exit 1 on any unhandled command
#
# Skips cleanly (exit 0) when horneroctl is not on PATH, e.g. minimal CI
# images: verb contracts are enforced by horneroctl's own repo CI.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v horneroctl > /dev/null 2>&1; then
	echo "SKIP: horneroctl not on PATH (bind audit)"
	exit 0
fi

declare -A HANDLED=()
# Parent path -> space-separated verb prefixes from `set-*` style globs.
declare -A GLOBS=()
# Full --help text per walked node, for value-domain checks.
declare -A HELP=()

# Walk the --help tree. Subgroups, set-* globs, and <a|b> leaves that own
# subcommands all recurse (depth-capped). `ipc -- <qs-args>` ends the
# walk. Value domains resolve at match time from each parent's --help
# body (see value_accepted).
walk() {
	local depth="$1"
	shift
	local prefix=("$@")
	local out usage_line token alt pending=""
	out="$(horneroctl "${prefix[@]}" --help 2> /dev/null)" || return 0
	usage_line="$(printf '%s\n' "$out" | grep -m1 '^Usage: horneroctl' || true)"
	[[ -n $usage_line ]] || return 0
	HANDLED["${prefix[*]}"]=1
	HELP["${prefix[*]}"]="$out"
	[[ $depth -ge 4 ]] && return 0
	# Strip everything up to the current prefix, then inspect tokens.
	usage_line="${usage_line#*horneroctl ${prefix[*]}}"
	usage_line="${usage_line#"${usage_line%%[![:space:]]*}"}"
	for token in $usage_line; do
		case "$token" in
			'--'*)
				# ipc passthrough and option terminators end this branch.
				return 0
				;;
			'<'*'>'|'\['*'\]')
				# Strip brackets, then split pipe alternations. A bare
				# `set-*` becomes a glob; `[...]` without pipes and
				# without placeholders carries flags only.
				inner="$token"
				[[ $inner == '['*']' ]] && inner="${inner#\[}" && inner="${inner%\]}"
				inner="${inner#<}"
				inner="${inner%>}"
				if [[ $inner != *'|'* ]]; then
					if [[ $inner == *'*' ]]; then
						GLOBS["${prefix[*]}"]+="${inner%\*} "
					fi
					pending=""
					continue
				fi
				IFS='|' read -r -a parts <<< "$inner" || true
				for alt in "${parts[@]}"; do
					if [[ -z $alt ]]; then
						continue
					fi
					if [[ $alt == *'*' ]]; then
						GLOBS["${prefix[*]}"]+="${alt%\*} "
						continue
					fi
					HANDLED["${prefix[*]} $alt"]=1
					# Leaves may own subcommands (theme>apply).
					walk $((depth + 1)) "${prefix[@]}" "$alt"
				done
				pending=""
				;;
			*'...'* | *'=='* | *'|'*)
				continue
				;;
			*)
				if [[ $token =~ ^[a-z][a-z-]*$ || $token =~ ^[a-z][a-z-]*\*$ ]]; then
					pending="${token%\*}"
					walk $((depth + 1)) "${prefix[@]}" "$pending"
				fi
				;;
		esac
	done
}

# Seed the walk from every top-level group in the root usage.
root_groups="$(horneroctl --help 2> /dev/null | grep -oE '^\s+[a-z][a-z-]+' | tr -d ' ' | sort -u || true)"
for group in $root_groups; do
	walk 1 "$group"
done

# IPC targets and functions come from the shell's IPC contract table
# (docs/IPC.md rows: | `target` | source | `fn()`, ... |). Drawer names
# themselves are dynamic runtime state, so only target+function resolve.
IPC_DOC="${ROOT}/home/dot_config/quickshell/docs/IPC.md"
declare -A IPC_FNS=()
if [[ -f $IPC_DOC ]]; then
	while IFS= read -r row; do
		target="$(printf '%s' "$row" | grep -oE '`[a-zA-Z]+`' | head -n 1 | tr -d '`' || true)"
		fns="$(printf '%s' "$row" | cut -d'|' -f3- || true)"
		if [[ -n $target && -n $fns ]]; then
			IPC_FNS["$target"]="$fns"
		fi
	done < <(grep -E '^\| `' "$IPC_DOC" || true)
fi

fail=0
check_invocation() {
	local inv="$1" origin="$2"
	local -a toks=()
	read -r -a toks <<< "$inv"
	local -a path=()
	local i t
	for ((i = 0; i < ${#toks[@]}; i++)); do
		t="${toks[$i]}"
		[[ $t == horneroctl ]] && continue
		if [[ $t == -- ]]; then
			# qs-ipc passthrough: `call <target> <fn> ...`; both must
			# exist in the shell IPC contract table.
			if [[ ${toks[$((i + 1))]:-} == call ]]; then
				local target="${toks[$((i + 2))]:-}" fn="${toks[$((i + 3))]:-}"
				if [[ -z ${IPC_FNS[$target]:-} ]]; then
					echo "FAIL: unknown ipc target '$target' in '$inv' ($origin)" >&2
					fail=1
				elif [[ ${IPC_FNS[$target]} != *"$fn("* ]]; then
					echo "FAIL: unknown ipc function '$fn' on target '$target' in '$inv' ($origin)" >&2
					fail=1
				fi
			fi
			break
		fi
		case "$t" in
			-* | *'/'* | *'$'* | *'<'* | *'>'* | *'='* | *'.'* | *'{'* | *'}'*)
				break
				;;
			'') continue ;;
			*) path+=("$t") ;;
		esac
	done
	if [[ ${#path[@]} -eq 0 ]]; then
		return 0
	fi
	local key="${path[*]}"
	# An exact handled node always resolves. Otherwise the trailing token
	# must satisfy the parent verb's value domain (enum member or free
	# value per the parent's own --help body).
	local probe="$key" found=0
	while [[ -n $probe ]]; do
		if node_resolves "$probe"; then
			if [[ $probe == "$key" ]]; then
				found=1
				break
			fi
			rest="${key#"$probe "}"
			if [[ $rest != *' '* ]] && value_accepted "$probe" "$rest"; then
				found=1
				break
			fi
		fi
		[[ $probe != *" "* ]] && break
		probe="${probe% *}"
	done
	if [[ $found -eq 0 ]]; then
		echo "FAIL: unhandled horneroctl invocation: '$inv' ($origin)" >&2
		fail=1
	fi
}

# Is a trailing value accepted after node? The node's parent --help body
# must document the node's verb with a placeholder: an alternation means
# enum (value must be a member), a free placeholder takes anything.
value_accepted() {
	local node="$1" value="$2"
	local parent="${node% *}" verb="${node##* }"
	local help="${HELP[$parent]:-}"
	[[ -n $help ]] || return 1
	local line ph inner
	while IFS= read -r line; do
		[[ $line =~ (^|[^a-zA-Z_-])$verb([^a-zA-Z_-]|$) ]] || continue
		for ph in $line; do
			case "$ph" in
				'<'*'>' | '\['*'<'*']')
					inner="$ph"
					[[ $inner == '['* ]] && inner="${inner#\[}" && inner="${inner%\]}"
					inner="${inner#<}"
					inner="${inner%>}"
					if [[ $inner == *'|'* ]]; then
						IFS='|' read -r -a members <<< "$inner" || true
						local m
						for m in "${members[@]}"; do
							[[ $value == "$m" ]] && return 0
						done
					else
						return 0
					fi
					;;
			esac
		done
	done <<< "$help"
	return 1
}

# A node resolves when recorded exactly or via a parent glob (set-*).
node_resolves() {
	local node="$1"
	[[ -n ${HANDLED[$node]:-} ]] && return 0
	local parent="${node% *}" leaf="${node##* }"
	[[ $parent == "$node" ]] && return 1
	local g
	for g in ${GLOBS[$parent]:-}; do
		[[ $leaf == "$g"* ]] && return 0
	done
	return 1
}

scan_file() {
	local file="$1" line inv
	while IFS= read -r line || [[ -n $line ]]; do
		while IFS= read -r inv; do
			[[ -n $inv ]] && check_invocation "$inv" "$file"
		done < <(printf '%s\n' "$line" | grep -oE 'horneroctl( [a-zA-Z0-9_./$-]+)+' || true)
	done < "$file"
}

while IFS= read -r -d '' file; do
	scan_file "$file"
done < <(find "${ROOT}/home/dot_config/hypr" "${ROOT}/home/dot_local/share/applications" "${ROOT}/home/.chezmoiscripts" \
	-type f \( -name '*.conf' -o -name '*.desktop' -o -name '*.tmpl' -o -name '*.sh' \) -print0 2> /dev/null)

if [[ $fail -ne 0 ]]; then
	echo "❌ horneroctl bind audit failed" >&2
	exit 1
fi
echo "✅ all horneroctl invocations resolve"
