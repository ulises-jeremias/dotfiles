<div align="center">
<h1>Dotfiles Generator</h1>

[Docs](https://github.com/ulises-jeremias/dotfiles/wiki) |
[Changelog](#) |
[Contributing](https://github.com/ulises-jeremias/dotfiles/blob/master/.github/CONTRIBUTING.md)

</div>
<div align="center">

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/PandaFoss/Awesome-Arch)
[![AUR Stable](https://img.shields.io/aur/version/dots-stable?label=AUR)](https://aur.archlinux.org/packages/dots-stable)
[![AUR Development](https://img.shields.io/aur/version/dots-git?label=AUR)](https://aur.archlinux.org/packages/dots-git)
[![License: MIT][licensebadge]][licenseurl]

</div>

Dotfiles generator that allows quick configuration of different window managers in multiple OSs.

![Dotfiles Screen Overview](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screen-2.jpg)

![Dotfiles Overview](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/demo.gif)

## Arch Linux

Install [dots-stable](https://aur.archlinux.org/packages/dots-stable/) from AUR

```sh
$ yay dots-stable
$ dots --help
```

or install the rolling release [dots-git](https://aur.archlinux.org/packages/dots-git/) from AUR

```sh
$ yay dots-git
$ dots --help
```

## Installation from Source

> Use this for any OS that is not `Arch Linux` or `Arch Linux based distro`

```sh
$ git clone https://github.com/ulises-jeremias/dotfiles /tmp/dotfiles
$ cd /tmp/dotfiles
$ sudo ./install
$ dots --help
```

The installation script allows you to install all the necessary dependencies that allow your dotfiles config work correctly.

## Customization

There is no need to fork this repository in order to customize it. Everything can be customized by leveraging the `custom-config` directory. You are encouraged to maintain a separate github repository of configurations for your own dotfiles.

Read more about this at [Customization Docs](https://github.com/ulises-jeremias/dotfiles/wiki/#Customization).

### Examples

![i3 with alacritty](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/nvim.png)

![Apps finder](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screenshot-launchpad.png)

![Apps finder](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screenshot-spotlight-dark.png)

![Apps finder](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screenshot-nord-two-lines.png)

## Testing

Maybe you want to contribute to this project or just test what the setup would look like before installing it. For this we develop test environments in which you can see how the changes look!

You can read more about this at [Testing Docs](https://github.com/ulises-jeremias/dotfiles/wiki/#Testing).

## Contributors 

<a href="https://github.com/ulises-jeremias/dotfiles/contributors">
  <img src="https://contrib.rocks/image?repo=ulises-jeremias/dotfiles"/>
</a>

Made with [contributors-img](https://contrib.rocks).


[docsdeploymentbadge]: https://github.com/ulises-jeremias/dotfiles/workflows/Deploy%20Docs/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[licenseurl]: https://github.com/ulises-jeremias/dotfiles/blob/master/LICENSE
