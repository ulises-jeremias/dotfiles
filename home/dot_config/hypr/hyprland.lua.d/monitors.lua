-- Lua equivalent of the retired hyprland.conf.d/monitors.conf. (loaded by hyprland.lua).
-- luacheck: globals hl

hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = "HDMI-A-5",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

-- Preserve the existing catch-all rule for other connected displays.
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})
