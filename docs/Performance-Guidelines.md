# Performance guidelines

Keep workstation configuration inexpensive at login and bounded during builds.

- Prefer packaged Hornero operations over duplicate background daemons.
- Do not generate wallpaper palettes or make network requests during chezmoi
  apply. Let the user trigger appearance operations in Hornero Settings.
- Keep optional services opt-in and avoid polling when a state-change signal
  or explicit user action is available.
- Build the optional Quickshell plugin with two jobs by default. The chezmoi
  build hook applies a systemd resource scope when available and supports an
  explicit `HORNERO_BUILD_JOBS` override.
- Put build output under `$XDG_CACHE_HOME/hornero/` and keep generated files
  out of the source tree.

Profile on representative hardware before changing cache or process behavior.
Use HorneroOS QA evidence for Shell startup and theme application when a
product regression is suspected.
