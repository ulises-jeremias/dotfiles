# Wallpapers

This directory holds the generic wallpaper pool — images that don't belong to a specific rice but are still part of the rotation.

```text
wallpapers/
└── curated/   # generic pool, linked to ~/Pictures/Wallpapers on `chezmoi apply`
```

Theme-specific wallpapers live next to the rice that uses them, in `home/dot_local/share/dots/rices/<rice>/backgrounds/`. The split is intentional:

- A rice's `backgrounds/` ships with the theme and tracks it. Adding a `cyberpunk-alley.png` to `neon-city/backgrounds/` means "this fits the neon-city palette".
- `curated/` is for images with no strong palette tie — the Quickshell launcher feeds its random-wallpaper picker from `~/Pictures/Wallpapers`, which is populated from this directory.

## How they get to `~/Pictures/Wallpapers`

The chezmoi script `home/.chezmoiscripts/linux/run_onchange_after_link-wallpapers.sh.tmpl` runs after `chezmoi apply` and symlinks every PNG/JPG in `curated/` into `~/Pictures/Wallpapers/`. Existing files there are left alone — drop your own additions in either place.

## Adding to the curated pool

Drop the file in `curated/` and commit it. The next `chezmoi apply` picks it up.

Keep an eye on size: each image lands in the repo as-is. Aim for ≤ 5 MB per PNG (1920×1080 with reasonable compression); anything heavier is a candidate for converting to webp or downsampling.
