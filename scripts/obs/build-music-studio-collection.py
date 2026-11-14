#!/usr/bin/env python3
"""Generate the OBS "Music Studio" scene collection and profile (developer tool).

Writes chezmoi sources with the create_ prefix: chezmoi installs them once and
then OBS owns them, so changes made in the OBS GUI are kept.

Audio (no plugin needed; OBS's native PulseAudio capture over pipewire-pulse):
  "REAPER Program"  Mic/Aux global source  <- PipeWire source reaper_program
                     (REAPER out 5-6: the full REAPER mix)        tracks 1 + 2
  "Discord Call"    Desktop Audio global   <- discord_call.monitor (the sink's monitor)
                     (Discord's output only, not all desktop audio) tracks 1 + 3
Recording tracks: 1 = full mix, 2 = REAPER only, 3 = Discord only.
OBS monitoring is off on every source, so OBS never plays audio back (no
doubled audio, no feedback). The virtual camera carries video only.

Usage: build-music-studio-collection.py [repo root]
"""

from __future__ import annotations

import json
import sys
import uuid
from pathlib import Path

NS = uuid.UUID("6f1d7a52-3c1b-4f3e-9a5e-6d1c2b3a4f50")


def uid(name: str) -> str:
    # stable UUIDs so regenerating the collection does not churn the file
    return str(uuid.uuid5(NS, name))


def source(name: str, sid: str, settings: dict, mixers: int = 0) -> dict:
    return {
        "name": name, "uuid": uid(name), "id": sid, "versioned_id": sid,
        "settings": settings, "mixers": mixers, "sync": 0, "flags": 0,
        "volume": 1.0, "balance": 0.5, "enabled": True, "muted": False,
        "push-to-mute": False, "push-to-mute-delay": 0,
        "push-to-talk": False, "push-to-talk-delay": 0, "hotkeys": {},
        "deinterlace_mode": 0, "deinterlace_field_order": 0,
        "monitoring_type": 0, "private_settings": {},
    }


def item(name: str, n: int, x: float, y: float, w: float, h: float) -> dict:
    # bounds_type 2 = scale to inner bounds: any camera/screen resolution fits
    return {
        "name": name, "source_uuid": uid(name), "visible": True, "locked": False,
        "rot": 0.0, "align": 5, "bounds_type": 2, "bounds_align": 0,
        "bounds_crop": False, "crop_left": 0, "crop_top": 0, "crop_right": 0,
        "crop_bottom": 0, "id": n, "group_item_backup": False,
        "pos": {"x": x, "y": y}, "scale": {"x": 1.0, "y": 1.0},
        "bounds": {"x": w, "y": h}, "scale_filter": "disable",
        "blend_method": "default", "blend_type": "normal",
        "show_transition": {"duration": 300}, "hide_transition": {"duration": 300},
        "private_settings": {},
    }


def text(name: str, label: str, size: int) -> dict:
    return source(name, "text_ft2_source_v2", {
        "text": label, "font": {"face": "Sans Serif", "size": size, "style": "Bold", "flags": 1},
        "color1": 4294967295, "color2": 4294967295, "outline": True, "drop_shadow": True,
    })


def scene(name: str, items: list[tuple]) -> dict:
    entries = [item(src, i + 1, *geom) for i, (src, geom) in enumerate(items)]
    return source(name, "scene", {"id_counter": len(entries), "custom_size": False, "items": entries})


def collection() -> dict:
    full = (0.0, 0.0, 1920.0, 1080.0)
    sources = [
        source("Studio Background", "color_source_v3", {"color": 4280295456, "width": 1920, "height": 1080}),
        # Camera: pick your webcam once in its properties (none is connected yet).
        source("Camera", "v4l2_input", {}),
        # PipeWire screen/window capture: OBS asks once through the desktop portal
        # and remembers the choice (restore token).
        source("Screen", "pipewire-screen-capture-source", {"ShowCursor": True}),
        source("REAPER Window", "pipewire-window-capture-source", {"ShowCursor": True}),
        text("Lesson Title", "Guitar Lesson", 56),
        text("Performance Title", "Live Performance", 56),
        text("Tutorial Title", "Music Tutorial", 56),
        scene("Guitar Lesson", [
            ("Studio Background", full),
            ("Camera", (0.0, 0.0, 1280.0, 1080.0)),
            ("REAPER Window", (1300.0, 560.0, 600.0, 500.0)),
            ("Lesson Title", (1320.0, 40.0, 560.0, 120.0)),
        ]),
        scene("Guitar Performance", [
            ("Studio Background", full),
            ("Camera", full),
            ("Performance Title", (60.0, 940.0, 900.0, 100.0)),
        ]),
        scene("Music Tutorial", [
            ("Studio Background", full),
            ("Screen", (0.0, 0.0, 1600.0, 900.0)),
            ("Camera", (1360.0, 720.0, 520.0, 320.0)),
            ("Tutorial Title", (40.0, 940.0, 900.0, 100.0)),
        ]),
    ]
    return {
        "name": "Music Studio",
        # Global audio sources (in every scene). Mixer bits: 1 = track 1, 2 = track 2, 4 = track 3.
        "AuxAudioDevice1": source("REAPER Program", "pulse_input_capture", {"device_id": "reaper_program"}, 1 | 2),
        "DesktopAudioDevice1": source("Discord Call", "pulse_output_capture", {"device_id": "discord_call.monitor"}, 1 | 4),
        "sources": sources,
        "groups": [],
        "scene_order": [{"name": "Guitar Lesson"}, {"name": "Guitar Performance"}, {"name": "Music Tutorial"}],
        "current_scene": "Guitar Lesson",
        "current_program_scene": "Guitar Lesson",
        "canvases": [],
        "current_transition": "Fade",
        "transition_duration": 300,
        "transitions": [],
        "quick_transitions": [],
        "saved_projectors": [],
        "preview_locked": False,
        "scaling_enabled": False,
        "scaling_level": 0,
        "scaling_off_x": 0.0,
        "scaling_off_y": 0.0,
        "modules": {},
        "resolution": {"x": 1920, "y": 1080},
        "version": 2,
    }


PROFILE = """[General]
Name=Music Studio

[Video]
BaseCX=1920
BaseCY=1080
OutputCX=1920
OutputCY=1080
FPSType=0
FPSCommon=30

[Audio]
SampleRate=48000
ChannelSetup=Stereo

[Output]
Mode=Simple
FilenameFormatting=Music Studio %CCYY-%MM-%DD %hh-%mm-%ss

[SimpleOutput]
FilePath={{ .chezmoi.homeDir }}/Videos
RecFormat2=hybrid_mp4
RecQuality=Small
RecEncoder=nvenc
StreamEncoder=nvenc
ABitrate=320
RecTracks=7

[AdvOut]
RecTracks=7
Track1Name=Full mix
Track2Name=REAPER
Track3Name=Discord
"""


def main(root: Path) -> int:
    obs = root / "home" / "dot_config" / "obs-studio" / "basic"
    scenes = obs / "scenes"
    profile = obs / "profiles" / "Music_Studio"
    scenes.mkdir(parents=True, exist_ok=True)
    profile.mkdir(parents=True, exist_ok=True)
    (scenes / "create_Music_Studio.json").write_text(json.dumps(collection(), indent=4) + "\n")
    (profile / "create_basic.ini.tmpl").write_text(PROFILE)
    print("wrote", scenes / "create_Music_Studio.json")
    print("wrote", profile / "create_basic.ini.tmpl")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[2]))
