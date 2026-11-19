-- One-click guitar tone: Avenged Sevenfold - Lead (shared logic in "Guitar - Choose tone.lua").
-- luacheck: globals reaper GUITAR_TONE
GUITAR_TONE = "Avenged Sevenfold - Lead"
local dir = select(2, reaper.get_action_context()):match("^(.*[/\\])")
dofile(dir .. "Guitar - Choose tone.lua")
GUITAR_TONE = nil
