💡 **Introduction**

Zsh, or Z Shell, is a powerful and feature-rich shell that provides an enhanced command-line experience. It offers a wide range of interactive features, extensive customization options, and advanced scripting capabilities. In our dotfiles setup, we have chosen to use Zsh as the default shell due to its numerous advantages over other shells like Bash or Fish.

🚀 **Improved User Experience**

Zsh provides advanced features that enhance productivity and convenience. With features like advanced tab completion, spelling correction, history search, and powerful globbing capabilities, working with the command line becomes easier and faster.

🔧 **Customization Options**

Zsh is highly customizable, allowing you to personalize your shell environment. You can define custom functions, aliases, and keybindings to streamline your workflow. Additionally, Zsh offers a wide range of prompt themes and plugins to enhance your shell experience, making it adaptable to your preferences and needs.

💡 **Advanced Scripting Support**

Zsh offers a powerful scripting language with additional features compared to other shells. It supports advanced control structures, associative arrays, and regular expressions, making it an excellent choice for scripting complex tasks. Zsh's scripting capabilities enable you to write efficient and robust scripts.

🔋 **Extensive Plugin Ecosystem**

Zsh has a vibrant community that has developed numerous plugins and extensions to extend its functionality. You can easily enhance your Zsh environment with plugins for syntax highlighting, auto-suggestions, Git integration, and more. These plugins greatly improve productivity and make working in the shell more enjoyable.

🔗 **Seamless Compatibility**

Zsh is fully compatible with most shell scripts written for Bash. You can run your existing Bash scripts without any modifications in Zsh, ensuring a smooth transition. Additionally, Zsh provides better handling of corner cases and edge scenarios, making it a reliable choice for shell scripting.

## Customizing Zsh!

Any file in your `~/.zsh/custom` directory ending with `.zsh` will automatically be sourced when you open a shell. You can use this to add additional aliases, functions, and more.

<details>
<summary><strong>Zsh + Antigen</strong></summary>

[Antigen](https://github.com/zsh-users/antigen) is a small set of functions that help you easily manage your shell (Zsh) plugins, called bundles. It is similar to bundles in a typical vim+pathogen setup.

To add Antigen as your plugin manager, execute the following command to download the latest stable version of Antigen into your home directory (check the [installation](https://github.com/zsh-users/antigen#installation) steps for more details):

```sh
curl -L git.io/antigen > ~/.antigen.zsh
```

Then, create the file `~/.zsh/custom/antigen.zsh` with the following content:

```sh
source "${HOME}"/.antigen.zsh

antigen apply
```

This file will be automatically sourced.

</details>

<details>
<summary><strong>Zsh + Power Level 10k</strong></summary>

You can use [Power Level 10k](https://github.com/romkatv/powerlevel10k) as your Zsh theme by installing it and creating a custom file, e.g., `~/.zsh/custom/p10k.zsh`, with the following content:

```sh
# Source Power Level 10k 💡
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# 💡

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[ ! -f ~/.p10k.zsh ] || source ~/.p10k.zsh
```

This file will be automatically sourced.

</details>

<details>
<summary><strong>Zsh + Oh My Zsh</strong></summary>

To customize your dotfiles setup to use Oh My Zsh, you can follow these steps:

1. Install Oh My Zsh by running the following command in your terminal:

```shell
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

2. Once Oh My Zsh is installed, you can create a custom file, e.g., `~/.zsh/custom/oh-my-zsh.zsh`, with the following content:

```shell
# Load Oh My Zsh
export ZSH="/your/oh-my-zsh/path"

source "$ZSH/oh-my-zsh.sh"
```

Make sure to replace `/your/oh-my-zsh/path` with the actual path to your Oh My Zsh installation directory.

3. Additionally, you can customize your Oh My Zsh configuration by creating or modifying the `.zshrc` file in your home directory. This file will be automatically sourced when you open a shell.

4. Restart your terminal or open a new shell session to apply the changes. Oh My Zsh should now be active, and your customizations will take effect.

With these steps, you can easily integrate Oh My Zsh into your dotfiles setup and take advantage of its powerful features and community-driven plugins and themes.

Feel free to explore the Oh My Zsh documentation and customize your shell experience to suit your needs and preferences. Happy customizing! ✨🚀

</details>
