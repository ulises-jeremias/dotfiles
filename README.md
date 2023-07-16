<div align="justify">

<div align="center">

<h1>🔥 Dotfiles Generator</h1>

[Docs](https://github.com/ulises-jeremias/dotfiles/wiki) |
[Changelog](#) |
[Contributing](https://github.com/ulises-jeremias/dotfiles/blob/master/.github/CONTRIBUTING.md)

</div> <!-- center -->
<div align="center">

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/PandaFoss/Awesome-Arch)
[![AUR Stable](https://img.shields.io/aur/version/dots-stable?label=AUR+Stable)](https://aur.archlinux.org/packages/dots-stable)
[![AUR Development](https://img.shields.io/aur/version/dots-git?label=AUR+Development)](https://aur.archlinux.org/packages/dots-git)
[![License: MIT][licensebadge]][licenseurl]

</div> <!-- center -->

<h1>
  <a href="#--------">
    <img alt="" align="right" src="https://badges.pufler.dev/visits/ulises-jeremias/dotfiles?style=flat-square&label=&color=000000&logo=github&logoColor=white&labelColor=000000"/>
  </a>
</h1>

<details open>
<summary>👋 ‎ <sup><sub><samp>HI THERE! THANKS FOR DROPPING BY!</samp></sub></sup></summary>

<a href="#octocat--hi-there-thanks-for-dropping-by">
  <picture>
    <source media="(prefers-color-scheme: dark)" alt="" align="right" width="400px" srcset="./static/screen-2.jpg"/>
    <img alt="" align="right" width="400px" src="./static/screen-2.jpg"/>
  </picture>
</a>

You might be here looking for (Linux) rice reference or to fully replicate my personal
configuration of my favorite Window Managers and several apps as well. ❄️

Most of them were written from scratch. Here are some details:

- **Window Manager** 🍱 [i3](https://i3wm.org) and/or [Openbox](http://openbox.org/wiki/Main_Page) and/or [XFCE](https://www.xfce.org/)!
- **Panel** 🌸 [Polybar](https://polybar.github.io/)!
- **Application Launcher** 🚀 [Rofi](https://github.com/davatorium/rofi) which is blazing fast!
- **Desktop Notification** 🌿 [Dunst](https://github.com/dunst-project/dunst) which is minimalist!
- **Terminal Emulator** 🌿 [Alacritty](https://alacritty.org/) which is GPU accelerated!
- **Shell** 🐚 [Zsh](https://zsh.org) with several post-installation tweaks!
- **Compositor** 🍧 [Picom](https://github.com/yshui/picom) for that perfection topping!
- **File Manager** 🃏 [Thunar](https://docs.xfce.org/xfce/thunar/start) with a customized side pane!
- and many more!

</details>

<details>
<summary>🌟 Installation</summary>

### From the Arch-Linux User Repository (AUR)

- Using a helper like [yay](https://github.com/Jguer/yay)

  Install [dots-stable](https://aur.archlinux.org/packages/dots-stable/)

  ```sh
  yay dots-stable
  dots --help
  ```

  or install the rolling release [dots-git](https://aur.archlinux.org/packages/dots-git/)

  ```sh
  yay dots-git
  dots --help
  ```

- Using `makepkg`

  Install [dots-stable](https://aur.archlinux.org/packages/dots-stable/)

  ```sh
  git clone https://aur.archlinux.org/dots-stable.git /tmp/dots-stable
  cd /tmp/dots-stable
  makepkg -si
  dots --help
  ```

  or install the rolling release [dots-git](https://aur.archlinux.org/packages/dots-git/)

  ```sh
  git clone https://aur.archlinux.org/dots-git.git /tmp/dots-git
  cd /tmp/dots-git
  makepkg -si
  dots --help
  ```

### From source

> Use this for any OS that is not `Arch Linux` or `Arch Linux based distro`.
> This will install unstable versions of the dotfiles generator. You can switch to a stable version by using any existing git tag.

```sh
git clone https://github.com/ulises-jeremias/dotfiles /tmp/dotfiles
cd /tmp/dotfiles
sudo ./install
dots --help
```

The installation script allows you to install all the necessary dependencies to make your dotfiles config work correctly.

</details>

<details>
<summary>🎨 Post install customization</summary>

There is no need to fork this repository in order to customize it. Everything can be customized by leveraging the generated dotfiles directory. You are encouraged to maintain a separate GitHub repository of configurations for your own dotfiles.

Read more about this at [Customization Docs](https://github.com/ulises-jeremias/dotfiles/wiki/#Customization).

</details>

<details>
<summary>🧪 Testing</summary>

We use [Vagrant](https://www.vagrantup.com/) to test the installation of the dotfiles generator in different OSs.

To run the testing environment, just execute the following commands:

```sh
git clone https://github.com/ulises-jeremias/dotfiles /tmp/dotfiles
cd /tmp/dotfiles

# start the VM
./bin/play

# provision the VM
./bin/play --provision

# remove the VM
./bin/play --remove

# use -h to know more about the available options
```

</details>

<details>
<summary>📁 Repository Structure</summary>

```sh
.
├── .github                 # GitHub related files
├── arch-linux              # Arch Linux override files (used by dots when installing in Arch Linux based distros)
│   ├── bin/                # binaries to be installed in Arch Linux based distros
│   ├── deps.sh             # Arch Linux specific dependencies
│   └── install-pkgs.sh     # Arch Linux specific script to install packages from the AUR and the official repos
├── bin/                    # Useful binaries
│   └── play                # script to run the testing environments
├── common                  # common files (used by dots when installing in any OS)
│   ├── bin/                # common binaries to be installed in any OS
│   ├── config/             # common config files to be installed in any OS
│   └── install             # script installed by dots at

 <dotfiles_dir>/install
├── debian                  # Debian override files (used by dots when installing in Debian based distros)
│   ├── bin/                # binaries to be installed in Debian based distros
│   ├── deps.sh             # Debian specific dependencies
│   └── install-pkgs.sh     # Debian specific script to install packages from the official repos and other sources
├── playground              # testing environments
│   └── vagrant/            # Vagrant setup to bootstrap the testing environments
├── scripts                 # scripts used by dots to install the dotfiles
│   └── install-pkgs        # script to install packages from the official repos and other sources
│   ├── install-dotfiles    # script to install the dotfiles in the system
│   └── install             # main installation script
├── static/                 # static files used by the README
├── ui/                     # UI files used by dots when installing in interactive mode - WIP
├── util/                   # utility files used by dots
├── dots                    # dots binary to install the dotfiles
└── install                 # installation `dots` binary in the system
```

</details>

## 🤝 Contributors

<a href="https://github.com/ulises-jeremias/dotfiles/contributors">
  <img src="https://contrib.rocks/image?repo=ulises-jeremias/dotfiles"/>
</a>

Made with [contributors-img](https://contrib.rocks).

[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[licenseurl]: https://github.com/ulises-jeremias/dotfiles/blob/master/LICENSE
</div> <!-- justify -->
