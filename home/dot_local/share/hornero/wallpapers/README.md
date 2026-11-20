# Wallpapers

Product wallpapers are owned by
[HorneroOS/config](https://github.com/HorneroOS/config) and installed by its
`hornero-config` package under `/usr/share/hornero/wallpapers/`. That tree is
the canonical wallpaper pool; this repository no longer tracks a copy of it.

This directory stays only as an optional personal-media pool: drop your own
images in a subdirectory here and they are linked into
`~/Pictures/Wallpapers/<dir>/` next to the product pool.

## Linking

`home/.chezmoiscripts/linux/run_onchange_after_link-wallpapers.sh.tmpl`
symlinks images from `/usr/share/hornero/wallpapers/` (when HorneroOS is
installed) and from this personal tree into `~/Pictures/Wallpapers/<dir>/`.
Existing non-symlink files are never clobbered. Installed copies of wallpapers
formerly tracked here are removed during migration only while their SHA-256
exactly matches the former tracked file, and a stale `~/Pictures/Wallpapers`
link is removed only when it points at that exact personal path; custom files
and unrelated links are preserved.

## Credits

Source, photographer, license, crop recipe, and checksums for product
wallpapers are recorded in Config's
[`wallpaper-provenance.json`](https://github.com/HorneroOS/config/blob/main/profiles/themes/wallpaper-provenance.json)
and
[`WALLPAPER-CREDITS.md`](https://github.com/HorneroOS/config/blob/main/profiles/themes/WALLPAPER-CREDITS.md).
Personal media does not become an official product asset merely by living
here; check rights before distributing any image in the HorneroOS product.
