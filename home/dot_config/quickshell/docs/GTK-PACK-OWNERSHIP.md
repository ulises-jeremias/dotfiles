# GTK pack-id and listing ownership — track 3a decision

Question: for GTK theme packs, who owns pack-id resolution and who owns
listing — the config-packs side (dots-owned data + CLIs) or the shell?

## Decision

- **Pack definitions and pack-id resolution stay owned by the config-packs
  side** (dots-owned `theme.json` registry + `dots-gtk-theme` /
  `dots-appearance` CLIs). The shell never resolves a pack id natively:
  `services/GtkSettings.qml` (`_startApply`) routes full applies with a
  pack id straight to the `dots-gtk-theme theme <id>` compat adapter.
- **The shell owns the listing UX, with the CLI as fallback transport.**
  `GtkThemeSection` (`dots-gtk-theme -q -p list`), `IconThemeSection`
  (`dots-gtk-theme -q -p icons`), and `modules/launcher/services/Themes.qml`
  (`dots-appearance theme list`) render whatever the CLI returns and
  degrade to an empty model when it is absent. A native directory scan
  (`index.theme` parsing + de-dup across system/user roots) stays deferred.

## Why not shell-owned listing data

The pack format (`theme.json` + wallpaper directories) lives with the
config-packs data. Vendoring a copy into the shell would fork the format:
every new pack field would need a two-repo change. The CLI boundary keeps
one owner for the format and one consumer for the UX.

## CLI fallback contract (kept working)

- Listings: missing CLI renders an empty list; the shell keeps running.
- Applies: missing `gsettings` falls through to `dots-gtk-theme`; pack-id
  applies always use the compat path (see `docs/NATIVE-APPEARANCE.md`).
- Markers: every call site above carries `TODO(hornero-compat)` and a
  `docs/COMPAT.md` row (disposition A).
