# Wallpapers

Optional wallpaper media lives here and is linked into `~/Pictures/Wallpapers/<theme-id>/` by a chezmoi change script.

```text
wallpapers/
├── curated/           # uncategorized pool
├── hornero/           # flagship HorneroOS light + dark (first-boot default)
├── patagonia/         # glacier, basalt and glacial water
├── fin-del-mundo/     # Beagle coast, southern forest and peatland
├── quebrada/          # high-altitude mineral bands and violet shade
├── ibera/             # lagoon water, floating greens and silver dawn
├── buenos-aires-nocturno/ # rain-dark avenues and electric city light
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

## Hornero Originals: landscapes and city atmospheres

`patagonia/patagonia-glacier-01.jpg` and
`fin-del-mundo/beagle-blue-hour-01.jpg` are original generated wallpaper
artworks for HorneroOS, not documentary photographs. Patagonia draws its
palette from glacial water, basalt, snow and a narrow copper horizon. Fin del
Mundo takes a maritime direction: Beagle Channel water, wind-shaped southern
forest and muted harbor light. The themes avoid flags and tourist landmarks.

The Quebrada artwork translates exposed mineral strata, an arid high-altitude
valley and the broad daily light of Jujuy into rose stone, pale salt and violet
shadow. The Iberá scene takes its structure from shallow lagoons, marshes and
floating vegetation; its dark water and silver dawn keep it distinct from the
olive grassland of Pampa. Buenos Aires Nocturno turns layered apartment
facades, rain-dark streets and amber traffic into an urban color world with a
small electric accent. The artwork is original generated art, not documentary
photography. The collection uses no flags, folk motifs or tourist landmarks.

Regional references were checked against public sources: [CONAE's Landsat
description of the Quebrada](https://www.argentina.gob.ar/ciencia/conae/educacion-y-formacion-masiva/quebrada-de-humahuaca-jujuy-landsat-8-oli-13-de-octubre-de-2015),
[UNESCO's Quebrada landscape description](https://whc.unesco.org/en/list/1116/),
[Argentina's National Parks overview of Iberá](https://www.argentina.gob.ar/parquesnacionales/ecorregiones/esteros-del-ibera),
and the [CONAE Landsat view of the Iberá wetlands](https://www.argentina.gob.ar/ciencia/conae/educacion-y-formacion-masiva/materiales-educativos/esteros-del-ibera-landsat-8-oli-12-de-mayo-de-2015).
The Buenos Aires scene draws on the city's public description of its [night-time
urban fabric](https://buenosaires.gob.ar/gcaba_historico/noticias/el-microcentro-porteno-impacta-de-noche-y-de-dia).
