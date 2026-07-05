require("hyprland.lua.d/animations")

hl.curve("retro", { type = "bezier", points = {{0.3, 0.8}, {0.2, 1.0}} })
hl.curve("dream", { type = "bezier", points = {{0.2, 1.1}, {0.3, 1.0}} })
hl.curve("sunset", { type = "bezier", points = {{0.4, 0.0}, {0.2, 1.0}} })
hl.curve("vhs", { type = "bezier", points = {{0.6, 0.0}, {0.4, 1.0}} })

hl.animation({ leaf = "windows", enabled = true, speed = 1.33, bezier = "dream", style = "popin 80%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.33, bezier = "retro", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.0, bezier = "sunset", style = "popin 75%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.33, bezier = "retro", style = "slide" })

hl.animation({ leaf = "border", enabled = true, speed = 1.67, bezier = "retro" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 13.33, bezier = "liner", style = "loop" })

hl.animation({ leaf = "fade", enabled = true, speed = 1.33, bezier = "vhs" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.67, bezier = "retro" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.33, bezier = "sunset" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.33, bezier = "retro" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 1.67, bezier = "retro" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 1.33, bezier = "sunset" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 1.67, bezier = "retro", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1.33, bezier = "dream", style = "slidevert" })

hl.animation({ leaf = "layers", enabled = true, speed = 1.0, bezier = "retro", style = "slide" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1.33, bezier = "dream", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.0, bezier = "sunset", style = "fade" })
