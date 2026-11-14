-- Vocal Studio - Choose take
--
-- Pick the vocal style you are about to sing; this script:
--   * arms exactly that vocal track and disarms the other vocal tracks,
--   * sets it to record mono Scarlett Input 1 with input monitoring on,
--   * for a LEAD style, mutes the other lead alternatives so only one lead
--     plays back (doubles and harmonies are never muted here),
--   * never touches the guitar DI, the guitar tones or the backing track.
-- Type "none" to disarm every vocal track.
--
-- One-click versions: "Vocal style - <name>.lua" (also on the "Music Studio"
-- toolbar) set VOCAL_STYLE and run this file.
--
-- Nothing is recorded by this script. When you press Record over an earlier
-- take, REAPER adds a new take to the item (it does not erase the old one):
-- switch takes with the T key or the item's take menu to compare performances.
-- luacheck: globals reaper VOCAL_STYLE

local LEAD = { ["Lead Clean"] = true, ["Lead Clean FX"] = true,
               ["Grit Vocal"] = true, ["Harsh Vocal"] = true }
local VOCAL = { ["Lead Clean"] = true, ["Lead Clean FX"] = true,
                ["Grit Vocal"] = true, ["Harsh Vocal"] = true,
                ["Double L"] = true, ["Double R"] = true, ["Harmonies"] = true }
-- friendly style names -> track names
local ALIAS = {
  ["natural clean"] = "Lead Clean", ["natural"] = "Lead Clean", ["clean"] = "Lead Clean",
  ["powerful clean"] = "Lead Clean FX", ["powerful"] = "Lead Clean FX", ["modern clean"] = "Lead Clean FX",
  ["grit"] = "Grit Vocal", ["raspy"] = "Grit Vocal",
  ["harsh"] = "Harsh Vocal", ["scream"] = "Harsh Vocal",
  ["doubles"] = "Double L", ["harmony"] = "Harmonies",
}

local function track_name(tr)
  local _, name = reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", "", false)
  return name
end

local answer = VOCAL_STYLE
if not answer then
  local ok
  ok, answer = reaper.GetUserInputs("Vocal Studio: choose take", 1,
    "Style (Natural Clean, Powerful Clean, Grit, Harsh, Double L, Double R, Harmonies, or none):",
    "Natural Clean")
  if not ok then return end
end
answer = answer:match("^%s*(.-)%s*$")
answer = ALIAS[answer:lower()] or answer

-- Resolve the target before changing anything.
local target, vocals = nil, {}
for i = 0, reaper.CountTracks(0) - 1 do
  local tr = reaper.GetTrack(0, i)
  local name = track_name(tr)
  if VOCAL[name] then vocals[#vocals + 1] = { tr = tr, name = name } end
  if name == answer and VOCAL[name] then target = tr end
end

if answer:lower() ~= "none" and not target then
  reaper.ShowMessageBox("No vocal track named \"" .. answer .. "\" in this project.\n" ..
    "Open the Music Studio or Vocal Studio template.", "Vocal Studio", 0)
  return
end

reaper.Undo_BeginBlock()
for _, v in ipairs(vocals) do
  reaper.SetMediaTrackInfo_Value(v.tr, "I_RECARM", 0)
end
if target then
  reaper.SetMediaTrackInfo_Value(target, "I_RECINPUT", 0) -- mono Scarlett Input 1 (mic)
  reaper.SetMediaTrackInfo_Value(target, "I_RECMODE", 0)  -- record the input (dry, effects stay live)
  reaper.SetMediaTrackInfo_Value(target, "I_RECMON", 1)   -- hear yourself through the chain
  reaper.SetMediaTrackInfo_Value(target, "I_RECARM", 1)
  reaper.SetMediaTrackInfo_Value(target, "B_MUTE", 0)
end
if LEAD[answer] then
  for _, v in ipairs(vocals) do
    if LEAD[v.name] then
      reaper.SetMediaTrackInfo_Value(v.tr, "B_MUTE", (v.name == answer) and 0 or 1)
    end
  end
end
reaper.Undo_EndBlock("Vocal Studio: choose take", -1)
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
