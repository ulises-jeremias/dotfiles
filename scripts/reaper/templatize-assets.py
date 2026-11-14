#!/usr/bin/env python3
"""Turn absolute guitar-asset paths in built REAPER files into chezmoi templates.

The builder writes NAM model and IR paths as absolute paths for the machine it
ran on (REAPER's LV2 state needs absolute paths). Committed files must not
contain one person's home directory, so every file under the REAPER source tree
that references the asset directory is rewritten as <name>.tmpl with
{{ .chezmoi.homeDir }}; chezmoi renders the right path on each host.

Usage: templatize-assets.py <REAPER source dir> <absolute home dir>
Run it after scripts/reaper/build-vocal-studio.lua.
"""

from __future__ import annotations

import sys
from pathlib import Path

ASSET_SUFFIX = "/.local/share/reaper-studio/guitar"


def main(root: Path, home: str) -> int:
    needle = home.rstrip("/") + ASSET_SUFFIX
    converted = 0
    for path in sorted(root.rglob("*")):
        if not path.is_file() or path.suffix == ".tmpl":
            continue
        try:
            text = path.read_text()
        except UnicodeDecodeError:
            continue
        if needle not in text:
            continue
        if "{{" in text or "}}" in text:
            raise SystemExit(f"{path}: already contains template delimiters; refusing")
        target = path.with_name(path.name + ".tmpl")
        target.write_text(text.replace(needle, "{{ .chezmoi.homeDir }}" + ASSET_SUFFIX))
        path.unlink()
        converted += 1
        print(f"templated {target.relative_to(root)}")
    print(f"{converted} file(s) templated")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    raise SystemExit(main(Path(sys.argv[1]), sys.argv[2]))
