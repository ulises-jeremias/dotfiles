-- Lua port of the corresponding legacy animation profile.
-- Keep one profile module selected at startup; loading multiple profiles
-- would overwrite curves and animation leaves with colliding names.
-- Legacy speed values are already deciseconds (1 ds = 100 ms), so they are
-- preserved numerically.
-- luacheck: globals hl

hl.curve("leaf", {
	type = "bezier",
	points = { { 0.25, 0.46 }, { 0.45, 0.94 } },
})

hl.curve("breeze", {
	type = "bezier",
	points = { { 0.16, 1.00 }, { 0.30, 1.00 } },
})

hl.curve("root", {
	type = "bezier",
	points = { { 0.22, 1.00 }, { 0.36, 1.00 } },
})

hl.curve("branch", {
	type = "bezier",
	points = { { 0.34, 1.56 }, { 0.64, 1.00 } },
})

hl.curve("settle", {
	type = "bezier",
	points = { { 0.08, 0.82 }, { 0.30, 1.00 } },
})

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 7,
	curve = "branch",
	style = "popin 80%",
})

hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 6,
	curve = "breeze",
	style = "popin 85%",
})

hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 5,
	curve = "settle",
	style = "popin 75%",
})

hl.animation({
	leaf = "windowsMove",
	enabled = true,
	speed = 8,
	curve = "leaf",
	style = "slide",
})

hl.animation({
	leaf = "border",
	enabled = true,
	speed = 10,
	curve = "settle",
})

hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 5,
	curve = "settle",
})

hl.animation({
	leaf = "fadeIn",
	enabled = true,
	speed = 4,
	curve = "breeze",
})

hl.animation({
	leaf = "fadeOut",
	enabled = true,
	speed = 4,
	curve = "leaf",
})

hl.animation({
	leaf = "fadeSwitch",
	enabled = true,
	speed = 5,
	curve = "root",
})

hl.animation({
	leaf = "fadeShadow",
	enabled = true,
	speed = 6,
	curve = "settle",
})

hl.animation({
	leaf = "fadeDim",
	enabled = true,
	speed = 5,
	curve = "leaf",
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 8,
	curve = "breeze",
	style = "slide",
})

hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 7,
	curve = "root",
	style = "slidevert",
})

hl.animation({
	leaf = "layers",
	enabled = true,
	speed = 5,
	curve = "breeze",
	style = "fade",
})

hl.animation({
	leaf = "layersIn",
	enabled = true,
	speed = 4,
	curve = "breeze",
	style = "fade",
})

hl.animation({
	leaf = "layersOut",
	enabled = true,
	speed = 4,
	curve = "settle",
	style = "fade",
})
