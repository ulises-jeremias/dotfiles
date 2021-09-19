<div align="center">
<h1>Dotfiles Generator</h1>

[Docs](https://ulises-jeremias.github.io/dotfiles) |
[Changelog](#) |
[Contributing](https://github.com/ulises-jeremias/dotfiles/blob/master/.github/CONTRIBUTING.md)

</div>
<div align="center">

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/PandaFoss/Awesome-Arch)
[![Docs Deployment][docsdeploymentbadge]][docsdeploymenturl]
[![License: MIT][licensebadge]][licenseurl]

</div>

Dotfiles generator that allows quick configuration of different window managers in multiple OSs.

## How it looks

<center>

<img src="https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screen.png" align="left" width="48.75%" style="margin-left: 2.5%; margin-right: 5%" />

<img src="https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/nvim.png" width="48.75%" />

<img src="https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/demo.gif" width="100%" style="margin-top: 15px;" />

</center>

## Installation

```sh
$ git clone https://github.com/ulises-jeremias/dotfiles /tmp/dotfiles
$ cd /tmp/dotfiles
$ ./dots --wms=<WMS> # use -h to know more about install options
```

being `WMS = i3,openbox,...`.

The installation script will install all the necessary dependencies that allow your dotfiles config work correctly.

## Customization

There is no need to fork this repository in order to customize it. Everything can be customized by leveraging the `custom-config` directory. You are encouraged to maintain a separate github repository of configurations for your own dotfiles.

The custom-config directory is intended to be the central location for all of your customizations. It is recommended that you maintain a github repository of your configurations. You may add the contents to the `custom-config` like so;

```sh
$ cd <dotfiles_dir>/custom-config
$ git init
$ git remote add origin git@github.com:your-username/your-custom-config-repo.git
$ git pull origin master
```

If you updated the updated the directory `<dotfiles_dir>/custom-config` you will need to apply those changes:

- To apply configuration files from scratch after the installation process you should only run the installation command
with the same flags you did before but with `--nodeps` to avoid installing all dependencies again.

- In some cases there are directories that already have their own `./install` script. You will need to execute only that
installation script if the changes are on those directories.

Read more about this at [customization docs](https://ulises-jeremias.github.io/dotfiles/#Customization).

## Testing

Maybe you want to contribute to this project or just test what the setup would look like before installing it. For this we develop test environments in which you can see how the changes look!

To run testing environment just run the following commands;

```sh
$ git clone https://github.com/ulises-jeremias/dotfiles /tmp/dotfiles
$ cd /tmp/dotfiles
$ ./bin/test --os=<OS> --wms=<WMS> # use -h to know more about install options
```

being `OS = arch-linux | debian` and `WMS = i3,openbox,...`.

You can read more about this at [testing docs](https://ulises-jeremias.github.io/dotfiles/#Testing).

[docsdeploymentbadge]: https://github.com/ulises-jeremias/dotfiles/workflows/Deploy%20Docs/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[docsdeploymenturl]: https://github.com/ulises-jeremias/dotfiles/commits/master
[licenseurl]: https://github.com/ulises-jeremias/dotfiles/blob/master/LICENSE
