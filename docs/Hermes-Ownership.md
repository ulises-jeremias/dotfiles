# Hermes ownership and migration

`horneroctl assistant setup` is the canonical writer for:

- `~/.config/systemd/user/hornero-hermes.service`
- `~/.hermes/skills/hornero/SKILL.md`

The dotfiles source does not manage either path. This avoids alternating
chezmoi and `horneroctl` writes to the same files. Workstation-specific systemd
changes belong in
`~/.config/systemd/user/hornero-hermes.service.d/10-dotfiles.conf`; personal
Hermes instructions belong in a separately named skill such as
`~/.hermes/skills/hornero-local/SKILL.md`.

## Existing installations

First inspect local changes and back up any personal edits. If the dotfiles
source still contains either canonical file, stop managing it with chezmoi
before updating the source:

```sh
set -e
chezmoi diff
if chezmoi managed | rg -q '(^|/)hornero-hermes\.service$'; then
  chezmoi forget ~/.config/systemd/user/hornero-hermes.service
fi
if chezmoi managed | rg -q '(^|/)skills/hornero/SKILL\.md$'; then
  chezmoi forget ~/.hermes/skills/hornero/SKILL.md
fi
if chezmoi managed | rg -q '(^|/)hornero-hermes\.service$|(^|/)skills/hornero/SKILL\.md$'; then
  echo 'Hermes base files are still managed by chezmoi' >&2
  exit 1
fi
```

`chezmoi forget` removes the entries from chezmoi's source state and leaves the
destination files in place. Run it only while those files are still present in
the source state. If a newer dotfiles revision already removed them, skip the
`forget` command and confirm that they no longer appear in `chezmoi managed`.
Do not use `chezmoi destroy`, `.chezmoiremove`, or an apply script to remove
these destinations.

The two independent checks handle partial migrations and avoid passing an
already-forgotten path to `chezmoi forget`. Their end anchors deliberately
allow the recommended `hornero-hermes.service.d/` drop-in.

Only use automatic adoption after installing a Hornero CLI version whose
`horneroctl assistant setup --help` lists `--adopt-dotfiles`. That option is
being implemented in [HorneroOS/hornero#278](https://github.com/HorneroOS/hornero/pull/278);
the currently published CLI may not provide it. Until the option is available,
keep existing files backed up and do not run `horneroctl assistant setup` for
that existing installation: the current CLI will preserve unreceipted files
and refuse to take ownership. Wait for a Hornero CLI release that supports
adoption, then use the commands below. Reconcile customized content separately
before adopting; never discard a customization merely to make setup pass.
When supported, preview adoption and then explicitly record ownership:

```sh
horneroctl assistant setup --adopt-dotfiles --dry-run
horneroctl assistant setup --adopt-dotfiles --yes
horneroctl assistant setup --yes
```

Adoption accepts only the exact legacy unit and skill contents shipped by the
recognized dotfiles revisions. It records receipts without rewriting either
file, enabling the assistant, creating a key, or changing systemd state. The
separate setup command performs the usual setup. If a file was customized or
does not match a recognized revision, adoption fails and preserves it; move
personal changes to the extension points above and reconcile the canonical
file manually. Adopted files remain unchanged through ordinary setup and
`assistant setup --remove`; removal only clears their Hornero ownership
receipts and does not stop the adopted service.

For example, `horneroctl assistant setup --remove --yes` disables the Hornero
assistant but keeps both adopted base files in place.

## New installations

After the dotfiles source cutover, `chezmoi apply` does not create or update the
canonical Hermes files. Install and configure the optional assistant through
the documented Hornero CLI flow. Personal drop-ins and separately named skills
remain managed by chezmoi.
