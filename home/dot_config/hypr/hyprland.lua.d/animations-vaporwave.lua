-- Staged Lua port of the corresponding legacy animation profile.
-- Keep one profile module selected at startup; loading multiple profiles
-- would overwrite curves and animation leaves with colliding names.
-- Legacy speed values are already deciseconds (1 ds = 100 ms), so they are
-- preserved numerically. This module is inert until full acceptance.
-- luacheck: globals hl

hl.curve("retro", {
	type = "bezier",
	points = { { 0.3, 0.8 }, { 0.2, 1.0 } },
})

hl.curve("dream", {
	type = "bezier",
	points = { { 0.2, 1.1 }, { 0.3, 1.0 } },
})

hl.curve("sunset", {
	type = "bezier",
	points = { { 0.4, 0.0 }, { 0.2, 1.0 } },
})

hl.curve("vhs", {
	type = "bezier",
	points = { { 0.6, 0.0 }, { 0.4, 1.0 } },
})

hl.curve("liner", {
	type = "bezier",
	points = { { 1, 1 }, { 1, 1 } },
})

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 8,
	curve = "dream",
	style = "popin 80%",
})

hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 8,
	curve = "retro",
	style = "popin 85%",
})

hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 6,
	curve = "sunset",
	style = "popin 75%",
})

hl.animation({
	leaf = "windowsMove",
	enabled = true,
	speed = 8,
	curve = "retro",
	style = "slide",
})

hl.animation({
	leaf = "border",
	enabled = true,
	speed = 10,
	curve = "retro",
})

hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 80,
	curve = "liner",
	style = "loop",
})

hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 8,
	curve = "vhs",
})

hl.animation({
	leaf = "fadeIn",
	enabled = true,
	speed = 10,
	curve = "retro",
})

hl.animation({
	leaf = "fadeOut",
	enabled = true,
	speed = 8,
	curve = "sunset",
})

hl.animation({
	leaf = "fadeSwitch",
	enabled = true,
	speed = 8,
	curve = "retro",
})

hl.animation({
	leaf = "fadeShadow",
	enabled = true,
	speed = 10,
	curve = "retro",
})

hl.animation({
	leaf = "fadeDim",
	enabled = true,
	speed = 8,
	curve = "sunset",
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 10,
	curve = "retro",
	style = "slide",
})

hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 8,
	curve = "dream",
	style = "slidevert",
})

hl.animation({
	leaf = "layers",
	enabled = true,
	speed = 6,
	curve = "retro",
	style = "slide",
})

hl.animation({
	leaf = "layersIn",
	enabled = true,
	speed = 8,
	curve = "dream",
	style = "slide",
})

hl.animation({
	leaf = "layersOut",
	enabled = true,
	speed = 6,
	curve = "sunset",
	style = "fade",
})
