-- Staged Lua equivalent of hyprland.conf.d/layout.conf. This file remains
-- inert until the full migration is accepted.
-- luacheck: globals hl

hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
		column_width = 0.62,
		focus_fit_method = 1,
		follow_focus = true,
		follow_min_visible = 0.45,
		explicit_column_widths = "0.333, 0.5, 0.618, 0.75, 1.0",
		direction = "right",
	},
	dwindle = {
		preserve_split = true,
		force_split = 0,
		smart_split = true,
		smart_resizing = true,
	},
	master = {
		new_status = "master",
		new_on_top = false,
		orientation = "left",
		slave_count_for_center_master = 2,
		center_master_fallback = "left",
	},
})
