-- Lua equivalent of the retired hyprland.conf.d/environment.conf. (loaded by hyprland.lua).
-- luacheck: globals hl

local environment = {
	{ "GDK_BACKEND", "wayland,x11" },
	{ "QT_QPA_PLATFORM", "wayland;xcb" },
	{ "SDL_VIDEODRIVER", "wayland" },
	{ "CLUTTER_BACKEND", "wayland" },
	{ "XDG_CURRENT_DESKTOP", "Hyprland" },
	{ "XDG_SESSION_TYPE", "wayland" },
	{ "XDG_SESSION_DESKTOP", "Hyprland" },
	{ "PASSWORD_STORE", "basic" },
	{ "KDE_FULL_SESSION", "" },
	{ "KDE_SESSION_VERSION", "" },
	{ "QT_AUTO_SCREEN_SCALE_FACTOR", "1" },
	{ "QT_WAYLAND_DISABLE_WINDOWDECORATION", "1" },
	{ "QT_QPA_PLATFORMTHEME", "qt6ct" },
	{ "GTK_IM_MODULE", "ibus" },
	{ "QT_IM_MODULE", "ibus" },
	{ "XMODIFIERS", "@im=ibus" },
	{ "MOZ_ENABLE_WAYLAND", "1" },
	{ "XCURSOR_SIZE", "24" },
	{ "XCURSOR_THEME", "elementary" },
	{ "_JAVA_AWT_WM_NONREPARENTING", "1" },
	{ "LIBVA_DRIVER_NAME", "nvidia" },
	{ "LIBVA_DRIVERS_PATH", "/usr/lib/dri" },
}

for _, entry in ipairs(environment) do
	hl.env(entry[1], entry[2])
end

-- These values depend on the current user session; do not bake in a UID or
-- assume that the runtime directory has a fixed path.
local runtime_dir = os.getenv("XDG_RUNTIME_DIR")
if runtime_dir and runtime_dir ~= "" then
	hl.env("DBUS_SESSION_BUS_ADDRESS", "unix:path=" .. runtime_dir .. "/bus")
	hl.env("GNOME_KEYRING_CONTROL", runtime_dir .. "/keyring")
end
