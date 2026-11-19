-- One-click vocal style: Natural Clean -> arms "Lead Clean" (logic in "Vocal Studio - Choose take.lua").
-- luacheck: globals reaper VOCAL_STYLE
VOCAL_STYLE = "Lead Clean"
local dir = select(2, reaper.get_action_context()):match("^(.*[/\\])")
dofile(dir .. "Vocal Studio - Choose take.lua")
VOCAL_STYLE = nil
