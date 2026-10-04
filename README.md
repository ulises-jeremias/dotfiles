# Hornero workstation configuration

This repository is the personal [chezmoi](https://www.chezmoi.io/) source for an Arch Linux workstation. It manages user-level applications, preferences, and optional media. It is not the HorneroOS release repository or its package catalogue.

The desktop product lives in the public [HorneroOS organization](https://github.com/HorneroOS):

- [Hornero Config](https://github.com/HorneroOS/config) owns system defaults, appearance packs, and packaged integration helpers.
- [Hornero Shell](https://github.com/HorneroOS/shell) owns the Quickshell desktop surfaces and user-facing controls.
- [Hornero CLI](https://github.com/HorneroOS/hornero) owns stable system and desktop operations.
- [HorneroOS documentation](https://hornero-os.vercel.app/docs) describes current product behavior.

This source may configure optional applications around the desktop, but Hornero's packages and catalogue are canonical for product behavior. Wallpapers in this repository are user media under `~/.local/share/hornero/wallpapers`; theme definitions are owned by Hornero Config and are not duplicated here.

## Apply on an Arch workstation

Review the pending changes before applying to an existing account:

```sh
chezmoi diff --source=/path/to/dotfiles --config ~/.config/chezmoi/dotfiles.toml
chezmoi apply --source=/path/to/dotfiles --config ~/.config/chezmoi/dotfiles.toml
```

If a deliberate replacement of managed files is needed, add `--force` only after reviewing that diff. This repository does not run `chezmoi apply` automatically during package installation.

## Repository map

- `home/` contains declarative chezmoi source files and templates.
- `docs/wiki/` preserves historical workstation notes; those notes may describe retired setups and should not be treated as current HorneroOS contracts.
- `playground/` contains isolated development and acceptance tooling.
- `scripts/` contains repository validation and host-source utilities.

## Contributing

Use a temporary HOME and isolated XDG directories for tests. Never apply this source to a live account as part of validation. Run the focused source checks, `scripts/verify-delivery.sh`, and the relevant shell-contract tests before proposing a change. See [CONTRIBUTING.md](CONTRIBUTING.md) for the current workflow.
