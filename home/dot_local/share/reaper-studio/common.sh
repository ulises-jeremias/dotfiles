# shellcheck shell=bash
# Shared routing helpers for reaper-studio and reaper-lesson.
#
# Everything here is REAPER-scoped: it links and unlinks only the JACK ports of
# the REAPER client plus the lesson bus it creates. It never changes the system
# default sink/source, never restarts PipeWire, and never touches Guitarix.
#
# Port names are stable device identifiers (ALSA card "Gen", Scarlett USB serial
# in the node name), never transient PipeWire node IDs.
#
# Verified mapping on the host (PipeWire 1.6, HiFi profile, Scarlett 2i2 4th Gen,
# USB 1235:8219, ALSA card "Gen"):
#   hw_Gen_0:capture_AUX0  = Input 1  (microphone)     -> REAPER in1
#   hw_Gen_0:capture_AUX1  = Input 2  (guitar DI)      -> REAPER in2
#   hw_Gen_0:capture_AUX2/3 = Monitor 3+4 hardware loopback of outputs 1-2
#                            (HiFi__Line4__source here). NEVER linked to REAPER.
#   Line1 sink             = headphones / line 1-2     <- REAPER out1/out2

set -euo pipefail

REAPER_TEMPLATE="${REAPER_TEMPLATE:-$HOME/.config/REAPER/ProjectTemplates/Modern Rock & Metal - Vocal Studio.RPP}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/reaper-studio"
mkdir -p "$STATE_DIR"

SCARLETT_CARD="alsa_input.hw_Gen_0"
MIC_IN="${SCARLETT_CARD}:capture_AUX0"
GUITAR_IN="${SCARLETT_CARD}:capture_AUX1"
LOOPBACK_PORTS_RE='capture_AUX2|capture_AUX3'
HEADPHONE_SINK_RE='alsa_output\.usb-Focusrite_Scarlett_2i2_4th_Gen.*HiFi__Line1__sink'
LESSON_SINK="reaper.lesson.mix"
LESSON_MIC="reaper.lesson.mic"
export LESSON_SINK LESSON_MIC

log() { printf '%s\n' "$*"; }
die() { printf 'reaper-studio: %s\n' "$*" >&2; exit 1; }

have_reaper() { pgrep -x reaper >/dev/null 2>&1; }

# Wait for REAPER's JACK client ports (up to ~30 s).
wait_reaper_ports() {

  for _ in $(seq 1 60); do
    if pw-link -o 2>/dev/null | grep -qx 'REAPER:out1' && pw-link -i 2>/dev/null | grep -qx 'REAPER:in1'; then
      return 0
    fi
    sleep 0.5
  done
  return 1
}

# Launch REAPER on the template (never opens the template file for editing).
launch_reaper() {
  if have_reaper; then return 0; fi
  [ -f "$REAPER_TEMPLATE" ] || die "template missing: $REAPER_TEMPLATE (run chezmoi apply)"
  nohup reaper -nosplash -template "$REAPER_TEMPLATE" >"$STATE_DIR/reaper.log" 2>&1 &
  wait_reaper_ports || die "REAPER JACK ports did not appear (see $STATE_DIR/reaper.log)"
}

# Idempotent link: create only if absent.
ensure_link() {
  local out="$1" in="$2"
  if pw-link -l 2>/dev/null | grep -F -A1 -- "$out" | grep -qF -- "|-> $in"; then return 0; fi
  pw-link "$out" "$in" 2>/dev/null || die "cannot link $out -> $in (is the port present?)"
}

# Remove any link from REAPER's outputs that is not one we want.
prune_reaper_outputs() {
  local keep_re="$1"
  pw-link -l 2>/dev/null | python3 -c '
import sys
cur = None
for raw in sys.stdin:
    if not raw.startswith(" "):
        cur = raw.strip(); continue
    if "|->" in raw and cur and cur.startswith("REAPER:out"):
        print(cur, raw.split("|->",1)[1].strip())
' | while read -r src dst; do
    if ! printf '%s\n' "$dst" | grep -Eq -- "$keep_re"; then
      pw-link -d "$src" "$dst" 2>/dev/null || true
      log "  unlinked $src -> $dst"
    fi
  done
}

# Find the Scarlett headphone sink ports (stable name pattern, not a node id).
headphone_ports() {
  pw-link -i 2>/dev/null | grep -E "$HEADPHONE_SINK_RE" | grep -E ':playback_(FL|FR)$' || true
}

# Peers of an exact port: prints the ports linked to it. $2 is "<-" (sources
# feeding an input port) or "->" (destinations fed by an output port).
peers_of() {
  local port="$1" dir="$2"
  pw-link -l 2>/dev/null | python3 -c '
import sys
port, d = sys.argv[1], sys.argv[2]
cur = None
for raw in sys.stdin:
    if not raw.startswith(" "):
        cur = raw.strip(); continue
    if cur == port and d in raw:
        print(raw.split(d, 1)[1].strip())
' "$port" "$dir"
}

# Doctor: every check prints ok/FAIL; returns the number of failed checks.
doctor_inputs() {
  local fails=0 peers
  check() { if [ "$1" = ok ]; then log "ok    $2"; else log "FAIL  $2"; fails=$((fails+1)); fi; }
  peers="$(peers_of REAPER:in1 '<-')"
  if [ "$peers" = "$MIC_IN" ]; then check ok "REAPER in1 = Input 1 mic ($MIC_IN)"; else check FAIL "REAPER in1 sources: ${peers:-none}"; fi
  peers="$(peers_of REAPER:in2 '<-')"
  if [ "$peers" = "$GUITAR_IN" ]; then check ok "REAPER in2 = Input 2 guitar DI ($GUITAR_IN)"; else check FAIL "REAPER in2 sources: ${peers:-none}"; fi
  local bad
  bad="$({ peers_of REAPER:in1 '<-'; peers_of REAPER:in2 '<-'; } | grep -E "$LOOPBACK_PORTS_RE" || true)"
  if [ -z "$bad" ]; then check ok "hardware loopback (AUX2/AUX3) not linked to REAPER"; else check FAIL "loopback feeds REAPER: $bad"; fi
  return "$fails"
}

doctor_outputs() {
  local fails=0 peers
  check() { if [ "$1" = ok ]; then log "ok    $2"; else log "FAIL  $2"; fails=$((fails+1)); fi; }
  peers="$(peers_of REAPER:out1 '->')"
  if printf '%s\n' "$peers" | grep -q 'Line1__sink:playback_FL$'; then check ok "REAPER out1 -> headphones FL"; else check FAIL "REAPER out1 not on headphones FL (peers: ${peers:-none})"; fi
  peers="$(peers_of REAPER:out2 '->')"
  if printf '%s\n' "$peers" | grep -q 'Line1__sink:playback_FR$'; then check ok "REAPER out2 -> headphones FR"; else check FAIL "REAPER out2 not on headphones FR (peers: ${peers:-none})"; fi
  if { peers_of REAPER:out1 '->'; peers_of REAPER:out2 '->'; } | grep -q 'USB_Audio_Device'; then check FAIL "REAPER output leaks to the USB dongle"; else check ok "REAPER output not on the USB dongle"; fi
  return "$fails"
}
