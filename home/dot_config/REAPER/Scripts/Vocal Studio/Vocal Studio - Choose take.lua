-- Vocal Studio - Choose take
--
-- Beginner helper for the "Modern Rock & Metal - Vocal Studio" template.
-- Type the take you want to record and this script:
--   * disarms every vocal track (the Backing Track is never armed),
--   * arms exactly the chosen vocal track (it records Mono Input 1),
--   * when a LEAD style is chosen, mutes the other lead alternatives so only
--     one lead plays back. Doubles and harmonies are never muted here.
-- Type "none" to disarm every vocal track.
--
-- Nothing is recorded by this script; it only changes arm/mute state.

local LEAD = { ["Lead Clean"] = true, ["Lead Clean FX"] = true,
               ["Grit Vocal"] = true, ["Harsh Vocal"] = true }
local VOCAL = { ["Lead Clean"] = true, ["Lead Clean FX"] = true,
                ["Grit Vocal"] = true, ["Harsh Vocal"] = true,
                ["Double L"] = true, ["Double R"] = true, ["Harmonies"] = true }

local function track_name(tr)
  local _, name = reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", "", false)
  return name
end

local ok, answer = reaper.GetUserInputs("Vocal Studio: choose take", 1,
  "Take (Lead Clean, Lead Clean FX, Grit Vocal, Harsh Vocal, Double L, Double R, Harmonies, or none):",
  "Lead Clean")
if not ok then return end
answer = answer:match("^%s*(.-)%s*$")

-- Resolve the target before changing anything.
local target, vocals = nil, {}
for i = 0, reaper.CountTracks(0) - 1 do
  local tr = reaper.GetTrack(0, i)
  local name = track_name(tr)
  if VOCAL[name] then vocals[#vocals + 1] = { tr = tr, name = name } end
  if name == answer then target = tr end
end

if answer ~= "none" and not target then
  reaper.ShowMessageBox("No track named \"" .. answer .. "\" in this project.\n" ..
    "Open the Modern Rock & Metal - Vocal Studio template.", "Vocal Studio", 0)
  return
end

reaper.Undo_BeginBlock()
for _, v in ipairs(vocals) do
  reaper.SetMediaTrackInfo_Value(v.tr, "I_RECARM", 0)
end
if target then
  reaper.SetMediaTrackInfo_Value(target, "I_RECARM", 1)
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
