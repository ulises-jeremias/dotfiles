# 🔄 Template Repository Plan

This document outlines the minimal changes needed to create a forkable/template version of this dotfiles repository that can be used by anyone as a starting point for their own dotfiles.

## 🎯 Objective

Create a template repository that:

- Removes personal/specific configurations
- Maintains the core functionality and structure
- Can be easily synchronized with the main repository for updates
- Requires minimal user customization to get started

---

## 📋 Required Changes

### 1. 🔐 **Remove Personal Credentials & Services**

#### LastPass Integration

- **File**: `home/dot_config/private_credentials/`
- **Action**: Remove LastPass-specific credential templates
- **Replace with**: Generic credential template examples
- **Impact**: Users can choose their own password manager

#### Personal API Keys

- **Files**: Any templates with hardcoded API keys
- **Action**: Replace with placeholder values
- **Example**: `OPENWEATHER_API_KEY=your_api_key_here`

#### SSH Keys & Git Configuration

- **Files**: `home/private_dot_ssh/`, `home/dot_config/git/`
- **Action**: Remove personal SSH keys, replace git config with placeholders
- **Replace with**: Template files with `{{.name}}`, `{{.email}}` variables

### 2. 🏠 **Generalize Personal Paths & Settings**

#### Home Directory References

- **Files**: Any scripts or configs with `/home/ulisesjcf/`
- **Action**: Replace with `$HOME` or chezmoi variables
- **Impact**: Works for any username

#### Personal Preferences

- **Files**: Theme configurations, wallpapers, personal shortcuts
- **Action**: Use neutral/default themes and generic wallpapers
- **Keep**: Core functionality, just change aesthetics

### 3. 📱 **Hardware-Specific Configurations**

#### Graphics Card Settings

- **Files**: NVIDIA-specific configurations
- **Action**: Make graphics drivers optional/conditional
- **Implementation**: Use chezmoi conditionals based on hardware detection

#### Network Configurations

- **Files**: NetworkManager profiles, WiFi configurations
- **Action**: Remove personal network profiles
- **Replace with**: Generic examples

### 4. 🎨 **Default Themes & Wallpapers**

#### Personal Images

- **Files**: `static/anime-girl-screen.png`, custom wallpapers
- **Action**: Replace with neutral/generic backgrounds
- **Keep**: Same image formats and resolution requirements

#### Custom Color Schemes

- **Files**: Personal rice configurations
- **Action**: Provide 2-3 generic rice options as examples
- **Impact**: Users can still customize, but starts with neutral themes

---

## 🔧 Implementation Strategy

### Phase 1: Core Sanitization

1. **Audit sensitive files**: Scan for personal data, credentials, hardcoded paths
2. **Create template variables**: Replace personal info with chezmoi variables
3. **Genericize configurations**: Make hardware/service-specific configs optional

### Phase 2: Documentation Updates

1. **Update README**: Add template-specific setup instructions
2. **Create SETUP.md**: Step-by-step guide for new users
3. **Update wiki**: Remove personal references, add generic examples

### Phase 3: Automation & Scripts

1. **Update install scripts**: Make them work for any user
2. **Add setup wizard**: Interactive script to configure personal settings
3. **Template initialization**: Script to replace placeholders with user data

---

## 📁 File-by-File Changes

### High Priority (Personal Data)

```
home/dot_config/private_credentials/     → Remove/template
home/private_dot_ssh/                    → Remove personal keys
home/dot_gitconfig.tmpl                  → Use {{.name}}/{{.email}}
home/dot_zsh_aliases.tmpl               → Remove personal aliases
static/personal-images/                  → Replace with generic
```

### Medium Priority (Preferences)

```
home/dot_config/polybar/                → Default themes only
home/dot_config/rofi/                   → Generic themes
home/dot_config/i3/                     → Remove personal shortcuts
home/dot_config/kitty/                  → Default color schemes
```

### Low Priority (Documentation)

```
docs/wiki/                              → Update examples
README.md                               → Template instructions
CONTRIBUTING.md                         → Generic guidelines
```

---

## 🔄 Synchronization Strategy

### Sync Process

1. **Core updates** (scripts, features) → Apply to both repositories
2. **Personal changes** → Stay in main repository only
3. **Template improvements** → Cherry-pick to main dotfiles repo if applicable

### Automation

```bash
# Script to sync core changes
./scripts/sync-template.sh
```

---

## 🚀 Template Repository Features

### What Users Get

- ✅ Complete dotfiles framework
- ✅ All utility scripts and tools
- ✅ Security audit and backup systems
- ✅ Comprehensive documentation
- ✅ Easy customization system

### What Users Need to Configure

- 🔧 Personal information (name, email)
- 🔧 API keys for services they use
- 🔧 Preferred themes and wallpapers
- 🔧 Hardware-specific settings
- 🔧 Service integrations (password managers, etc.)

### Setup Wizard (Proposed)

```bash
# Interactive setup for new users
./scripts/setup-template.sh

# Prompts for:
# - Name and email
# - Preferred password manager
# - Theme preferences
# - Hardware type (NVIDIA/AMD/Intel)
# - Services to enable
```

---

## 📝 Documentation Updates

### New Files Needed

1. **TEMPLATE_SETUP.md** - Template-specific setup guide
2. **CUSTOMIZATION.md** - How to personalize the template
3. **SERVICES.md** - Optional service integrations guide
4. **HARDWARE.md** - Hardware-specific configuration guide

### Updated Files

1. **README.md** - Add template usage instructions
2. **Security.md** - Generic security recommendations
3. **Wiki pages** - Remove personal examples

---

## 🎯 Success Criteria

### User Experience

- [ ] New user can set up dotfiles in < 30 minutes
- [ ] No personal data exposed in template
- [ ] All core features work out-of-the-box
- [ ] Easy customization process

### Maintainability

- [ ] Core changes sync easily between repositories
- [ ] Template stays up-to-date with main features
- [ ] Clear separation between personal and generic configs
- [ ] Automated testing for template functionality

### Community

- [ ] Clear contribution guidelines
- [ ] Example configurations for popular use cases
- [ ] Active issue templates and support
- [ ] Documentation for extending the system

---

## 🔮 Future Considerations

### Advanced Features

- **Multi-OS support**: Conditional configs for different Linux distros
- **Profile system**: Gaming, work, development profiles
- **Cloud sync**: Optional cloud backup integration
- **Community themes**: Repository of community-contributed themes

### Automation

- **GitHub Actions**: Automatic template testing
- **Bot integration**: Sync updates from main repository
- **Release management**: Tagged releases for stable versions

---

## ⚡ Quick Start Implementation

### Immediate Actions (Week 1)

1. Create `dotfiles-template` repository.
2. Remove all personal credentials and data
3. Add chezmoi variables for user information
4. Update README with template instructions

### Short Term (Month 1)

1. Complete file sanitization
2. Create setup wizard script
3. Update all documentation
4. Test with fresh user accounts

### Long Term (Ongoing)

1. Establish sync workflow
2. Community feedback integration
3. Advanced features development
4. Maintenance and updates

This plan ensures the template version maintains all the powerful features of your dotfiles while being accessible and safe for public use.
