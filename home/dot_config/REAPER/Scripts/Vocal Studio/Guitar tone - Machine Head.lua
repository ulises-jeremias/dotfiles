-- One-click guitar tone: Machine Head - Groove Thrash (shared logic in "Guitar - Choose tone.lua").
-- luacheck: globals reaper GUITAR_TONE
GUITAR_TONE = "Machine Head - Groove Thrash"
local dir = select(2, reaper.get_action_context()):match("^(.*[/\\])")
dofile(dir .. "Guitar - Choose tone.lua")
GUITAR_TONE = nil
