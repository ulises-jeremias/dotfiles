-- Staged Lua equivalent of hyprland.conf.d/autostart.conf.
-- This file is intentionally not loaded until the complete configuration
-- migration has passed its acceptance checks.
-- luacheck: globals hl

hl.on("hyprland.start", function()
	hl.exec_cmd("dex --autostart --environment Hyprland")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("$HOME/.local/bin/start-gnome-keyring.sh")
	hl.exec_cmd("pkill -9 kwalletd5 kwalletd6 2>/dev/null || true")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("horneroctl hypr layout restore --yes")
	hl.exec_cmd("horneroctl apps switcher daemon --yes")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("horneroctl hardware battery monitor --daemon --yes")
	hl.exec_cmd("xrdb -merge \"$HOME/.Xresources\"")
	hl.exec_cmd("hyprctl setcursor elementary 24")
	hl.exec_cmd("horneroctl shell start --yes")
	hl.exec_cmd("thunar --daemon")
	hl.exec_cmd("ibus-daemon -drx")
end)
