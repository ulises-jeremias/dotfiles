-- Staged Lua equivalent of hyprland.conf.d/monitors.conf.
-- This file is intentionally not loaded until the complete configuration
-- migration has passed its acceptance checks.

hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "HDMI-A-5",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

-- Preserve the existing catch-all rule for other connected displays.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})
