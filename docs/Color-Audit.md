# Appearance and color ownership

Hornero Config owns the theme-pack catalogue and curated GTK assets. Hornero
Shell owns live shell colors and wallpaper analysis. `horneroctl` coordinates
installed theme operations. This personal source may include wallpaper media;
it does not define a second theme registry or color cache.

For current user behavior, see the [Appearance guide](https://horneroos.com/docs/desktop/appearance/). For architecture and pack validation, see [HorneroOS/config](https://github.com/HorneroOS/config/tree/main/profiles/themes) and [HorneroOS/shell](https://github.com/HorneroOS/shell).

## Review checklist

- Keep semantic text pairs readable in both light and dark roles.
- Check generated palettes against the actual wallpaper and translucent
  surfaces, not only flat token pairs.
- Confirm GTK, icons, Qt, and Shell colors report the applied state.
- Keep wallpaper binaries separate from pack metadata and preserve source
  provenance for generated art.
- Test color changes using the installed Hornero CLI and Shell, not a copied
  helper implementation.
