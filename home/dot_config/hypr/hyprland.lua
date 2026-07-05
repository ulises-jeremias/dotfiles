require("hyprland.lua.d.monitors")
require("hyprland.lua.d.environment")
require("hyprland.lua.d.autostart")
require("hyprland.lua.d.input")
require("hyprland.lua.d.layout")
require("hyprland.lua.d.keybindings")
require("hyprland.lua.d.window-rules")

local animOk, _ = pcall(require, "hyprland.lua.d.animations-current")
if not animOk then
    require("hyprland.lua.d.animations")
end

local colorsOk, _ = pcall(dofile, os.getenv("HOME") .. "/.cache/dots/smart-colors/colors.lua")
if not colorsOk then
    require("hyprland.lua.d.colors-manual")
end

require("hyprland.lua.d.static")
