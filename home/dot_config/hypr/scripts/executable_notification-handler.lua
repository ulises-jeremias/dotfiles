#!/usr/bin/env lua

-- Copyright (C) 2019-2025 Ulises Jeremias Cornejo Fandos
-- Licensed under MIT.
--
-- Notification action handler for Mako
-- Handles interactive notification actions (media controls, app launching, etc.)
--
-- Usage:
--     notification-handler.lua [ACTION] [APP_NAME] [SUMMARY] [BODY]
--
-- Actions:
--     middle       Handle middle button click
--     left         Handle left button click
--     right        Handle right button click
--
-- Options:
--     -h, --help   Show this help message
--
-- (Lua port of the former notification-handler.sh.)

local ACTION = arg[1] or ""
local APP_NAME = arg[2] or ""
local SUMMARY = arg[3] or ""
local BODY = arg[4] or ""

local function shell_quote(value)
	return string.format("%q", value)
end

local function log(level, message)
	if level == "ERROR" or level == "WARN" then
		io.stderr:write(string.format("[%s] %s\n", level, message))
	elseif level == "INFO" then
		print(string.format("[INFO] %s", message))
	else
		print(message)
	end
end

local function command_exists(name)
	local ok = os.execute(string.format("command -v %s >/dev/null 2>&1", shell_quote(name)))
	return ok == true or ok == 0
end

local media_apps = {
	Spotify = true,
	spotify = true,
	mpv = true,
	vlc = true,
	rhythmbox = true,
}

local function handle_media_notification(app_name, action)
	if not media_apps[app_name] then
		return
	end
	local commands = {
		middle = { "play-pause", "Media play/pause toggled" },
		left = { "previous", "Previous track" },
		right = { "next", "Next track" },
	}
	local entry = commands[action]
	if entry and command_exists("playerctl") then
		os.execute(string.format("playerctl %s", shell_quote(entry[1])))
		log("INFO", entry[2])
	end
end

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

local function handle_app_notification(app_name, action, summary)
	if browsers[app_name] then
		if action == "left" and summary:find("http", 1, true) then
			os.execute(string.format("xdg-open %s 2>/dev/null || true", shell_quote(summary)))
		end
	elseif chat_apps[app_name] then
		if action == "left" then
			local helper = (os.getenv("HOME") or "") .. "/.local/bin/hyprland-runtime.lua"
			os.execute(
				string.format(
					"lua %s focus-class %s 2>/dev/null || exo-open --launch %s 2>/dev/null || true",
					shell_quote(helper),
					shell_quote(app_name),
					shell_quote(app_name)
				)
			)
		end
	end
	-- BODY kept for parity with the former positional interface.
	local _ = BODY
end

if ACTION == "" then
	log("ERROR", "No action specified")
	os.exit(1)
end

handle_media_notification(APP_NAME, ACTION)
handle_app_notification(APP_NAME, ACTION, SUMMARY)
