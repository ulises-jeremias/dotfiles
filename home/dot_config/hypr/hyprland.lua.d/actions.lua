-- Hyprland actions: former standalone helper scripts, now Lua functions
-- loaded inside the Hyprland Lua config (hyprland.lua.d/). Loaded with
-- dofile() by keybindings.lua and autostart.lua; returns the actions table.
-- The gaps / smart-float / notification / runtime / gnome-keyring logic
-- lives here instead of in standalone scripts invoked by path, so binds
-- call these functions directly through hl.bind callbacks. Behavior
-- (hyprctl reads, notifications, stdout/stderr text, validation) matches
-- the former gaps-interactive, smart-float, notification-handler,
-- hyprland-runtime and start-gnome-keyring scripts; os.exit() in a script
-- becomes a false return here because exiting the compositor is not an
-- option.
-- luacheck: globals hl

local actions = {}

local function shell_quote(value)
	return string.format("%q", value)
end

local function capture(cmd)
	local fh = io.popen(cmd, "r")
	if not fh then
		return nil
	end
	local out = fh:read("*a") or ""
	local ok = fh:close()
	if not ok then
		return nil
	end
	return out
end

local function run(cmd)
	local ok = os.execute(cmd)
	return ok == true or ok == 0
end

local function command_exists(name)
	local ok = os.execute(string.format("command -v %s >/dev/null 2>&1", shell_quote(name)))
	return ok == true or ok == 0
end

actions.command_exists = command_exists

local function nonnegative_integer(value)
	if not value then
		return false
	end
	value = tostring(value)
	if value == "0" then
		return true
	end
	if not value:match("^[1-9][0-9]*$") or #value > 4 then
		return false
	end
	return tonumber(value) <= 1000
end

local function positive_dimension(value)
	if not value then
		return false
	end
	value = tostring(value)
	if not value:match("^[1-9][0-9]?[0-9]?[0-9]?[0-9]?[0-9]?$") then
		return false
	end
	return tonumber(value) <= 100000
end

local gap_options = {
	inner = { config = "gaps_in", option = "general.gaps_in" },
	outer = { config = "gaps_out", option = "general.gaps_out" },
}

-- Former `hyprland-runtime get-gap`: raw hyprctl output, first custom token.
function actions.get_gap(which)
	local gap = gap_options[which]
	if not gap then
		return nil
	end
	local out = capture(string.format("hyprctl -j getoption %q", gap.option))
	if not out then
		return nil
	end
	local custom = out:match('"custom"%s*:%s*"([^"]*)"')
	if not custom then
		return nil
	end
	return custom:match("^%S+")
end

-- Former `hyprland-runtime set-gap`.
function actions.set_gap(which, value)
	local gap = gap_options[which]
	if not gap or not nonnegative_integer(value) then
		return false
	end
	hl.config({ general = { [gap.config] = tonumber(value) } })
	return true
end

-- Former `hyprland-runtime adjust-gap` (clamped to 0..1000).
function actions.adjust_gap(which, delta)
	delta = tostring(delta)
	if not gap_options[which] or (delta ~= "5" and delta ~= "-5") then
		return false
	end
	local current = actions.get_gap(which)
	if not nonnegative_integer(current) then
		io.stderr:write("hyprland-runtime: could not read a valid current gap value\n")
		return false
	end
	local value = tonumber(current) + tonumber(delta)
	if value < 0 then
		value = 0
	end
	if value > 1000 then
		value = 1000
	end
	return actions.set_gap(which, value)
end

-- Former `hyprland-runtime toggle-float`.
function actions.toggle_float()
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	return true
end

-- Former `hyprland-runtime resize-active`.
function actions.resize_active(width, height)
	if not positive_dimension(width) or not positive_dimension(height) then
		return false
	end
	hl.dispatch(hl.dsp.window.resize({ x = tonumber(width), y = tonumber(height), relative = false }))
	return true
end

-- Former `hyprland-runtime center`.
function actions.center()
	hl.dispatch(hl.dsp.window.center())
	return true
end

-- Former `hyprland-runtime focus-class`.
function actions.focus_class(class)
	if not class or not tostring(class):match("^[A-Za-z0-9_%.%-]+$") then
		return false
	end
	hl.dispatch(hl.dsp.focus({ window = "class:" .. tostring(class) }))
	return true
end

-- Former `hyprland-runtime dpms <on|off>` (also used for hypridle, which
-- now calls the same hl.dsp.dpms expression through hyprctl directly).
function actions.dpms(state)
	local action
	if state == "on" then
		action = "enable"
	elseif state == "off" then
		action = "disable"
	else
		return false
	end
	hl.dispatch(hl.dsp.dpms({ action = action }))
	return true
end

-- Former gaps-interactive script (SUPER+SHIFT+G).
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

function actions.gaps_interactive()
	print("Gaps Mode")
	print("1) Inner Gaps")
	print("2) Outer Gaps")
	io.write("Choice [1-2]: ")
	io.flush()
	local main_n = io.read("*l")
	if not main_n then
		return false
	end

	local which, label, default_gap
	if main_n == "1" then
		which, label, default_gap = "inner", "Inner Gaps", "6"
	elseif main_n == "2" then
		which, label, default_gap = "outer", "Outer Gaps", "18"
	else
		return false
	end

	local current = actions.get_gap(which) or ""
	local choice = show_menu(string.format("%s (current: %s)", label, current))
	if not choice then
		return false
	end

	if choice == "Increase (+5)" or choice == "Increase All (Shift +5)" then
		actions.adjust_gap(which, "5")
	elseif choice == "Decrease (-5)" or choice == "Decrease All (Shift -5)" then
		actions.adjust_gap(which, "-5")
	elseif choice == "Set to zero" then
		actions.set_gap(which, "0")
	elseif choice == "Restore defaults" then
		actions.set_gap(which, default_gap)
	end

	if command_exists("notify-send") then
		os.execute(
			string.format(
				"notify-send %s %s -t 2000",
				shell_quote("Gaps Updated"),
				shell_quote(
					string.format(
						"Inner: %s | Outer: %s",
						actions.get_gap("inner") or "",
						actions.get_gap("outer") or ""
					)
				)
			)
		)
	end
	return true
end

-- Former smart-float script (SUPER+SHIFT+F).
local MAX_WIDTH = 1400
local MAX_HEIGHT = 900

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

function actions.smart_float()
	local window_info = capture("hyprctl activewindow -j")
	if not window_info then
		return false
	end
	local is_floating = window_info:match('"floating"%s*:%s*(%a+)')

	local monitor_info = capture("hyprctl monitors -j")
	if not monitor_info then
		return false
	end
	local monitor_width = tonumber(monitor_info:match('"width"%s*:%s*(%d+)')) or 0
	local monitor_height = tonumber(monitor_info:match('"height"%s*:%s*(%d+)')) or 0

	local optimal_width = math.floor(monitor_width * 80 / 100)
	local optimal_height = math.floor(monitor_height * 80 / 100)

	local final_width = math.min(optimal_width, MAX_WIDTH)
	local final_height = math.min(optimal_height, MAX_HEIGHT)

	if is_floating == "false" then
		actions.toggle_float()
		actions.resize_active(final_width, final_height)
		actions.center()
		notify("Smart Float", string.format("Window: %dx%d", final_width, final_height), "low", 1500)
	else
		actions.toggle_float()
		notify("Smart Float", "Window tiled", "low", 1500)
	end
	return true
end

-- Former notification-handler script (mako action handler; no caller in
-- this tree, kept as a function so notification actions can call it
-- in-process instead of by script path).
local function log(level, message)
	if level == "ERROR" or level == "WARN" then
		io.stderr:write(string.format("[%s] %s\n", level, message))
	elseif level == "INFO" then
		print(string.format("[INFO] %s", message))
	else
		print(message)
	end
end

local media_apps = {
	Spotify = true,
	spotify = true,
	mpv = true,
	vlc = true,
	rhythmbox = true,
}

local media_commands = {
	middle = { "play-pause", "Media play/pause toggled" },
	left = { "previous", "Previous track" },
	right = { "next", "Next track" },
}

local browsers = {
	["zen-browser"] = true,
	Zen = true,
	["app.zen_browser.Zen"] = true,
	["brave-browser"] = true,
	firefox = true,
	chromium = true,
}

local chat_apps = {
	discord = true,
	Slack = true,
	["telegram-desktop"] = true,
}

function actions.notification(action, app_name, summary, _body)
	action = action or ""
	app_name = app_name or ""
	summary = summary or ""
	if action == "" then
		log("ERROR", "No action specified")
		return false
	end

	if media_apps[app_name] then
		local entry = media_commands[action]
		if entry and command_exists("playerctl") then
			os.execute(string.format("playerctl %s", shell_quote(entry[1])))
			log("INFO", entry[2])
		end
	end

	if browsers[app_name] then
		if action == "left" and summary:find("http", 1, true) then
			os.execute(string.format("xdg-open %s 2>/dev/null || true", shell_quote(summary)))
		end
	elseif chat_apps[app_name] then
		if action == "left" then
			if not actions.focus_class(app_name) then
				os.execute(string.format("exo-open --launch %s 2>/dev/null || true", shell_quote(app_name)))
			end
		end
	end
	return true
end

-- Former start-gnome-keyring script (autostart). The daemon daemonizes
-- itself with --start; its printed environment was only ever visible to
-- the short-lived wrapper process, so it is started the same way here.
function actions.start_gnome_keyring()
	if command_exists("gnome-keyring-daemon") then
		return run("gnome-keyring-daemon --start --components=secrets,pkcs11,ssh >/dev/null")
	end
	io.stderr:write("gnome-keyring-daemon not found\n")
	return false
end

return actions
