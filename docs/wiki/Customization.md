# 🎨 Dotfiles Customization Guide

This repository is designed to be a starting point for your personalized dotfiles setup. You’re encouraged to **fork it**, adapt it to your needs, and maintain your own GitHub repository with your custom configurations.

> [!TIP]
> The dotfiles use [Chezmoi](https://www.chezmoi.io/) to manage, edit, and apply configuration changes across multiple machines — securely and efficiently.

---

## 🛠️ Getting Started with Customization

### 1. Fork This Repository

Create your own version of the dotfiles:

```sh
git clone https://github.com/<your-username>/dotfiles.git ~/.dotfiles
```

### 2. Initialize Chezmoi

> [!IMPORTANT]
> This dotfiles setup includes references to my personal LastPass vault for storing sensitive information (like tokens or secrets).  
> If you plan to use or adapt these configs, make sure to **replace or remove** any references to LastPass and configure your own preferred secret management method — such as Bitwarden, 1Password, `pass`, `gopass`, or `chezmoi's built-in encrypted secrets`.  
> Double-check any scripts or encrypted templates (`*.tmpl`) before applying changes.

Link your forked dotfiles directory with chezmoi:

```sh
chezmoi init --source ~/.dotfiles
```

### 3. Edit Your Configurations

Use chezmoi’s built-in editing command:

```sh
chezmoi edit --source ~/.dotfiles
```

Make the changes that suit your preferences:

- Theme and style adjustments
- New keybindings
- Custom scripts
- Tool settings and plugins

### 4. Apply Your Changes

Once you're ready:

```sh
chezmoi apply --source ~/.dotfiles
```

All changes will be synced to your system.

---

## 📁 What You Can Customize

- 🌊 Compositor settings (Hyprland)
- 💻 Terminal experience (Zsh, Kitty)
- 🎨 Theme and color schemes (Quickshell M3, pywal, smart colors)
- 🛠️ Utility scripts (`dots`) and workflow helpers
- 🔒 Security tools and system behaviors

> [!TIP]
> Use `chezmoi diff` to preview your changes before applying.

---

## 🎨 Theming & Visual Customization

### Smart Colors System

The dotfiles include an **intelligent color system** that automatically optimizes colors for any theme:

- **Semantic Colors**: Error, success, warning, info colors that adapt to any palette
- **Theme Intelligence**: Automatically selects optimal colors based on wallpaper
- **Application Integration**: Works with Hyprland, Quickshell, terminals, and custom scripts
- **Automatic Updates**: Colors refresh automatically when changing wallpapers

Learn more: [Smart Colors System](Smart-Colors-System)

### Theme Pack Management

---

## 🌍 Multi-Machine Consistency

One of the biggest advantages of using Chezmoi is **portable configuration**. You can sync your setup across multiple machines using a private or public GitHub repository.

Just run:

```sh
chezmoi init git@github.com:<your-username>/dotfiles.git
chezmoi apply
```

And your personalized setup will be ready!

---

## 🆘 Need Help?

- [Chezmoi Docs](https://www.chezmoi.io/docs/)
- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Go ahead — personalize everything. Make your desktop, terminal, and tooling truly yours! 🚀
