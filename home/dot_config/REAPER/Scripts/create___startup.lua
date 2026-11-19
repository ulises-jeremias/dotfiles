-- REAPER runs Scripts/__startup.lua at every start (native REAPER feature).
-- Installed only if you have no __startup.lua yet (chezmoi create_); if you
-- already use one, add the two lines below to it.
-- Music Studio: register the Vocal Studio actions and the "Music Studio"
-- toolbar (see "Vocal Studio/Music Studio - Register actions.lua").
-- luacheck: globals reaper
local path = reaper.GetResourcePath() .. "/Scripts/Vocal Studio/Music Studio - Register actions.lua"
if reaper.file_exists(path) then
	dofile(path)
end
