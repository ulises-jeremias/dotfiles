#!/usr/bin/env python3
"""Convert a binary P6 PPM frame (QEMU screendump output) to PNG.

Usage: ppm_to_png.py INPUT.ppm OUTPUT.png

Standard library only, so the harness never depends on ImageMagick.
QEMU screendumps are P6 with maxval 255; anything else is rejected.
"""

import struct
import sys
import zlib


def read_ppm(path):
    with open(path, "rb") as handle:
        magic = handle.readline().strip()
        if magic != b"P6":
            raise ValueError(f"not a binary P6 PPM file: {path}")
        dims = b""
        while len(dims.split()) < 2:
            line = handle.readline()
            if not line:
                raise ValueError(f"truncated PPM header: {path}")
            if line.startswith(b"#"):
                continue
            dims += b" " + line
        width, height = (int(part) for part in dims.split()[:2])
        maxval = b""
        while not maxval.strip():
            line = handle.readline()
            if not line:
                raise ValueError(f"truncated PPM header: {path}")
            if line.startswith(b"#"):
                continue
            maxval = line
        if int(maxval) != 255:
            raise ValueError(f"only maxval 255 is supported: {path}")
        pixels = handle.read(width * height * 3)
    if len(pixels) != width * height * 3:
        raise ValueError(f"truncated PPM pixels: {path}")
    return width, height, pixels


def write_png(path, width, height, pixels):
    def chunk(tag, data):
        out = struct.pack(">I", len(data)) + tag + data
        return out + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    header = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    rows = b"".join(
        b"\x00" + pixels[y * width * 3:(y + 1) * width * 3]
        for y in range(height)
    )
    with open(path, "wb") as handle:
        handle.write(b"\x89PNG\r\n\x1a\n")
        handle.write(chunk(b"IHDR", header))
        handle.write(chunk(b"IDAT", zlib.compress(rows)))
        handle.write(chunk(b"IEND", b""))


def main(argv):
    if len(argv) == 2 and argv[1] in ("-h", "--help"):
        print("usage: ppm_to_png.py INPUT.ppm OUTPUT.png")
        return 0
    if len(argv) != 3:
        print("usage: ppm_to_png.py INPUT.ppm OUTPUT.png")
        return 2
    try:
        width, height, pixels = read_ppm(argv[1])
        write_png(argv[2], width, height, pixels)
    except (OSError, ValueError) as exc:
        print(f"FAIL {argv[1]} ({exc})")
        return 1
    print(f"PASS {argv[2]} ({width}x{height})")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
