-- Modern Rock & Metal - Vocal Studio: reload verification (developer tool).
--
-- Run against the SAVED project (not the builder's in-memory state):
--   VS_TT_DIR=<TrackTemplates/Vocal Studio> VS_TONE_ROOT=<REAPER resource dir>
--   VS_FX_DIR=<FXChains/Vocal Studio> VS_REPORT=<report.txt>
--   reaper -nosplash -ignoreerrors <path to .RPP> scripts/reaper/verify-vocal-studio.lua
--
-- Reports: track structure, arm/input/monitor/mute state, FX chain with
-- bypass state, formatted parameter values, sends, and whether every exported
-- track template and FX chain loads with its FX intact.
-- luacheck: globals reaper  (REAPER host API, provided by ReaScript)

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
  "Double L", "Double R", "Harmonies", "FX RETURNS", "Vocal Reverb", "Vocal Room", "Vocal Delay",
  "ELECTRIC GUITAR", "Electric Guitar DI", "Crystal Clean", "Warm Clean - Ambient",
  "AC-DC - Classic Crunch", "Avenged Sevenfold - Lead", "Machine Head - Groove Thrash",
  "Lamb of God - Groove Metal", "Slipknot - Nu Metal", "Asking Alexandria - Metalcore",
  "Discord Lesson Bus",
}
-- VS_ARMED: comma-separated tracks the template ships armed with input
-- monitoring ("Music Studio": the guitar DI and Lead Clean); all others disarmed.
local ARMED = {}
for name in (os.getenv("VS_ARMED") or ""):gmatch("[^,]+") do ARMED[name] = true end
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
  if ARMED[name] then
    check(rec == 1 and mon == 1, "armed with input monitoring: " .. name)
  else
    check(rec == 0, "disarmed: " .. name)
  end
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
    check(reaper.GetTrackNumSends(tr, 0) == 8, "guitar DI sends to all eight tones")
  end
  if name == "Crystal Clean" or name == "Machine Head - Groove Thrash" then
    check(reaper.GetMediaTrackInfo_Value(tr, "I_RECINPUT") == -1, "tone track has no record input: " .. name)
  end
  if name == "Backing Track" then
    check(reaper.GetMediaTrackInfo_Value(tr, "I_RECINPUT") == -1, "backing track has no input")
    check(reaper.GetTrackNumSends(tr, 0) == 0, "backing track never reaches the Discord lesson bus")
  end
end

-- Output buses: lesson bus -> out 3-4 only; master -> out 1-2 and 5-6.
local function hw_channels(tr)
  local chans = {}
  for k = 0, reaper.GetTrackNumSends(tr, 1) - 1 do
    chans[#chans + 1] = math.floor(reaper.GetTrackSendInfo_Value(tr, 1, k, "I_DSTCHAN"))
  end
  table.sort(chans)
  return table.concat(chans, ",")
end
local lesson
for i = 0, n - 1 do
  local tr = reaper.GetTrack(0, i)
  if track_name(tr) == "Discord Lesson Bus" then lesson = tr end
end
check(lesson ~= nil, "Discord Lesson Bus exists")
if lesson then
  check(reaper.GetMediaTrackInfo_Value(lesson, "B_MAINSEND") == 0,
    "lesson bus is not in the master (headphones/OBS) mix")
  check(hw_channels(lesson) == "2", "lesson bus -> REAPER out 3-4 only (got " .. hw_channels(lesson) .. ")")
  local feeds = {}
  for k = 0, reaper.GetTrackNumSends(lesson, -1) - 1 do
    local src = reaper.GetTrackSendInfo_Value(lesson, -1, k, "P_SRCTRACK")
    feeds[track_name(src)] = true
  end
  check(feeds["Vocal Bus"], "lesson bus receives the vocal bus")
  for _, t in ipairs({ "Crystal Clean", "Machine Head - Groove Thrash", "Asking Alexandria - Metalcore" }) do
    check(feeds[t], "lesson bus receives " .. t)
  end
  check(not feeds["Backing Track"] and not feeds["Electric Guitar DI"], "lesson bus: no backing track, no raw DI")
end
check(hw_channels(reaper.GetMasterTrack(0)) == "0,4", "master -> out 1-2 (headphones) and 5-6 (OBS) (got "
  .. hw_channels(reaper.GetMasterTrack(0)) .. ")")

-- Vocal presets: key parameters read back from the saved project (units as
-- REAPER displays them: Hz, dB, ms; Calf threshold is linear).
local VOCAL_EXPECT = {
  ["Lead Clean"] = {
    eq = { 80, 250, -2, 3000, 3, 10000, 2 }, comp = { -27, 3 }, deess = 0.04,
    sends = { ["Vocal Reverb"] = -18, ["Vocal Room"] = -28, ["Vocal Delay"] = -30 },
  },
  ["Lead Clean FX"] = {
    eq = { 80, 250, -2.5, 3000, 3.5, 10000, 2.5 }, comp = { -27, 4 }, deess = 0.04,
    sends = { ["Vocal Reverb"] = -22, ["Vocal Room"] = -22, ["Vocal Delay"] = -26 },
  },
  ["Grit Vocal"] = {
    eq = { 100, 250, -3, 3000, 3.5, 10000, 1.5 }, comp = { -27, 4 }, deess = 0.04,
    sends = { ["Vocal Reverb"] = -32, ["Vocal Room"] = -20, ["Vocal Delay"] = -32 },
  },
  ["Harsh Vocal"] = {
    eq = { 120, 250, -4, 4000, 3, 8000, 1 }, comp = { -28, 5 }, deess = 0.05,
    sends = { ["Vocal Room"] = -24, ["Vocal Delay"] = -34 },
  },
  ["Double L"] = {
    eq = { 120, 250, -2, 3000, 2, 10000, 1 }, comp = { -26, 3 }, deess = 0.03,
    sends = { ["Vocal Reverb"] = -20, ["Vocal Room"] = -24 },
  },
  ["Double R"] = {
    eq = { 120, 250, -2, 3000, 2, 10000, 1 }, comp = { -26, 3 }, deess = 0.03,
    sends = { ["Vocal Reverb"] = -20, ["Vocal Room"] = -24 },
  },
  ["Harmonies"] = {
    eq = { 110, nil, nil, 3000, 0, 10000, 0 }, comp = { -26, 2 }, deess = 0.04,
    sends = { ["Vocal Reverb"] = -20, ["Vocal Delay"] = -26 },
  },
}
local function num(tr, fx, pname)
  for p = 0, reaper.TrackFX_GetNumParams(tr, fx) - 1 do
    local _, pn = reaper.TrackFX_GetParamName(tr, fx, p, "")
    if pn == pname then
      local _, v = reaper.TrackFX_GetFormattedParamValue(tr, fx, p, "")
      return tonumber(v:match("[-+]?[%d%.]+"))
    end
  end
end
local function near(a, b, tol) return a ~= nil and b ~= nil and math.abs(a - b) <= (tol or 0.06) end
local function find_fx(tr, needle)
  for k = 0, reaper.TrackFX_GetCount(tr) - 1 do
    local _, fxn = reaper.TrackFX_GetFXName(tr, k, "")
    if fxn:find(needle, 1, true) then return k end
  end
  return -1
end
for i = 0, n - 1 do
  local tr = reaper.GetTrack(0, i)
  local name = track_name(tr)
  local e = VOCAL_EXPECT[name]
  if e then
    check(reaper.GetMediaTrackInfo_Value(tr, "I_RECINPUT") == 0, name .. ": records mono Scarlett Input 1")
    local eqi, ci, di = find_fx(tr, "ReaEQ"), find_fx(tr, "ReaComp"), find_fx(tr, "Calf Deesser")
    check(eqi >= 0 and ci > eqi and di > ci, name .. ": EQ -> compressor -> de-esser")
    check(not reaper.TrackFX_GetEnabled(tr, find_fx(tr, "ReaGate")), name .. ": gate bypassed")
    if eqi >= 0 then
      check(near(num(tr, eqi, "Freq-High Pass 5"), e.eq[1], 0.6), string.format("%s: high-pass %d Hz", name, e.eq[1]))
      if e.eq[2] then
        check(near(num(tr, eqi, "Freq-Band 2"), e.eq[2], 0.6) and near(num(tr, eqi, "Gain-Band 2"), e.eq[3]),
          string.format("%s: band 2 %d Hz %+.1f dB", name, e.eq[2], e.eq[3]))
      end
      check(near(num(tr, eqi, "Freq-Band 3"), e.eq[4], 0.6) and near(num(tr, eqi, "Gain-Band 3"), e.eq[5]),
        string.format("%s: band 3 %d Hz %+.1f dB", name, e.eq[4], e.eq[5]))
      check(near(num(tr, eqi, "Freq-High Shelf 4"), e.eq[6], 0.6) and near(num(tr, eqi, "Gain-High Shelf 4"), e.eq[7]),
        string.format("%s: high shelf %d Hz %+.1f dB", name, e.eq[6], e.eq[7]))
    end
    if ci >= 0 then
      check(near(num(tr, ci, "Threshold"), e.comp[1]) and near(num(tr, ci, "Ratio"), e.comp[2]),
        string.format("%s: compressor %d dB %.0f:1", name, e.comp[1], e.comp[2]))
    end
    if di >= 0 then
      check(near(num(tr, di, "Threshold"), e.deess, 0.006), string.format("%s: de-esser threshold %.2f", name, e.deess))
    end
    local got = {}
    for k = 0, reaper.GetTrackNumSends(tr, 0) - 1 do
      local dst = reaper.GetTrackSendInfo_Value(tr, 0, k, "P_DESTTRACK")
      local v = reaper.GetTrackSendInfo_Value(tr, 0, k, "D_VOL")
      got[track_name(dst)] = v > 0 and 20 * math.log(v, 10) or -math.huge
    end
    for dst, db in pairs(e.sends) do
      check(near(got[dst], db, 0.1), string.format("%s: send to %s %d dB", name, dst, db))
    end
    for dst in pairs(got) do check(e.sends[dst] ~= nil, string.format("%s: no unexpected send (%s)", name, dst)) end
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
-- gate, EQ, compressor(s), de-esser, optional parallel saturation
local VOCAL_FX_COUNT = {
  ["Lead Clean"] = 4, ["Lead Clean FX"] = 6, ["Grit Vocal"] = 5, ["Harsh Vocal"] = 5,
  ["Double L"] = 4, ["Double R"] = 4, ["Harmonies"] = 4, ["Electric Guitar DI"] = 0,
  ["Optional/High Harsh"] = 5, ["Optional/Low Harsh - Growl"] = 5,
  ["Vocal Reverb"] = 1, ["Vocal Room"] = 1, ["Vocal Delay"] = 1,
}
if TT_DIR then
  for _, f in ipairs({ "Lead Clean", "Lead Clean FX", "Grit Vocal", "Harsh Vocal", "Double L", "Double R", "Harmonies",
                       "Electric Guitar DI", "Optional/High Harsh", "Optional/Low Harsh - Growl" }) do
    local c = read_file(TT_DIR .. "/" .. f .. ".RTrackTemplate")
    check(c ~= nil, "track template present: " .. f)
    if c then load_into_new_track("TT " .. f, c, VOCAL_FX_COUNT[f]) end
  end
end
if FX_DIR then
  for _, f in ipairs({ "Lead Clean", "Lead Clean FX", "Grit Vocal", "Harsh Vocal", "Double L", "Double R", "Harmonies",
                       "Vocal Reverb", "Vocal Room", "Vocal Delay",
                       "Optional/High Harsh", "Optional/Low Harsh - Growl" }) do
    local c = read_file(FX_DIR .. "/" .. f .. ".RfxChain")
    check(c ~= nil, "fx chain present: " .. f)
    if c then
      -- An RfxChain is a bare <FXCHAIN> block; wrap it in a TRACK chunk to load it.
      local wrapped = "<TRACK\n" .. c .. ">\n"
      load_into_new_track("FX " .. f, wrapped, VOCAL_FX_COUNT[f])
    end
  end
end

local TONE_LIST = {
  { "Clean", "Crystal Clean", 5 }, { "Clean", "Warm Clean - Ambient", 6 },
  { "Rock", "AC-DC - Classic Crunch", 4 }, { "Rock", "Avenged Sevenfold - Lead", 9 },
  { "Metal", "Machine Head - Groove Thrash", 6 }, { "Metal", "Lamb of God - Groove Metal", 6 },
  { "Metal", "Slipknot - Nu Metal", 6 }, { "Metal", "Asking Alexandria - Metalcore", 7 },
}
local TONE_ROOT = os.getenv("VS_TONE_ROOT")

-- Load tone templates/chains one at a time and let each amp model finish
-- loading before the next: concurrent NAM model loads have crashed the NAM LV2
-- loader (seen once with ~21 simultaneous loads).
local jobs = {}
if TONE_ROOT then
  for _, t in ipairs(TONE_LIST) do
    local cat, name, count = t[1], t[2], t[3]
    local base = TONE_ROOT .. "/%s/Guitar Tones/" .. cat .. "/" .. name
    jobs[#jobs + 1] = { "TONE TT " .. name, base:format("TrackTemplates") .. ".RTrackTemplate", count, false }
    jobs[#jobs + 1] = { "TONE FX " .. name, base:format("FXChains") .. ".RfxChain", count, true }
  end
end

local function finish()
  out("")
  out(string.format("SUMMARY failures=%d", failures))
  local f = assert(io.open(REPORT, "w"))
  f:write(table.concat(lines, "\n") .. "\n")
  f:close()
  reaper.Main_OnCommand(40004, 0) -- File: Quit REAPER
end

local job, current, t_start = 0, nil, 0
local function step()
  if current then
    if reaper.time_precise() - t_start < 1.5 then reaper.defer(step); return end
    local tr = current.tr
    local _, c = reaper.GetTrackStateChunk(tr, "", false)
    check(c:find("neural%-amp%-modeler%-lv2#model /") ~= nil, current.label .. ": amp capture loaded")
    check(c:find("impulse_responses_mono/ports#ifn /") ~= nil, current.label .. ": cabinet IR loaded")
    reaper.DeleteTrack(tr)
    current = nil
  end
  job = job + 1
  if job > #jobs then finish(); return end
  local label, path, count, wrap = table.unpack(jobs[job])
  local text = read_file(path)
  check(text ~= nil, label .. " present")
  if not text then reaper.defer(step); return end
  local idx = reaper.CountTracks(0)
  reaper.InsertTrackAtIndex(idx, false)
  local tr = reaper.GetTrack(0, idx)
  check(reaper.SetTrackStateChunk(tr, wrap and ("<TRACK\n" .. text .. ">\n") or text, false), label .. " parses")
  local fx_count = reaper.TrackFX_GetCount(tr)
  check(fx_count == count, string.format("%s FX count %d == %d", label, fx_count, count))
  current, t_start = { tr = tr, label = label }, reaper.time_precise()
  reaper.defer(step)
end
step()
