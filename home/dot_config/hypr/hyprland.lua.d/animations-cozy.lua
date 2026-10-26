-- Lua port of the corresponding legacy animation profile.
-- Keep one profile module selected at startup; loading multiple profiles
-- would overwrite curves and animation leaves with colliding names.
-- Legacy speed values are already deciseconds (1 ds = 100 ms), so they are
-- preserved numerically.
-- luacheck: globals hl

hl.curve("soft", {
	type = "bezier",
	points = { { 0.2, 0.8 }, { 0.2, 1.0 } },
})

hl.curve("bounce", {
	type = "bezier",
	points = { { 0.2, 1.3 }, { 0.3, 1.0 } },
})

hl.curve("gentle", {
	type = "bezier",
	points = { { 0.1, 0.8 }, { 0.2, 1.0 } },
})

hl.curve("float", {
	type = "bezier",
	points = { { 0.3, 0.9 }, { 0.4, 1.0 } },
})

hl.curve("cuddle", {
	type = "bezier",
	points = { { 0.15, 1.0 }, { 0.25, 1.0 } },
})

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 10,
	bezier = "bounce",
	style = "popin 75%",
})

hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 8,
	bezier = "cuddle",
	style = "popin 80%",
})

hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 8,
	bezier = "gentle",
	style = "popin 70%",
})

hl.animation({
	leaf = "windowsMove",
	enabled = true,
	speed = 10,
	bezier = "float",
	style = "slide",
})

hl.animation({
	leaf = "border",
	enabled = true,
	speed = 12,
	bezier = "soft",
})

hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 60,
	bezier = "float",
	style = "loop",
})

hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 8,
	bezier = "gentle",
})

hl.animation({
	leaf = "fadeIn",
	enabled = true,
	speed = 10,
	bezier = "soft",
})

hl.animation({
	leaf = "fadeOut",
	enabled = true,
	speed = 8,
	bezier = "soft",
})

hl.animation({
	leaf = "fadeSwitch",
	enabled = true,
	speed = 8,
	bezier = "gentle",
})

hl.animation({
	leaf = "fadeShadow",
	enabled = true,
	speed = 10,
	bezier = "soft",
})

hl.animation({
	leaf = "fadeDim",
	enabled = true,
	speed = 10,
	bezier = "soft",
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 12,
	bezier = "float",
	style = "slide",
})

hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 10,
	bezier = "bounce",
	style = "slidevert",
})

hl.animation({
	leaf = "layers",
	enabled = true,
	speed = 6,
	bezier = "soft",
	style = "slide",
})

hl.animation({
	leaf = "layersIn",
	enabled = true,
	speed = 8,
	bezier = "gentle",
	style = "slide",
})

hl.animation({
	leaf = "layersOut",
	enabled = true,
	speed = 6,
	bezier = "gentle",
	style = "fade",
})
