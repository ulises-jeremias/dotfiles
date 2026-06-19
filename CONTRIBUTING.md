# Contributing

If you want to send a PR — a fix, a rice, a doc improvement — this is what I'll need from you.

## Setup

```bash
# Fork on GitHub first, then:
git clone https://github.com/YOUR-USERNAME/dotfiles ~/.dotfiles
cd ~/.dotfiles
git remote add upstream https://github.com/ulises-jeremias/dotfiles

# Install pre-commit (shellcheck, shfmt, markdown lint, secret scan)
pipx install pre-commit && pre-commit install

# Verify the hooks pass on a clean tree
pre-commit run --all-files
```

If you don't have `pipx`: `sudo pacman -S python-pipx` on Arch, `sudo apt install pipx` on Debian, `brew install pipx` on macOS.

## Conventions

- **Commits** — Conventional Commits: `feat(rice): …`, `fix(quickshell): …`, `docs: …`, `chore: …`. Scope is the affected component.
- **Shell** — `set -euo pipefail` at the top, idempotent, OS detection before package manager calls. ShellCheck and shfmt run on every commit.
- **Docs** — If your change affects behavior visible to users, update the relevant page. The wiki lives in `docs/wiki/`.
- **Secrets** — Never commit. Use `.env.example` as a template, real values go in `.env` (gitignored).
- **English** — All commit messages, PR descriptions, and committed text are in English.

The deeper standards (templates, error handling patterns, performance budgets) live in [`docs/Development-Standards.md`](docs/Development-Standards.md) and [`AGENTS.md`](AGENTS.md).

## Testing changes

There's a Vagrant playground that boots a clean VM and provisions HorneroConfig inside it:

```bash
./bin/play                        # boot
./bin/play --provision hyprland   # apply the config
./bin/play --remove               # tear down
```

Use it for anything that touches install scripts, Hyprland config, or the Quickshell shell — easier than reverting your own machine.

## Adding a new rice

Each rice is a directory under `home/dot_local/share/dots/rices/<name>/` with:

```
<name>/
├── backgrounds/   # at least one 1920x1080 wallpaper that matches the palette
├── config.json    # machine-readable metadata + colors + GTK/icon/cursor themes
├── config.sh      # human-readable description, tags, theme components
└── preview.png    # screenshot, ideally 1920x1080
```

`config.json` is what the rice loader reads at runtime; `config.sh` mirrors the same info in shell variables for scripts. Copy an existing rice (`neon-city`, `cozy-corner`, `everforest`) and adapt — same fields, different values.

Apply it locally with `dots rice apply <name>` and confirm Quickshell, Hyprland, and Kitty all reload with the right palette.

The wiki has the full [rice system reference](https://github.com/ulises-jeremias/dotfiles/wiki/Rice-System-Theme-Management).

## Bugs and feature requests

GitHub issues are the place. The templates ([`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/)) ask for the things I'll need anyway — environment, repro steps, logs. Filling them in saves a round-trip.

For visual bugs, a screenshot is worth a thousand stack traces.

## PR checklist

- [ ] `pre-commit run --all-files` passes
- [ ] Tested in the playground (or explained why it can't be)
- [ ] Docs/wiki updated if the change is user-visible
- [ ] PR description links the issue and explains the *why*

## Code of conduct

Be decent. The full text lives in [`.github/CODE_OF_CONDUCT.md`](.github/CODE_OF_CONDUCT.md).
