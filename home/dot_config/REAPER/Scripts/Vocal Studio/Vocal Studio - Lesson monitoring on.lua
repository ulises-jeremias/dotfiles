-- Vocal Studio - Lesson monitoring on
--
-- Live monitoring for a guitar lesson: arms and monitors the chosen vocal track
-- (default Lead Clean) and the Electric Guitar DI so Input 1 (mic) and Input 2
-- (guitar, through the tone chosen with "Guitar - Choose tone") reach REAPER's
-- output and the lesson mic.
--
-- This does NOT record: arming only routes audio. Pressing Record in REAPER
-- starts a take. Run "Vocal Studio - Lesson monitoring off" to disarm everything.

local VOCAL = "Lead Clean"
local TARGET = { [VOCAL] = true, ["Electric Guitar DI"] = true }

local function name_of(tr)
  local _, n = reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", "", false)
  return n
end

local tracks = {}
for i = 0, reaper.CountTracks(0) - 1 do
  local tr = reaper.GetTrack(0, i)
  tracks[#tracks + 1] = { tr = tr, name = name_of(tr) }
end

local found = 0
for _, t in ipairs(tracks) do if TARGET[t.name] then found = found + 1 end end
if found < 2 then
  reaper.ShowMessageBox("Open the Modern Rock & Metal - Vocal Studio template first.",
    "Vocal Studio: lesson monitoring", 0)
  return
end

reaper.Undo_BeginBlock()
for _, t in ipairs(tracks) do
  local on = TARGET[t.name] and true or false
  -- the Backing Track is never armed
  if t.name == "Backing Track" then on = false end
  reaper.SetMediaTrackInfo_Value(t.tr, "I_RECARM", on and 1 or 0)
  if on then reaper.SetMediaTrackInfo_Value(t.tr, "I_RECMON", 1) end
end
reaper.Undo_EndBlock("Vocal Studio: lesson monitoring on", -1)
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
