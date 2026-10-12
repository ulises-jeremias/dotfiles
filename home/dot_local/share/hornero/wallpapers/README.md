# Wallpapers

Optional wallpaper media lives here and is linked into `~/Pictures/Wallpapers/<theme-id>/` by a chezmoi change script.

```text
wallpapers/
├── curated/           # uncategorized user-selected pool
├── hornero/           # flagship HorneroOS light + dark SVG-derived art
├── vapor-dreams/
├── neon-city/
├── gruvbox/
└── …
```

Theme definitions and product default wallpapers are owned by
[HorneroOS/config](https://github.com/HorneroOS/config) and shipped through
its `hornero-config` AUR package. This personal repository supplies optional
user media only; it does not duplicate the product catalogue or store current
theme state. Argentina-specific product defaults are not copied into this
collection. Their source, photographer, license, crop recipe, and checksums are
recorded in Config's
[`wallpaper-provenance.json`](https://github.com/HorneroOS/config/blob/main/profiles/themes/wallpaper-provenance.json)
and full credits are listed in its
[`WALLPAPER-CREDITS.md`](https://github.com/HorneroOS/config/blob/main/profiles/themes/WALLPAPER-CREDITS.md).

## Linking

`home/.chezmoiscripts/linux/run_onchange_after_link-wallpapers.sh.tmpl` symlinks
images under each optional theme directory into
`~/Pictures/Wallpapers/<theme-id>/`. Existing non-symlink files are never
clobbered. During migration it removes only known old regional assets whose
SHA-256 exactly matches the former generated files, and only removes a stale
wallpaper link when it points to one of those exact source paths. Custom files
and unrelated links are preserved.

## Adding images

Drop user-selected media under the matching theme directory (or `curated/`) and
commit. Prefer ≤ 2560px on the long edge and JPEG/WebP for photos. Check rights
before distributing any image in the HorneroOS product; optional personal
media does not become an official product asset merely by living here.

## Regional visual direction

Hornero's Argentina-inspired themes span Buenos Aires city light, the Beagle
Channel at blue hour, Iberá wetlands, humid Pampas waterways, Perito Moreno ice,
and Jujuy's mineral bands. These are product defaults supplied by the AUR
package as licensed photography. HorneroOS/config records exact attribution and
license information. The personal collection no longer duplicates those
assets.
