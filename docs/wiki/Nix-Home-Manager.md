# ❄️ Nix / Home-Manager Notes

HorneroConfig is **chezmoi-first**: packages install through pacman and
dotfiles render through chezmoi templates. There is no supported
home-manager module yet — this page documents the honest state and the
practical paths if your system is NixOS or uses home-manager.

---

## ✅ What Works Today

- **NixOS host running Hyprland**: you can manage the _runtime_ configs
  with home-manager as plain files and still use the Hornero **dots-\***
  scripts (they are plain bash + quickshell):
  1. Clone the repo and apply only what you need:

     ```bash
     git clone https://github.com/ulises-jeremias/dotfiles ~/.dotfiles
     cd ~/.dotfiles
     chezmoi init    # generates ~/.config/chezmoi/... from home/.chezmoi.toml.tmpl
     chezmoi apply
     ```

  2. Or bypass chezmoi and symlink fragments directly:

     ```nix
     xdg.configFile."hypr".source = ~/.dotfiles/home/dot_config/hypr;
     xdg.configFile."quickshell".source = ~/.dotfiles/home/dot_config/quickshell;
     ```

- **Quickshell**: available in nixpkgs as `quickshell` (or built from
  source); Hornero expects its QML modules on `QML_IMPORT_PATH` — the
  launcher scripts set this for the Arch install, adapt for your Nix store paths.

---

## ⚠️ What Does Not Map 1:1

| Hornero concept                             | Nix equivalent                                                        | Notes                                                               |
| ------------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------- |
| `pacman` package lists in `.chezmoiscripts` | `environment.systemPackages` / home-manager `home.packages`           | Translate the lists manually; AUR packages need overlays            |
| `run_onchange_before_install-*.sh.tmpl`     | NixOS modules or `home.activation`                                    | These scripts assume pacman/yay                                     |
| `dots-*` CLI registry                       | plain PATH scripts                                                    | Works as-is; copy or symlink `home/dot_local/bin`                   |
| hyprland.conf.d fragments                   | home-manager `wayland.windowManager.hyprland` settings or plain files | Plain `xdg.configFile` keeps parity with upstream                   |
| Wallpaper → M3 pipeline (`dots-m3-colors`)  | runs on PATH                                                          | Needs python + the materialyoucolor deps; consider a nix derivation |

---

## 🗺️ If You Want Full Nix Support

The cleanest shape would be:

1. A flake exposing `homeManagerModules.hornero` that renders the same
   configs (template data -> module options)
2. A `nix()` data tag switch inside `.chezmoi.toml.tmpl` so package
   fragments become no-ops on NixOS
3. CI: a Nix job rendering the templates with `nix run nixpkgs#chezmoi`

None of that exists yet — contributions welcome, start from
[CONTRIBUTING](https://github.com/ulises-jeremias/dotfiles/blob/main/CONTRIBUTING.md).

---

## 🆘 Need Help?

- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)
- [Home-Manager Manual](https://nix-community.github.io/home-manager/)
