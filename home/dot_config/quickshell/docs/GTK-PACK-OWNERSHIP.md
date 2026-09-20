# GTK pack-id and listing ownership — track 3a decision

Question: for GTK theme packs, who owns pack-id resolution and who owns
listing — the config-packs side (dots-owned data + CLIs) or the shell?

## Decision

- **Pack definitions and pack-id resolution stay owned by the config-packs
  side** (`theme.json` registry + `horneroctl appearance gtk theme` /
  `horneroctl appearance theme list --full`). The shell never resolves a
  pack id natively: `services/GtkSettings.qml` (`_startApply`) routes full
  applies with a pack id straight to the `horneroctl appearance gtk theme`
  verb.
- **The shell owns the listing UX, with the CLI as fallback transport.**
  `GtkThemeSection` (`horneroctl appearance gtk list`), `IconThemeSection`
  (`horneroctl appearance gtk icons`), and
  `modules/launcher/services/Themes.qml`
  (`horneroctl appearance theme list --full`) render whatever the CLI
  returns and degrade to an empty model when it is absent.

## Why not shell-owned listing data

The pack format (`theme.json` + wallpaper directories) lives with the
config-packs data. Vendoring a copy into the shell would fork the format:
every new pack field would need a two-repo change. The CLI boundary keeps
one owner for the format and one consumer for the UX.

## CLI fallback contract (kept working)

- Listings: missing CLI renders an empty list; the shell keeps running.
- Applies: missing `gsettings` falls through to
  `horneroctl appearance gtk …`; pack-id applies resolve natively
  (see `docs/NATIVE-APPEARANCE.md`).
- Markers: every call site above carries `TODO(hornero-compat)` and a
  `docs/COMPAT.md` row (disposition A).
