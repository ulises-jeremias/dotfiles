#!/usr/bin/env python3
"""Objective guitar-tone metrics for A/B comparisons (developer tool).

Supplements listening; it does not replace it. Metrics are computed per section
of the synthetic performance DI (scripts generate it with these sections):

    0-4 s   palm-muted low E 16ths     -> attack and low-end tightness
    4-8 s   open power chords          -> band balance, fizz
    8-11 s  one sustained note         -> sustain (gate damage shows here)
    11-17 s single-note riff + fast alternate picking
    17-24 s lead phrase with vibrato

Usage: analyze-tones.py render1.wav [render2.wav ...]
"""

from __future__ import annotations

import sys
import wave

import numpy as np

BANDS = [("sub<80", 20, 80), ("low80-250", 80, 250), ("lmid250-800", 250, 800),
         ("mid0.8-2k", 800, 2000), ("pres2-5k", 2000, 5000), ("fizz5-10k", 5000, 10000),
         ("air>10k", 10000, 20000)]


def load(path: str) -> tuple[np.ndarray, int]:
    with wave.open(path) as w:
        ch, sw, rate, n = w.getnchannels(), w.getsampwidth(), w.getframerate(), w.getnframes()
        raw = w.readframes(n)
    if sw == 3:
        b = np.frombuffer(raw, dtype=np.uint8).reshape(-1, 3)
        x = (b[:, 0].astype(np.int32) | (b[:, 1].astype(np.int32) << 8) | (b[:, 2].astype(np.int32) << 16))
        x = np.where(x & 0x800000, x - 0x1000000, x) / 8388608.0
    elif sw == 2:
        x = np.frombuffer(raw, dtype="<i2") / 32768.0
    elif sw == 4:
        x = np.frombuffer(raw, dtype="<f4").astype(np.float64)  # REAPER renders float
        if np.max(np.abs(x)) > 4:  # int32 fallback
            x = np.frombuffer(raw, dtype="<i4") / 2147483648.0
    else:
        raise ValueError(f"unsupported sample width {sw}")
    x = x.reshape(-1, ch)[:, 0]
    return x.astype(np.float64), rate


def db(v: float) -> float:
    return 20 * np.log10(max(v, 1e-12))


def bands(x: np.ndarray, rate: int) -> dict[str, float]:
    spec = np.abs(np.fft.rfft(x * np.hanning(len(x)))) ** 2
    freqs = np.fft.rfftfreq(len(x), 1 / rate)
    total = spec[(freqs >= 20) & (freqs < 20000)].sum()
    return {name: 10 * np.log10(spec[(freqs >= lo) & (freqs < hi)].sum() / total + 1e-12)
            for name, lo, hi in BANDS}


def onsets(x: np.ndarray, rate: int, step_s: float, start: float, end: float) -> list[int]:
    return [int((start + k * step_s) * rate) for k in range(int((end - start) / step_s))]


def lowpass_energy(seg: np.ndarray, rate: int, cutoff: float = 150.0) -> np.ndarray:
    spec = np.fft.rfft(seg)
    freqs = np.fft.rfftfreq(len(seg), 1 / rate)
    spec[freqs > cutoff] = 0
    return np.fft.irfft(spec, len(seg))


def analyze(path: str) -> dict[str, float]:
    x, rate = load(path)
    rms = np.sqrt(np.mean(x ** 2)); peak = np.max(np.abs(x))
    m: dict[str, float] = {"rms": db(rms), "peak": db(peak), "crest": db(peak) - db(rms)}
    # palm-mute attack and low-end tightness on the 0-4 s chugs (16ths at 140 BPM)
    step = 60 / 140 / 4
    atk, tight = [], []
    for o in onsets(x, rate, step, 0.0, 3.8):
        head = x[o:o + int(0.010 * rate)]
        body = x[o + int(0.010 * rate):o + int(0.080 * rate)]
        if len(body) and np.sqrt(np.mean(body ** 2)) > 0:
            atk.append(db(np.max(np.abs(head))) - db(np.sqrt(np.mean(body ** 2))))
        seg = x[o:o + int(step * rate)]
        if len(seg) > 64:
            lo = lowpass_energy(seg, rate)
            early = np.sqrt(np.mean(lo[: len(lo) // 3] ** 2)); late = np.sqrt(np.mean(lo[2 * len(lo) // 3:] ** 2))
            if early > 0:
                tight.append(db(late) - db(early))
    m["pm_attack_db"] = float(np.median(atk)) if atk else float("nan")
    m["low_decay_db"] = float(np.median(tight)) if tight else float("nan")
    # sustain on the 8-11 s note: level at ~2.5 s vs ~0.3 s after onset
    o = int(8.0 * rate)
    early = np.sqrt(np.mean(x[o + int(0.2 * rate):o + int(0.4 * rate)] ** 2))
    late = np.sqrt(np.mean(x[o + int(2.4 * rate):o + int(2.6 * rate)] ** 2))
    m["sustain_db"] = db(late) - db(early)
    # band balance on the open chords (4-8 s)
    m.update(bands(x[int(4.0 * rate):int(8.0 * rate)], rate))
    return m


def main(paths: list[str]) -> None:
    keys = None
    rows = []
    for p in paths:
        m = analyze(p)
        keys = keys or list(m.keys())
        rows.append((p.rsplit("/", 1)[-1].removesuffix(".wav"), m))
    width = max(len(r[0]) for r in rows)
    print("tone".ljust(width), " ".join(k[:11].rjust(11) for k in keys))
    for name, m in rows:
        print(name.ljust(width), " ".join(f"{m[k]:11.1f}" for k in keys))


if __name__ == "__main__":
    main(sys.argv[1:])
