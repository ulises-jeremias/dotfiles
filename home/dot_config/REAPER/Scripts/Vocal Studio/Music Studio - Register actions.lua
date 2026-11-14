-- Music Studio - Register actions
--
-- Makes the Vocal Studio scripts available in REAPER's Action list and builds
-- the "Music Studio" floating toolbar (toolbar 16): one button per guitar tone
-- and per vocal style. Run automatically by Scripts/__startup.lua on every
-- REAPER start; idempotent (re-registering a script keeps its command ID) and
-- it never touches the project.
--
-- The toolbar is written to reaper-menu.ini only if toolbar 16 is not defined
-- yet, so a toolbar you customize in REAPER is never overwritten. It opens
-- automatically the first time; afterwards REAPER remembers whether it is open.
-- luacheck: globals reaper

local dir = reaper.GetResourcePath() .. "/Scripts/Vocal Studio/"
local TOOLBAR = 16

-- button order and labels (file name without .lua -> label)
local BUTTONS = {
  { "Guitar tone - Crystal Clean", "Clean" },
  { "Guitar tone - Warm Clean", "Warm" },
  { "Guitar tone - AC-DC", "AC/DC" },
  { "Guitar tone - Avenged Sevenfold", "A7X" },
  { "Guitar tone - Machine Head", "Machine Head" },
  { "Guitar tone - Lamb of God", "Lamb of God" },
  { "Guitar tone - Slipknot", "Slipknot" },
  { "Guitar tone - Asking Alexandria", "Asking Alex." },
  { "Vocal style - Natural Clean", "Voice: Natural" },
  { "Vocal style - Powerful Clean", "Voice: Powerful" },
  { "Vocal style - Grit", "Voice: Grit" },
  { "Vocal style - Harsh", "Voice: Harsh" },
  { "Vocal style - Double L", "Double L" },
  { "Vocal style - Double R", "Double R" },
  { "Vocal style - Harmonies", "Harmony" },
}

local ids = {}
local i = 0
while true do
  local name = reaper.EnumerateFiles(dir, i)
  if not name then break end
  if name:match("%.lua$") and name ~= "Music Studio - Register actions.lua" then
    local id = reaper.AddRemoveReaScript(true, 0, dir .. name, false)
    if id and id > 0 then ids[name:gsub("%.lua$", "")] = "_" .. reaper.ReverseNamedCommandLookup(id) end
  end
  i = i + 1
end
-- commit the action list once
reaper.AddRemoveReaScript(true, 0, dir .. "Guitar - Choose tone.lua", true)

local menu = reaper.GetResourcePath() .. "/reaper-menu.ini"
local text = ""
local fh = io.open(menu, "r")
if fh then text = fh:read("a"); fh:close() end
local section = "[Floating toolbar " .. TOOLBAR .. "]"
if not text:find(section, 1, true) then
  local lines = { section }
  local n = 0
  for _, b in ipairs(BUTTONS) do
    if ids[b[1]] then
      lines[#lines + 1] = string.format("item_%d=%s %s", n, ids[b[1]], b[2])
      n = n + 1
    end
  end
  lines[#lines + 1] = "title=Music Studio"
  local out = io.open(menu, "a")
  if out then
    out:write((text ~= "" and not text:match("\n$")) and "\n" or "")
    out:write(table.concat(lines, "\n") .. "\n")
    out:close()
  end
end

-- open the toolbar the first time only
if reaper.GetExtState("MusicStudio", "toolbar_opened") ~= "1" then
  local want = "Toolbar: Open/close toolbar " .. TOOLBAR
  for cmd = 40000, 42500 do
    if reaper.kbd_getTextFromCmd(cmd, 0) == want then
      if reaper.GetToggleCommandState(cmd) ~= 1 then reaper.Main_OnCommand(cmd, 0) end
      break
    end
  end
  reaper.SetExtState("MusicStudio", "toolbar_opened", "1", true)
end
