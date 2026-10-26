-- Lua equivalent of the retired hyprland.conf.d/autostart.conf. (loaded by hyprland.lua).
-- luacheck: globals hl

local here = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$") .. "/"
local actions = dofile(here .. "actions.lua")

hl.on("hyprland.start", function()
	hl.exec_cmd("dex --autostart --environment Hyprland")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	actions.start_gnome_keyring()
	hl.exec_cmd("pkill -9 kwalletd5 kwalletd6 2>/dev/null || true")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("horneroctl hypr layout restore --yes")
	hl.exec_cmd("horneroctl apps switcher daemon --yes")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("horneroctl hardware battery monitor --daemon --yes")
	hl.exec_cmd('xrdb -merge "$HOME/.Xresources"')
	hl.exec_cmd("hyprctl setcursor elementary 24")
	hl.exec_cmd("horneroctl shell start --yes")
	hl.exec_cmd("thunar --daemon")
	hl.exec_cmd("ibus-daemon -drx")
end)
