# pelicano — HorneroOS Studio + dotfiles (guía en español)

`pelicano` es la ASUS ROG Strix G16 G615LR con HorneroOS Studio. HorneroOS
es dueño del sistema (Shell, Config, Greeter, drivers, PipeWire, Studio);
estos dotfiles solo agregan la capa personal.

## Qué hace este repo en pelicano

- Hostname `pelicano`: `personal = true`, `docker = false` (la máquina de
  producción/streaming no levanta servicios que no necesita; Docker se
  activa a mano si hace falta).
- SSH/mDNS: `hornero`, `colibri` y `pelicano` se alcanzan como
  `<host>.local` con la misma clave personal.
- Detección nativa: si el sistema es HorneroOS nativo
  (`HORNERO_NATIVE=1` hasta que el instalador publique `ID=horneroos` en
  os-release), los scripts que instalan Shell/Config/Greeter/SDDM/Zsh o
  tocan `/etc/os-release` se saltean: eso ya lo hizo la ISO.

## Aplicar (después de instalar HorneroOS Studio)

```bash
chezmoi init --source ~/.local/share/chezmoi   # o tu clon habitual
chezmoi diff          # revisar ANTES de aplicar
chezmoi apply --dry-run --verbose
chezmoi apply
```

Nunca aplicar sin revisar el diff. No ejecutar apply destructivo sobre
una máquina de producción sin backup de `~/.config` y `~/.local/share`.

## Rollback

`chezmoi` no borra archivos personales; para revertir un cambio puntual,
restaurar el archivo desde el backup previo al apply o desde el historial
de git del propio repo. Las reglas de limpieza viven en
`home/.chezmoiremove` y solo retiran overrides ya reemplazados por
HorneroOS (hoy: la config Hyprland pre-Lua).

## Inventario

Ver `docs/hornero-capability-inventory.csv`: cada capacidad de estos
dotfiles está clasificada (factory default, Developer, Studio, Gaming,
opcional, personal o legacy) con su dueño propuesto y estado.
