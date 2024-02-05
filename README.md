<div align="justify">

<div align="center">

```ocaml
NEVER SKIP / IGNORE / AVOID README
```

<h1>🔥 Dotfiles Generator</h1>

[Docs](https://ulises-jeremias.github.io/dotfiles) |
[Changelog](#) |
[Contributing](https://github.com/ulises-jeremias/dotfiles/blob/master/.github/CONTRIBUTING.md)

</div> <!-- center -->

<div align="center">

[![Awesome](https://awesome.re/mentioned-badge.svg)](https://github.com/PandaFoss/Awesome-Arch)
[![AUR Stable](https://img.shields.io/aur/version/dots-stable?label=AUR+Stable)](https://aur.archlinux.org/packages/dots-stable)
[![AUR Development](https://img.shields.io/aur/version/dots-git?label=AUR+Development)](https://aur.archlinux.org/packages/dots-git)
[![License: MIT][licensebadge]][licenseurl]

</div> <!-- center -->

<h1>
  <a href="#--------">
    <img alt="" align="right" src="https://badges.pufler.dev/visits/ulises-jeremias/dotfiles?style=flat-square&label=&color=000000&logo=github&logoColor=white&labelColor=000000"/>
  </a>
</h1>

### :octocat: ‎ <sup><sub><samp>HI THERE! THANKS FOR DROPPING BY!</samp></sub></sup>

You might be here looking for (Linux) rice reference or to (full?) replicate my personal
configuration of my favorite Window Managers and several apps as well. ⛄

These configuration is not only suitable for Desktop Environments but also for use in [GitHub Codespaces](https://docs.github.com/codespaces/customizing-your-codespace/personalizing-codespaces-for-your-account#dotfiles), [Gitpod](https://www.gitpod.io/docs/config-dotfiles), [VS Code Remote - Containers](https://code.visualstudio.com/docs/remote/containers#_personalizing-with-dotfile-repositories), or even Linux distributions that are not Arch Linux.

This dotfiles are backed by [Chezmoi](https://www.chezmoi.io/) which is a dotfiles manager that is designed to be flexible and extensible. It is easy to bootstrap new machines and keep multiple machines in sync. It supports any platform that is supported by Go!

<div align="center">

```ocaml
CLICK OR TAP ❲☰❳ TO SHOW TABLE-OF-CONTENTS
```

</div>

<a href="#octocat--hi-there-thanks-for-dropping-by">
  <picture>
    <source media="(prefers-color-scheme: dark)" alt="" align="right" width="400px" srcset="./static/screen-2.jpg"/>
    <img alt="" align="right" width="400px" src="./static/screen-2.jpg"/>
  </picture>
</a>

Most were written from scratch. Some details:

- **Window Manager** 🍱 [i3](https://i3wm.org) and/or [Openbox](http://openbox.org/wiki/Main_Page) and/or [XFCE](https://www.xfce.org/)!
- **Panel** 🌸 [Polybar](https://polybar.github.io/) whic is a fast and easy-to-use status bar!
- **Application Launcher** 🚀 [Rofi](https://github.com/davatorium/rofi) which is blazing fast!
- **Desktop Notification** 🌿 [Dunst](https://github.com/dunst-project/dunst) which is minimalist!
- **Terminal Emulator** 🌿 [Alacritty](https://alacritty.org/) which is GPU accelerated!
- **Shell** 🐚 [Zsh](https://zsh.org) with several post-installation tweaks!
- **Compositor** 🍧 [Picom fork by FT-Labs](https://github.com/FT-Labs/picom) for that perfection topping with Animations!
- **File Manager** 🃏 [Thunar](https://docs.xfce.org/xfce/thunar/start) with a customized side pane!
- and many more!

Managed with [`chezmoi`](https://chezmoi.io), a great dotfiles manager.

## Getting started 🚀

You can use a [convenient script](./scripts/install_dotfiles.sh) to install the dotfiles on any machine with a single command. Simply run the following command in your terminal:

```bash
sh -c "$(wget -qO- "https://github.com/ulises-jeremias/dotfiles/blob/master/scripts/install_dotfiles.sh?raw=true")"
```

> 💡 We use `wget` here because it comes preinstalled with most Linux distributions. But you can also use `curl`:
>
> ```bash
> sh -c "$(curl -fsSL "https://github.com/ulises-jeremias/dotfiles/blob/master/scripts/install_dotfiles.sh?raw=true")"
> ```

This will install the dotfiles in `~/.dotfiles`.

<details>
<summary>🌟 Other ways to install the dotfiles</summary>

### Using Chezmoi

> This is a recommended way to install the dotfiles generator. It will install the latest stable version of the dotfiles generator using [Chezmoi](https://www.chezmoi.io/) which is a dotfiles manager that is designed to be flexible and extensible.

```sh
chezmoi init --apply ulises-jeremias --source ~/.dotfiles
```

This will install the dotfiles in `~/.dotfiles`.

### From source

> Use this for any OS that is not `Arch Linux` or `Arch Linux based distro`.
> This will install unstable versions of the dotfiles generator. You can switch to a stable version by using any existing git tag.

```sh
git clone https://github.com/ulises-jeremias/dotfiles ~/.dotfiles
~/.dotfiles/install
```

The installation script allows you to install all the necessary dependencies to make your dotfiles config work correctly.

### From the Arch-Linux User Repository (AUR)

- Using a helper like [yay](https://github.com/Jguer/yay)

  Install [dots-stable](https://aur.archlinux.org/packages/dots-stable/)

  ```sh
  yay dots-stable
  ```

  or install the rolling release [dots-git](https://aur.archlinux.org/packages/dots-git/)

  ```sh
  yay dots-git
  ```

- Using `makepkg`

  Install [dots-stable](https://aur.archlinux.org/packages/dots-stable/)

  ```sh
  git clone https://aur.archlinux.org/dots-stable.git /tmp/dots-stable
  cd /tmp/dots-stable
  makepkg -si
  ```

  or install the rolling release [dots-git](https://aur.archlinux.org/packages/dots-git/)

  ```sh
  git clone https://aur.archlinux.org/dots-git.git /tmp/dots-git
  cd /tmp/dots-git
  makepkg -si
  ```

</details>

## 🎨 Post install Customization

You can fork this repository and customize it to suit your preferences and workflow. You are encouraged to maintain a separate GitHub repository of configurations for your own dotfiles and keep this repository as a template!

<details>
<summary>Expand to see the steps to customize your environment!</summary>

We use [Chezmoi](https://www.chezmoi.io/) to manage the dotfiles. Chezmoi is a sophisticated yet easy-to-use command-line tool that helps you manage your dotfiles across multiple machines. It is designed to be secure, flexible, and easy to use.

To customize the dotfiles, follow these steps:

1. Run the command `chezmoi init --source ~/.dotfiles` to initialize Chezmoi.

2. Run the command `chezmoi edit --source ~/.dotfiles` to open the dotfiles directory.

3. Customize the dotfiles to suit your preferences and workflow.

4. Run the command `chezmoi apply --source ~/.dotfiles` to apply the changes.

</details>

Read more about this at [Customization Docs](https://ulises-jeremias.github.io/dotfiles/#Customization).

## 🛡️ Privacy and Security

Although I like making it look as nice as possible, these dotfiles also try to be private and secure!

You can read more about this at [Privacy and Security Docs](https://ulises-jeremias.github.io/dotfiles/#Security).

## 🧪 Testing

We use [Vagrant](https://www.vagrantup.com/) to test the installation of the dotfiles generator in different
Operating Systems and machine architectures.

<details>
<summary>Expand to learn how to run a testing environment!</summary>

To run the testing environment, just execute the following commands:

```sh
git clone https://github.com/ulises-jeremias/dotfiles
cd ./dotfiles

# start the VM
./bin/play

# provision the VM
./bin/play --provision

# remove the VM
./bin/play --remove

# use -h to know more about the available options
```

</details>

## 🤝 Contributing

Contributions, issues and feature requests are welcome! Check out the [Contributing Guide](./CONTRIBUTING.md) for more details!

Bellow you can find a list of all the amazing contributors who have made this project possible:

<a href="https://github.com/ulises-jeremias/dotfiles/contributors">
  <img src="https://contrib.rocks/image?repo=ulises-jeremias/dotfiles" alt="Contributors">
</a>

_Made with [contributors-img](https://contrib.rocks)._

[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[licenseurl]: https://github.com/ulises-jeremias/dotfiles/blob/master/LICENSE

</div> <!-- justify -->
