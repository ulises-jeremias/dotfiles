<div align="center">
<h1>Dotfiles Generator</h1>

[Docs](https://github.com/ulises-jeremias/dotfiles/wiki) |
[Changelog](#) |
[Contributing](https://github.com/ulises-jeremias/dotfiles/blob/master/.github/CONTRIBUTING.md)

</div>
<div align="center">

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/PandaFoss/Awesome-Arch)
[![AUR Stable](https://img.shields.io/aur/version/dots-stable?label=AUR+Stable)](https://aur.archlinux.org/packages/dots-stable)
[![AUR Development](https://img.shields.io/aur/version/dots-git?label=AUR+Development)](https://aur.archlinux.org/packages/dots-git)
[![License: MIT][licensebadge]][licenseurl]

</div>

Dotfiles generator that allows quick configuration of different window managers in multiple OSs.

- [Installation](#installation)
  - [From the Arch Linux User Repository (AUR)](#from-the-arch-linux-user-repository-aur)
- [Installation from Source](#installation-from-source)
- [Customization](#customization)
  - [Examples](#examples)
- [Testing](#testing)
  - [Docker and Xephyr](#docker-and-xephyr)
  - [Vagrant](#vagrant)
- [Repository Structure](#repository-structure)
- [Contributors](#contributors)

## Installation

### From the Arch Linux User Repository (AUR)

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

## Installation from Source

> Use this for any OS that is not `Arch Linux` or `Arch Linux based distro`.
> This will install unstable versions of the dotfiles generator. You can switch to a stable version by using any existing git tag.

```sh
git clone https://github.com/ulises-jeremias/dotfiles /tmp/dotfiles
cd /tmp/dotfiles
sudo ./install
dots --help
```

The installation script allows you to install all the necessary dependencies that allow your dotfiles config work correctly.

## Customization

There is no need to fork this repository in order to customize it. Everything can be customized by leveraging the `custom-config` directory. You are encouraged to maintain a separate github repository of configurations for your own dotfiles.

Read more about this at [Customization Docs](https://github.com/ulises-jeremias/dotfiles/wiki/#Customization).

### Examples

<div class="container">
  <img alt="Dotfiles Screen Overview" src="./static/screen-2.jpg" />
  <img alt="Nord Two Lines" src="./static/screenshot-nord-two-lines.png" />
  <img alt="Launchpad" src="./static/screenshot-launchpad.png" />
  <img alt="Spotlight Dark" src="./static/screenshot-spotlight-dark.png" />
  <img alt="Dotfiles Overview" src="./static/demo.gif" />
  <img alt="i3 with alacritty" src="./static/nvim.png" />
</div>

## Testing

We have different testing environments that allow us to test the dotfiles generator in different OSs and window managers.

### Docker and Xephyr

To run the testing environment just run the following commands;

```sh
git clone https://github.com/ulises-jeremias/dotfiles /tmp/dotfiles
cd /tmp/dotfiles

# start the docker compose env
./bin/play --docker

# use -h to know more about the available options
```

### Vagrant

To run the testing environment just run the following commands;

```sh
git clone https://github.com/ulises-jeremias/dotfiles /tmp/dotfiles
cd /tmp/dotfiles
cd ./playground/vagrant/<os>/

# start the VM
./bin/play --vagrant

# provision the VM
./bin/play --vagrant --provision

# remove the VM
./bin/play --vagrant --remove

# use -h to know more about the available options
```

## Repository Structure

```sh
.
├── .github                 # github related files
├── arch-linux              # Arch Linux override files (used by dots when installing in Arch Linux based distros)
│   ├── bin/                # binaries to be installed in Arch Linux based distros
│   ├── deps.sh             # Arch Linux specific dependencies
│   └── install-pkgs.sh     # Arch Linux specific script to install packages from the AUR and the official repos
├── bin/                    # Useful binaries
│   └── play                # script to run the testing environments
├── common                  # common files (used by dots when installing in any OS)
│   ├── bin/                # common binaries to be installed in any OS
│   ├── config/             # common config files to be installed in any OS
│   └── install             # script installed by dots at <dotfiles_dir>/install
├── debian                  # Debian override files (used by dots when installing in Debian based distros)
│   ├── bin/                # binaries to be installed in Debian based distros
│   ├── deps.sh             # Debian specific dependencies
│   └── install-pkgs.sh     # Debian specific script to install packages from the official repos and other sources
├── default-config          # default config files (used by dots when installing in any OS). Check the docs https://github.com/ulises-jeremias/dotfiles/wiki/Customization for more info.
│   ├── common/             # common config files to be installed in any OS
│   ├── wm/                 # window manager config files to be installed in any OS based on the intallation flag `--wms`
├── playground              # testing environments
│   └── docker/             # docker setup to bootstrap the testing environments
│   └── vagrant/            # vagrant setup to bootstrap the testing environments
├── scripts                 # scripts used by dots to install the dotfiles
│   └── install-pkgs        # script to install packages from the official repos and other sources
│   ├── install-dotfiles    # script to install the dotfiles in the system
│   └── install             # main installation script
├── static/                 # static files used by the README
├── ui/                     # ui files used by dots when installing in interactive mode - WIP
├── util/                   # util files used by dots
├── dots                    # dots binary to install the dotfiles
└── install                 # installation `dots` binary in the system
```

## Contributors

<a href="https://github.com/ulises-jeremias/dotfiles/contributors">
  <img src="https://contrib.rocks/image?repo=ulises-jeremias/dotfiles"/>
</a>

Made with [contributors-img](https://contrib.rocks).

[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[licenseurl]: https://github.com/ulises-jeremias/dotfiles/blob/master/LICENSE
