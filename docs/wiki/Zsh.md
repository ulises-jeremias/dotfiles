# 🌀 Zsh Configuration Guide

Zsh (Z Shell) is a powerful, interactive shell that offers advanced features, extensive customization, and a vibrant ecosystem of plugins and themes.

> [!TIP]
> Everything in this setup is fully customizable. From themes, prompts, plugins, to aliases and functions — you’re in control. All configuration lives in your dotfiles and is managed through chezmoi.

---

## ⚙️ Configuration Files Location

Zsh is configured using a modular structure inside:

```sh
~/.zsh/config.d/
```

Every `.zsh` file inside this folder is automatically sourced on shell startup.

To edit files using chezmoi:

```sh
chezmoi edit ~/.zsh/config.d/yourfile.zsh --source ~/.dotfiles
```

Apply changes with:

```sh
chezmoi apply
```

> [!TIP]
> Use separate files for aliases, plugins, and theme settings for better organization.

---

## 🔧 What You Can Customize

- **Prompt themes** (e.g., Powerlevel10k)
- **Plugin managers** (e.g., Antigen, Oh My Zsh)
- **Aliases and shell functions**
- **Autocompletion and syntax highlighting**
- **Environment variables**

---

## 🎨 Prompt Themes

### Powerlevel10k

To use [Powerlevel10k](https://github.com/romkatv/powerlevel10k):

1. Install the theme
2. Create a config file:

```sh
chezmoi edit ~/.zsh/config.d/p10k.zsh
```

```zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[ ! -f ~/.p10k.zsh ] || source ~/.p10k.zsh
```

Run `p10k configure` to customize your prompt interactively.

---

## 🔌 Plugin Managers

### Antigen

[Antigen](https://github.com/zsh-users/antigen) allows you to load and manage plugins easily:

```sh
curl -L git.io/antigen > ~/.antigen.zsh
```

```zsh
# ~/.zsh/config.d/antigen.zsh
source "$HOME/.antigen.zsh"
antigen apply
```

### Oh My Zsh

Install with:

```sh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Configure in:

```zsh
# ~/.zsh/config.d/oh-my-zsh.zsh
export ZSH="/your/oh-my-zsh/path"
source "$ZSH/oh-my-zsh.sh"
```

---

## 📁 Structure and Recommendations

We recommend keeping your customizations modular:

- `aliases.zsh`: command shortcuts
- `functions.zsh`: reusable shell functions
- `theme.zsh`: your theme settings
- `plugins.zsh`: plugin manager logic

This keeps your configuration clean and easy to maintain.

---

## 🧪 Testing Changes

After editing your configuration:

```sh
source ~/.zshrc
```

Or simply open a new terminal tab/session.

> [!TIP]
> Use `zsh -x` to debug issues during shell startup.

---

## 🆘 Need Help?

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/Release/)
- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Zsh is not just a shell — it’s a productivity tool. Customize it to reflect your style and workflow! ⚡
