-- Staged Lua port of the corresponding legacy animation profile.
-- Keep one profile module selected at startup; loading multiple profiles
-- would overwrite curves and animation leaves with colliding names.
-- Legacy speed values are already deciseconds (1 ds = 100 ms), so they are
-- preserved numerically. This module is inert until full acceptance.
-- luacheck: globals hl

hl.curve("glitch", {
	type = "bezier",
	points = { { 0.7, 0.0 }, { 0.3, 1.0 } },
})

hl.curve("neon", {
	type = "bezier",
	points = { { 0.2, 1.2 }, { 0.3, 1.0 } },
})

hl.curve("cyber", {
	type = "bezier",
	points = { { 0.85, 0.0 }, { 0.15, 1.0 } },
})

hl.curve("flash", {
	type = "bezier",
	points = { { 0.9, 0.0 }, { 0.1, 1.0 } },
})

hl.curve("liner", {
	type = "bezier",
	points = { { 1, 1 }, { 1, 1 } },
})

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 4,
	curve = "cyber",
	style = "popin 85%",
})

hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 3,
	curve = "neon",
	style = "popin 90%",
})

hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 3,
	curve = "flash",
	style = "popin 85%",
})

hl.animation({
	leaf = "windowsMove",
	enabled = true,
	speed = 4,
	curve = "glitch",
	style = "slide",
})

hl.animation({
	leaf = "border",
	enabled = true,
	speed = 4,
	curve = "cyber",
})

hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 50,
	curve = "liner",
	style = "loop",
})

hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 3,
	curve = "flash",
})

hl.animation({
	leaf = "fadeIn",
	enabled = true,
	speed = 2,
	curve = "flash",
})

hl.animation({
	leaf = "fadeOut",
	enabled = true,
	speed = 2,
	curve = "flash",
})

hl.animation({
	leaf = "fadeSwitch",
	enabled = true,
	speed = 3,
	curve = "cyber",
})

hl.animation({
	leaf = "fadeShadow",
	enabled = true,
	speed = 4,
	curve = "cyber",
})

hl.animation({
	leaf = "fadeDim",
	enabled = true,
	speed = 3,
	curve = "cyber",
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 4,
	curve = "glitch",
	style = "slide",
})

hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 4,
	curve = "neon",
	style = "slidevert",
})

hl.animation({
	leaf = "layers",
	enabled = true,
	speed = 2,
	curve = "flash",
	style = "fade",
})

hl.animation({
	leaf = "layersIn",
	enabled = true,
	speed = 2,
	curve = "flash",
	style = "fade",
})

hl.animation({
	leaf = "layersOut",
	enabled = true,
	speed = 2,
	curve = "flash",
	style = "fade",
})
