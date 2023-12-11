# Customizing Dotfiles

You don't need to fork this repository to customize it. You can easily customize the dotfiles by leveraging the generated dotfiles directory. We encourage you to maintain a separate GitHub repository for your own dotfiles configurations.

To get started, follow these steps:

1. Change directory to your dotfiles directory:
   ```sh
   cd <dotfiles_dir>
   ```

2. Initialize a new Git repository:
   ```sh
   git init
   ```

3. Add your custom dotfiles repository as a remote origin:
   ```sh
   git remote add origin git@github.com:your-username/your-dotfiles-repo.git
   ```

4. Pull the changes from the remote origin:
   ```sh
   git pull origin master
   ```

If you made changes to the `<dotfiles_dir>/config` directory, you need to apply those changes. Here's how:

- For directories that already have their own `./install` script, you only need to execute the installation script if the changes are within those directories.

- If you want to ensure that your customizations are applied to all your dotfiles, run the `<dotfiles_dir>/install` script. This will automatically run the installation process for all the dotfiles in your dotfiles directory.

### Examples

Here are some examples of customizations made using the dotfiles:

![i3 with alacritty](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/nvim.png)

![Apps finder](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screenshot-launchpad.png)

![Apps finder](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screenshot-spotlight-dark.png)

![Apps finder](https://raw.githubusercontent.com/ulises-jeremias/dotfiles/master/static/screenshot-nord-two-lines.png)

Feel free to customize and personalize your dotfiles to suit your preferences and workflow!
