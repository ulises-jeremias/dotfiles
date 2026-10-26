#!/usr/bin/env lua

-- Hyprland runtime helper (Lua port of the former bash helper).
-- Selects legacy hyprlang or Lua-provider syntax from the active
-- standard Hyprland config path. It does not reload the compositor.

local function usage(stream)
	local text = [[Usage: hyprland-runtime <operation> [arguments]

Operations:
  get-gap <inner|outer>
  set-gap <inner|outer> <integer>
  adjust-gap <inner|outer> <5|-5>
  toggle-float
  resize-active <width> <height>
  center
  focus-class <class>
  dpms <on|off>

The helper selects legacy hyprlang or Lua-provider syntax from the active
standard Hyprland config path. It does not reload the compositor.
]]
	;(stream or io.stdout):write(text)
end

local function fail_usage()
	usage(io.stderr)
	os.exit(2)
end

local home = os.getenv("HOME") or ""
local config_dir = (os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")) .. "/hypr"

local function file_exists(path)
	local fh = io.open(path, "r")
	if fh then
		fh:close()
		return true
	end
	return false
end

local lua_provider = file_exists(config_dir .. "/hyprland.lua")

local function run(cmd)
	local ok, _, code = os.execute(cmd)
	if not ok then
		os.exit(code or 1)
	end
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

local function nonnegative_integer(value)
	if not value then
		return false
	end
	if value == "0" then
		return true
	end
	if not value:match("^[1-9][0-9]*$") or #value > 4 then
		return false
	end
	return tonumber(value) <= 1000
end

local function positive_dimension(value)
	if not value or not value:match("^[1-9][0-9]?[0-9]?[0-9]?[0-9]?[0-9]?$") then
		return false
	end
	return tonumber(value) <= 100000
end

local function get_gap_option(option, legacy)
	if lua_provider then
		io.write(capture(string.format("hyprctl -j getoption %q", option)))
	else
		io.write(capture(string.format("hyprctl -j getoption %q", legacy)))
	end
	io.flush()
end

local function get_gap_value(option, legacy)
	local out
	if lua_provider then
		out = capture(string.format("hyprctl -j getoption %q", option))
	else
		out = capture(string.format("hyprctl -j getoption %q", legacy))
	end
	local custom = out:match('"custom"%s*:%s*"([^"]*)"')
	if not custom then
		return nil
	end
	return custom:match("^%S+")
end

local function set_gap_option(option, legacy, value)
	if lua_provider then
		run(string.format("hyprctl eval %q", string.format("hl.config({ general = { %s = %s } })", option, value)))
	else
		run(string.format("hyprctl keyword %q %q", legacy, value))
	end
end

local function dispatch_lua(expression)
	run(string.format("hyprctl dispatch %q", expression))
end

local function dispatch_legacy(...)
	local parts = { "hyprctl", "dispatch" }
	for _, part in ipairs({ ... }) do
		parts[#parts + 1] = string.format("%q", part)
	end
	run(table.concat(parts, " "))
end

local op = arg[1]

if op == "get-gap" then
	if #arg ~= 2 then
		fail_usage()
	end
	if arg[2] == "inner" then
		get_gap_option("general.gaps_in", "general:gaps_in")
	elseif arg[2] == "outer" then
		get_gap_option("general.gaps_out", "general:gaps_out")
	else
		fail_usage()
	end
elseif op == "set-gap" then
	if #arg ~= 3 or not nonnegative_integer(arg[3]) then
		fail_usage()
	end
	if arg[2] == "inner" then
		set_gap_option("gaps_in", "general:gaps_in", arg[3])
	elseif arg[2] == "outer" then
		set_gap_option("gaps_out", "general:gaps_out", arg[3])
	else
		fail_usage()
	end
elseif op == "adjust-gap" then
	if #arg ~= 3 or (arg[3] ~= "5" and arg[3] ~= "-5") then
		fail_usage()
	end
	local option, legacy, query, legacy_query
	if arg[2] == "inner" then
		option, legacy, query, legacy_query = "gaps_in", "general:gaps_in", "general.gaps_in", "general:gaps_in"
	elseif arg[2] == "outer" then
		option, legacy, query, legacy_query = "gaps_out", "general:gaps_out", "general.gaps_out", "general:gaps_out"
	else
		fail_usage()
	end
	local current = get_gap_value(query, legacy_query)
	if not nonnegative_integer(current) then
		io.stderr:write("hyprland-runtime: could not read a valid current gap value\n")
		os.exit(1)
	end
	local value = tonumber(current) + tonumber(arg[3])
	if value < 0 then
		value = 0
	end
	if value > 1000 then
		value = 1000
	end
	set_gap_option(option, legacy, tostring(value))
elseif op == "toggle-float" then
	if #arg ~= 1 then
		fail_usage()
	end
	if lua_provider then
		dispatch_lua('hl.dsp.window.float({ action = "toggle" })')
	else
		dispatch_legacy("togglefloating")
	end
elseif op == "resize-active" then
	if #arg ~= 3 or not positive_dimension(arg[2]) or not positive_dimension(arg[3]) then
		fail_usage()
	end
	if lua_provider then
		dispatch_lua(
			string.format("hl.dsp.window.resize({ x = %s, y = %s, relative = false })", arg[2], arg[3])
		)
	else
		dispatch_legacy("resizeactive", "exact", arg[2], arg[3])
	end
elseif op == "center" then
	if #arg ~= 1 then
		fail_usage()
	end
	if lua_provider then
		dispatch_lua("hl.dsp.window.center()")
	else
		dispatch_legacy("centerwindow")
	end
elseif op == "focus-class" then
	if #arg ~= 2 or not arg[2]:match("^[A-Za-z0-9_%.%-]+$") then
		fail_usage()
	end
	if lua_provider then
		dispatch_lua(string.format('hl.dsp.focus({ window = "class:%s" })', arg[2]))
	else
		dispatch_legacy("focuswindow", "class:" .. arg[2])
	end
elseif op == "dpms" then
	if #arg ~= 2 then
		fail_usage()
	end
	local action, legacy
	if arg[2] == "on" then
		action, legacy = "enable", "on"
	elseif arg[2] == "off" then
		action, legacy = "disable", "off"
	else
		fail_usage()
	end
	if lua_provider then
		dispatch_lua(string.format('hl.dsp.dpms({ action = "%s" })', action))
	else
		dispatch_legacy("dpms", legacy)
	end
elseif op == "-h" or op == "--help" or op == "help" then
	usage()
else
	fail_usage()
end
