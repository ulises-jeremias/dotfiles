require("hyprland.lua.d/animations")

hl.curve("leaf", { type = "bezier", points = {{0.25, 0.46}, {0.45, 0.94}} })
hl.curve("breeze", { type = "bezier", points = {{0.16, 1.00}, {0.30, 1.00}} })
hl.curve("root", { type = "bezier", points = {{0.22, 1.00}, {0.36, 1.00}} })
hl.curve("branch", { type = "bezier", points = {{0.34, 1.56}, {0.64, 1.00}} })
hl.curve("settle", { type = "bezier", points = {{0.08, 0.82}, {0.30, 1.00}} })

hl.animation({ leaf = "windows", enabled = true, speed = 1.17, bezier = "branch", style = "popin 80%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.0, bezier = "breeze", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.83, bezier = "settle", style = "popin 75%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.33, bezier = "leaf", style = "slide" })

hl.animation({ leaf = "border", enabled = true, speed = 1.67, bezier = "settle" })

hl.animation({ leaf = "fade", enabled = true, speed = 0.83, bezier = "settle" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 0.67, bezier = "breeze" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 0.67, bezier = "leaf" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 0.83, bezier = "root" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 1.0, bezier = "settle" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 0.83, bezier = "leaf" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 1.33, bezier = "breeze", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1.17, bezier = "root", style = "slidevert" })

hl.animation({ leaf = "layers", enabled = true, speed = 0.83, bezier = "breeze", style = "fade" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 0.67, bezier = "breeze", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 0.67, bezier = "settle", style = "fade" })
