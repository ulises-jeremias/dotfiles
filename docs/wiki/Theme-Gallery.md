# 🎨 Theme Gallery

Every theme ships with a wallpaper, a Material You 3 palette generated from
it, and a preview. Switch instantly:

```bash
dots-appearance theme apply <theme-id>
```

or from the shell: **Appearance pane → Themes**, or the launcher.

---

## The Collection

| Theme              | Vibe                        | Preview                                                                               |
| ------------------ | --------------------------- | ------------------------------------------------------------------------------------- |
| `catppuccin-latte` | Light, pastel, low-contrast | ![Catppuccin Latte](../home/dot_local/share/dots/themes/catppuccin-latte/preview.jpg) |
| `catppuccin-mocha` | Dark, warm pastels          | ![Catppuccin Mocha](../home/dot_local/share/dots/themes/catppuccin-mocha/preview.jpg) |
| `everforest`       | Muted forest greens         | ![Everforest](../home/dot_local/share/dots/themes/everforest/preview.jpg)             |
| `gruvbox`          | Retro warm oranges/browns   | ![Gruvbox](../home/dot_local/share/dots/themes/gruvbox/preview.jpg)                   |
| `landscape`        | Natural landscape tones     | ![Landscape](../home/dot_local/share/dots/themes/landscape/preview.jpg)               |
| `monochrome`       | Pure grayscale discipline   | ![Monochrome](../home/dot_local/share/dots/themes/monochrome/preview.jpg)             |
| `neon-city`        | Cyberpunk neon on dark      | ![Neon City](../home/dot_local/share/dots/themes/neon-city/preview.jpg)               |
| `nord-dreams`      | Cool nordic blues           | ![Nord Dreams](../home/dot_local/share/dots/themes/nord-dreams/preview.jpg)           |
| `rose-pine`        | Soft muted rose/pine        | ![Rose Pine](../home/dot_local/share/dots/themes/rose-pine/preview.jpg)               |
| `soft-morning`     | Gentle dawn pastels         | ![Soft Morning](../home/dot_local/share/dots/themes/soft-morning/preview.jpg)         |
| `vapor-dreams`     | Vaporwave dreamscape        | ![Vapor Dreams](../home/dot_local/share/dots/themes/vapor-dreams/preview.jpg)         |
| `warm-sunset`      | Sunset oranges and pinks    | ![Warm Sunset](../home/dot_local/share/dots/themes/warm-sunset/preview.jpg)           |

---

## How Theming Works

1. `theme.json` in each theme directory declares the wallpaper and metadata
2. The wallpaper feeds the M3 color pipeline (`dots-m3-colors`) which
   generates the Material You palette consumed by Quickshell, GTK and terminals
3. `dots wal-reload` re-runs the pipeline when you change wallpapers manually

See [Smart Colors System](Smart-Colors-System) for the full pipeline and
[Customization](Customization) for adding your own theme:

```bash
mkdir -p ~/.local/share/dots/themes/my-theme
# drop a wallpaper.jpg + theme.json describing the theme
dots-appearance theme apply my-theme
```

---

## Animation Pairings

Pair themes with Hyprland animation profiles for a full rice:

| Theme                        | Suggested profile                                     |
| ---------------------------- | ----------------------------------------------------- |
| `cozy` feel                  | `dots hypr-animations --set=cozy`                     |
| `neon-city` / `vapor-dreams` | `dots hypr-animations --set=vaporwave` or `cyberpunk` |
| `monochrome` / `nord-dreams` | `dots hypr-animations --set=minimal`                  |

---

## 🆘 Need Help?

- [Appearance docs →](Customization)
- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)
