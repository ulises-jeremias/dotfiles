-- Offline A/B renderer for guitar tones (developer tool, runs inside REAPER).
--
-- Renders every (FX chain x DI file) pair through REAPER's own "Apply track FX
-- to items" so A/B comparisons use the exact same input and the real plugins.
--
--   RT_CHAINS=chains.txt   lines: label|/path/to/chain.RfxChain
--   RT_DIS=dis.txt         lines: label|/path/to/di.wav
--   RT_OUT=/out/dir        renders land here as <chain>__<di>.wav
--   reaper -newinst -nosplash -ignoreerrors scripts/reaper/render-tones.lua
--
-- NAM models and IRs load asynchronously, so each chain gets a settle delay
-- before rendering. REAPER quits when done.

local function lines_of(path)
  local out = {}
  for line in io.lines(path) do
    local a, b = line:match("^(.-)|(.+)$")
    if a then out[#out + 1] = { a, b } end
  end
  return out
end

local CHAINS = lines_of(os.getenv("RT_CHAINS"))
local DIS = lines_of(os.getenv("RT_DIS"))
local OUT = os.getenv("RT_OUT")
local SETTLE = tonumber(os.getenv("RT_SETTLE") or "2.5")
local log = io.open(OUT .. "/render-log.txt", "w")
local function w(s) log:write(s .. "\n"); log:flush() end

reaper.GetSetProjectInfo_String(0, "RECORD_PATH", OUT .. "/tmp", true)
reaper.RecursiveCreateDirectory(OUT .. "/tmp", 0)

local function read(path)
  local f = assert(io.open(path, "r")); local s = f:read("a"); f:close(); return s
end

-- One track per chain, created up front so all chains load in parallel.
local tracks = {}
for i, c in ipairs(CHAINS) do
  reaper.InsertTrackAtIndex(i - 1, false)
  local t = reaper.GetTrack(0, i - 1)
  local ok = reaper.SetTrackStateChunk(t, "<TRACK\n" .. read(c[2]) .. ">\n", false)
  w(string.format("chain %-28s loaded=%s fx=%d", c[1], tostring(ok), reaper.TrackFX_GetCount(t)))
  tracks[i] = t
end

local t0 = reaper.time_precise()
local function run()
  if reaper.time_precise() - t0 < SETTLE then reaper.defer(run); return end
  for i, c in ipairs(CHAINS) do
    local t = tracks[i]
    for _, d in ipairs(DIS) do
      local item = reaper.AddMediaItemToTrack(t)
      local take = reaper.AddTakeToMediaItem(item)
      local src = reaper.PCM_Source_CreateFromFile(d[2])
      reaper.SetMediaItemTake_Source(take, src)
      reaper.SetMediaItemLength(item, reaper.GetMediaSourceLength(src), false)
      reaper.SelectAllMediaItems(0, false)
      reaper.SetMediaItemSelected(item, true)
      reaper.Main_OnCommand(40209, 0) -- Item: Apply track/take FX to items
      local rendered = reaper.GetMediaSourceFileName(reaper.GetMediaItemTake_Source(reaper.GetActiveTake(item)), "")
      local dest = string.format("%s/%s__%s.wav", OUT, c[1], d[1])
      os.rename(rendered, dest)
      w(string.format("render %-28s %-14s -> %s", c[1], d[1], dest))
      reaper.DeleteTrackMediaItem(t, item)
    end
  end
  log:close()
  reaper.Main_OnCommand(40004, 0)
end
run()
