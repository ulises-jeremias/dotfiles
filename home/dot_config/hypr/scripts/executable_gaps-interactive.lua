#!/usr/bin/env lua

-- Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
-- Licensed under MIT.
--
-- Interactive gaps management for Hyprland
-- Equivalent to i3-gaps interactive gap mode
-- (Lua port of the former gaps-interactive.sh.)

local helper = (os.getenv("HOME") or "") .. "/.local/bin/hyprland-runtime.lua"

local function shell_quote(value)
	return string.format("%q", value)
end

local function capture(cmd)
	local fh = io.popen(cmd, "r")
	if not fh then
		return ""
	end
	local out = fh:read("*a") or ""
	fh:close()
	return out
end

local function run_helper(...)
	local parts = { "lua", shell_quote(helper) }
	for _, part in ipairs({ ... }) do
		parts[#parts + 1] = shell_quote(part)
	end
	local ok, _, code = os.execute(table.concat(parts, " "))
	if not ok then
		os.exit(code or 1)
	end
end

local function get_gap(which)
	local out = capture(
		string.format("lua %s get-gap %s", shell_quote(helper), shell_quote(which))
	)
	local custom = out:match('"custom"%s*:%s*"([^"]*)"') or ""
	return custom:match("^%S+") or ""
end

local function command_exists(name)
	local ok = os.execute(string.format("command -v %s >/dev/null 2>&1", shell_quote(name)))
	return ok == true or ok == 0
end

local menu_options = {
	"Increase (+5)",
	"Decrease (-5)",
	"Increase All (Shift +5)",
	"Decrease All (Shift -5)",
	"Set to zero",
	"Restore defaults",
}

local function show_menu(title)
	print(title)
	for i, option in ipairs(menu_options) do
		print(string.format("%d) %s", i, option))
	end
	io.write("Choice [1-6]: ")
	io.flush()
	local n = io.read("*l")
	if not n then
		return nil
	end
	return menu_options[tonumber(n)]
end

print("Gaps Mode")
print("1) Inner Gaps")
print("2) Outer Gaps")
io.write("Choice [1-2]: ")
io.flush()
local main_n = io.read("*l")
if not main_n then
	os.exit(1)
end

local which, label, default_gap
if main_n == "1" then
	which, label, default_gap = "inner", "Inner Gaps", "6"
elseif main_n == "2" then
	which, label, default_gap = "outer", "Outer Gaps", "18"
else
	os.exit(1)
end

local current = get_gap(which)
local choice = show_menu(string.format("%s (current: %s)", label, current))
if not choice then
	os.exit(1)
end

if choice == "Increase (+5)" or choice == "Increase All (Shift +5)" then
	run_helper("adjust-gap", which, "5")
elseif choice == "Decrease (-5)" or choice == "Decrease All (Shift -5)" then
	run_helper("adjust-gap", which, "-5")
elseif choice == "Set to zero" then
	run_helper("set-gap", which, "0")
elseif choice == "Restore defaults" then
	run_helper("set-gap", which, default_gap)
end

if command_exists("notify-send") then
	os.execute(
		string.format(
			"notify-send %s %s -t 2000",
			shell_quote("Gaps Updated"),
			shell_quote(string.format("Inner: %s | Outer: %s", get_gap("inner"), get_gap("outer")))
		)
	)
end
