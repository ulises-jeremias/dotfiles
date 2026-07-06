hl.window_rule({
    name = "pavucontrol-float",
    match = { class = ".*pavucontrol.*" },
    float = true,
    center = true,
    size = { "40%", "50%" },
})

hl.window_rule({
    name = "pwvucontrol-float",
    match = { class = ".*pwvucontrol.*" },
    float = true,
    center = true,
    size = { "40%", "50%" },
})

hl.window_rule({
    name = "blueman-float",
    match = { class = ".*blueman.*" },
    float = true,
    center = true,
    size = { "40%", "50%" },
})

hl.window_rule({
    name = "nm-connection-editor-float",
    match = { class = ".*nm-connection-editor.*" },
    float = true,
    center = true,
    size = { "40%", "50%" },
})

hl.window_rule({
    name = "calculator-float",
    match = { class = ".*calculator.*" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "wpg-float",
    match = { class = ".*[Ww]pg.*" },
    float = true,
    center = true,
    size = { "40%", "50%" },
})

hl.window_rule({
    name = "copyq-float",
    match = { class = ".*copyq.*" },
    float = true,
    center = true,
    size = { "35%", "50%" },
    stay_focused = true,
})

hl.window_rule({
    name = "auto-cpufreq-float",
    match = { class = ".*auto-cpufreq.*" },
    float = true,
    center = true,
    size = { "40%", "50%" },
})

hl.window_rule({
    name = "lxappearance-float",
    match = { class = ".*lxappearance.*" },
    float = true,
    center = true,
    size = { "50%", "60%" },
})

hl.window_rule({
    name = "arandr-float",
    match = { class = ".*arandr.*" },
    float = true,
    center = true,
    size = { "60%", "70%" },
})

hl.window_rule({
    name = "lxqt-config-float",
    match = { class = ".*lxqt-config.*" },
    float = true,
    center = true,
    size = { "60%", "70%" },
})

hl.window_rule({
    name = "yazi-popup",
    match = { class = "^yazi-popup$" },
    float = true,
    center = true,
    size = { "75%", "80%" },
    opacity = "0.95 0.90",
})

hl.window_rule({
    name = "file-operation-progress",
    match = { title = "^File Operation Progress$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "confirm-replace-files",
    match = { title = "^Confirm to replace files$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "thunar-bulk-rename",
    match = { class = "^thunar$", title = "^Bulk Rename$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "btop-float",
    match = { class = "^btop$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "htop-float",
    match = { class = "^htop$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "pip-float",
    match = { title = "^Picture-in-Picture$" },
    float = true,
    pin = true,
    size = { "25%", "25%" },
    move = { "72%", "72%" },
})

hl.window_rule({
    name = "kitty-opacity",
    match = { class = "^kitty$" },
    opacity = "0.95 0.85",
})

hl.window_rule({
    name = "alacritty-opacity",
    match = { class = "^Alacritty$" },
    opacity = "0.95 0.85",
})

hl.window_rule({
    name = "thunar-opacity",
    match = { class = "^thunar$" },
    opacity = "0.95 0.90",
})

hl.window_rule({
    name = "nautilus-opacity",
    match = { class = "^nautilus$" },
    opacity = "0.95 0.90",
})

hl.window_rule({
    name = "dolphin-opacity",
    match = { class = "^dolphin$" },
    opacity = "0.95 0.90",
})

hl.window_rule({
    name = "code-opacity",
    match = { class = "^Code$" },
    opacity = "0.98 0.95",
})

hl.window_rule({
    name = "code-url-handler-opacity",
    match = { class = "^code-url-handler$" },
    opacity = "0.98 0.95",
})

hl.window_rule({
    name = "discord-opacity",
    match = { class = "^discord$" },
    opacity = "0.95 0.90",
})

hl.window_rule({
    name = "vesktop-opacity",
    match = { class = "^vesktop$" },
    opacity = "0.95 0.90",
})

hl.window_rule({
    name = "firefox-workspace",
    match = { class = "^firefox$" },
    workspace = "1 silent",
})

hl.window_rule({
    name = "chromium-workspace",
    match = { class = "^chromium$" },
    workspace = "1 silent",
})

hl.window_rule({
    name = "google-chrome-workspace",
    match = { class = "^google-chrome$" },
    workspace = "1 silent",
})

hl.window_rule({
    name = "code-workspace",
    match = { class = "^Code$" },
    workspace = "2 silent",
})

hl.window_rule({
    name = "discord-workspace",
    match = { class = "^discord$" },
    workspace = "3 silent",
})

hl.window_rule({
    name = "vesktop-workspace",
    match = { class = "^vesktop$" },
    workspace = "3 silent",
})

hl.window_rule({
    name = "slack-workspace",
    match = { class = "^Slack$" },
    workspace = "3 silent",
})

hl.window_rule({
    name = "telegram-workspace",
    match = { class = "^telegram-desktop$" },
    workspace = "3 silent",
})

hl.window_rule({
    name = "spotify-workspace",
    match = { class = "^[Ss]potify$" },
    workspace = "4 silent",
    tile = true,
})

hl.window_rule({
    name = "steam-games",
    match = { class = "^steam_app.*" },
    fullscreen = true,
    immediate = true,
    workspace = "special:games silent",
    no_blur = true,
})

hl.window_rule({
    name = "mpv-idle",
    match = { class = "^mpv$" },
    idle_inhibit = "always",
})

hl.window_rule({
    name = "vlc-idle",
    match = { class = "^vlc$" },
    idle_inhibit = "always",
})

hl.window_rule({
    name = "firefox-youtube-idle",
    match = { class = "^firefox$", title = ".*YouTube.*" },
    idle_inhibit = "focus",
})

hl.window_rule({
    name = "peek-fix",
    match = { class = "^peek$" },
    float = true,
    move = { "0", "0" },
    pin = true,
    no_anim = true,
    no_initial_focus = true,
    stay_focused = true,
    no_shadow = true,
    border_size = 0,
})

hl.window_rule({
    name = "xwayland-video-bridge",
    match = { class = "^xwaylandvideobridge$" },
    opacity = "0.0 override 0.0 override",
    no_anim = true,
    no_focus = true,
    no_initial_focus = true,
})

hl.window_rule({
    name = "suppress-maximize-all",
    match = { class = ".*" },
    suppress_event = "maximize",
})
