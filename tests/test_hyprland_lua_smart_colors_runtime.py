"""Exercise the staged Smart Colors Lua loader with an isolated Lua runtime."""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "home/dot_config/hypr/hyprland.lua.d/smart-colors.lua"


def test_smart_colors_lua_factory_fallback_and_generated_overlay():
    lua = shutil.which("lua5.4") or shutil.which("lua")
    if lua is None:
        raise RuntimeError("Lua 5.4 or compatible `lua` is required for this test")

    with tempfile.TemporaryDirectory(prefix="hornero-smart-colors-") as temporary:
        isolated_home = Path(temporary)
        default_cache = isolated_home / ".cache/hornero/smart-colors"
        default_cache.mkdir(parents=True)
        harness = r'''
local module = assert(os.getenv("SMART_COLORS_MODULE"))
local calls = {}
hl = { config = function(value) table.insert(calls, value) end }
assert(loadfile(module))()
assert(#calls >= 1)
local factory = calls[1]
assert(factory.general.col.active_border.colors[1] == "rgba(e07856ee)")
assert(factory.general.col.active_border.colors[2] == "rgba(f2b749ee)")
assert(factory.general.col.inactive_border == "rgba(6b4e3baa)")
assert(factory.group.col.border_active == "rgba(e07856ee)")
assert(factory.group.col.border_inactive == "rgba(6b4e3baa)")
assert(factory.group.col.border_locked_active == "rgba(f2b749ee)")
assert(factory.group.col.border_locked_inactive == "rgba(3c2c21aa)")
assert(factory.group.groupbar.col.active == "rgba(e07856ee)")
assert(factory.group.groupbar.col.inactive == "rgba(2b1f18ee)")
assert(factory.group.groupbar.col.locked_active == "rgba(f2b749ee)")
assert(factory.group.groupbar.col.locked_inactive == "rgba(3c2c21ee)")

local generated = calls[2]
if os.getenv("EXPECT_GENERATED") == "1" then
  assert(generated, "generated colors should load")
  assert(generated.group.col.border_active == "rgba(123456ee)")
else
  assert(not generated, "invalid or missing generated colors must preserve defaults")
end
'''

        def run_case(
            content: str | None,
            *,
            expect_generated: bool = False,
            smart_colors_dir: Path | None = None,
            xdg_cache_home: Path | None = None,
            shadow_content: str | None = None,
        ) -> None:
            active_cache = smart_colors_dir or (
                (xdg_cache_home or (isolated_home / ".cache"))
                / "hornero/smart-colors"
            )
            active_cache.mkdir(parents=True, exist_ok=True)
            generated_file = active_cache / "colors-hyprland.lua"
            if content is None:
                generated_file.unlink(missing_ok=True)
            else:
                generated_file.write_text(content, encoding="utf-8")
            if shadow_content is not None:
                shadow_cache = (
                    xdg_cache_home / "hornero/smart-colors"
                    if smart_colors_dir is not None
                    else default_cache
                )
                shadow_cache.mkdir(parents=True, exist_ok=True)
                (shadow_cache / "colors-hyprland.lua").write_text(
                    shadow_content, encoding="utf-8"
                )
            environment = os.environ.copy()
            environment.pop("HORNERO_SMART_COLORS_DIR", None)
            environment.pop("XDG_CACHE_HOME", None)
            if smart_colors_dir is not None:
                environment["HORNERO_SMART_COLORS_DIR"] = str(smart_colors_dir)
            if xdg_cache_home is not None:
                environment["XDG_CACHE_HOME"] = str(xdg_cache_home)
            environment["HOME"] = str(isolated_home)
            environment["SMART_COLORS_MODULE"] = str(MODULE)
            environment["EXPECT_GENERATED"] = "1" if expect_generated else "0"
            subprocess.run(
                [lua, "-"], input=harness, text=True, check=True,
                cwd=ROOT, env=environment, capture_output=True,
            )

        run_case(None)
        valid = (
            'hl.config({ group = { col = { border_active = "rgba(123456ee)" } } })\n'
        )
        run_case(valid, expect_generated=True)
        run_case("this is not valid Lua !!!\n")
        run_case('error("broken generated palette")\n')
        decoy = (
            'hl.config({ group = { col = { border_active = "rgba(654321ee)" } } })\n'
        )
        run_case(
            valid,
            expect_generated=True,
            xdg_cache_home=isolated_home / "xdg-cache",
            shadow_content=decoy,
        )
        run_case(
            valid,
            expect_generated=True,
            smart_colors_dir=isolated_home / "custom-cache",
            xdg_cache_home=isolated_home / "xdg-cache",
            shadow_content=decoy,
        )


if __name__ == "__main__":
    test_smart_colors_lua_factory_fallback_and_generated_overlay()
    print("PASS: Smart Colors Lua factory, generated overlay, and safe fallbacks")
