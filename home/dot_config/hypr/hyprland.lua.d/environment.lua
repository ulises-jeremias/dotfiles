hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

local xdg_runtime = os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000"
hl.env("DBUS_SESSION_BUS_ADDRESS", "unix:path=" .. xdg_runtime .. "/bus")
hl.env("GNOME_KEYRING_CONTROL", xdg_runtime .. "/keyring")

local home = os.getenv("HOME") or ""
hl.env("PASSWORD_STORE", "basic")
hl.env("KDE_FULL_SESSION", "")
hl.env("KDE_SESSION_VERSION", "")

hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.env("GTK_IM_MODULE", "ibus")
hl.env("QT_IM_MODULE", "ibus")
hl.env("XMODIFIERS", "@im=ibus")

hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "elementary")

if home ~= "" then
    hl.env("QML2_IMPORT_PATH", home .. "/.local/usr/lib/qt6/qml:" .. home .. "/.local/lib/quickshell/qml:" .. home .. "/.config/quickshell")
    hl.env("QS_PLUGIN_PATH", home .. "/.local/lib/quickshell")
end

hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("LIBVA_DRIVERS_PATH", "/usr/lib/dri")
