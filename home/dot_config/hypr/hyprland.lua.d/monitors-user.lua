-- User monitor overrides (dotfiles, this host).
-- Loaded by the packaged hyprland.lua after the factory monitors.lua,
-- so these machine-specific outputs win. Emptying this file restores
-- the generic autodetect fallback. Personal only: never mirror the
-- factory modules here — hornero-config owns them.
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
