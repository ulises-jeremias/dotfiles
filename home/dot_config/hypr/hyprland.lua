-- HorneroOS — Hyprland Lua configuration (the only Hyprland config;
-- the legacy hyprlang hyprland.conf + hyprland.conf.d tree was retired
-- when this migration was accepted).
--
-- Module order mirrors the retired hyprland.conf source order, with
-- the old inline general/decoration/gesture/misc sections living in
-- static.lua and gestures.lua. Animation profiles stay selectable at
-- runtime through horneroctl; animations.lua is the startup default.
-- luacheck: globals hl

local here = debug.getinfo(1, "S").source:match("^@(.*)/[^/]*$") .. "/hyprland.lua.d/"

dofile(here .. "monitors.lua")
dofile(here .. "autostart.lua")
dofile(here .. "environment.lua")
dofile(here .. "input.lua")
dofile(here .. "gestures.lua")
dofile(here .. "layout.lua")
dofile(here .. "keybindings.lua")
dofile(here .. "window-rules.lua")
dofile(here .. "animations.lua")
dofile(here .. "smart-colors.lua")
dofile(here .. "static.lua")
