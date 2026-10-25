-- Lua equivalent of the retired keyboard, pointer, touchpad, and cursor
-- settings from hyprland.conf.d/input.conf (loaded by hyprland.lua).
-- luacheck: globals hl

hl.config({
	input = {
		kb_layout = "us,latam",
		kb_variant = "",
		kb_model = "",
		kb_options = "grp:alt_shift_toggle",
		kb_rules = "",
		follow_mouse = 1,
		repeat_rate = 50,
		repeat_delay = 300,
		numlock_by_default = true,
		sensitivity = 0.0,
		accel_profile = "flat",
		force_no_accel = false,
		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
			clickfinger_behavior = true,
			middle_button_emulation = true,
			tap_to_click = true,
			drag_lock = false,
			scroll_factor = 1.0,
		},
	},
	cursor = {
		no_hardware_cursors = 1,
		no_break_fs_vrr = 0,
		min_refresh_rate = 24,
		hotspot_padding = 1,
		inactive_timeout = 0,
		no_warps = false,
		persistent_warps = false,
		warp_on_change_workspace = 0,
	},
})
