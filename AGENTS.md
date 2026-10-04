# Contributor guide

This repository is a personal chezmoi source for an Arch workstation. It is
not the source of HorneroOS system packages, Shell behavior, or theme-pack
metadata; those belong to the `HorneroOS` organization.

## Core rules

- Prefer declarative chezmoi files for user configuration.
- Use `horneroctl` for supported Hornero desktop operations. Do not add a
  second script framework or compatibility layer in this source.
- Keep Hornero appearance pack metadata in HorneroOS/config. This repository
  may provide optional wallpaper media under
  `home/dot_local/share/hornero/wallpapers/`.
- Use XDG paths and the Hornero namespace for new product-specific state.
- Never run `chezmoi apply` against the developer's account during tests.
- Render chezmoi templates with both managed-host and static configurations.
- Keep historical workstation notes in `docs/wiki/` clearly identified as
  historical; they do not define current product contracts.
- Never commit credentials, private keys, personal host facts, or generated
  caches.

## Validation

Run the focused contract tests, `scripts/audit-horneroctl-binds.sh`,
`scripts/verify-delivery.sh`, and the relevant chezmoi template checks. Use a
temporary HOME and isolated XDG directories for runtime tests.

## Product references

- [HorneroOS](https://github.com/HorneroOS)
- [Config](https://github.com/HorneroOS/config)
- [Shell](https://github.com/HorneroOS/shell)
- [CLI](https://github.com/HorneroOS/hornero)
- [User documentation](https://hornero-os.vercel.app/docs)
