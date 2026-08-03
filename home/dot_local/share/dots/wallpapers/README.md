# Wallpapers

Themed wallpaper packs ship here and are symlinked into `~/Pictures/Wallpapers/<theme-id>/` on `chezmoi apply`.

```text
wallpapers/
├── curated/           # uncategorized pool
├── vapor-dreams/
├── neon-city/
├── gruvbox/
└── …
```

Theme recipes (mode, scheme, GTK, icons, default wallpaper) live separately in
`home/dot_local/share/dots/themes/<id>/theme.json`. Themes are apply-once packs —
they do not own a sticky “current theme” state.

## Linking

`home/.chezmoiscripts/linux/run_onchange_after_link-wallpapers.sh.tmpl` symlinks
every image under each theme directory into `~/Pictures/Wallpapers/<theme-id>/`.
Existing non-symlink files are never clobbered.

## Adding images

Drop files under the matching theme directory (or `curated/`) and commit.
Prefer ≤ 2560px on the long edge and JPEG/WebP for photos.
