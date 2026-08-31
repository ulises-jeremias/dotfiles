# E2E Desktop Testing Harness

Real end-to-end testing for the Hornero dotfiles: boots an **Arch Linux VM**
(QEMU/KVM inside Docker), provisions the desktop stack, applies the working
tree, starts **Hyprland + Quickshell**, and captures **screenshots and
screen recordings** as artifacts.

```text
Host (Arch, Docker + /dev/kvm)
└── Docker container (dotfiles-e2e-qemu)          [non-root runner, kvm group]
    └── QEMU VM (Arch cloud image, virtio-vga)    [user: hornero]
        └── Hyprland (DRM backend) + Quickshell
            └── grim (screenshots) + wf-recorder (video)
```

## Prerequisites

| Requirement | Notes |
|---|---|
| Docker | running daemon |
| `/dev/kvm` | optional but strongly recommended (TCG fallback is very slow) |
| `jq`, `ssh` | used by the scenario scripts |
| ~4 GB free RAM | VM uses 3 GB by default (`E2E_VM_MEM`) |

## Quickstart

```bash
cd playground/e2e

# Full pipeline: boot, provision, deploy, session, record, assert
./scenarios/desktop-smoke.sh

# Or run it step by step:
./lib/run.sh            # start VM container (builds image + seed on first run)
./lib/wait-ssh.sh       # wait for SSH (first boot: a few minutes)
./lib/provision.sh      # pacman install (hyprland, quickshell, wf-recorder, ...)
./lib/deploy-dots.sh    # copy working-tree configs into the VM
./lib/start-session.sh  # Hyprland + Quickshell via DRM
./lib/screenshot.sh     # grim -> artifacts/screenshots/desktop.png
./lib/record.sh start   # wf-recorder -> artifacts/recordings/
./lib/record.sh stop
./lib/record.sh fetch
./lib/stop.sh           # tear down (disk image stays cached)
```

## Recording

The scenario records real desktop interaction using **wf-recorder** inside the
VM (10 fps by default, MP4/H264):

```bash
./lib/record.sh start                    # starts wf-recorder -o Virtual-1
# ... interact: hyprctl dispatch workspace 2, etc.
./lib/record.sh stop                     # SIGINT finalizes the file
./lib/record.sh fetch                    # scp to artifacts/recordings/
```

Environment knobs: `E2E_FPS` (default `10`),
`RECORDING_REMOTE` (default `/tmp/e2e-recording.mp4`).

> wf-recorder requires a `wlr-screencopy` compositor — Hyprland supports it.
> The recorder must be stopped with **SIGINT** (`record.sh stop` does this);
> `SIGTERM` leaves a truncated file.
>
> **Damage-driven capture**: `wlr-screencopy` only emits frames on screen
> damage. A static desktop produces a header-only MP4 (~261 bytes). The
> scenario keeps the screen busy (workspace switches) while recording. When
> recording manually, interact with the desktop or the file will be empty.

## Artifacts

Everything lands in `playground/e2e/artifacts/` (gitignored):

```text
artifacts/
├── console.log                 # VM serial console (boot + cloud-init)
├── assertions.json             # machine-readable PASS/FAIL report
├── screenshots/desktop-final.png
├── recordings/desktop-recording.mp4
└── logs/
    ├── hyprland.log
    └── quickshell.log
```

## Configuration

All knobs are environment variables (see `lib/env.sh`):

| Variable | Default | Description |
|---|---|---|
| `E2E_CONTAINER_NAME` | `dotfiles-e2e-vm` | Docker container name |
| `E2E_SSH_PORT` | `2222` | Host port forwarded to guest SSH |
| `E2E_VM_MEM` | `3072` | VM RAM (MB) |
| `E2E_VM_SMP` | `2` | VM vCPUs |
| `E2E_FPS` | `10` | Recording frame rate |
| `E2E_CLOUD_IMAGE_URL` | Arch geo mirror | Cloud image source |

The disk image (`cache/arch-cloudimg.qcow2`) and cloud-init seed are **cached**:
subsequent runs boot in seconds and only re-run provisioning if the marker file
is missing. SSH keys are ephemeral per checkout (`ssh/`, gitignored) and get
baked into a fresh seed ISO automatically.

## How it works

1. **`run.sh`** builds the container image (Arch + QEMU), generates an
   ephemeral SSH keypair, renders `user-data.tmpl` into a cloud-init seed ISO
   (`mkisofs -volid cidata`), and starts QEMU with KVM, `virtio-vga`, and user
   networking (`hostfwd` for SSH, VNC on `:0`).
2. **`provision.sh`** installs the desktop stack via pacman over SSH and adds
   the user to `seat`/`video`/`render` groups (SSH sessions have no logind
   seat, so `seatd` handles DRM device access).
3. **`deploy-dots.sh`** pipes the working tree (`hypr`, `quickshell` configs)
   into the VM via tar-over-ssh — no shared filesystem needed.
4. **`start-session.sh`** starts Hyprland with `WLR_BACKENDS=drm`, then
   Quickshell, and verifies both processes.
5. **`record.sh` / `screenshot.sh`** run `wf-recorder` / `grim` inside the VM
   against the `Virtual-1` output and copy results out over SCP.
6. **`desktop-smoke.sh`** chains all steps, switches workspaces while
   recording, and writes `assertions.json`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `SSH did not come up` | check `artifacts/console.log`; first boot downloads nothing but cloud-init needs ~2 min |
| Hyprland fails to start | seatd must be running and user in `seat` group (`provision.sh` does both); check VM `/tmp/hypr.log` |
| Chaotic-AUR / mirror 503 | transient; re-run `provision.sh` |
| Recording file is 0 bytes or truncated | recorder was killed without SIGINT — always use `record.sh stop` |
| VM feels sluggish | host under memory pressure; lower `E2E_VM_MEM` or close host apps (VM can OOM at 4 GB) |
| Push to CI fails on the image | never commit `cache/`, `ssh/`, or `artifacts/` (gitignored by design) |

## Known limitations

- Quickshell hot-reload does not recreate bar items after style changes —
  restart `qs` instead.
- Video wallpapers need `qt6-multimedia` in the guest (installed by
  `provision.sh`).
- The VM has no GPU acceleration beyond virtio-vga; visual differences vs the
  host are expected.
