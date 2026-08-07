# shellcheck shell=bash
# Resolve a Python interpreter that can import materialyoucolor.
# Prefer /usr/bin/python3 (Arch python-materialyoucolor) over pyenv shims.

dots_python_m3() {
	if [[ -x /usr/bin/python3 ]] && /usr/bin/python3 -c 'import materialyoucolor' > /dev/null 2>&1; then
		printf '%s\n' /usr/bin/python3
		return 0
	fi
	if command -v python3 > /dev/null 2>&1 && python3 -c 'import materialyoucolor' > /dev/null 2>&1; then
		command -v python3
		return 0
	fi
	return 1
}

# Run generate-m3-colors.py with the resolved interpreter.
# Usage: dots_run_m3_colors --image ... --output ...
dots_run_m3_colors() {
	local script="${DOTS_M3_SCRIPT:-$HOME/.local/lib/dots/generate-m3-colors.py}"
	local py
	[[ -f $script ]] || {
		echo "dots_run_m3_colors: missing $script" >&2
		return 1
	}
	py="$(dots_python_m3)" || {
		echo "dots_run_m3_colors: materialyoucolor not found (install python-materialyoucolor)" >&2
		return 1
	}
	"$py" "$script" "$@"
}
