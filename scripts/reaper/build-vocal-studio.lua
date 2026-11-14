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
  if cfg.ls then
    set_value(tr, fx, "ReaEQ", "Freq-Low Shelf", cfg.ls[1])
    set_value(tr, fx, "ReaEQ", "Gain-Low Shelf", cfg.ls[2])
  end
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

-- ---------------------------------------------------------------------------
-- Guitar amp and cabinet stage (v2): Neural Amp Modeler captures + LSP IRs.
--
-- Why not the Guitarix amps/cabs any more (measured, see docs):
--   * GxCabinet had no measurable effect on the signal in the previous build.
--   * Several Guitarix convolvers (GxCabinet, GxAmplifier-X's own cab) in one
--     REAPER process crash in libfftw3f (planner is not thread-safe).
--   * The Guitarix metal amp barely saturated a Strat DI (crest factor ~17 dB,
--     same as the dry DI); NAM captures reach ~9 dB on the same DI.
-- NAM models and IRs are user assets, not in Git: reaper-guitar-assets installs
-- them under ~/.local/share/reaper-studio/guitar from pinned upstream sources.
-- File paths are written as REAPER's plain-text LV2 state ("P <uri> <path> 3"),
-- which is what REAPER itself saves; both plugins restore from it.

local NAM_ID = "LV2: Neural Amp Modeler (Mike Oliphant) (Mono)"
local IR_ID = "LV2: LSP Impulse Responses Mono (LSP LV2)"
local NAM_PROP = "http://github.com/mikeoliphant/neural-amp-modeler-lv2#model"
local IR_PROP = "http://lsp-plug.in/plugins/lv2/impulse_responses_mono/ports#ifn"
local ASSETS = os.getenv("VS_ASSETS") or (os.getenv("HOME") .. "/.local/share/reaper-studio/guitar")
local PENDING = {}   -- track -> { nam = {state...}, ir = {state...} }, applied in one chunk edit

local function file_exists(path)
  local f = io.open(path, "r"); if f then f:close(); return true end; return false
end

local function queue_state(tr, kind, text)
  PENDING[tr] = PENDING[tr] or { nam = {}, ir = {} }
  table.insert(PENDING[tr][kind], text)
end

-- Write every queued NAM/IR file state of a track in ONE chunk edit, in plugin
-- order. Models load asynchronously: a second chunk edit before they finish
-- loading would write their (still empty) state back and lose the model.
local function apply_states(tr, queue)
  local _, c = reaper.GetTrackStateChunk(tr, "", false)
  -- skip_depth > 0 while replacing a STATE block; LSP's STATE contains a nested
  -- <L ...> block, so the block ends only when nesting returns to zero.
  local out, cur, nq, skip_depth = {}, nil, { nam = 1, ir = 1 }, 0
  for line in (c .. "\n"):gmatch("(.-)\n") do
    if skip_depth > 0 then
      if line:match("^%s*<") then skip_depth = skip_depth + 1
      elseif line:match("^%s*>%s*$") then
        skip_depth = skip_depth - 1
        if skip_depth == 0 then out[#out + 1] = ">" end
      end
    else
      if line:find('^<LV2 "' .. NAM_ID:gsub("%p", "%%%0")) then cur = "nam"
      elseif line:find('^<LV2 "' .. IR_ID:gsub("%p", "%%%0")) then cur = "ir"
      elseif line:match("^<LV2") or line:match("^<VST") or line:match("^<JS") then cur = nil end
      if line == "<STATE" and cur and queue[cur][nq[cur]] then
        out[#out + 1] = line
        out[#out + 1] = queue[cur][nq[cur]]
        nq[cur] = nq[cur] + 1
        skip_depth = 1
      else
        out[#out + 1] = line
      end
    end
  end
  return reaper.SetTrackStateChunk(tr, table.concat(out, "\n"), false)
end

-- Amp capture. input_db feeds the capture (gain staging before the amp);
-- output_db sets the level after it.
local NAM_OUT = {}  -- tone name -> NAM Output Lvl (dB), from guitar-tones-trim.txt 'nam:' lines
local CURRENT_TONE = nil
local function nam(tr, model, input_db, output_db)
  output_db = NAM_OUT[CURRENT_TONE] or output_db
  local fx = add_fx(tr, NAM_ID)
  if fx < 0 then return end
  set_value(tr, fx, "NAM", "Input Lvl", input_db)
  set_value(tr, fx, "NAM", "Output Lvl", output_db)
  local path = ASSETS .. "/nam/" .. model
  check(file_exists(path) and not path:find(" "), "NAM capture present (no spaces): " .. model)
  queue_state(tr, "nam", "P " .. NAM_PROP .. " " .. path .. " 3")
end

-- Cabinet IR, 100% wet. gain is linear (IRs here add ~+12 dB, so ~0.25).
local function cab_ir(tr, ir, gain)
  local fx = add_fx(tr, IR_ID)
  if fx < 0 then return end
  set_value(tr, fx, "LSP IR", "Dry amount", 0)
  set_value(tr, fx, "LSP IR", "Dry/Wet balance", 100)
  set_value(tr, fx, "LSP IR", "Output gain", gain)
  local path = ASSETS .. "/ir/" .. ir
  check(file_exists(path) and not path:find(" "), "cabinet IR present (no spaces): " .. ir)
  queue_state(tr, "ir", "P " .. IR_PROP .. " " .. path .. " 3")
end

-- Single-coil 50 Hz mains hum (measured on the Squier DI: 50/150/250 Hz peaks).
-- Narrow cuts before the amp, so high gain does not amplify the hum.
local function hum_notch(tr)
  eq(tr, { hp = 35, b2 = { 50, -12, 0.1 }, b3 = { 150, -9, 0.06 } })
end

-- Transparent gate in front of the amp, at DI level where the signal/noise
-- ratio is best. Fast attack keeps pick transients; -6 dB hysteresis closes
-- below the open threshold so sustained notes are not chopped.
-- Calibrated on the real Squier DI at the current Scarlett gain: noise peaks
-- reach -59.4 dBFS, playing peaks sit near -28 dBFS. Open -50 / close -56 dBFS
-- clears the noise by ~3 dB and leaves >20 dB for sustained notes. If Input 2
-- gain is raised, raise these thresholds by the same amount (see docs).
-- (The previous GxExpander had a 1 s attack: its ATTACK port is in seconds.)
local function guitar_gate(tr, thr, release)
  local fx = add_fx(tr, "VST: ReaGate (Cockos)")
  if fx < 0 then return end
  set_value(tr, fx, "ReaGate", "Threshold", thr)
  set_value(tr, fx, "ReaGate", "Attack", 1)
  set_value(tr, fx, "ReaGate", "Hold", 40)
  set_value(tr, fx, "ReaGate", "Release", release)
  set_value(tr, fx, "ReaGate", "Hysteresis", -6)
end

-- Tube Screamer as a tightening boost: little drive, high level, mid-focused tone.
local function ts_boost(tr, drive, level, tone)
  local fx = lv2(tr, "LV2: GxTubeScreamer (Guitarix team) (Mono)")
  if fx < 0 then return end
  set_value(tr, fx, "GxTubeScreamer", "Drive", drive)
  set_value(tr, fx, "GxTubeScreamer", "Level", level)
  set_value(tr, fx, "GxTubeScreamer", "Tone", tone)
end

local function insert_reverb(tr, wet_db)
  local fx = add_fx(tr, "VST: ReaVerbate (Cockos)")
  if fx < 0 then return end
  set_value(tr, fx, "ReaVerbate", "Wet", wet_db)
  set_value(tr, fx, "ReaVerbate", "Dry", 0)
  set_value(tr, fx, "ReaVerbate", "Room size", 30)
  set_value(tr, fx, "ReaVerbate", "Dampening", 60)
  set_value(tr, fx, "ReaVerbate", "Lowpass", 7000)
  set_value(tr, fx, "ReaVerbate", "Hipass", 150)
end

local function insert_delay(tr, seconds, wet_db, feedback_db)
  local fx = add_fx(tr, "VST: ReaDelay (Cockos)")
  if fx < 0 then return end
  set_value(tr, fx, "ReaDelay", "Wet", wet_db)
  set_value(tr, fx, "ReaDelay", "Dry", 0)
  set_value(tr, fx, "ReaDelay", "1: Length (time)", seconds)
  set_value(tr, fx, "ReaDelay", "1: Feedback", feedback_db)
  set_value(tr, fx, "ReaDelay", "1: Lowpass", 5000)
  set_value(tr, fx, "ReaDelay", "1: Hipass", 200)
end

local TONE_FN = {}

-- Crystal Clean: Fender Twin Reverb capture (genuinely clean, crest ~22 dB on a
-- Strat DI). The capture's Bright switch is very bright at low volume (measured
-- -26 dB lows), so the fullest IR (Don Spinacio) and a low shelf rebalance it.
TONE_FN.crystal = function(tr)
  comp(tr, { thr = -26, ratio = 2.5, att = 8, rel = 120 })
  nam(tr, "twin-reverb-normal-bright.nam", 0, 0)
  cab_ir(tr, "emerald/5_Don_Spinacio_48.wav", 0.25)
  eq(tr, { hp = 70, ls = { 180, 3 }, b2 = { 320, -1, 1.0 }, b3 = { 3200, -1, 1.0 }, hs = { 9000, -1.5 } })
  insert_reverb(tr, -24)
end

-- Warm Clean / Ambient: chorus into a Vox AC15 (input -6 dB keeps it clean),
-- the fattest IR (Kill Dill), dark top, long echo and hall.
TONE_FN.warm = function(tr)
  local ch = lv2(tr, "LV2: GxChorus-Stereo (Guitarix team)")
  if ch >= 0 then
    set_value(tr, ch, "GxChorus", "Level", 0.5)
    set_value(tr, ch, "GxChorus", "Depth", 0.35)
    set_value(tr, ch, "GxChorus", "Freq", 1.2)
  end
  nam(tr, "vox-ac15-jonar1.nam", -6, 0)
  cab_ir(tr, "emerald/6_Kill_Dill_48.wav", 0.25)
  eq(tr, { hp = 80, b2 = { 250, -1.5, 1.0 }, hs = { 5500, -3 } })
  local ec = lv2(tr, "LV2: GxEcho-Stereo (Guitarix team)")
  if ec >= 0 then
    set_value(tr, ec, "GxEcho", "L Time", 375)
    set_value(tr, ec, "GxEcho", "R Time", 410)
    set_value(tr, ec, "GxEcho", "L Level", 25)
    set_value(tr, ec, "GxEcho", "R Level", 25)
  end
  local rv = lv2(tr, "LV2: GxReverb-Stereo (Guitarix team)")
  if rv >= 0 then
    set_value(tr, rv, "GxReverb", "Dry/Wet", 35)
    set_value(tr, rv, "GxReverb", "Roomsize", 0.7)
    set_value(tr, rv, "GxReverb", "Damp", 0.5)
  end
end

-- Classic Rock / Crunch: JCM2000 crunch with less input (-6 dB) for a lighter,
-- touch-sensitive crunch; balanced Greenback IR.
TONE_FN.classic = function(tr)
  nam(tr, "jcm2000-crunch.nam", -6, 0)
  cab_ir(tr, "emerald/3_Wasabi_Warrior_48.wav", 0.25)
  eq(tr, { hp = 90, b2 = { 350, -1.5, 1.0 }, b3 = { 2500, 1, 1.0 }, hs = { 7500, -1.5 } })
  insert_reverb(tr, -24)
end

-- Hard Rock / Heavy Lead: compressed, TS-boosted JCM2000 lead channel, quarter-note delay.
TONE_FN.hardrock = function(tr)
  hum_notch(tr)
  guitar_gate(tr, -50, 250)
  comp(tr, { thr = -24, ratio = 3, att = 15, rel = 150 })
  ts_boost(tr, 0.2, 2, 750)
  nam(tr, "jcm2000-lead2-g8.nam", 0, 0)
  cab_ir(tr, "emerald/5_Don_Spinacio_48.wav", 0.25)
  eq(tr, { hp = 100, b2 = { 400, -1.5, 1.0 }, b3 = { 1800, 1.5, 1.0 }, hs = { 7500, -2 } })
  insert_delay(tr, 0.5, -18, -14)
  insert_reverb(tr, -22)
end

-- Modern Metal Rhythm: tight Tube Screamer boost into a 6505+ red channel
-- (crest ~9 dB on a Strat DI), V30 + SM57. Thick, mid-forward, tight low end.
TONE_FN.metal = function(tr)
  hum_notch(tr)
  guitar_gate(tr, -50, 90)
  ts_boost(tr, 0.05, 4, 800)
  nam(tr, "6505plus-red-noboost.nam", 0, 0)
  cab_ir(tr, "brutal/1_Cookie_Monster.wav", 0.25)
  eq(tr, { hp = 85, b2 = { 300, -2.5, 1.2 }, b3 = { 1200, 1.5, 1.0 }, hs = { 6500, -3 } })
end

-- Extreme Metal Rhythm: a different amp family (Engl E530 preamp + 840 power
-- amp, DS-1 in front, captured together), pushed +6 dB, plus a zero-drive TS
-- for low-end tightness (measured: without it the low end decays far slower),
-- tighter high-pass, more 2.5 kHz bite, brighter V30/Rockdriver blend, faster gate.
TONE_FN.extreme = function(tr)
  hum_notch(tr)
  guitar_gate(tr, -48, 60)
  ts_boost(tr, 0.0, 4, 900)
  nam(tr, "engl-e530-840-ds1.nam", 6, 0)
  cab_ir(tr, "brutal/5_Iceburn_Suicide.wav", 0.25)
  eq(tr, { hp = 110, b2 = { 400, -3, 1.0 }, b3 = { 2500, 2.5, 1.0 }, hs = { 6000, -3.5 } })
end

-- Metalcore / Melodic Lead: Mesa Mark IV lead (already very saturated, crest
-- ~7 dB, so no extra boost), V30, dotted-eighth delay, reverb.
TONE_FN.metalcore = function(tr)
  hum_notch(tr)
  guitar_gate(tr, -50, 250)
  nam(tr, "mesa-markiv.nam", 0, 0)
  cab_ir(tr, "brutal/12_World_Collider.wav", 0.25)
  eq(tr, { hp = 100, b2 = { 350, -1.5, 1.0 }, b3 = { 1000, 1.5, 1.0 }, hs = { 6500, -2.5 } })
  insert_delay(tr, 0.375, -16, -12)
  insert_reverb(tr, -24)
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
  green = color(90, 170, 70), clean = color(110, 170, 220),
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
  -- into every guitar tone track, and has no direct master route, so only the
  -- processed tone is heard. Playing a recorded DI item re-amps it through the chain.
  { name = "ELECTRIC GUITAR", depth = 1, color = C.green },
  { name = "Electric Guitar DI", depth = 0, color = C.green, kind = "di" },
  { name = "Crystal Clean", depth = 0, color = C.clean, kind = "tone", fn = "crystal", cat = "Clean", mute = false },
  { name = "Warm Clean - Ambient", depth = 0, color = C.clean, kind = "tone", fn = "warm", cat = "Clean", mute = true },
  { name = "Classic Rock - Crunch", depth = 0, color = C.orange, kind = "tone", fn = "classic", cat = "Rock", mute = true },
  { name = "Hard Rock - Heavy Lead", depth = 0, color = C.orange, kind = "tone", fn = "hardrock", cat = "Rock", mute = true },
  { name = "Modern Metal Rhythm", depth = 0, color = C.red, kind = "tone", fn = "metal", cat = "Metal", mute = true },
  { name = "Extreme Metal Rhythm", depth = 0, color = C.red, kind = "tone", fn = "extreme", cat = "Metal", mute = true },
  { name = "Metalcore - Melodic Lead", depth = -1, color = C.red, kind = "tone", fn = "metalcore", cat = "Metal", mute = true },
}

-- Per-tone fader trims in dB (name|dB per line), written after loudness calibration.
local TRIM = {}
do
  local f = io.open(os.getenv("VS_TRIM") or (OUT .. "/../../../scripts/reaper/guitar-tones-trim.txt"), "r")
  if f then
    for line in f:lines() do
      local nam_name, nam_db = line:match("^nam:(.-)|(%-?[%d%.]+)$")
      local name, db = line:match("^(.-)|(%-?[%d%.]+)$")
      if nam_name then NAM_OUT[nam_name] = tonumber(nam_db)
      elseif name then TRIM[name] = tonumber(db) end
    end
    f:close()
  end
end

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
  elseif spec.kind == "tone" then
    reaper.SetMediaTrackInfo_Value(tr, "I_RECINPUT", -1) -- processed track: never recordable
    reaper.SetMediaTrackInfo_Value(tr, "B_MAINSEND", 1)
    reaper.SetMediaTrackInfo_Value(tr, "B_MUTE", spec.mute and 1 or 0)
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
  elseif spec.kind == "tone" then
    CURRENT_TONE = spec.name
    TONE_FN[spec.fn](tr)
    spec.fx_count = reaper.TrackFX_GetCount(tr)
    reaper.SetMediaTrackInfo_Value(tr, "D_VOL", db2lin(TRIM[spec.name] or 0))
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

-- Guitar monitor path: DI (Input 2) -> send (post-fader) -> each tone track.
for _, spec in ipairs(LAYOUT) do
  if spec.kind == "tone" then send(T["Electric Guitar DI"], T[spec.name], 0) end
end

-- Amp captures and cabinet IRs: one state write per track (see apply_states).
for tr, q in pairs(PENDING) do
  check(apply_states(tr, q), "file states applied: " .. select(2, reaper.GetTrackName(tr)))
end
-- A malformed state edit silently drops every plugin after it; prove none were lost.
for _, spec in ipairs(LAYOUT) do
  if spec.kind == "tone" then
    local n = reaper.TrackFX_GetCount(T[spec.name])
    check(n == spec.fx_count, string.format("%s keeps all %d plugins after state edit (got %d)", spec.name, spec.fx_count, n))
  end
end

-- Expected structure, verified on the built project.
local nTracks = reaper.CountTracks(0)
check(nTracks == #LAYOUT, string.format("track count %d == %d", nTracks, #LAYOUT))

-- NAM loads its model asynchronously and only saves a model path once loaded,
-- so exporting must wait; otherwise chains would be saved without an amp.
local SETTLE = tonumber(os.getenv("VS_SETTLE") or "6")
local t_settle = reaper.time_precise()

local function export_all()

  -- Export track templates and FX chains (per vocal style and returns).
  local TT_DIR = OUT .. "/TrackTemplates/Vocal Studio"
  local TT_GUITAR = OUT .. "/TrackTemplates/Guitar Tones"
  local FX_GUITAR = OUT .. "/FXChains/Guitar Tones"
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
  -- Guitar tones: one track template and one FX chain per tone, in REAPER categories.
  for _, spec in ipairs(LAYOUT) do
    if spec.kind == "tone" then
      local cat_tt = TT_GUITAR .. "/" .. spec.cat
      local cat_fx = FX_GUITAR .. "/" .. spec.cat
      mkdir(cat_tt); mkdir(cat_fx)
      write_file(cat_tt .. "/" .. spec.name .. ".RTrackTemplate", track_template_chunk(T[spec.name]))
      write_file(cat_fx .. "/" .. spec.name .. ".RfxChain", fxchain_chunk(T[spec.name]))
    end
  end
  write_file(TT_DIR .. "/Electric Guitar DI.RTrackTemplate", track_template_chunk(T["Electric Guitar DI"]))
  write_file(FX_DIR .. "/Vocal Delay.RfxChain", fxchain_chunk(T["Vocal Delay"]))

  -- Project template: no media items anywhere, every audio track disarmed.
  -- Inactive tones: muted, FX bypassed AND FX offline. Offline FX keep their
  -- state (amp capture, IR) but are not loaded, so opening the project loads a
  -- single NAM model: less RAM/CPU, and it avoids a crash seen in the NAM LV2
  -- model loader when many models load concurrently. The tone switcher brings
  -- the chosen tone online. (Exported templates/chains above stay online.)
  for _, spec in ipairs(LAYOUT) do
    if spec.kind == "tone" then
      local tr = T[spec.name]
      reaper.SetMediaTrackInfo_Value(tr, "I_FXEN", spec.mute and 0 or 1)
      for fx = 0, reaper.TrackFX_GetCount(tr) - 1 do
        reaper.TrackFX_SetOffline(tr, fx, spec.mute and true or false)
      end
    end
  end
  local items = reaper.CountMediaItems(0)
  check(items == 0, "project has zero media items (" .. items .. ")")
  local pt = PT_DIR .. "/" .. TEMPLATE_NAME .. ".RPP"
  reaper.Main_SaveProjectEx(0, pt, 0)
  log("wrote   " .. pt)

  write_file(REPORT_PATH, table.concat(report, "\n") .. string.format(
    "\n\nSUMMARY failures=%d\n", failures))
  reaper.Main_OnCommand(40004, 0) -- File: Quit REAPER
end

local function wait_and_export()
  if reaper.time_precise() - t_settle < SETTLE then reaper.defer(wait_and_export); return end
  -- every queued capture/IR must have survived into the saved state
  for _, spec in ipairs(LAYOUT) do
    if spec.kind == "tone" and PENDING[T[spec.name]] then
      local _, c = reaper.GetTrackStateChunk(T[spec.name], "", false)
      local q = PENDING[T[spec.name]]
      local nam_n, ir_n = 0, 0
      for _ in c:gmatch(NAM_PROP:gsub("%p", "%%%0") .. " /") do nam_n = nam_n + 1 end
      for _ in c:gmatch(IR_PROP:gsub("%p", "%%%0") .. " /") do ir_n = ir_n + 1 end
      check(nam_n == #q.nam, string.format("%s: amp capture loaded and saved (%d/%d)", spec.name, nam_n, #q.nam))
      check(ir_n == #q.ir, string.format("%s: cabinet IR loaded and saved (%d/%d)", spec.name, ir_n, #q.ir))
    end
  end
  export_all()
end
wait_and_export()
