# Customization

- [Customization](#customization)
  - [Window Managers](#window-managers)
    - [i3 Gaps](#i3-gaps)
    - [Openbox](#openbox)
  - [Common Apps](#common-apps)
    - [Polybar](#polybar)
    - [Zsh](#zsh)
    - [Zsh + Power Level 10k](#zsh--power-level-10k)
    - [NeoVim](#neovim)
  - [Misc Customization](#misc-customization)

There is no need to fork this repository in order to customize it. Everything can be customized by leveraging the `custom-config` directory. You are encouraged to maintain a separate github repository of configurations for your own dotfiles.

The custom-config directory is intended to be the central location for all of your customizations. It is recommended that you maintain a github repository of your configurations. You may add the contents to the `custom-config` like so;

```sh
$ cd <dotfiles_dir>/custom-config
$ git init
$ git remote add origin git@github.com:your-username/your-custom-config-repo.git
$ git pull origin master
```

To apply configuration files after the installation process you should only run the command `<dotfiles_dir>/default-config/install` after having modified the contents of the directory `<dotfiles_dir>/custom-config`.

## Window Managers

This section explains how to customize the installed window managers. It is important to note that in some cases, to update configuration files after the installation process you should only run the command `<dotfiles_dir>/default-config/install` after having modified the contents of the directory `<dotfiles_dir>/custom-config`.

### i3 Gaps

All `i3-gaps` configuration is in file `<dotfiles_dir>/custom-config/i3/config`. You are completely free to configure it as you wish. In case you have problems or want to go back, you can see the default configuration in `<dotfiles_dir>/default-config/i3/config`.

### Openbox

All `openbox` configurations are in `<dotfiles_dir>/custom-config/openbox`. You are completely free to configure it as you wish. In case you have problems or want to go back, you can see the default configuration in `<dotfiles_dir>/default-config/openbox`.

These dotfiles are fully compatible with openbox configuration app. You can use them instead of doing it by hand.

## Common Apps

### Polybar

The polybar configuration is parameterizable. For this you can modify the parameters of the file `<dotfiles_dir>/custom-config/Xresources.d/polybar`. In case you have problems with this, you can check the default values in `<dotfiles_dir>/default-config/Xresources.d/polybar`.

You can also add modules and polybars in the files `<dotfiles_dir>/custom-config/polybar/modules/custom.conf` and `<dotfiles_dir>/custom-config/polybar/polybars/custom.conf`, respectively.

For the parameterization of modules, you can use all those that are defined on `<dotfiles_dir>/config/polybar/modules.conf` and `<dotfiles_dir>/custom-config/polybar/modules/custom.conf`.

### Zsh

Any file in your `<dotfiles_dir>/custom-config` directory ending with `.sh` will automatically be sourced when you open a shell. You can use this to add additional alias, functions, etc.

For example, you can create the file `<dotfiles_dir>/custom-config/zsh/paths.sh` with the following content.

```sh
# custom exports

export LD_LIBRARY_PATH=/usr/local/lib
export PATH="$(yarn global bin):$HOME/bin:$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.config"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/zsh_completion" ] && \. "$NVM_DIR/zsh_completion"  # This loads nvm zsh_completion
```

This file will be automatically sourced.

### Zsh + Power Level 10k

You can use [Power Level 10k](https://github.com/romkatv/powerlevel10k) as your zsh theme installing it and creating a file at your `custom-config`, e.g. `<dotfiles_dir>/custom-config/zsh/p10k.sh`, with the following content:

```sh
# Source Power Level 10k <<1
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# >>1

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

This file will be automatically sourced.

### NeoVim

Not yet

## Misc Customization

You can use your own configuration file in place of any of the following

- gitconfig
- xprofile
- Xresources

To do so you just need to include a file of the same name in your version controlled directory that you save into `custom-config` the create symlinks scripts will link the files properly.

To add configuration files after the installation process you should only run the command `<dotfiles_dir>/default-config/install` after having modified the contents of the directory `<dotfiles_dir>/custom-config`.
