# 🎨 Theme Gallery

Hornero offers two kinds of themes through one picker. The three semantic
themes carry their own accessible color tokens; appearance recipes generate
their Shell palette from the selected wallpaper. Wallpaper media is curated
separately from theme metadata, and flagship defaults are included with the
Hornero packages and dotfiles fallback.

Switch from the Shell's **Settings → Appearance → Themes** or the CLI:

```bash
horneroctl appearance theme apply <theme-id> --yes
```

or from the shell: **Appearance pane → Themes**, or the launcher.

---

## The Collection

| Theme              | Character                                                      | Preview                                                                               |
|--------------------|----------------------------------------------------------------|---------------------------------------------------------------------------------------|
| `hornero-dark`     | Semantic flagship · warm ember on a deep night landscape       | ![Hornero Dark](../home/dot_local/share/dots/themes/hornero-dark/preview.jpg)         |
| `hornero-light`    | Semantic flagship · terracotta and paper in morning light      | ![Hornero Light](../home/dot_local/share/dots/themes/hornero-light/preview.jpg)       |
| `pampa`            | Semantic flagship · grassland night, harvest moon, muted olive | ![Pampa](../home/dot_local/share/dots/themes/pampa/preview.png)                       |
| `catppuccin-latte` | Light, pastel, low-contrast                                    | ![Catppuccin Latte](../home/dot_local/share/dots/themes/catppuccin-latte/preview.jpg) |
| `catppuccin-mocha` | Dark, warm pastels                                             | ![Catppuccin Mocha](../home/dot_local/share/dots/themes/catppuccin-mocha/preview.jpg) |
| `everforest`       | Muted forest greens                                            | ![Everforest](../home/dot_local/share/dots/themes/everforest/preview.jpg)             |
| `gruvbox`          | Retro warm oranges/browns                                      | ![Gruvbox](../home/dot_local/share/dots/themes/gruvbox/preview.jpg)                   |
| `landscape`        | Natural landscape tones                                        | ![Landscape](../home/dot_local/share/dots/themes/landscape/preview.jpg)               |
| `monochrome`       | Pure grayscale discipline                                      | ![Monochrome](../home/dot_local/share/dots/themes/monochrome/preview.jpg)             |
| `neon-city`        | Cyberpunk neon on dark                                         | ![Neon City](../home/dot_local/share/dots/themes/neon-city/preview.jpg)               |
| `nord-dreams`      | Cool nordic blues                                              | ![Nord Dreams](../home/dot_local/share/dots/themes/nord-dreams/preview.jpg)           |
| `rose-pine`        | Soft muted rose/pine                                           | ![Rose Pine](../home/dot_local/share/dots/themes/rose-pine/preview.jpg)               |
| `soft-morning`     | Gentle dawn pastels                                            | ![Soft Morning](../home/dot_local/share/dots/themes/soft-morning/preview.jpg)         |
| `vapor-dreams`     | Vaporwave dreamscape                                           | ![Vapor Dreams](../home/dot_local/share/dots/themes/vapor-dreams/preview.jpg)         |
| `warm-sunset`      | Sunset oranges and pinks                                       | ![Warm Sunset](../home/dot_local/share/dots/themes/warm-sunset/preview.jpg)           |

---

## How Theming Works

1. `hornero-config` installs the canonical themes, semantic GTK packs, and flagship wallpapers.
2. Hornero Dark, Hornero Light, and Pampa apply their accessible semantic tokens.
3. Appearance recipes use the selected wallpaper to generate Shell colors through the M3 pipeline.
4. Changing wallpaper refreshes dynamic colors when the active theme follows its wallpaper.

See [Smart Colors System](Smart-Colors-System) for the full pipeline and
[Customization](Customization) for adding your own theme:

```bash
mkdir -p ~/.local/share/hornero/themes/my-theme
# drop a wallpaper.jpg + theme.json describing the theme
horneroctl appearance theme apply my-theme --yes
```

The bundled Hornero theme definitions follow `HorneroOS/config` v0.2.1. Pampa's
fallback wallpaper and preview are rendered from its canonical
`assets/brand/wallpaper/pampa.svg` source.

---

## Animation Pairings

Pair themes with Hyprland animation profiles for a full rice:

| Theme                        | Suggested profile                                     |
|------------------------------|-------------------------------------------------------|
| `cozy` feel                  | `dots hypr-animations --set=cozy`                     |
| `neon-city` / `vapor-dreams` | `dots hypr-animations --set=vaporwave` or `cyberpunk` |
| `monochrome` / `nord-dreams` | `dots hypr-animations --set=minimal`                  |

---

## 🆘 Need Help?

- [Appearance docs →](Customization)
- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)
