# Contributing to HorneroConfig

> **Welcome!** 👋 We're thrilled you're interested in contributing to HorneroConfig. This guide will help you get started.

---

## 🌟 Ways to Contribute

There are many ways to contribute to HorneroConfig, and all of them are valuable:

### 💬 Share Your Experience

- **Star the repository** ⭐ - Show your support
- **Share on social media** - Help others discover HorneroConfig
- **Write blog posts** - Share your setup and customizations
- **Answer questions** - Help others in discussions and issues

### 🐛 Report Issues

Found a bug or have an idea? We want to hear about it!

- **Bug reports** - Help us improve stability and reliability
- **Feature requests** - Suggest new capabilities and enhancements
- **Documentation improvements** - Help us explain things better
- **Rice themes** - Share your beautiful theme creations

### 💻 Contribute Code

- **Fix bugs** - Tackle open issues
- **Add features** - Implement new capabilities
- **Improve performance** - Optimize existing code
- **Enhance documentation** - Write guides and tutorials

### 🎨 Create Content

- **Design rice themes** - Create beautiful desktop themes
- **Make wallpapers** - Contribute artwork
- **Create tutorials** - Help others learn
- **Record demos** - Show off features in action

---

## 🚀 Getting Started

### Prerequisites

Before you start, make sure you have:

- A GitHub account
- Git installed on your system
- Basic familiarity with shell scripting (for code contributions)
- A Linux system for testing (preferably Arch Linux)

### Setting Up Your Development Environment

1. **Fork the repository** on GitHub

2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/dotfiles ~/.dotfiles
   cd ~/.dotfiles
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ulises-jeremias/dotfiles
   ```

4. **Install dependencies**:
   ```bash
   ./install.sh
   ```

5. **Set up pre-commit hooks** (required for contributors):

   We use [pre-commit](https://pre-commit.com/) to maintain code quality. Install it with [pipx](https://pipx.pypa.io/) (recommended):

   ```bash
   # Install pipx if not already installed
   # Arch Linux:
   sudo pacman -S python-pipx

   # Ubuntu/Debian:
   sudo apt install pipx && pipx ensurepath

   # macOS:
   brew install pipx && pipx ensurepath

   # Install pre-commit
   pipx install pre-commit

   # Set up git hooks in the repository
   pre-commit install

   # Test it works
   pre-commit run --all-files
   ```

   **What pre-commit does:**
   - ✅ Validates shell scripts with ShellCheck
   - ✅ Formats shell scripts with shfmt
   - ✅ Lints Markdown files
   - ✅ Validates YAML syntax
   - ✅ Checks for security issues (private keys, etc.)
   - ✅ Validates custom dots scripts
   - ✅ Prevents direct commits to main branch

6. **Test in the playground** (recommended):
   ```bash
   ./bin/play
   ```

---

## 🐛 Reporting Bugs

### Before Submitting

- **Search existing issues** - Your bug might already be reported
- **Try the latest version** - The issue might already be fixed
- **Test in playground** - Verify it's reproducible in a clean environment

### Creating a Good Bug Report

Use our [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) and include:

1. **Clear title** - Briefly describe the issue
2. **Environment details** - OS, window manager, versions
3. **Steps to reproduce** - What did you do?
4. **Expected behavior** - What should happen?
5. **Actual behavior** - What actually happened?
6. **Screenshots** - Visual evidence helps immensely
7. **Error messages** - Include relevant logs

**Example:**

> **Title:** Polybar weather module shows wrong temperature
>
> **Environment:** Arch Linux, i3wm, Polybar 3.6.3
>
> **Steps:**
> 1. Apply gruvbox-anime rice
> 2. Check weather module on polybar
> 3. Compare with actual weather
>
> **Expected:** Should show current temperature (72°F)
> **Actual:** Shows 32°F (last cached value)
>
> **Logs:** `~/.cache/dots/weather.log` shows API timeout

---

## 💡 Suggesting Features

### Before Submitting

- **Check existing suggestions** - Someone might have had the same idea
- **Consider the scope** - Does it fit HorneroConfig's philosophy?
- **Think about impact** - How would this benefit users?

### Creating a Feature Request

Use our [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) and include:

1. **Clear title** - What's the feature?
2. **Problem statement** - What need does this address?
3. **Proposed solution** - How should it work?
4. **Alternatives** - What other approaches did you consider?
5. **Additional context** - Screenshots, mockups, examples

**Example:**

> **Title:** Add support for Wayland compositors
>
> **Problem:** HorneroConfig currently only supports X11 window managers
>
> **Solution:** Add configuration profiles for Sway and Hyprland
>
> **Alternatives:**
> - Create a separate project for Wayland
> - Provide documentation for manual Wayland setup
>
> **Context:** Many users are moving to Wayland for better security and performance

---

## 🔧 Contributing Code

### The Contribution Process

1. **Discuss first** for significant changes
   - Open an issue to propose your idea
   - Get feedback from maintainers
   - Agree on implementation approach

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style and patterns
   - Write clear commit messages
   - Test thoroughly in the playground

4. **Commit with meaningful messages**:
   ```bash
   git commit -m "feat: add spotify integration to music player module"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Use the PR template
   - Describe what changed and why
   - Link related issues
   - Add screenshots for visual changes

### Code Style Guidelines

**For detailed technical guidelines:**
- Quick reference: [AGENTS.md](AGENTS.md)
- Comprehensive guides: [docs/](docs/)
  - [Development Standards](docs/Development-Standards.md) - Script templates and standards
  - [Architecture Philosophy](docs/Architecture-Philosophy.md) - Design principles
  - [Integration Patterns](docs/Integration-Patterns.md) - Best practices
  - [Security Guidelines](docs/Security-Guidelines.md) - Security requirements
  - [Performance Guidelines](docs/Performance-Guidelines.md) - Optimization tips

Here are the key principles:

- **Follow existing patterns** - Look at similar code for examples
- **Keep it simple** - Readable code is better than clever code
- **Write comments** - Explain the "why", not just the "what"
- **Test your changes** - Use the playground environment
- **Check with shellcheck** - Lint your shell scripts
- **Handle errors gracefully** - Don't leave users confused

### Commit Message Format

We follow conventional commits for clarity:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**
```
feat: add weather forecast to polybar module
fix: correct color contrast in light themes
docs: update installation guide for Ubuntu
refactor: simplify smart colors caching logic
```

---

## 🎨 Creating Rice Themes

Want to share your beautiful desktop theme? Here's how:

### Rice Theme Structure

Create a new directory in `home/dot_local/share/dots/rices/`:

```
your-rice-name/
├── config.sh          # Theme configuration
├── apply.sh           # Application script
├── backgrounds/       # Wallpaper images
├── preview.png        # Theme preview (required)
└── README.md          # Theme description (optional)
```

### What to Include

**config.sh** - Theme settings:
```bash
#!/usr/bin/env bash

# Rice metadata
RICE_NAME="your-rice-name"
RICE_DESCRIPTION="Brief description of your theme"

# Polybar configuration
POLYBAR_PROFILE="default"  # or "minimal"

# GTK theme
GTK_THEME="Orchis-Dark-Compact"
ICON_THEME="Papirus-Dark"

# Optional: Window manager specific settings
I3_GAPS_INNER=10
I3_GAPS_OUTER=5
```

**apply.sh** - Setup script:
```bash
#!/usr/bin/env bash

# Load rice configuration
RICE_DIR="$(dirname "$(readlink -f "$0")")"
source "${RICE_DIR}/config.sh"

# Your customization logic here
# Set wallpaper, apply colors, configure apps, etc.
```

**backgrounds/** - At least one high-quality wallpaper

**preview.png** - Screenshot showcasing your theme (recommended: 1920x1080)

### Submitting Your Rice

1. Create your rice theme directory
2. Test it thoroughly:
   ```bash
   dots rice apply your-rice-name
   ```
3. Take beautiful screenshots
4. Submit a PR with:
   - Your rice files
   - Preview screenshot
   - Description of the theme's aesthetic
   - Any special requirements or dependencies

---

## 🧪 Testing Your Changes

### Using the Playground

The playground provides a safe testing environment:

```bash
# Start default environment
./bin/play

# Test with specific window manager
./bin/play --provision i3
./bin/play --provision openbox

# Clean up when done
./bin/play --remove
```

### What to Test

**For all changes:**
- Does it work as intended?
- Does it handle errors gracefully?
- Does it work in both light and dark themes?
- Does it work with different window managers?

**For visual changes:**
- Does it look good in all rice themes?
- Are colors appropriate and readable?
- Does it scale properly on different resolutions?
- Does it work on multiple monitors?

**For scripts:**
- Does it handle missing dependencies?
- Does it clean up after itself?
- Does it log appropriately?
- Does shellcheck pass?

---

## 📝 Documentation Contributions

Good documentation helps everyone! You can help by:

### Types of Documentation

- **Wiki pages** - Comprehensive guides and tutorials
- **Code comments** - Explain complex logic
- **README updates** - Keep main docs current
- **ADRs** - Document architectural decisions
- **Examples** - Show how to use features

### Documentation Style

- **Be clear and concise** - Get to the point
- **Use examples** - Show, don't just tell
- **Add screenshots** - Visuals help understanding
- **Link related docs** - Help users find more info
- **Test your instructions** - Make sure they actually work

---

## 📁 Repository Structure

Understanding the repository layout helps you navigate:

```
.
├── .github/               # GitHub workflows, templates, copilot instructions
├── docs/                  # Documentation and wiki content
│   ├── adrs/             # Architecture Decision Records
│   ├── images/           # Documentation images
│   └── wiki/             # Wiki pages
├── home/                  # Chezmoi-managed dotfiles
│   ├── dot_config/       # ~/.config/ files
│   ├── dot_local/        # ~/.local/ files
│   │   ├── bin/          # Executable scripts
│   │   ├── lib/          # Shared libraries
│   │   └── share/        # Rice themes, data files
│   └── dot_zsh/          # Zsh configuration
├── playground/            # Testing environment (Vagrant/Docker)
├── scripts/              # Installation and validation scripts
├── bin/                  # Utility scripts (play, etc.)
└── AGENTS.md             # AI agent guidelines (technical details)
```

### Key Files

- `CONTRIBUTING.md` (this file) - Human contribution guide
- `AGENTS.md` - AI agent quick reference
- `README.md` - Project overview and features
- `install.sh` - Installation script
- `docs/` - Technical documentation and architecture guides
  - `Architecture-Philosophy.md` - Core design principles
  - `System-Architecture.md` - Detailed system components
  - `Development-Standards.md` - Coding standards and templates
  - `Integration-Patterns.md` - Integration best practices
  - `Testing-Strategy.md` - Testing approach and requirements
  - `Security-Guidelines.md` - Security practices
  - `Performance-Guidelines.md` - Optimization strategies

---

## 🤝 Community Guidelines

### Our Values

- **Respect** - Treat everyone with kindness and professionalism
- **Inclusivity** - Welcome contributors of all skill levels
- **Collaboration** - Work together to solve problems
- **Quality** - Strive for excellence in everything
- **Fun** - Enjoy the creative process!

### Code of Conduct

We follow a [Code of Conduct](.github/CODE_OF_CONDUCT.md). By participating, you agree to uphold this code. Report unacceptable behavior to the maintainers.

### Getting Help

- **GitHub Discussions** - Ask questions, share ideas
- **Issues** - Report bugs and request features
- **Wiki** - Comprehensive documentation
- **Examples** - Learn from existing code

---

## 🎯 Finding Something to Work On

Not sure where to start? Try these:

### Good First Issues

Look for issues labeled:
- `good first issue` - Perfect for beginners
- `help wanted` - Maintainers would appreciate help
- `documentation` - Improve docs (no coding required)
- `enhancement` - New feature requests

### Popular Contribution Areas

- **Polybar modules** - Add new system monitors or integrations
- **Rice themes** - Create beautiful desktop themes
- **Documentation** - Write guides and tutorials
- **Bug fixes** - Tackle open bug reports
- **Testing** - Improve test coverage
- **Performance** - Optimize slow operations

---

## ✅ Pull Request Checklist

Before submitting your PR, verify:

- [ ] Code follows existing patterns and style
- [ ] All scripts pass shellcheck
- [ ] Changes tested in playground environment
- [ ] Works in both light and dark themes (if applicable)
- [ ] Documentation updated (if needed)
- [ ] Commit messages follow conventional format
- [ ] PR description explains what and why
- [ ] Screenshots included (for visual changes)
- [ ] Related issues linked

---

## 🎓 Learning Resources

### For Contributors

- **[AGENTS.md](AGENTS.md)** - AI agent quick reference
- **[Technical Documentation](docs/)** - Comprehensive guides
  - [Architecture Philosophy](docs/Architecture-Philosophy.md)
  - [System Architecture](docs/System-Architecture.md)
  - [Development Standards](docs/Development-Standards.md)
  - [Integration Patterns](docs/Integration-Patterns.md)
  - [Testing Strategy](docs/Testing-Strategy.md)
  - [Security Guidelines](docs/Security-Guidelines.md)
  - [Performance Guidelines](docs/Performance-Guidelines.md)
- **[ADRs](docs/adrs/)** - Understand architectural decisions
- **[Wiki](docs/wiki/)** - In-depth feature documentation
- **Existing code** - Best examples are in the codebase

### External Resources

- [Google Shell Style Guide](https://google.github.io/styleguide/shellxml)
- [Chezmoi Documentation](https://www.chezmoi.io/)
- [i3 User's Guide](https://i3wm.org/docs/userguide.html)
- [Polybar Wiki](https://github.com/polybar/polybar/wiki)

---

## 💖 Thank You!

Every contribution, no matter how small, makes HorneroConfig better. We appreciate your time and effort!

**Questions?** Feel free to ask in discussions or issues. We're here to help! 🚀

---

## 📧 Contact

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and general chat
- **Pull Requests**: Code contributions
- **Email**: For private concerns (see repository owner profile)

---

*Built with ❤️ by the HorneroConfig community*
