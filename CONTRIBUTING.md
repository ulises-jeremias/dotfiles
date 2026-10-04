# Contributing to the Hornero workstation source

This repository is a personal chezmoi source for an Arch workstation. It can
configure optional user applications and provide wallpaper media. Product
behavior, package defaults, theme definitions, and desktop operations belong
to the canonical repositories in the [HorneroOS organization](https://github.com/HorneroOS).

## Ownership boundaries

- Keep theme manifests, generated catalogue data, GTK packs, and system
  defaults in [HorneroOS/config](https://github.com/HorneroOS/config).
- Keep bars, launcher, Dashboard, notifications, OSD, and Control Center in
  [HorneroOS/shell](https://github.com/HorneroOS/shell).
- Keep supported system and desktop operations in
  [HorneroOS/hornero](https://github.com/HorneroOS/hornero).
- This repository may supply optional wallpaper files under
  `home/dot_local/share/hornero/wallpapers/` and personal application config.
  Do not copy product registries or add another command framework here.

## Source conventions

- Prefer declarative, idempotent chezmoi files over scripts.
- Use XDG directories and Hornero product paths for new configuration.
- Keep host-specific values out of shared files; use documented chezmoi data
  where a template genuinely needs a host choice.
- Never introduce secret values, generated caches, or personal credentials.
- Preserve user data. Tests must not run `chezmoi apply` against the developer
  account or the live desktop.
- `docs/wiki/` is a historical archive. Rewrite useful ideas for current
  behavior before moving them into active documentation.

## Validation

Use a temporary HOME and isolated XDG directories for commands that render or
apply chezmoi state. Before opening a pull request, run the checks relevant to
the changed files:

```sh
python3 -m pytest tests/test_hornero_source_contract.py -q
bash scripts/audit-horneroctl-binds.sh
bash scripts/test-shell-layout-consistency.sh
bash scripts/check-shell-contract.sh
bash scripts/verify-delivery.sh
```

For template changes, render each affected template with both managed-host and
static chezmoi data. For image changes, inspect the actual files and keep
wallpaper assets reasonably sized.

## Pull requests

Use a short, descriptive title and explain the user-visible effect, ownership
boundary, validation, and any host-specific assumptions. Do not include
secrets, private machine details, or claims about HorneroOS features that are
not present in its current packages.
