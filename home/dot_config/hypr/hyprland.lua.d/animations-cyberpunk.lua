require("hyprland.lua.d.animations")

hl.curve("glitch", { type = "bezier", points = {{0.7, 0.0}, {0.3, 1.0}} })
hl.curve("neon", { type = "bezier", points = {{0.2, 1.2}, {0.3, 1.0}} })
hl.curve("cyber", { type = "bezier", points = {{0.85, 0.0}, {0.15, 1.0}} })
hl.curve("flash", { type = "bezier", points = {{0.9, 0.0}, {0.1, 1.0}} })

hl.animation({ leaf = "windows", enabled = true, speed = 0.67, bezier = "cyber", style = "popin 85%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 0.5, bezier = "neon", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.5, bezier = "flash", style = "popin 85%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 0.67, bezier = "glitch", style = "slide" })

hl.animation({ leaf = "border", enabled = true, speed = 0.67, bezier = "cyber" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8.33, bezier = "liner", style = "loop" })

hl.animation({ leaf = "fade", enabled = true, speed = 0.5, bezier = "flash" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 0.33, bezier = "flash" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 0.33, bezier = "flash" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 0.5, bezier = "cyber" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 0.67, bezier = "cyber" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 0.5, bezier = "cyber" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 0.67, bezier = "glitch", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 0.67, bezier = "neon", style = "slidevert" })

hl.animation({ leaf = "layers", enabled = true, speed = 0.33, bezier = "flash", style = "fade" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 0.33, bezier = "flash", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 0.33, bezier = "flash", style = "fade" })
