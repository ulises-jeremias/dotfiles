# NVIDIA Troubleshooting Guide (Arch Linux)

This guide provides comprehensive troubleshooting steps for NVIDIA-related issues on Arch Linux, including driver installation, hybrid GPU setups, and solutions for common problems such as black screens or GPU conflicts.

---

## Table of Contents

- [NVIDIA Troubleshooting Guide (Arch Linux)](#nvidia-troubleshooting-guide-arch-linux)
  - [Table of Contents](#table-of-contents)
  - [Driver Installation](#driver-installation)
    - [Blacklisting Nouveau](#blacklisting-nouveau)
    - [Choosing Between `nvidia` and `nvidia-dkms`](#choosing-between-nvidia-and-nvidia-dkms)
  - [Common Issues](#common-issues)
    - [Black Screen After Login](#black-screen-after-login)
    - [Internal Display Not Detected (on Laptops)](#internal-display-not-detected-on-laptops)
    - [GTK Apps Freezing or Blank](#gtk-apps-freezing-or-blank)
    - [No NVIDIA Processes Detected](#no-nvidia-processes-detected)
  - [Diagnostic Commands](#diagnostic-commands)
  - [Hybrid GPU Setup (Intel + NVIDIA)](#hybrid-gpu-setup-intel--nvidia)
  - [Quick Recovery Checklist](#quick-recovery-checklist)
  - [Useful Links](#useful-links)
  - [Additional Resources](#additional-resources)

---

## Driver Installation

### Blacklisting Nouveau

The open-source `nouveau` driver can conflict with the proprietary NVIDIA driver. To disable it:

1. Create a modprobe blacklist file:

   ```bash
   sudo nano /etc/modprobe.d/blacklist-nouveau.conf
   ```

2. Add the following lines:

   ```conf
   blacklist nouveau
   options nouveau modeset=0
   ```

3. Regenerate the initramfs:

   ```bash
   sudo mkinitcpio -P
   ```

4. Reboot:

   ```bash
   sudo reboot
   ```

---

### Choosing Between `nvidia` and `nvidia-dkms`

| Package       | Description                                   | Use When...                                        |
| ------------- | --------------------------------------------- | -------------------------------------------------- |
| `nvidia`      | Precompiled for stock Arch kernel             | You're using the standard `linux` kernel           |
| `nvidia-dkms` | Builds driver per installed kernel (via DKMS) | You're using `linux-lts`, `zen`, or custom kernels |

Installation examples:

```bash
# For standard kernel
sudo pacman -S nvidia

# For DKMS version
sudo pacman -S nvidia-dkms
```

---

## Common Issues

### Black Screen After Login

- Check NVIDIA modules:

  ```bash
  lsmod | grep nvidia
  ```

- Check Xorg logs:

  ```bash
  cat /var/log/Xorg.0.log | grep nvidia
  ```

- Confirm kernel parameters:

  ```bash
  cat /proc/cmdline
  ```

- Ensure `nvidia-drm.modeset=1` is passed:

  - For GRUB: edit `/etc/default/grub` and run `sudo grub-mkconfig -o /boot/grub/grub.cfg`
  - For systemd-boot with UKI: add `--cmdline 'nvidia-drm.modeset=1'` in your `mkinitcpio.preset`

---

### Internal Display Not Detected (on Laptops)

- Check current outputs:

  ```bash
  xrandr
  ```

- Try enabling the internal panel:

  ```bash
  xrandr --output eDP-1 --auto
  ```

- Open NVIDIA Settings GUI:

  ```bash
  nvidia-settings
  ```

> [!TIP]
> This usually happens if the internal display is wired through the Intel iGPU and `i915` was blacklisted.

---

### GTK Apps Freezing or Blank

- Check OpenGL status:

  ```bash
  glxinfo | grep "OpenGL renderer"
  ```

- Ensure `nvidia-utils` and `mesa` are installed.

- Disable compositing (especially in i3, bspwm, etc.)

---

### No NVIDIA Processes Detected

- Check:

  ```bash
  nvidia-smi
  lsmod | grep nvidia
  journalctl -b | grep -i nvidia
  ```

- Ensure `nvidia-persistenced` is running if needed:

  ```bash
  systemctl status nvidia-persistenced
  ```

---

## Diagnostic Commands

```bash
# Check which GPUs are present
lspci -k | grep -A 2 -E "(VGA|3D)"

# Verify modules
lsmod | grep -E 'nvidia|nouveau|i915'

# GPU renderer info
glxinfo | grep "OpenGL renderer"

# Display detection
xrandr

# NVIDIA status
nvidia-smi
nvidia-settings

# Kernel log
journalctl -b | grep -i nvidia
```

---

## Hybrid GPU Setup (Intel + NVIDIA)

If your laptop uses both an integrated Intel GPU and a dedicated NVIDIA GPU:

1. Install required packages:

   ```bash
   sudo pacman -S nvidia nvidia-utils nvidia-settings xf86-video-intel mesa
   ```

2. Create `/etc/modprobe.d/nvidia.conf`:

   ```conf
   options nvidia-drm modeset=1
   ```

3. For GRUB: edit `/etc/default/grub`:

   ```text
   GRUB_CMDLINE_LINUX_DEFAULT="quiet nvidia-drm.modeset=1"
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```

4. For systemd-boot with UKI:

   - Add `--cmdline 'nvidia-drm.modeset=1'` to your preset in `/etc/mkinitcpio.d/linux.preset`
   - Then regenerate:

     ```bash
     sudo mkinitcpio -p linux
     ```

5. Optional Xorg config:

   ```bash
   sudo nano /etc/X11/xorg.conf.d/10-hybrid.conf
   ```

   ```conf
   Section "Device"
       Identifier "Intel Graphics"
       Driver "modesetting"
       BusID "PCI:0:2:0"
       Option "TearFree" "true"
   EndSection

   Section "Device"
       Identifier "NVIDIA"
       Driver "nvidia"
       BusID "PCI:1:0:0"
       Option "AllowEmptyInitialConfiguration"
   EndSection
   ```

---

## Quick Recovery Checklist

If you're stuck on a black screen or SDDM doesn't appear:

```bash
# Switch to TTY
Ctrl + Alt + F2

# Check for blacklisted Intel
ls /etc/modprobe.d/

# Remove i915 blacklist if present
sudo rm /etc/modprobe.d/blacklist-intel.conf

# Rebuild initramfs
sudo mkinitcpio -P

# Reboot
sudo reboot
```

---

## Useful Links

- [Arch Wiki: NVIDIA](https://wiki.archlinux.org/title/NVIDIA)
- [Arch Wiki: Nouveau](https://wiki.archlinux.org/title/Nouveau)
- [Arch Wiki: Kernel Mode Setting](https://wiki.archlinux.org/title/Kernel_mode_setting)
- [Arch Wiki: PRIME](https://wiki.archlinux.org/title/PRIME)
- [Arch Wiki: Hybrid Graphics](https://wiki.archlinux.org/title/Hybrid_graphics)

---

## Additional Resources

- [NVIDIA Linux Driver Documentation](https://docs.nvidia.com/drivers/index.html)
- [NVIDIA Developer Forums](https://forums.developer.nvidia.com/)
- [Arch Linux Forums](https://bbs.archlinux.org/)
