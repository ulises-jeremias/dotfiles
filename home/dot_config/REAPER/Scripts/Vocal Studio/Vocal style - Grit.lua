-- One-click vocal style: Grit -> arms "Grit Vocal" (logic in "Vocal Studio - Choose take.lua").
-- luacheck: globals reaper VOCAL_STYLE
VOCAL_STYLE = "Grit Vocal"
local dir = select(2, reaper.get_action_context()):match("^(.*[/\\])")
dofile(dir .. "Vocal Studio - Choose take.lua")
VOCAL_STYLE = nil
