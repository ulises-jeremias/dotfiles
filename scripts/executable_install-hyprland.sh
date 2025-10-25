#!/usr/bin/env bash
# ============================================================================
# Hyprland Installation Script
# ============================================================================
#
# Installs Hyprland and all required dependencies for HorneroConfig
# ============================================================================

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
  echo -e "${CYAN}==>${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}!${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

# Check if running on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
  print_error "This script is designed for Arch Linux"
  exit 1
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
  print_error "Do not run this script as root"
  exit 1
fi

print_step "Installing Hyprland and dependencies..."

# ============================================================================
# Core packages
# ============================================================================
CORE_PACKAGES=(
  # Compositor
  hyprland
  xdg-desktop-portal-hyprland

  # Status bar
  waybar

  # Application launcher
  rofi-lbonn-wayland-git # AUR - Wayland-native Rofi

  # Notifications
  mako
  libnotify

  # Screen locking
  swaylock-effects
  hypridle

  # Screenshots
  grim
  slurp
  swappy

  # Wallpaper
  swaybg
  hyprpaper

  # Clipboard
  wl-clipboard
  cliphist

  # Terminal (if not installed)
  kitty

  # File manager (if not installed)
  thunar

  # Utilities
  brightnessctl
  playerctl
  pamixer

  # System tray apps
  network-manager-applet
  blueman
  pavucontrol

  # Fonts
  ttf-jetbrains-mono-nerd
  ttf-font-awesome
  noto-fonts-emoji

  # Theme components
  qt5-wayland
  qt6-wayland
  gtk3
  gtk4

  # Dependencies for existing tools
  polkit-gnome
  xfce4-settings

  # Video bridge for screen sharing
  xwaylandvideobridge
)

# ============================================================================
# Optional packages (NVIDIA support)
# ============================================================================
NVIDIA_PACKAGES=(
  nvidia-dkms
  nvidia-utils
  libva
  libva-nvidia-driver-git
)

# ============================================================================
# AUR packages
# ============================================================================
AUR_PACKAGES=(
  rofi-lbonn-wayland-git
  hyprpicker
  wlogout
)

# Install paru if not present (AUR helper)
if ! command -v paru &>/dev/null; then
  print_step "Installing paru (AUR helper)..."

  cd /tmp
  git clone https://aur.archlinux.org/paru.git
  cd paru
  makepkg -si --noconfirm
  cd ..
  rm -rf paru

  print_success "Paru installed"
fi

# Update system
print_step "Updating system..."
sudo pacman -Syu --noconfirm

# Install core packages
print_step "Installing core packages..."
for package in "${CORE_PACKAGES[@]}"; do
  if pacman -Qi "$package" &>/dev/null; then
    print_success "$package already installed"
  else
    if sudo pacman -S --noconfirm "$package" 2>/dev/null; then
      print_success "Installed $package"
    else
      print_warning "Could not install $package from repos, trying AUR..."
      paru -S --noconfirm "$package" || print_warning "Failed to install $package"
    fi
  fi
done

# Ask about NVIDIA
echo ""
read -p "Do you have an NVIDIA GPU? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  print_step "Installing NVIDIA packages..."

  for package in "${NVIDIA_PACKAGES[@]}"; do
    if pacman -Qi "$package" &>/dev/null; then
      print_success "$package already installed"
    else
      paru -S --noconfirm "$package" || print_warning "Failed to install $package"
    fi
  done

  print_success "NVIDIA packages installed"
  print_warning "Remember to enable DRM kernel mode setting in your kernel parameters"
  print_warning "Add 'nvidia_drm.modeset=1' to your bootloader configuration"
fi

# Install AUR packages
print_step "Installing AUR packages..."
for package in "${AUR_PACKAGES[@]}"; do
  if pacman -Qi "${package%-git}" &>/dev/null || pacman -Qi "$package" &>/dev/null; then
    print_success "$package already installed"
  else
    paru -S --noconfirm "$package" || print_warning "Failed to install $package"
  fi
done

# Enable services
print_step "Enabling services..."
systemctl --user enable --now pipewire.service
systemctl --user enable --now pipewire-pulse.service
systemctl --user enable --now wireplumber.service

print_success "Hyprland installation complete!"

echo ""
print_step "Next steps:"
echo "  1. Log out and select 'Hyprland' from your display manager"
echo "  2. Or add 'exec Hyprland' to your ~/.xinitrc and run 'startx'"
echo "  3. Run 'dots rice-select' to choose a theme"
echo ""
print_warning "Note: Some applications may need to be restarted for Wayland support"
