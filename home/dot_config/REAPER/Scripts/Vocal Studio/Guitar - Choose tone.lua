-- Guitar - Choose tone
--
-- Switch the guitar tone for Studio recording and Discord lessons. Type a tone
-- name and this unmutes it and mutes the other six. The DI track and the vocal
-- tracks are never changed, so it is safe to switch tones mid-lesson.
--
-- Tones (genre folders in the Guitar Tones template browser):
--   Crystal Clean, Warm Clean - Ambient                              (Clean)
--   Classic Rock - Crunch, Hard Rock - Heavy Lead                    (Rock)
--   Modern Metal Rhythm, Extreme Metal Rhythm, Metalcore - Melodic Lead (Metal)
--
-- The chosen tone is unmuted with its FX online; the others are muted and
-- their FX taken offline (state kept, plugin unloaded), so only one amp capture
-- is loaded. The chosen amp model needs about a second to load after switching.
-- Nothing here records.

local TONES = {
  "Crystal Clean", "Warm Clean - Ambient", "Classic Rock - Crunch",
  "Hard Rock - Heavy Lead", "Modern Metal Rhythm", "Extreme Metal Rhythm",
  "Metalcore - Melodic Lead",
}
local IS_TONE = {}
for _, name in ipairs(TONES) do IS_TONE[name] = true end

local ok, answer = reaper.GetUserInputs("Guitar: choose tone", 1,
  "Tone (" .. table.concat(TONES, " / ") .. "):", "Crystal Clean")
if not ok then return end
answer = answer:match("^%s*(.-)%s*$")
if not IS_TONE[answer] then
  reaper.ShowMessageBox("Unknown tone: \"" .. answer .. "\".\nChoose one of:\n" .. table.concat(TONES, "\n"),
    "Guitar: choose tone", 0)
  return
end

local function name_of(tr)
  local _, n = reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", "", false)
  return n
end

reaper.Undo_BeginBlock()
local found = false
for i = 0, reaper.CountTracks(0) - 1 do
  local tr = reaper.GetTrack(0, i)
  local n = name_of(tr)
  if IS_TONE[n] then
    local active = (n == answer)
    if active then found = true end
    reaper.SetMediaTrackInfo_Value(tr, "B_MUTE", active and 0 or 1)
    reaper.SetMediaTrackInfo_Value(tr, "I_FXEN", active and 1 or 0)
    for fx = 0, reaper.TrackFX_GetCount(tr) - 1 do
      reaper.TrackFX_SetOffline(tr, fx, not active)
    end
  end
end
reaper.Undo_EndBlock("Guitar: choose tone", -1)
if not found then
  reaper.ShowMessageBox("Open the Modern Rock & Metal - Vocal Studio template first.", "Guitar: choose tone", 0)
end
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
