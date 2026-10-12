-- Staged replacement for the legacy workspace-swipe configuration.
-- Hyprland 0.55+ uses hl.gesture; the old threshold/cancel tuning has no
-- direct equivalent in this API and must be evaluated in an isolated session.
-- This file is inert until the full migration is accepted.
-- luacheck: globals hl

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
