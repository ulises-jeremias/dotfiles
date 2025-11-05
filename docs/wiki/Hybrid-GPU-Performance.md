# Hybrid GPU Performance Guide

## Hardware Setup

- **iGPU**: Intel Raptor Lake-S UHD Graphics
- **dGPU**: NVIDIA RTX 4060 Max-Q Mobile
- **Physical Connection**:
  - Laptop Display (eDP-1) → Intel iGPU
  - External Monitor (HDMI-A-5) → NVIDIA dGPU (physical HDMI port)

## The Performance Problem

When your external monitor is connected **directly to the NVIDIA HDMI port**, it creates a **Reverse PRIME** situation:

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│  Intel iGPU (renders everything)                    │
│         │                                            │
│         ├──► eDP-1 (laptop) ✓ Direct                │
│         │                                            │
│         └──► [Frame Copy] ──► NVIDIA dGPU           │
│                                    │                 │
│                                    └──► HDMI-A-5     │
│                                         (external)   │
│                                                      │
│  Overhead: ~5-15ms latency per frame copy           │
└──────────────────────────────────────────────────────┘
```

### Impacts

- ❌ **Additional latency**: 5-15ms per frame copy
- ❌ **NVIDIA always active**: Doesn't enter deep power-save
- ❌ **Higher power consumption**: ~5-10W extra even without gaming
- ⚠️  **Possible tearing**: If VRR isn't properly configured

## Solutions and Trade-offs

### ✅ Option 1: Keep Reverse PRIME (Current Configuration)

**Advantages:**

- Better battery life than NVIDIA full-time
- Wayland works better with Intel as compositor
- NVIDIA available for gaming with `prime-run`

**Disadvantages:**

- Frame copies Intel→NVIDIA
- ~5-15ms latency on external monitor
- NVIDIA never completely turns off

**When to use:**

- Working primarily on battery
- Not gaming on external monitor
- Prioritize efficiency over minimal latency

---

### ⚡ Option 2: NVIDIA as Primary GPU

Change to have NVIDIA render everything (including compositor).

**Required configuration:**

```bash
# In environment.conf, change to:
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1

# Remove:
# env = __NV_PRIME_RENDER_OFFLOAD,1
```

**Advantages:**

- No frame copies for external monitor
- Minimal latency on HDMI-A-5
- Better for fulltime gaming

**Disadvantages:**

- ❌ **MUCH higher consumption** (+15-25W even at idle)
- ❌ **Fans always active** under Wayland
- ❌ **Worse Wayland support** on NVIDIA
- ❌ **Battery drains 2-3x faster**

**When to use:**

- External monitor always connected
- Intensive gaming on external monitor
- Laptop always plugged into power

---

### 🎯 Option 3: Dynamic Hybrid Mode (Recommended)

Use **different profiles** depending on usage:

#### For Work/Battery (Current config)

```bash
# Already configured - uses Intel for compositor
hyprctl reload
```

#### For Gaming/Performance

```bash
# Script to temporarily switch to NVIDIA primary
prime-run hyprland  # Or configure separate Hyprland session
```

---

## Current Applied Configuration

Your system is configured for **Option 1 (Optimized Reverse PRIME)**:

### `environment.conf`

- Intel handles VA-API (video decode)
- NVIDIA configured to present on physical HDMI port
- `__NV_PRIME_RENDER_OFFLOAD` variables active
- Hardware cursors enabled (test for glitches)

### `monitors.conf`

- eDP-1 explicitly configured
- HDMI-A-5 with auto-detect
- Reverse PRIME flow documented

## Verifying Performance

### 1. Check which GPU Hyprland uses

```bash
# See active GPU for Hyprland
hyprctl systeminfo | grep -i "gpu"

# Or verify processes:
nvidia-smi  # Check if Hyprland appears here
```

### 2. Check input latency

```bash
# On external monitor, move windows quickly
# Feel if there's noticeable lag vs laptop screen
```

### 3. Measure power consumption

```bash
# See power consumption
cat /sys/class/power_supply/BAT*/power_now
# Lower number = better (values in µW)

# See NVIDIA GPU usage
nvidia-smi dmon
```

### 4. If you see cursor glitches on external monitor

```bash
# Uncomment in environment.conf:
env = WLR_NO_HARDWARE_CURSORS,1
```

## Recommendations

### For your case (2 monitors, hybrid laptop)

1. **Keep current configuration** (Reverse PRIME) for daily use
2. **Monitor latency** on external monitor
3. **If you notice annoying lag**: Consider switching to NVIDIA primary
4. **For gaming**: Use `prime-run` or launch games with NVIDIA variables

### Signs you should switch to NVIDIA primary

- ✓ Noticeable lag/tearing on external monitor
- ✓ Frequently gaming on external monitor
- ✓ Laptop always plugged into power
- ✓ Don't care about fan noise

### Keep Reverse PRIME if

- ✓ Regularly use battery
- ✓ Current lag is imperceptible
- ✓ Prioritize silence/low temperature
- ✓ Not doing intensive gaming

## Troubleshooting

### Problem: External monitor has noticeable lag

**Solution**: Switch to NVIDIA primary (Option 2)

### Problem: Cursor corrupts on external monitor

**Solution**: Enable `WLR_NO_HARDWARE_CURSORS,1`

### Problem: NVIDIA doesn't release memory

**Solution**:

```bash
# Kill persistent NVIDIA processes
sudo systemctl restart display-manager
```

### Problem: Tearing on external monitor

**Solution**:

```properties
# In hyprland.conf, verify:
misc {
    vrr = 1  # Variable Refresh Rate
    no_direct_scanout = false
}
```

## Useful Commands

```bash
# See active GPUs
lspci | grep -E "VGA|3D"

# See processes using NVIDIA
nvidia-smi

# See monitors in Hyprland
hyprctl monitors

# See DRM outputs
drm_info | grep -A5 "Connector"

# See which GPU a specific window uses
hyprctl clients | grep -A10 "class:"

# Launch specific app on NVIDIA
prime-run <app>
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <app>
```

## Performance States Explained

NVIDIA GPUs have different performance states (P-states):

| P-State | Mode | Power Usage | Use Case |
|---------|------|-------------|----------|
| P0 | Maximum Performance | ~50-55W | Gaming, Heavy Compute |
| P2 | Balanced | ~20-30W | Video Editing |
| P5 | Low Power | ~5-10W | Display Output Only |
| P8 | Idle (not achievable with display) | ~1-2W | No display connected |

In Reverse PRIME mode with external monitor, NVIDIA stays at **P5** (5W) minimum.

## Expected Performance Metrics

### Battery Life Impact

- **Before optimization**: ~15-25W additional GPU consumption
- **After (Reverse PRIME)**: ~5W (3-5x better battery duration)
- **NVIDIA Primary**: ~20-30W (worst battery life)

### Latency

- **Laptop Monitor (eDP-1)**: 0ms overhead ✓
- **External Monitor (HDMI-A-5)**: ~5-10ms overhead (frame copy)

### Gaming

Use `prime-run` to force full NVIDIA:

```bash
prime-run steam
prime-run lutris
prime-run godot
```

## Advanced: Creating Profile Scripts

Create profile switching scripts for different scenarios:

### `~/.local/bin/dots-gpu-mode-battery`

```bash
#!/usr/bin/env bash
# Switch to battery-optimized mode (Intel primary)

# Copy environment.conf with Intel settings
# Reload Hyprland
hyprctl reload
notify-send "GPU Mode" "Switched to Battery Mode (Intel primary)"
```

### `~/.local/bin/dots-gpu-mode-performance`

```bash
#!/usr/bin/env bash
# Switch to performance mode (NVIDIA primary)

# Copy environment.conf with NVIDIA settings
# Reload Hyprland
hyprctl reload
notify-send "GPU Mode" "Switched to Performance Mode (NVIDIA primary)"
```

## References

- [Hyprland NVIDIA Guide](https://wiki.hyprland.org/Nvidia/)
- [Arch Wiki: PRIME](https://wiki.archlinux.org/title/PRIME)
- [NVIDIA Wayland Support](https://wiki.archlinux.org/title/Wayland#NVIDIA)
- [Kernel DRM PRIME Documentation](https://www.kernel.org/doc/html/latest/gpu/drm-kms.html)

## Related Documentation

- [[Hardware]] - General hardware configuration
- [[Hardware-nvidia-troubleshooting]] - NVIDIA-specific issues
- [[Hyprland-Setup]] - Hyprland configuration guide
- [[Window-Managers]] - Window manager configurations
