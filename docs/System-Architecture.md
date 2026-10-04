# Workstation architecture

The personal workstation source sits alongside HorneroOS; it is not another
implementation of the desktop product.

```text
HorneroOS/config ── package defaults, theme catalogue, GTK and wallpaper contracts
         │
         ├── HorneroOS/shell ── bars, Launcher, Dashboard, Settings and feedback
         │
         └── HorneroOS/hornero ── stable CLI and OS capabilities
                         │
                         └── this chezmoi source ── optional apps, user preferences,
                                                      host choices and wallpaper media
```

## Product configuration

`hornero-config` owns packaged system defaults and appearance pack metadata.
`horneroctl` reads the installed catalogue and applies supported operations.
The Shell presents the controls and reports live state. User overrides belong
in the XDG Hornero paths documented by the
[HorneroOS appearance guide](https://hornero-os.vercel.app/docs/desktop/appearance/).

This repository may provide optional wallpaper media under
`home/dot_local/share/hornero/wallpapers/`. It does not own theme definitions,
Shell state, generated palettes, or a competing theme manager.

## Personal workstation configuration

Chezmoi templates materialize account-level settings and optional application
choices. Files should be idempotent and scoped to their declared targets.
A missing optional application should leave the remaining desktop usable.
Package installation and HorneroOS system operations are not performed by
personal shell wrappers in this source.

## Data flow

```text
tracked chezmoi source → rendered user config → HorneroOS package/CLI/Shell
        optional user media ────────────────────────────────┘
```

Theme metadata has one canonical source in HorneroOS/config. Wallpaper image
files can be supplied separately. Runtime state and generated caches are
owned by the product services and remain outside this source tree.
