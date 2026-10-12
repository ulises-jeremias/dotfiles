-- Staged Lua equivalent of the non-generated inline Hyprland settings and
-- debug.conf. Theme-generated border and shadow colors remain separate.
-- This file is inert until the full migration is accepted.
-- luacheck: globals hl

hl.config({
	general = {
		gaps_in = 6,
		gaps_out = 18,
		border_size = 2,
		layout = "scrolling",
		allow_tearing = false,
		resize_on_border = true,
		extend_border_grab_area = 15,
		hover_icon_on_border = true,
	},
	decoration = {
		rounding = 12,
		active_opacity = 1.0,
		inactive_opacity = 0.95,
		fullscreen_opacity = 1.0,
		blur = {
			enabled = true,
			size = 8,
			passes = 3,
			new_optimizations = true,
			xray = true,
			ignore_opacity = false,
			noise = 0.0117,
			contrast = 1.0,
			brightness = 1.0,
			vibrancy = 0.2,
			vibrancy_darkness = 0.0,
		},
		shadow = {
			enabled = true,
			range = 12,
			render_power = 2,
			scale = 1.0,
		},
		dim_inactive = true,
		dim_strength = 0.08,
	},
	misc = {
		vrr = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		force_default_wallpaper = 0,
		enable_swallow = true,
		swallow_regex = "^(kitty)$",
		focus_on_activate = true,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
		always_follow_on_dnd = true,
		layers_hog_keyboard_focus = true,
		animate_manual_resizes = true,
		animate_mouse_windowdragging = true,
		disable_autoreload = false,
		initial_workspace_tracking = 1,
		middle_click_paste = true,
	},
	xwayland = {
		force_zero_scaling = true,
	},
	debug = {
		overlay = false,
		damage_tracking = 2,
		damage_blink = false,
		suppress_errors = true,
	},
})
