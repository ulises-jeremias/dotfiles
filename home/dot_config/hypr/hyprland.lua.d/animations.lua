-- Lua port of the corresponding legacy animation profile.
-- Keep one profile module selected at startup; loading multiple profiles
-- would overwrite curves and animation leaves with colliding names.
-- Legacy speed values are already deciseconds (1 ds = 100 ms), so they are
-- preserved numerically.
-- luacheck: globals hl

hl.curve("wind", {
	type = "bezier",
	points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})

hl.curve("winIn", {
	type = "bezier",
	points = { { 0.1, 1.1 }, { 0.1, 1.0 } },
})

hl.curve("winOut", {
	type = "bezier",
	points = { { 0.3, -0.3 }, { 0, 1 } },
})

hl.curve("liner", {
	type = "bezier",
	points = { { 1, 1 }, { 1, 1 } },
})

hl.curve("linear", {
	type = "bezier",
	points = { { 0.0, 0.0 }, { 1.0, 1.0 } },
})

hl.curve("easeInOut", {
	type = "bezier",
	points = { { 0.42, 0.0 }, { 0.58, 1.0 } },
})

hl.curve("easeOut", {
	type = "bezier",
	points = { { 0.0, 0.0 }, { 0.58, 1.0 } },
})

hl.curve("focusPulse", {
	type = "bezier",
	points = { { 0.4, 0.0 }, { 0.2, 1.0 } },
})

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 6,
	curve = "wind",
	style = "slide",
})

hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 6,
	curve = "winIn",
	style = "slide",
})

hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 6,
	curve = "winOut",
	style = "slide",
})

hl.animation({
	leaf = "windowsMove",
	enabled = true,
	speed = 6,
	curve = "wind",
	style = "slide",
})

hl.animation({
	leaf = "border",
	enabled = true,
	speed = 6,
	curve = "easeInOut",
})

hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 30,
	curve = "liner",
	style = "loop",
})

hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 6,
	curve = "easeInOut",
})

hl.animation({
	leaf = "fadeIn",
	enabled = true,
	speed = 6,
	curve = "easeOut",
})

hl.animation({
	leaf = "fadeOut",
	enabled = true,
	speed = 6,
	curve = "easeOut",
})

hl.animation({
	leaf = "fadeSwitch",
	enabled = true,
	speed = 6,
	curve = "easeInOut",
})

hl.animation({
	leaf = "fadeShadow",
	enabled = true,
	speed = 6,
	curve = "easeInOut",
})

hl.animation({
	leaf = "fadeDim",
	enabled = true,
	speed = 6,
	curve = "easeInOut",
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 6,
	curve = "wind",
	style = "slidevert",
})

hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 6,
	curve = "wind",
	style = "slidevert",
})

hl.animation({
	leaf = "windowsMove",
	enabled = true,
	speed = 6,
	curve = "wind",
	style = "slide",
})

hl.animation({
	leaf = "layers",
	enabled = true,
	speed = 4,
	curve = "easeOut",
	style = "slide",
})

hl.animation({
	leaf = "layersIn",
	enabled = true,
	speed = 4,
	curve = "easeOut",
	style = "slide",
})

hl.animation({
	leaf = "layersOut",
	enabled = true,
	speed = 4,
	curve = "easeOut",
	style = "slide",
})
