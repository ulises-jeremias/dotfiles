#!/usr/bin/env lua

-- Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
-- Licensed under MIT.
--
-- Smart floating mode for Hyprland
-- Toggles floating, centers window, and sets a nice maximum size
-- (Lua port of the former smart-float.sh.)

local helper = (os.getenv("HOME") or "") .. "/.local/bin/hyprland-runtime.lua"

local MAX_WIDTH = 1400
local MAX_HEIGHT = 900

local function shell_quote(value)
	return string.format("%q", value)
end

local function capture(cmd)
	local fh = assert(io.popen(cmd, "r"))
	local out = fh:read("*a") or ""
	local ok, _, code = fh:close()
	if not ok then
		os.exit(code or 1)
	end
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

local function command_exists(name)
	local ok = os.execute(string.format("command -v %s >/dev/null 2>&1", shell_quote(name)))
	return ok == true or ok == 0
end

local function notify(title, body, urgency, timeout)
	if command_exists("notify-send") then
		os.execute(
			string.format(
				"notify-send %s %s -t %d -u %s",
				shell_quote(title),
				shell_quote(body),
				timeout,
				shell_quote(urgency)
			)
		)
	end
end

local window_info = capture("hyprctl activewindow -j")
local is_floating = window_info:match('"floating"%s*:%s*(%a+)')

local monitor_info = capture("hyprctl monitors -j")
local monitor_width = tonumber(monitor_info:match('"width"%s*:%s*(%d+)')) or 0
local monitor_height = tonumber(monitor_info:match('"height"%s*:%s*(%d+)')) or 0

local optimal_width = math.floor(monitor_width * 80 / 100)
local optimal_height = math.floor(monitor_height * 80 / 100)

local final_width = math.min(optimal_width, MAX_WIDTH)
local final_height = math.min(optimal_height, MAX_HEIGHT)

if is_floating == "false" then
	run_helper("toggle-float")
	run_helper("resize-active", tostring(final_width), tostring(final_height))
	run_helper("center")
	notify("Smart Float", string.format("Window: %dx%d", final_width, final_height), "low", 1500)
else
	run_helper("toggle-float")
	notify("Smart Float", "Window tiled", "low", 1500)
end
