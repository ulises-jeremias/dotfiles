-- One-click guitar tone: Warm Clean - Ambient (shared logic in "Guitar - Choose tone.lua").
-- luacheck: globals reaper GUITAR_TONE
GUITAR_TONE = "Warm Clean - Ambient"
local dir = select(2, reaper.get_action_context()):match("^(.*[/\\])")
dofile(dir .. "Guitar - Choose tone.lua")
GUITAR_TONE = nil
