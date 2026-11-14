-- Vocal Studio - Lesson monitoring off
--
-- Disarms every track and turns off input monitoring. Does not touch recordings,
-- items, mutes or FX.

reaper.Undo_BeginBlock()
for i = 0, reaper.CountTracks(0) - 1 do
  local tr = reaper.GetTrack(0, i)
  reaper.SetMediaTrackInfo_Value(tr, "I_RECARM", 0)
  reaper.SetMediaTrackInfo_Value(tr, "I_RECMON", 0)
end
reaper.Undo_EndBlock("Vocal Studio: lesson monitoring off", -1)
reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
