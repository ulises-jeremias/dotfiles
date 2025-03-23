# 🧨 Dots Eject Guide

While [Chezmoi](https://www.chezmoi.io/) is a powerful and recommended tool for managing dotfiles across multiple systems, we understand that some users may prefer to maintain their own independent distribution.

> [!TIP]
> This guide helps you **eject from chezmoi** and take full manual control of your dotfiles — useful for advanced users or custom workflows.

---

## 🚀 Why Use Chezmoi?

Chezmoi offers:

- 🔁 Synchronization of dotfiles across machines
- 🧼 Separation of source/config vs. applied state
- 🔐 Secret management
- 🔧 Easy templating and onboarding of new environments

But if you no longer wish to use chezmoi, you can safely eject.

---

## 📦 How to Eject from Chezmoi

Follow the official guide here:
👉 [Migrate away from chezmoi](https://www.chezmoi.io/user-guide/advanced/migrate-away-from-chezmoi/)

The process includes:

1. Applying all changes to your home directory:

   ```sh
   chezmoi apply
   ```

2. Copying the real files to a new git-tracked directory:

   ```sh
   mkdir ~/my-dotfiles
   chezmoi managed --include=all | xargs -I {} cp --parents {} ~/my-dotfiles/
   cd ~/my-dotfiles && git init
   ```

3. Removing chezmoi from your workflow:

   ```sh
   sudo pacman -Rns chezmoi  # or appropriate command for your distro
   ```

Now you're managing your dotfiles fully manually or with your own tooling.

---

## 🧠 Things to Consider Before Ejecting

- ✅ Are you managing secrets that chezmoi helps encrypt?
- ✅ Do you still want templating, or are static files fine?
- ✅ Do you want a clean separation between machine-specific and shared config?

If the answer is “no” or “you want full control,” ejecting is a valid next step.

---

## 🆘 Need Help?

- [Chezmoi Docs](https://www.chezmoi.io/)
- [Dotfiles Discussions](https://github.com/ulises-jeremias/dotfiles/discussions)

Whether you stay with chezmoi or go fully manual, the goal is the same: **dotfiles that reflect your ideal workflow**. Choose the path that works best for you. 🛠️
