-- Personal keybinding overrides (dotfiles). Loaded by the packaged
-- hyprland.lua after the factory keybindings.lua; unbind/bind pairs win.
-- horneroctl hardware keyboard rebind also manages this file and may
-- rewrite it — re-apply this override after using that tool if needed.
-- luacheck: globals hl

-- SUPER + O opens the Shell Dashboard instead of the ScrollOverview plugin.
hl.unbind("SUPER + O")
hl.bind("SUPER + O", hl.dsp.exec_cmd("horneroctl apps toggle dashboard --yes"))
