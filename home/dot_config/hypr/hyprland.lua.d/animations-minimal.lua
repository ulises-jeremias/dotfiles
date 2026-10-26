-- Lua port of the corresponding legacy animation profile.
-- Keep one profile module selected at startup; loading multiple profiles
-- would overwrite curves and animation leaves with colliding names.
-- Legacy speed values are already deciseconds (1 ds = 100 ms), so they are
-- preserved numerically.
-- luacheck: globals hl

hl.curve("linear", {
	type = "bezier",
	points = { { 0.0, 0.0 }, { 1.0, 1.0 } },
})

hl.curve("snap", {
	type = "bezier",
	points = { { 0.5, 0.0 }, { 0.5, 1.0 } },
})

hl.curve("direct", {
	type = "bezier",
	points = { { 0.4, 0.0 }, { 0.6, 1.0 } },
})

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 2,
	bezier = "snap",
	style = "slide",
})

hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 2,
	bezier = "linear",
	style = "slide",
})

hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 1,
	bezier = "linear",
	style = "slide",
})

hl.animation({
	leaf = "windowsMove",
	enabled = true,
	speed = 2,
	bezier = "direct",
	style = "slide",
})

hl.animation({
	leaf = "border",
	enabled = true,
	speed = 2,
	bezier = "linear",
})

hl.animation({
	leaf = "borderangle",
	enabled = false,
	speed = 1,
	bezier = "linear",
})

hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 2,
	bezier = "linear",
})

hl.animation({
	leaf = "fadeIn",
	enabled = true,
	speed = 1,
	bezier = "linear",
})

hl.animation({
	leaf = "fadeOut",
	enabled = true,
	speed = 1,
	bezier = "linear",
})

hl.animation({
	leaf = "fadeSwitch",
	enabled = true,
	speed = 2,
	bezier = "linear",
})

hl.animation({
	leaf = "fadeShadow",
	enabled = true,
	speed = 2,
	bezier = "linear",
})

hl.animation({
	leaf = "fadeDim",
	enabled = true,
	speed = 2,
	bezier = "linear",
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 2,
	bezier = "snap",
	style = "slide",
})

hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 2,
	bezier = "snap",
	style = "slidevert",
})

hl.animation({
	leaf = "layers",
	enabled = true,
	speed = 1,
	bezier = "linear",
	style = "fade",
})

hl.animation({
	leaf = "layersIn",
	enabled = true,
	speed = 1,
	bezier = "linear",
	style = "fade",
})

hl.animation({
	leaf = "layersOut",
	enabled = true,
	speed = 1,
	bezier = "linear",
	style = "fade",
})
