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
- Detección nativa: si el sistema es HorneroOS nativo, los scripts que
  instalan Shell/Config/Greeter/SDDM/Zsh o tocan `/etc/os-release` se
  saltean: eso ya lo hizo la ISO. La preview28 ya publica `ID=horneroos`
  en os-release, pero `pelicano` se instaló con preview24 (`ID=arch`) y
  la identidad no se actualiza con los paquetes: en esta máquina hay que
  exportar `HORNERO_NATIVE=1` para que la detección se active. Ver la
  guía de migración preview24 → preview28 en HorneroOS/docs
  (`getting-started/upgrading-from-preview24.md`).

## Aplicar (después de instalar HorneroOS Studio)

```bash
chezmoi init --source ~/.local/share/chezmoi   # o tu clon habitual
chezmoi diff          # revisar ANTES de aplicar
chezmoi apply --dry-run --verbose
chezmoi apply
```

Nunca aplicar sin revisar el diff. No ejecutar apply destructivo sobre
una máquina de producción sin backup de `~/.config` y `~/.local/share`.

## Limpieza de overrides obsoletos

Las reglas viven en `home/.chezmoiremove` y en el script de migración
`run_after_remove-retired-kitty.sh.tmpl`; solo retiran archivos
que HorneroOS ya reemplazó de forma verificada (detalle por archivo en
`docs/Chezmoi-Migration-Ledger.md`):

- En todos los hosts: la config Hyprland pre-Lua y los helpers `.sh` /
  `.lua` retirados por la migración Lua.
- Solo en HorneroOS nativo (`horneroNative`) y una única vez: los
  temas Kitty retirados en #347, hoy propiedad de `hornero-config`.
  La baja solo ocurre si `hornero-config >= 0.3.14` está instalado;
  un `kitty.conf` que crees después es configuración personal y no
  se vuelve a borrar. En Arch clásico no se tocan salvo que exportes
  `HORNERO_NATIVE=1` (exactamente `1`; otro valor no activa nada).

Antes de aplicar, revisá exactamente qué se borraría:

```bash
chezmoi diff                    # incluye las bajas de .chezmoiremove
chezmoi apply --dry-run --verbose
```

## Rollback

`chezmoi` no borra archivos personales; para revertir un cambio puntual,
restaurar el archivo desde el backup previo al apply o desde el historial
de git del propio repo. Backup mínimo antes de un apply con bajas:

```bash
cp -a ~/.config/kitty ~/.config/kitty.bak-$(date +%F)   # si existe
```

Si el apply retiró un archivo que querías conservar, restauralo desde
ese backup: chezmoi ya no lo gestiona, así que no vuelve solo. Un
segundo `chezmoi apply` no debe producir cambios.

## Inventario

Ver `docs/hornero-capability-inventory.csv`: cada capacidad de estos
dotfiles está clasificada (factory default, Developer, Studio, Gaming,
opcional, personal o legacy) con su dueño propuesto y estado.
