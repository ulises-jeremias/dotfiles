#!/usr/bin/env lua

-- Start gnome-keyring-daemon (Lua port of the former start-gnome-keyring.sh).
-- The daemon daemonizes itself with --start; the environment assignments it
-- prints were only ever visible to the short-lived wrapper process, so the
-- Lua port starts the daemon the same way without evaluating shell output.

local function command_exists(name)
	local ok = os.execute(string.format("command -v %q >/dev/null 2>&1", name))
	return ok == true or ok == 0
end

if command_exists("gnome-keyring-daemon") then
	local ok, _, code = os.execute("gnome-keyring-daemon --start --components=secrets,pkcs11,ssh >/dev/null")
	if not ok then
		os.exit(code or 1)
	end
else
	io.stderr:write("gnome-keyring-daemon not found\n")
	os.exit(1)
end
