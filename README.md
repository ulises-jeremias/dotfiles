# Dotfiles

My personal dotfiles for i3, polybar, fgmenu, compton, ...

## Install

```sh
$ git clone https://github.com/ulises-jeremias/dotfiles /tmp/dotfiles
$ cd /tmp/dotfiles
$ ./scripts/install [--os <os>] [-l <file_path>] [--dotfiles-dir <dir_path>] [--no-deps]
```

The installation script will install all the necessary dependencies that allow your dotfiles config work correctly.

### Installation args

- `<os> = common | arch-linux | debian | ...` where common is supposed to work correctly with any linux distro. `common` is set as default value for this flag.

- `<file_path>` is `/tmp/install_progress_log_$(date +'%m-%d-%y_%H:%M:%S').txt` as default.

- `<dir_path>` is `~/dotfiles` as default.

## Screenshots

### Home

![preview-home](./images/screen.png)

### Terminals

![preview-terminals](./images/nvim&termite.png)
