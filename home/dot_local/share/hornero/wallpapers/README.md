# Wallpapers

Optional wallpaper media lives here and is linked into `~/Pictures/Wallpapers/<theme-id>/` by a chezmoi change script.

```text
wallpapers/
├── curated/           # uncategorized pool
├── hornero/           # flagship HorneroOS light + dark (first-boot default)
├── patagonia/         # glacier, basalt and glacial water
├── fin-del-mundo/     # Beagle coast, southern forest and peatland
├── vapor-dreams/
├── neon-city/
├── gruvbox/
└── …
```

Theme definitions (mode, palette recipe, GTK, icons, and default wallpaper)
are owned by [HorneroOS/config](https://github.com/HorneroOS/config). This
repository supplies only optional wallpaper files; it does not duplicate the
theme catalogue or store the current theme state.

## Linking

`home/.chezmoiscripts/linux/run_onchange_after_link-wallpapers.sh.tmpl` symlinks
every image under each theme directory into `~/Pictures/Wallpapers/<theme-id>/`.
Existing non-symlink files are never clobbered.

## Adding images

Drop files under the matching theme directory (or `curated/`) and commit.
Prefer ≤ 2560px on the long edge and JPEG/WebP for photos.

## Argentine landscape series

`patagonia/patagonia-glacier-01.jpg` and
`fin-del-mundo/beagle-blue-hour-01.jpg` are original generated wallpaper
artworks for HorneroOS, not documentary photographs. Patagonia draws its
palette from glacial water, basalt, snow and a narrow copper horizon. Fin del
Mundo takes a maritime direction: Beagle Channel water, wind-shaped southern
forest and muted harbor light. The themes avoid flags and tourist landmarks.

The landscape references were checked against the official descriptions of
[Patagonia](https://www.argentina.travel/en/news/where-is-patagonia-a-guide-to-discovering-argentine-patagonia)
and [Tierra del Fuego National Park](https://www.argentina.gob.ar/parquesnacionales/recuperacion-sustentable-de-paisajes-y-medios-de-vida-en-argentina/paisajes-de-conservacion-y-produccion/paisaje-bosques-subantarticos).
