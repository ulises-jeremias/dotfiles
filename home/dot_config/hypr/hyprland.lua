require("hyprland.lua.d/monitors")
require("hyprland.lua.d/environment")
require("hyprland.lua.d/autostart")
require("hyprland.lua.d/input")
require("hyprland.lua.d/layout")
require("hyprland.lua.d/keybindings")
require("hyprland.lua.d/window-rules")

pcall(require, "hyprland.lua.d.animations")

local home = os.getenv("HOME")
if home then
    local colorsOk, _ = pcall(dofile, home .. "/.cache/dots/smart-colors/colors.lua")
    if not colorsOk then
        require("hyprland.lua.d/colors-manual")
    end
else
    require("hyprland.lua.d/colors-manual")
end

require("hyprland.lua.d/static")
