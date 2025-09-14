## Thunar Side Panel (Static Bookmarks)

The Thunar side panel (GTK bookmarks) is managed directly via a versioned template in this repository. No generation script is used: what you see in the template is what gets deployed.

### File Deployed

Runtime location: `~/.config/gtk-3.0/bookmarks`

Source template: `home/dot_config/gtk-3.0/bookmarks.tmpl`

### Managed Section

Inside the template there is a clearly delimited block:

```text
## BEGIN MANAGED SECTION
... lines ...
## END MANAGED SECTION
```

Edit that block in the template only (not in-place after deployment) to keep changes tracked. Anything you add BELOW the END marker (in your local deployed file) will persist across future template edits, because chezmoi will treat local modifications outside the managed lines as user changes unless you force overwrite. If you want fully reproducible state, keep all bookmarks inside the managed block and re-apply.

### Custom Bookmarks

Add personal, machine‑specific bookmarks below the managed section directly in `~/.config/gtk-3.0/bookmarks`. Example lines:

```text
file:///mnt/storage  🗄 Storage
smb://nas.local/share  🌐 NAS Share
```

### Removing Emojis

If you prefer a minimalist look, edit the template and delete the emoji / icon column (they are just literal characters). Re-apply with:

```bash
chezmoi apply --force --include=files
```

### Recommended Folder Set

The template includes: Home, Projects, Dev, Downloads, Documents, Pictures, Music, Videos, .config, LocalShare, Rices, Wallpapers, Bin. Remove or reorder directly in the template to reflect your workflow.

### Adding Per-Rice Bookmarks (Optional Manual Pattern)

If a specific rice needs additional paths (e.g. a theme assets folder), just append them manually after switching rice. Since we removed automation, we intentionally keep this lightweight. If automation becomes desirable again, a simple helper script or a chezmoi data-driven conditional can be reintroduced later.

### Keeping Things Clean

If a bookmarked directory no longer exists, Thunar will still show it (but inaccessible). Periodically prune obsolete lines manually. You can safely create missing directories with:

```bash
mkdir -p ~/Projects ~/Dev ~/.local/share/dots/rices ~/.local/share/wallpapers
```

### Restoring / Resetting

Accidentally broke the file? Just re-apply:

```bash
chezmoi apply --force --include=files
```

### Font / Emoji Issues

If emojis appear as empty squares, install a font with emoji coverage (e.g. Noto Color Emoji or a Nerd Font variant) or remove the symbols.

### Future Enhancements (Optional Ideas)

- Folder-specific icons using `.directory` files
- Conditional entries via Go template (per host / per rice)
- Color-tag comments referencing Smart Colors system

For now the approach stays intentionally simple: a single, explicit source of truth under version control.
