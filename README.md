<div align="center">
<h1>Dotfiles Generator</h1>

[Docs](https://ulises-jeremias.github.io/dotfiles) |
[Changelog](#) |
[Contributing](https://github.com/ulises-jeremias/dotfiles/blob/master/.github/CONTRIBUTING.md)

</div>
<div align="center">

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/PandaFoss/Awesome-Arch)
[![AUR Development](https://img.shields.io/aur/version/dots-git?label=AUR)](https://aur.archlinux.org/packages/dots-git)
[![Docs Deployment][docsdeploymentbadge]][docsdeploymenturl]
[![License: MIT][licensebadge]][licenseurl]

</div>

Dotfiles generator that allows quick configuration of different window managers in multiple OSs.

![Dotfiles Overview](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/demo.gif)

## Arch Linux

> Install [dots](https://aur.archlinux.org/packages/dots-git/) from AUR

```sh
$ yay dots-git
$ dots --help
```

## Installation from Source

```sh
$ git clone https://github.com/ulises-jeremias/dotfiles /tmp/dotfiles
$ cd /tmp/dotfiles
$ sudo ./install
$ dots --help
```

The installation script allows you to install all the necessary dependencies that allow your dotfiles config work correctly.

## Customization

There is no need to fork this repository in order to customize it. Everything can be customized by leveraging the `custom-config` directory. You are encouraged to maintain a separate github repository of configurations for your own dotfiles.

Read more about this at [Customization Docs](https://ulises-jeremias.github.io/dotfiles/#Customization).

### Examples

![i3 with alacritty](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/nvim.png)

![Apps finder](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screenshot-launchpad.png)

![Apps finder](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screenshot-spotlight-dark.png)

![Apps finder](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screenshot-nord-two-lines.png)

## Testing

Maybe you want to contribute to this project or just test what the setup would look like before installing it. For this we develop test environments in which you can see how the changes look!

You can read more about this at [Testing Docs](https://ulises-jeremias.github.io/dotfiles/#Testing).

[docsdeploymentbadge]: https://github.com/ulises-jeremias/dotfiles/workflows/Deploy%20Docs/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[docsdeploymenturl]: https://github.com/ulises-jeremias/dotfiles/commits/master
[licenseurl]: https://github.com/ulises-jeremias/dotfiles/blob/master/LICENSE
