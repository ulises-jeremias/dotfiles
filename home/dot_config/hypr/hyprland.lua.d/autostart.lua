hl.on("hyprland.start", function()
    local home = os.getenv("HOME")

    hl.exec_cmd("dex --autostart --environment Hyprland")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    if home then
        hl.exec_cmd(home .. "/.local/bin/start-gnome-keyring.sh")
    end
    hl.exec_cmd("pkill -9 kwalletd5 kwalletd6 2>/dev/null || true")
    hl.exec_cmd("hypridle")
    if home then
        hl.exec_cmd(home .. "/.local/bin/dots-hypr-layout --restore --quiet")
        hl.exec_cmd(home .. "/.local/bin/dots-snappy-switcher daemon")
    end
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    if home then
        hl.exec_cmd(home .. "/.local/bin/dots-battery-monitor -d")
        hl.exec_cmd("xrdb -merge " .. home .. "/.Xresources")
    end
    hl.exec_cmd("hyprctl setcursor elementary 24")
    if home then
        hl.exec_cmd(home .. "/.local/bin/dots-quickshell start")
    end
    hl.exec_cmd("thunar --daemon")
    hl.exec_cmd("ibus-daemon -drx")
end)
