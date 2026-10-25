-- Smart Colors integration for the Lua entrypoint.
-- Factory defaults match the retired colors.conf values.
-- luacheck: globals hl

local factory = {
	general = {
		col = {
			active_border = { colors = { "rgba(e07856ee)", "rgba(f2b749ee)" }, angle = 45 },
			inactive_border = "rgba(6b4e3baa)",
		},
	},
	group = {
		col = {
			border_active = "rgba(e07856ee)",
			border_inactive = "rgba(6b4e3baa)",
			border_locked_active = "rgba(f2b749ee)",
			border_locked_inactive = "rgba(3c2c21aa)",
		},
		groupbar = {
			col = {
				active = "rgba(e07856ee)",
				inactive = "rgba(2b1f18ee)",
				locked_active = "rgba(f2b749ee)",
				locked_inactive = "rgba(3c2c21ee)",
			},
		},
	},
}

hl.config(factory)

local cache = os.getenv("HORNERO_SMART_COLORS_DIR")
if not cache or cache == "" then
	local cache_home = os.getenv("XDG_CACHE_HOME")
	if not cache_home or cache_home == "" then
		cache_home = (os.getenv("HOME") or "") .. "/.cache"
	end
	cache = cache_home .. "/hornero/smart-colors"
end

-- The generated file is optional on fresh installs and may be absent until
-- `horneroctl appearance colors generate --yes` has run. Load the chunk on
-- every config evaluation instead of using require's module cache, so a
-- regenerated palette is visible on reload. A malformed or missing cache
-- file leaves the safe factory palette above in effect.
local generated = loadfile(cache .. "/colors-hyprland.lua")
if generated then
	pcall(generated)
end
