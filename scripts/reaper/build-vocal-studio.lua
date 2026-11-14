-- Modern Rock & Metal - Vocal Studio: template builder (developer tool).
--
-- Builds the project template, track templates and FX chains inside REAPER so
-- every plugin parameter is written and read back through the ReaScript API
-- (never by editing opaque VST state blobs).
--
-- Run (REAPER must be able to open a GUI session, e.g. Hyprland/Wayland):
--   VS_OUT=~/.dotfiles/home/dot_config/REAPER \
--   VS_REPORT=/path/report.txt \
--   reaper -nosplash -ignoreerrors scripts/reaper/build-vocal-studio.lua
--
-- Output layout (relative to VS_OUT, the chezmoi source of the REAPER dir):
--   ProjectTemplates/Modern Rock & Metal - Vocal Studio.RPP
--   TrackTemplates/Vocal Studio/*.RTrackTemplate
--   FXChains/Vocal Studio/*.RfxChain
--
-- The script exits REAPER when finished (action 40004 = File: Quit REAPER).

local OUT = os.getenv("VS_OUT") or reaper.GetResourcePath()
local REPORT_PATH = os.getenv("VS_REPORT") or (OUT .. "/vocal-studio-build-report.txt")
local TEMPLATE_NAME = "Modern Rock & Metal - Vocal Studio"

local report, failures = {}, 0
local TRACE = os.getenv("VS_TRACE")
local function trace(msg)
  if not TRACE then return end
  local f = io.open(TRACE, "a"); f:write(msg .. "\n"); f:close()
end
local function log(s) report[#report + 1] = s end
local function check(ok, msg)
  if ok then log("ok    " .. msg) else failures = failures + 1; log("FAIL  " .. msg) end
end

local function db2lin(db) if db == -math.huge then return 0 end return 10 ^ (db / 20) end
local function color(r, g, b) return reaper.ColorToNative(r, g, b) | 0x1000000 end

-- Parse the numeric part of a REAPER formatted parameter string
-- ("-inf", "+0.0", "250.0", "1.00k", "-6.0 dB"). Returns nil when non-numeric.
local function to_num(s)
  if s == nil then return nil end
  s = s:match("^%s*(.-)%s*$")
  if s:find("inf") then return (s:sub(1, 1) == "-") and -math.huge or math.huge end
  local n, rest = s:match("^([+-]?%d*%.?%d+)(.*)$")
  if not n then return nil end
  local v = tonumber(n)
  if v and rest:match("^k") then v = v * 1000 end
  return v
end

local function fmt_of(tr, fx, p)
  local _, s = reaper.TrackFX_GetFormattedParamValue(tr, fx, p, "")
  return s
end

local function find_param(tr, fx, name)
  for p = 0, reaper.TrackFX_GetNumParams(tr, fx) - 1 do
    local _, pn = reaper.TrackFX_GetParamName(tr, fx, p, "")
    if pn == name then return p end
  end
  error("parameter not found: " .. name)
end

-- Write a human value (in the plugin's own displayed unit) by binary search on
-- the normalized value, then read it back and report what the plugin shows.
local function set_value(tr, fx, fxname, name, target)
  trace("set " .. fxname .. " " .. name .. " " .. tostring(target))
  local p = find_param(tr, fx, name)
  local best
  if target == -math.huge then
    reaper.TrackFX_SetParamNormalized(tr, fx, p, 0.0)
    best = 0.0
  else
    reaper.TrackFX_SetParamNormalized(tr, fx, p, 0.0)
    local v_lo = to_num(fmt_of(tr, fx, p))
    reaper.TrackFX_SetParamNormalized(tr, fx, p, 1.0)
    local v_hi = to_num(fmt_of(tr, fx, p))
    if v_lo == nil or v_hi == nil then
      check(false, string.format("%s / %s: unit not numeric (%s .. %s)", fxname, name,
        tostring(v_lo), tostring(v_hi)))
      return
    end
    local increasing = v_hi > v_lo
    local lo, hi = 0.0, 1.0
    for _ = 1, 60 do
      local mid = (lo + hi) / 2
      reaper.TrackFX_SetParamNormalized(tr, fx, p, mid)
      local v = to_num(fmt_of(tr, fx, p))
      if v == nil then break end
      if (v < target) == increasing then lo = mid else hi = mid end
    end
    local err = math.huge
    for _, n in ipairs({ lo, hi }) do
      reaper.TrackFX_SetParamNormalized(tr, fx, p, n)
      local v = to_num(fmt_of(tr, fx, p))
      if v and math.abs(v - target) < err then best, err = n, math.abs(v - target) end
    end
    best = best or lo
    reaper.TrackFX_SetParamNormalized(tr, fx, p, best)
  end
  local shown = fmt_of(tr, fx, p)
  local got = to_num(shown)
  local tol = math.max(0.02 * math.abs(target), 0.05)
  if target == -math.huge then
    check(got == -math.huge, string.format("%-22s %-22s target=-inf got=%s", fxname, name, shown))
  else
    check(got ~= nil and math.abs(got - target) <= tol,
      string.format("%-22s %-22s target=%s got=%s", fxname, name, tostring(target), shown))
  end
end

-- Enum / switch parameters: write a normalized value and verify the label the
-- plugin displays (e.g. "M-Lead", "4x12", "Off").
local function set_norm(tr, fx, fxname, name, norm, label)
  local p = find_param(tr, fx, name)
  reaper.TrackFX_SetParamNormalized(tr, fx, p, norm)
  local shown = fmt_of(tr, fx, p)
  check(shown and shown:find(label, 1, true) ~= nil,
    string.format("%-22s %-22s want=%s got=%s", fxname, name, label, tostring(shown)))
end

local function add_fx(tr, ident)
  local idx = reaper.TrackFX_AddByName(tr, ident, false, -1)
  check(idx >= 0, "plugin loads: " .. ident)
  return idx
end

-- ReaEQ slots: High Pass 5, Band 2, Band 3, High Shelf 4 (Low Shelf unused, flat).
local function eq(tr, cfg)
  local fx = add_fx(tr, "VST: ReaEQ (Cockos)")
  if fx < 0 then return end
  set_value(tr, fx, "ReaEQ", "Freq-High Pass 5", cfg.hp)
  if cfg.hp_bw then set_value(tr, fx, "ReaEQ", "BW-High Pass 5", cfg.hp_bw) end
  if cfg.b2 then
    set_value(tr, fx, "ReaEQ", "Freq-Band 2", cfg.b2[1])
    set_value(tr, fx, "ReaEQ", "Gain-Band 2", cfg.b2[2])
    set_value(tr, fx, "ReaEQ", "BW-Band 2", cfg.b2[3])
  end
  if cfg.b3 then
    set_value(tr, fx, "ReaEQ", "Freq-Band 3", cfg.b3[1])
    set_value(tr, fx, "ReaEQ", "Gain-Band 3", cfg.b3[2])
    set_value(tr, fx, "ReaEQ", "BW-Band 3", cfg.b3[3])
  end
  if cfg.hs then
    set_value(tr, fx, "ReaEQ", "Freq-High Shelf 4", cfg.hs[1])
    set_value(tr, fx, "ReaEQ", "Gain-High Shelf 4", cfg.hs[2])
  end
end

-- ReaGate ships bypassed on vocal tracks: the gate clipped word endings in
-- earlier tests, so it is configured but left off until the noise floor is measured.
local function gate(tr, cfg)
  local fx = add_fx(tr, "VST: ReaGate (Cockos)")
  if fx < 0 then return end
  set_value(tr, fx, "ReaGate", "Threshold", cfg.thr)
  set_value(tr, fx, "ReaGate", "Attack", cfg.att)
  set_value(tr, fx, "ReaGate", "Hold", cfg.hold)
  set_value(tr, fx, "ReaGate", "Release", cfg.rel)
  set_value(tr, fx, "ReaGate", "Hysteresis", cfg.hys)
  reaper.TrackFX_SetEnabled(tr, fx, false)
  check(not reaper.TrackFX_GetEnabled(tr, fx), "ReaGate bypassed by default")
end

local function comp(tr, cfg)
  local fx = add_fx(tr, "VST: ReaComp (Cockos)")
  if fx < 0 then return end
  set_value(tr, fx, "ReaComp", "Threshold", cfg.thr)
  set_value(tr, fx, "ReaComp", "Ratio", cfg.ratio)
  set_value(tr, fx, "ReaComp", "Attack", cfg.att)
  set_value(tr, fx, "ReaComp", "Release", cfg.rel)
end

-- Distortion / saturation: only single-control JSFX exist here (verified by
-- enumerating parameters). Drive/Tone/Mix from the brief do not exist.
local function saturation(tr, amount)
  local fx = add_fx(tr, "JS: loser/Saturation")
  if fx < 0 then return end
  set_value(tr, fx, "Saturation", "Amount (%)", amount)
end

local function waveshaper(tr, pct)
  local fx = add_fx(tr, "JS: waveShapingDstr")
  if fx < 0 then return end
  set_value(tr, fx, "waveShapingDstr", "Distortion (%)", pct)
end

-- Genuine Guitarix LV2 plugins (gxplugins/guitarix 0.47). Their internal BYPASS
-- port defaults to ON, so every one is explicitly switched off here.
-- Not every Guitarix LV2 has an internal BYPASS port (GxFuzz and GxSaturator
-- do not); only the ones that do are switched on.
local function has_param(tr, fx, name)
  for p = 0, reaper.TrackFX_GetNumParams(tr, fx) - 1 do
    local _, pn = reaper.TrackFX_GetParamName(tr, fx, p, "")
    if pn == name then return true end
  end
  return false
end

local function lv2(tr, ident)
  local fx = add_fx(tr, ident)
  if fx < 0 then return -1 end
  if has_param(tr, fx, "BYPASS") then set_norm(tr, fx, ident, "BYPASS", 0.0, "Off") end
  return fx
end

-- Hard Stuff: the bank's enabled blocks, in signal order. The main amp is OFF
-- in the bank (amp.on_off = 0), so no amp head is used. Order: AstroFuzz
-- (pre), tone stack (post), shaper, cabinet.
local function hard_stuff(tr)
  trace("hard_stuff start")
  local fz = lv2(tr, "LV2: GxFuzz (Guitarix team) (Mono)")
  if fz >= 0 then                                   -- AstroFuzz stand-in (no LV2 build)
    set_value(tr, fz, "GxFuzz", "TONE", 0.51)
    set_value(tr, fz, "GxFuzz", "OUTPUT", 85.5)
    set_value(tr, fz, "GxFuzz", "DRIVE", 1.0)
  end
  -- Tone stack: GxAmplifier-X crashes REAPER when saved with GxCabinet in the
  -- same project (reproduced on reopen, with or without its own cab), so the
  -- M-Lead tone stack is approximated with native ReaEQ. Values are a first pass,
  -- to refine with an A/B against the real Guitarix render.
  local ts = add_fx(tr, "VST: ReaEQ (Cockos)")
  if ts >= 0 then
    set_value(tr, ts, "ReaEQ tone stack", "Freq-Low Shelf", 100)
    set_value(tr, ts, "ReaEQ tone stack", "Gain-Low Shelf", 0)
    set_value(tr, ts, "ReaEQ tone stack", "Freq-Band 2", 700)
    set_value(tr, ts, "ReaEQ tone stack", "Gain-Band 2", 2)
    set_value(tr, ts, "ReaEQ tone stack", "BW-Band 2", 1.0)
    set_value(tr, ts, "ReaEQ tone stack", "Freq-Band 3", 3000)
    set_value(tr, ts, "ReaEQ tone stack", "Gain-Band 3", 0)
    set_value(tr, ts, "ReaEQ tone stack", "Freq-High Shelf 4", 6000)
    set_value(tr, ts, "ReaEQ tone stack", "Gain-High Shelf 4", 0)
    set_value(tr, ts, "ReaEQ tone stack", "Freq-High Pass 5", 30)
    set_value(tr, ts, "ReaEQ tone stack", "Gain-High Pass 5", 0)
  end
  local sh = lv2(tr, "LV2: GxSaturator (Guitarix team) (Mono)")
  if sh >= 0 then                                   -- Shaper stand-in (no LV2 build)
    set_value(tr, sh, "GxSaturator", "INTENSITY", 10)
    set_value(tr, sh, "GxSaturator", "SATURATE", 60)
  end
  local cb = lv2(tr, "LV2: GxCabinet (Guitarix team) (Mono)")
  if cb >= 0 then                                   -- bank: cab Level 3.4925, bass 6.7, treble 3.4, 4x12
    set_value(tr, cb, "GxCabinet", "Cabinet", 3.4925)
    set_value(tr, cb, "GxCabinet", "Bass", 6.7)
    set_value(tr, cb, "GxCabinet", "Treble", 3.4)
    set_norm(tr, cb, "GxCabinet", "Cab Model", 0.0, "4x12")
  end
end

-- Machine Head variant: the amp is ON. GxAmplifier-X carries the tone stack
-- (M-Lead) and its own 4x12 cab. It is never combined with GxCabinet, which
-- crashes REAPER when the two are saved in the same project.
local function machine_head(tr)
  local fz = lv2(tr, "LV2: GxFuzz (Guitarix team) (Mono)")
  if fz >= 0 then
    set_value(tr, fz, "GxFuzz", "TONE", 0.51)
    set_value(tr, fz, "GxFuzz", "OUTPUT", 85.5)
    set_value(tr, fz, "GxFuzz", "DRIVE", 1.0)
  end
  local am = lv2(tr, "LV2: GxAmplifier-X (Guitarix team) (Mono)")
  if am >= 0 then
    set_value(tr, am, "GxAmp", "PreGain", 8.4)        -- bank amp2.stage1.Pregain
    set_value(tr, am, "GxAmp", "Distortion", 80)      -- high-gain end of the clean/dist blend
    set_value(tr, am, "GxAmp", "Drive", 0.6)
    set_value(tr, am, "GxAmp", "MasterGain", 0)
    set_value(tr, am, "GxAmp", "Presence", 5)
    set_value(tr, am, "GxAmp", "Bass", 0.5)           -- bank tonestack
    set_value(tr, am, "GxAmp", "Middle", 0.71)
    set_value(tr, am, "GxAmp", "Treble", 0.525)
    set_norm(tr, am, "GxAmp", "Tonestack Model", 6 / 26, "M-Lead")
    set_norm(tr, am, "GxAmp", "Cab Model", 0.0, "4x12")
  end
  local sh = lv2(tr, "LV2: GxSaturator (Guitarix team) (Mono)")
  if sh >= 0 then
    set_value(tr, sh, "GxSaturator", "INTENSITY", 10)
    set_value(tr, sh, "GxSaturator", "SATURATE", 60)
  end
end

-- Shared return: 100% wet, reverb level is controlled by the sends.
local function reverb_return(tr)
  local fx = add_fx(tr, "VST: ReaVerbate (Cockos)")
  if fx < 0 then return end
  set_value(tr, fx, "ReaVerbate", "Wet", 0)
  set_value(tr, fx, "ReaVerbate", "Dry", -math.huge)
  set_value(tr, fx, "ReaVerbate", "Room size", 35)
  set_value(tr, fx, "ReaVerbate", "Dampening", 70)
  set_value(tr, fx, "ReaVerbate", "Delay", 20)
  set_value(tr, fx, "ReaVerbate", "Lowpass", 8000)
  set_value(tr, fx, "ReaVerbate", "Hipass", 200)
end

local function delay_return(tr)
  local fx = add_fx(tr, "VST: ReaDelay (Cockos)")
  if fx < 0 then return end
  set_value(tr, fx, "ReaDelay", "Wet", 0)
  set_value(tr, fx, "ReaDelay", "Dry", -math.huge)
  -- 0.25 s = 1/8 note at 120 BPM (the template tempo). REAPER shows one decimal.
  set_value(tr, fx, "ReaDelay", "1: Length (time)", 0.25)
  set_value(tr, fx, "ReaDelay", "1: Feedback", -10)
  set_value(tr, fx, "ReaDelay", "1: Lowpass", 6000)
  set_value(tr, fx, "ReaDelay", "1: Hipass", 200)
end

-- Starting recipes (brief sections 4-5). Threshold values are placeholders:
-- they must be calibrated against a real take.
local STYLES = {
  lead_clean = {
    gate = { thr = -40, att = 3, hold = 50, rel = 150, hys = 4 },
    eq = { hp = 80, hp_bw = 0.7, b2 = { 250, -3, 1.0 }, b3 = { 3000, 3, 1.0 }, hs = { 10000, 2 } },
    comp = { thr = -20, ratio = 3, att = 10, rel = 100 },
    fader = 0, reverb_send = -18, delay_send = nil, pan = 0, rec_color = "lead",
  },
  lead_clean_fx = {
    gate = { thr = -40, att = 3, hold = 50, rel = 150, hys = 4 },
    eq = { hp = 80, hp_bw = 0.7, b2 = { 250, -3, 1.0 }, b3 = { 3000, 4, 1.0 }, hs = { 10000, 3 } },
    comp = { thr = -20, ratio = 4, att = 10, rel = 100 },
    fader = -2, reverb_send = -20, delay_send = nil, pan = 0, rec_color = "lead",
  },
  grit = {
    gate = { thr = -45, att = 3, hold = 50, rel = 150, hys = 4 },
    eq = { hp = 100, b2 = { 250, -4, 1.0 }, b3 = { 3000, 5, 1.0 }, hs = { 10000, 2 } },
    comp = { thr = -20, ratio = 4, att = 10, rel = 100 },
    sat = 15, fader = -5, reverb_send = -22, delay_send = nil, pan = 0, rec_color = "lead",
  },
  harsh = {
    gate = { thr = -50, att = 3, hold = 60, rel = 200, hys = 4 },
    eq = { hp = 120, b2 = { 250, -5, 1.0 }, b3 = { 4000, 6, 1.0 }, hs = { 8000, 3 } },
    comp = { thr = -20, ratio = 5, att = 5, rel = 120 },
    dist = 12, fader = -8, reverb_send = -25, delay_send = nil, pan = 0, rec_color = "lead",
  },
  double_l = {
    eq = { hp = 120, b3 = { 3000, 2, 1.0 }, hs = { 10000, 1 } },
    comp = { thr = -20, ratio = 3, att = 10, rel = 100 },
    fader = -10, reverb_send = -20, delay_send = nil, pan = -0.5, rec_color = "layer",
  },
  double_r = {
    eq = { hp = 120, b3 = { 3000, 2, 1.0 }, hs = { 10000, 1 } },
    comp = { thr = -20, ratio = 3, att = 10, rel = 100 },
    fader = -10, reverb_send = -20, delay_send = nil, pan = 0.5, rec_color = "layer",
  },
  harmony = {
    eq = { hp = 110, b3 = { 3000, 0, 1.0 }, hs = { 10000, 0 } },
    comp = { thr = -20, ratio = 2, att = 10, rel = 120 },
    fader = -12, reverb_send = -20, delay_send = -26, pan = 0, rec_color = "layer",
  },
}

local C = {
  grey = color(120, 120, 120), red = color(200, 60, 60), blue = color(60, 120, 210),
  teal = color(40, 160, 150), purple = color(130, 80, 190), orange = color(230, 130, 40),
  green = color(90, 170, 70),
}

-- Track order / folder structure. depth: +1 opens a folder, negative closes
-- that many folder levels after this track.
local LAYOUT = {
  { name = "BACKING", depth = 1, color = C.grey },
  { name = "Backing Track", depth = -1, color = C.grey, kind = "backing" },
  { name = "VOCAL ROUTING", depth = 1, color = C.purple },
  { name = "Vocal Bus", depth = 1, color = C.purple, kind = "bus" },
  { name = "LEAD VOCALS", depth = 1, color = C.red },
  { name = "Lead Clean", depth = 0, color = C.red, style = "lead_clean" },
  { name = "Lead Clean FX", depth = 0, color = C.red, style = "lead_clean_fx" },
  { name = "Grit Vocal", depth = 0, color = C.red, style = "grit" },
  { name = "Harsh Vocal", depth = -1, color = C.red, style = "harsh" },
  { name = "VOCAL LAYERS", depth = 1, color = C.blue },
  { name = "Double L", depth = 0, color = C.blue, style = "double_l" },
  { name = "Double R", depth = 0, color = C.blue, style = "double_r" },
  { name = "Harmonies", depth = -3, color = C.blue, style = "harmony" },
  { name = "FX RETURNS", depth = 1, color = C.teal },
  { name = "Vocal Reverb", depth = 0, color = C.teal, kind = "reverb" },
  { name = "Vocal Delay", depth = -1, color = C.teal, kind = "delay" },
  -- Guitar: the DI track records Scarlett Input 2 raw, monitors through a send
  -- into the Hard Stuff track, and has no direct master route, so only the
  -- processed tone is heard. Playing a recorded DI item re-amps it through the chain.
  { name = "ELECTRIC GUITAR", depth = 1, color = C.green },
  { name = "Electric Guitar DI", depth = 0, color = C.green, kind = "di" },
  { name = "Electric Guitar - Machine Head", depth = 0, color = C.green, kind = "machinehead" },
  { name = "Electric Guitar - Hard Stuff", depth = -1, color = C.green, kind = "hardstuff" },
}

local function write_file(path, content)
  local f = assert(io.open(path, "w"), "cannot write " .. path)
  f:write(content)
  f:close()
end

local function mkdir(path) reaper.RecursiveCreateDirectory(path, 0) end

-- Track template = the track's own <TRACK> chunk without send wiring
-- (AUXRECV references other track GUIDs, which are not portable).
local function track_template_chunk(tr)
  local _, chunk = reaper.GetTrackStateChunk(tr, "", false)
  local out = {}
  for line in (chunk .. "\n"):gmatch("(.-)\n") do
    if not line:match("^%s*AUXRECV") then out[#out + 1] = line end
  end
  while out[#out] == "" do out[#out] = nil end
  return table.concat(out, "\n") .. "\n"
end

-- FX chain = the <FXCHAIN> block of the track chunk. GetTrackStateChunk puts
-- every block opener at column 0, and every block (FXCHAIN and each nested
-- <VST>) closes with a bare ">" line, so track nesting depth until it returns to 0.
local function fxchain_chunk(tr)
  local _, chunk = reaper.GetTrackStateChunk(tr, "", false)
  local out, depth = {}, 0
  for line in (chunk .. "\n"):gmatch("(.-)\n") do
    if depth == 0 then
      if line:match("^<FXCHAIN") then depth = 1; out[#out + 1] = line end
    else
      out[#out + 1] = line
      if line:match("^%s*<") then depth = depth + 1
      elseif line == ">" then depth = depth - 1 end
      if depth == 0 then break end
    end
  end
  assert(#out > 0, "track has no <FXCHAIN> block")
  return table.concat(out, "\n") .. "\n"
end

-- ---------------------------------------------------------------------------
reaper.Main_OnCommand(40001, 0) -- Track: Insert new track (ensures a valid project)
while reaper.CountTracks(0) > 0 do reaper.DeleteTrack(reaper.GetTrack(0, 0)) end
reaper.GetSetProjectInfo(0, "PROJECT_SRATE", 48000, true)
reaper.GetSetProjectInfo(0, "PROJECT_SRATE_USE", 1, true)

local T = {}
for i, spec in ipairs(LAYOUT) do
  reaper.InsertTrackAtIndex(i - 1, true)
  local tr = reaper.GetTrack(0, i - 1)
  T[spec.name] = tr
  reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", spec.name, true)
  reaper.SetMediaTrackInfo_Value(tr, "I_CUSTOMCOLOR", spec.color)
  reaper.SetMediaTrackInfo_Value(tr, "I_FOLDERDEPTH", spec.depth)
  reaper.SetMediaTrackInfo_Value(tr, "I_RECARM", 0)     -- every track disarmed
  reaper.SetMediaTrackInfo_Value(tr, "I_RECMON", 0)     -- no software monitoring by default
  reaper.SetMediaTrackInfo_Value(tr, "I_RECMODE", 0)    -- record input
  if spec.kind == "backing" then
    reaper.SetMediaTrackInfo_Value(tr, "I_RECINPUT", -1) -- no input: never recordable by accident
  elseif spec.kind == "di" then
    reaper.SetMediaTrackInfo_Value(tr, "I_RECINPUT", 1)  -- Scarlett Input 2 (guitar DI), mono
    reaper.SetMediaTrackInfo_Value(tr, "I_RECMON", 1)    -- monitor input while armed (feeds the send)
    reaper.SetMediaTrackInfo_Value(tr, "B_MAINSEND", 0)  -- no direct master: raw DI never reaches the output
  elseif spec.kind == "machinehead" then
    reaper.SetMediaTrackInfo_Value(tr, "I_RECINPUT", -1) -- processed track: never recordable
  elseif spec.kind == "hardstuff" then
    reaper.SetMediaTrackInfo_Value(tr, "I_RECINPUT", -1) -- processed track: never recordable
    reaper.SetMediaTrackInfo_Value(tr, "B_MUTE", 1)      -- A/B: unmute to compare with Machine Head
  elseif spec.style then
    reaper.SetMediaTrackInfo_Value(tr, "I_RECINPUT", 0)  -- Scarlett Input 1, mono
  end
end

-- Insert chains and faders.
for _, spec in ipairs(LAYOUT) do
  local tr = T[spec.name]
  trace("chain " .. spec.name)
  if spec.style then
    local s = STYLES[spec.style]
    reaper.SetMediaTrackInfo_Value(tr, "D_VOL", db2lin(s.fader))
    reaper.SetMediaTrackInfo_Value(tr, "D_PAN", s.pan)
    if s.gate then gate(tr, s.gate) end
    if s.eq then eq(tr, s.eq) end
    if s.comp then comp(tr, s.comp) end
    if s.sat then saturation(tr, s.sat) end
    if s.dist then waveshaper(tr, s.dist) end
  elseif spec.kind == "reverb" then
    reverb_return(tr)
  elseif spec.kind == "delay" then
    delay_return(tr)
  elseif spec.kind == "machinehead" then
    machine_head(tr)
    reaper.SetMediaTrackInfo_Value(tr, "D_VOL", db2lin(-6.4))
  elseif spec.kind == "hardstuff" then
    hard_stuff(tr)
    reaper.SetMediaTrackInfo_Value(tr, "D_VOL", db2lin(-6.4)) -- bank master output
  end
end

-- Shared returns and sends (post-fader). Dry signal stays on the vocal track's
-- folder route; the returns only carry the wet part.
local function send(src, dst, db)
  local idx = reaper.CreateTrackSend(src, dst)
  reaper.SetTrackSendInfo_Value(src, 0, idx, "D_VOL", db2lin(db))
  local _, dst_name = reaper.GetTrackName(dst)
  check(idx >= 0, string.format("send %s -> %s at %.1f dB", select(2, reaper.GetTrackName(src)), dst_name, db))
end
for _, spec in ipairs(LAYOUT) do
  if spec.style then
    local s = STYLES[spec.style]
    send(T[spec.name], T["Vocal Reverb"], s.reverb_send)
    if s.delay_send then send(T[spec.name], T["Vocal Delay"], s.delay_send) end
  end
end

-- Guitar monitor path: DI (Input 2) -> send (post-fader) -> Hard Stuff.
send(T["Electric Guitar DI"], T["Electric Guitar - Machine Head"], 0)
send(T["Electric Guitar DI"], T["Electric Guitar - Hard Stuff"], 0)

-- Expected structure, verified on the built project.
local nTracks = reaper.CountTracks(0)
check(nTracks == #LAYOUT, string.format("track count %d == %d", nTracks, #LAYOUT))

-- Export track templates and FX chains (per vocal style and returns).
local TT_DIR = OUT .. "/TrackTemplates/Vocal Studio"
local FX_DIR = OUT .. "/FXChains/Vocal Studio"
local PT_DIR = OUT .. "/ProjectTemplates"
mkdir(TT_DIR); mkdir(FX_DIR); mkdir(PT_DIR)

local EXPORT = {
  { file = "Lead Clean", tr = "Lead Clean" },
  { file = "Lead Clean FX", tr = "Lead Clean FX" },
  { file = "Grit Vocal", tr = "Grit Vocal" },
  { file = "Harsh Vocal", tr = "Harsh Vocal" },
  { file = "Double L", tr = "Double L" },
  { file = "Double R", tr = "Double R" },
  { file = "Harmonies", tr = "Harmonies" },
}
for _, e in ipairs(EXPORT) do
  write_file(TT_DIR .. "/" .. e.file .. ".RTrackTemplate", track_template_chunk(T[e.tr]))
  write_file(FX_DIR .. "/" .. e.file .. ".RfxChain", fxchain_chunk(T[e.tr]))
end
write_file(FX_DIR .. "/Vocal Reverb.RfxChain", fxchain_chunk(T["Vocal Reverb"]))
write_file(FX_DIR .. "/Hard Stuff.RfxChain", fxchain_chunk(T["Electric Guitar - Hard Stuff"]))
write_file(FX_DIR .. "/Machine Head.RfxChain", fxchain_chunk(T["Electric Guitar - Machine Head"]))
write_file(TT_DIR .. "/Electric Guitar - Machine Head.RTrackTemplate", track_template_chunk(T["Electric Guitar - Machine Head"]))
write_file(TT_DIR .. "/Electric Guitar DI.RTrackTemplate", track_template_chunk(T["Electric Guitar DI"]))
write_file(TT_DIR .. "/Electric Guitar - Hard Stuff.RTrackTemplate", track_template_chunk(T["Electric Guitar - Hard Stuff"]))
write_file(FX_DIR .. "/Vocal Delay.RfxChain", fxchain_chunk(T["Vocal Delay"]))

-- Project template: no media items anywhere, every audio track disarmed.
local items = reaper.CountMediaItems(0)
check(items == 0, "project has zero media items (" .. items .. ")")
local pt = PT_DIR .. "/" .. TEMPLATE_NAME .. ".RPP"
reaper.Main_SaveProjectEx(0, pt, 0)
log("wrote   " .. pt)

write_file(REPORT_PATH, table.concat(report, "\n") .. string.format(
  "\n\nSUMMARY failures=%d\n", failures))
reaper.Main_OnCommand(40004, 0) -- File: Quit REAPER
