-- One-click guitar tone: Lamb of God - Groove Metal (shared logic in "Guitar - Choose tone.lua").
-- luacheck: globals reaper GUITAR_TONE
GUITAR_TONE = "Lamb of God - Groove Metal"
local dir = select(2, reaper.get_action_context()):match("^(.*[/\\])")
dofile(dir .. "Guitar - Choose tone.lua")
GUITAR_TONE = nil
