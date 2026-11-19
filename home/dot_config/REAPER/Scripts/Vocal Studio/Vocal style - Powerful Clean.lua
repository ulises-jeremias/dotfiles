-- One-click vocal style: Powerful Clean -> arms "Lead Clean FX" (logic in "Vocal Studio - Choose take.lua").
-- luacheck: globals reaper VOCAL_STYLE
VOCAL_STYLE = "Lead Clean FX"
local dir = select(2, reaper.get_action_context()):match("^(.*[/\\])")
dofile(dir .. "Vocal Studio - Choose take.lua")
VOCAL_STYLE = nil
