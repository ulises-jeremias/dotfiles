# General Learnings

| Date | Learning | Context |
|------|----------|---------|
| 2026-08-27 | hyprland 0.56.2: gaps_out NO soporta valores por-edge aunque getoption muestre '60 10 10 10' (echo del valor, el layout lo ignora — verificado con ventanas tiled que no se mueven). El espacio por-borde se logra con layer-shell exclusive zones (lo que ya hace el shell hornero) | Session |
| 2026-08-31 | E2E harness (playground/e2e) gotchas: (1) wlr-screencopy es damage-driven — wf-recorder sobre desktop estático produce mp4 de solo header (~261B), hay que interactuar durante la grabación; (2) detener wf-recorder con SIGINT (SIGTERM deja archivo truncado); (3) lanzar Hyprland/QS con `ssh -f` o los FDs mantienen la conexión SSH abierta; (4) Hyprland desde SSH necesita XDG_CONFIG_HOME exportado o los source= globbing fallan; (5) firmas viejas de instancias Hyprland se acumulan — elegir con `ls -t`; (6) libcava (Chaotic-AUR) es requerida por el plugin C++ Hornero; (7) cloud-init solo re-ejecuta write_files si cambia el instance-id de meta-data; (8) deshabilitar idle-lock headless o hyprlock crashea en pantalla "Ooopsie daisy". Escenario completo PASS en ~33s con cache | Session |
