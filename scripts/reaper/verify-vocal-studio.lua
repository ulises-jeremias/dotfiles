-- Modern Rock & Metal - Vocal Studio: reload verification (developer tool).
--
-- Run against the SAVED project (not the builder's in-memory state):
--   VS_PROJECT=<path to .RPP> VS_TT_DIR=<TrackTemplates/Vocal Studio>
--   VS_FX_DIR=<FXChains/Vocal Studio> VS_REPORT=<report.txt>
--   reaper -nosplash -ignoreerrors <path to .RPP> scripts/reaper/verify-vocal-studio.lua
--
-- Reports: track structure, arm/input/monitor/mute state, FX chain with
-- bypass state, formatted parameter values, sends, and whether every exported
-- track template and FX chain loads with its FX intact.

local PROJECT = os.getenv("VS_PROJECT")
local TT_DIR = os.getenv("VS_TT_DIR")
local FX_DIR = os.getenv("VS_FX_DIR")
local REPORT = os.getenv("VS_REPORT") or "/tmp/vocal-studio-verify.txt"

local lines, failures = {}, 0
local function out(s) lines[#lines + 1] = s end
local function check(ok, msg)
  if ok then out("ok    " .. msg) else failures = failures + 1; out("FAIL  " .. msg) end
end

local function track_name(tr)
  local _, n = reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", "", false)
  return n
end

local function fx_summary(tr, indent)
  for fx = 0, reaper.TrackFX_GetCount(tr) - 1 do
    local _, fxname = reaper.TrackFX_GetFXName(tr, fx, "")
    local enabled = reaper.TrackFX_GetEnabled(tr, fx) and "on " or "off"
    out(string.format("%sFX[%d] %-30s %s", indent, fx, fxname, enabled))
    for p = 0, reaper.TrackFX_GetNumParams(tr, fx) - 1 do
      local _, pn = reaper.TrackFX_GetParamName(tr, fx, p, "")
      local _, pv = reaper.TrackFX_GetFormattedParamValue(tr, fx, p, "")
      out(string.format("%s      %-24s %s", indent, pn, pv))
    end
  end
end

-- ---------------------------------------------------------------------------
-- The project is opened as the launch argument, so project 0 is the template.
check(reaper.GetProjectName(0, "") ~= "", "project loaded: " .. reaper.GetProjectName(0, ""))
local EXPECT_ORDER = {
  "BACKING", "Backing Track", "VOCAL ROUTING", "Vocal Bus", "LEAD VOCALS",
  "Lead Clean", "Lead Clean FX", "Grit Vocal", "Harsh Vocal", "VOCAL LAYERS",
  "Double L", "Double R", "Harmonies", "FX RETURNS", "Vocal Reverb", "Vocal Delay",
  "ELECTRIC GUITAR", "Electric Guitar DI", "Crystal Clean", "Warm Clean - Ambient",
  "Classic Rock - Crunch", "Hard Rock - Heavy Lead", "Modern Metal Rhythm",
  "Metalcore - Modern Lead", "Hard Stuff (Legacy)",
}
local n = reaper.CountTracks(0)
check(n == #EXPECT_ORDER, "track count " .. n .. " == " .. #EXPECT_ORDER)

local depth = 0
for i = 0, n - 1 do
  local tr = reaper.GetTrack(0, i)
  local name = track_name(tr)
  local fd = reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERDEPTH")
  local rec = reaper.GetMediaTrackInfo_Value(tr, "I_RECARM")
  local inp = reaper.GetMediaTrackInfo_Value(tr, "I_RECINPUT")
  local mon = reaper.GetMediaTrackInfo_Value(tr, "I_RECMON")
  local mute = reaper.GetMediaTrackInfo_Value(tr, "B_MUTE")
  local vol = reaper.GetMediaTrackInfo_Value(tr, "D_VOL")
  local pan = reaper.GetMediaTrackInfo_Value(tr, "D_PAN")
  local sends = reaper.GetTrackNumSends(tr, 0)
  local voldb = vol > 0 and 20 * math.log(vol, 10) or -math.huge
  depth = depth + 1 + 0
  out(string.format("[%2d] %-16s rec=%d input=%d monitor=%d mute=%d vol=%.1fdB pan=%.2f sends=%d folder=%d",
    i, name, rec, inp, mon, mute, voldb, pan, sends, fd))
  check(name == EXPECT_ORDER[i + 1], "order: " .. name)
  check(rec == 0, "disarmed: " .. name)
  fx_summary(tr, "      ")
end

check(reaper.CountMediaItems(0) == 0, "no media items in template")
local vocalNames = { ["Lead Clean"] = 0, ["Double L"] = -0.5, ["Double R"] = 0.5 }
for i = 0, n - 1 do
  local tr = reaper.GetTrack(0, i)
  local name = track_name(tr)
  if vocalNames[name] then
    check(reaper.GetMediaTrackInfo_Value(tr, "I_RECINPUT") == 0, "mono input 1: " .. name)
  end
  if name == "Electric Guitar DI" then
    check(reaper.GetMediaTrackInfo_Value(tr, "I_RECINPUT") == 1, "guitar DI on Input 2 (mono index 1)")
    check(reaper.GetMediaTrackInfo_Value(tr, "B_MAINSEND") == 0, "guitar DI has no direct master route")
    check(reaper.GetTrackNumSends(tr, 0) == 7, "guitar DI sends to all seven tones")
  end
  if name == "Hard Stuff (Legacy)" or name == "Crystal Clean" then
    check(reaper.GetMediaTrackInfo_Value(tr, "I_RECINPUT") == -1, "tone track has no record input: " .. name)
  end
  if name == "Backing Track" then
    check(reaper.GetMediaTrackInfo_Value(tr, "I_RECINPUT") == -1, "backing track has no input")
  end
end

-- Track templates and FX chains must load into a fresh track with their FX.
local function read_file(p)
  local f = io.open(p, "r")
  if not f then return nil end
  local s = f:read("a"); f:close(); return s
end
local function load_into_new_track(label, chunk, expect_fx)
  local idx = reaper.CountTracks(0)
  reaper.InsertTrackAtIndex(idx, false)
  local tr = reaper.GetTrack(0, idx)
  local ok = reaper.SetTrackStateChunk(tr, chunk, false)
  check(ok, "chunk parses: " .. label)
  local fx = reaper.TrackFX_GetCount(tr)
  check(fx == expect_fx, string.format("%s FX count %d == %d", label, fx, expect_fx))
  out("      " .. label .. " loaded:")
  fx_summary(tr, "        ")
  reaper.DeleteTrack(tr)
end
if TT_DIR then
  for _, f in ipairs({ "Lead Clean", "Lead Clean FX", "Grit Vocal", "Harsh Vocal", "Double L", "Double R", "Harmonies", "Electric Guitar DI" }) do
    local c = read_file(TT_DIR .. "/" .. f .. ".RTrackTemplate")
    check(c ~= nil, "track template present: " .. f)
    if c then load_into_new_track("TT " .. f, c, ({ ["Lead Clean"]=3, ["Lead Clean FX"]=3, ["Grit Vocal"]=4, ["Harsh Vocal"]=4, ["Double L"]=2, ["Double R"]=2, ["Harmonies"]=2, ["Electric Guitar DI"]=0 })[f]) end
  end
end
if FX_DIR then
  for _, f in ipairs({ "Lead Clean", "Lead Clean FX", "Grit Vocal", "Harsh Vocal", "Double L", "Double R", "Harmonies", "Vocal Reverb", "Vocal Delay" }) do
    local c = read_file(FX_DIR .. "/" .. f .. ".RfxChain")
    check(c ~= nil, "fx chain present: " .. f)
    if c then
      -- An RfxChain is a bare <FXCHAIN> block; wrap it in a TRACK chunk to load it.
      local wrapped = "<TRACK\n" .. c .. ">\n"
      load_into_new_track("FX " .. f, wrapped, ({ ["Lead Clean"]=3, ["Lead Clean FX"]=3, ["Grit Vocal"]=4, ["Harsh Vocal"]=4, ["Double L"]=2, ["Double R"]=2, ["Harmonies"]=2, ["Vocal Reverb"]=1, ["Vocal Delay"]=1, })[f])
    end
  end
end

local TONE_LIST = {
  { "Clean", "Crystal Clean", 4 }, { "Clean", "Warm Clean - Ambient", 5 },
  { "Rock", "Classic Rock - Crunch", 5 }, { "Rock", "Hard Rock - Heavy Lead", 6 },
  { "Metal", "Modern Metal Rhythm", 4 }, { "Metal", "Metalcore - Modern Lead", 7 },
  { "Legacy", "Hard Stuff (Legacy)", 4 },
}
local TONE_ROOT = os.getenv("VS_TONE_ROOT")
if TONE_ROOT then
  for _, t in ipairs(TONE_LIST) do
    local cat, name, count = t[1], t[2], t[3]
    local tt = read_file(TONE_ROOT .. "/TrackTemplates/Guitar Tones/" .. cat .. "/" .. name .. ".RTrackTemplate")
    check(tt ~= nil, "tone track template present: " .. name)
    if tt then load_into_new_track("TONE TT " .. name, tt, count) end
    local fxc = read_file(TONE_ROOT .. "/FXChains/Guitar Tones/" .. cat .. "/" .. name .. ".RfxChain")
    check(fxc ~= nil, "tone fx chain present: " .. name)
    if fxc then load_into_new_track("TONE FX " .. name, "<TRACK\n" .. fxc .. ">\n", count) end
  end
end

out("")
out(string.format("SUMMARY failures=%d", failures))
local f = assert(io.open(REPORT, "w"))
f:write(table.concat(lines, "\n") .. "\n")
f:close()
reaper.Main_OnCommand(40004, 0) -- File: Quit REAPER
