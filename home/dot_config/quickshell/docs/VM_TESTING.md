# Graphical VM testing

The `tests/vm` harness boots a throwaway Arch Linux VM with QEMU/KVM,
deploys the checkout under test as the live Quickshell config, starts
Hyprland plus this shell, and captures screenshots and a screen recording
as regression artifacts. It is inspired by the dotfiles `playground/e2e`
pipeline (Hyprland plus Quickshell plus `grim`/`wf-recorder` plus a smoke
scenario) but runs QEMU directly on the host and deploys this repository
instead of a dotfiles tree.

```text
Host (Arch, QEMU + KVM)
└── QEMU VM (Arch cloud image, virtio-vga)    [user: hornero]
    ├── Hyprland (DRM backend, test-only config)
    └── this shell (repo checkout as ~/.config/quickshell)
        ├── grim (screenshots) + wf-recorder (video)
        └── QEMU HMP screendump fallback (no guest agent needed)
```

## Prerequisites

Host side (Arch Linux example; adapt package names elsewhere):

```bash
sudo pacman -S --needed qemu-desktop curl openssh jq python3 cdrtools
```

| Requirement | Notes |
|---|---|
| `qemu-system-x86_64` | direct host install, no container needed |
| `/dev/kvm` | strongly recommended; without it QEMU falls back to TCG (very slow) |
| `ssh`, `scp`, `ssh-keygen` | guest access over a forwarded port |
| `curl`, `jq`, `python3` | image download, report parsing, PNG checks |
| One seed-ISO tool | `cloud-localds`, `genisoimage`, or `mkisofs` |
| ~4 GB free RAM | VM uses 3 GB by default (`VM_MEM`) |
| Network access | first run downloads the Arch cloud image (cached afterwards) |

The guest installs everything else itself (`provision.sh`): Hyprland,
Quickshell (AUR), `grim`, `wf-recorder`, Qt6 modules, `cmake`, and fonts.
`provision.sh` fails fast when the guest has less than
`VM_MIN_GUEST_FREE_GB` GB free (default 6); `boot.sh` grows the ephemeral
boot overlay to `VM_MIN_IMAGE_GB` GiB virtual size (default 14). The
verified base image is never resized (see `Image verification`).

## Native plugin in the guest

`deploy-shell.sh` builds the shell's native QML plugin from the deployed
checkout with the guest's `cmake` + Qt6, installing to a user prefix
(`VM_GUEST_PREFIX`, default guest `~/.local`, no sudo), and
`start-session.sh` exposes it via `QML2_IMPORT_PATH`. Rebuilds happen only
when the working tree changed (marker in the guest cache); a failed build
warns and continues without `Hornero.*` modules so the smoke run still
reports honestly instead of hanging.

## Image verification

`boot.sh` verifies the base cloud image against its published SHA256
sidecar on every run, including cached images
(`VM_CLOUD_IMAGE_SHA256_URL`, default `<image-url>.SHA256`). A mismatch
deletes the untrusted base image (plus its overlay) and aborts;
`VM_ALLOW_UNVERIFIED_IMAGE=1` bypasses with a loud warning (not recommended).
The mirror also publishes a GPG `.sig` next to the image; verifying it is a
manual opt-in until the harness pins a signing key:

```bash
curl -fSLO https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2.sig
gpg --verify Arch-Linux-x86_64-cloudimg.qcow2.sig arch-cloudimg.qcow2
```

## Boot overlay design (issue #12)

Repro: `boot.sh` used to attach the verified cache read-write, so a first
run's guest writes dirtied `cache/arch-cloudimg.qcow2` and the next run's
fail-closed verify failed on a legitimately dirty image.

Fix: QEMU boots an ephemeral qcow2 overlay (`VM_OVERLAY`, default
`cache/vm-overlay.qcow2`) with the verified base as its backing file, so
all guest writes land in the overlay and the cache stays pristine:

```bash
qemu-img create -f qcow2 -F qcow2 -b cache/arch-cloudimg.qcow2 cache/vm-overlay.qcow2
```

`boot.sh` rebuilds the overlay when it is missing, when the base is newer
(re-downloaded), or when its recorded backing file no longer points at the
base, then grows the overlay (never the base) to `VM_MIN_IMAGE_GB` GiB and
passes the overlay as the QEMU system disk. The verify gate still runs on
the base on every boot, so a swapped or bitrotted cache is caught before
any VM starts. To reset the VM without re-downloading, delete the overlay:

```bash
rm tests/vm/cache/vm-overlay.qcow2
```

Dry-run proof (no KVM needed):

```bash
./tests/vm/lib/boot.sh --dry-run
python3 -m pytest tests/vm/test_vm_overlay.py -q
```

## Runbook

Full pipeline (first run provisions, later runs reuse the cached image):

```bash
./tests/vm/scenarios/vm-smoke.sh
```

Faster repeat runs (skip the slow guest package install):

```bash
./tests/vm/scenarios/vm-smoke.sh --skip-provision
```

Step by step (same stages the scenario chains):

```bash
./tests/vm/lib/boot.sh            # start VM (builds image + seed on first run)
./tests/vm/lib/wait-ssh.sh        # wait for SSH (first boot takes minutes)
./tests/vm/lib/provision.sh       # install the guest desktop stack
./tests/vm/lib/deploy-shell.sh    # copy this checkout into the VM
./tests/vm/lib/start-session.sh   # Hyprland plus shell via DRM
./tests/vm/lib/screenshot.sh      # grim -> artifacts/screenshots/desktop.png
./tests/vm/lib/record.sh start    # wf-recorder -> artifacts/recordings/
./tests/vm/lib/record.sh stop
./tests/vm/lib/record.sh fetch
```

Validate the harness without any hypervisor (used by CI too):

```bash
./tests/vm/scenarios/vm-smoke.sh --dry-run
python3 -m pytest tests/vm/ -q
```

## Welcome scenario

`./tests/vm/scenarios/vm-welcome.sh` proves the Welcome Center end to end
on a fresh-boot simulation (state wiped, installer factory state): first
login auto-opens on `start`, a repeat login auto-opens again, a same-session
shell reload stays silent, `horneroctl welcome set-show-on-login false`
survives a new login, and manual reopen (`horneroctl welcome open` plus
`qs ipc call welcome open`) lands on the requested page. It also captures
the dark/light/Pampa matrix by swapping `scheme.json` live
(`tests/vm/lib/welcome-schemes.py` derives light from the built-in M3
tables and Pampa from `profiles/themes/pampa/theme.json`; unit-tested in
`tests/vm/test_welcome_schemes.py`).

Login sessions are simulated with `XDG_SESSION_ID`, the same key the shell
uses for its once-per-session marker. Requires the composed guest
(`HX_MATERIALIZE_BIN` for `shortcuts.json` badges, `HX_HOREROCTL_BIN` for
opt-out writes):

```bash
HX_MATERIALIZE_BIN=<config-checkout>/scripts/materialize.sh \
HX_HOREROCTL_BIN=<hornero-checkout>/cli/build/horneroctl \
./tests/vm/scenarios/vm-welcome.sh [--skip-provision]
```

`VM_CACHE_DIR` relocates the base image, overlay, seed, and SSH keys when
the checkout lives on a small filesystem (defaults to `tests/vm/cache`).

Every stage script also accepts `--dry-run` and `--help` individually.

## What is asserted

A passing `vm-smoke.sh` run writes `artifacts/assertions.json` with
`result: PASS`. Each gate fails loudly instead of archiving empty output:

| Gate | How |
|---|---|
| VM booted, SSH reachable | `boot.sh` pidfile plus `wait-ssh.sh` probe |
| Guest stack installed | `provision.sh` marker plus package installs |
| Checkout deployed intact | `shell.qml` and `hyprland.conf` exist in the guest |
| Compositor alive | `pgrep -x Hyprland` in the guest |
| Shell alive | `pgrep -x qs` (fallback `quickshell`) in the guest |
| Compositor IPC responds | `hyprctl -j monitors` returns an output name |
| Shell IPC responds | `qs ipc call drawers list` returns drawer names |
| Screen is really rendering | `grim` probe, then the final capture must pass `check_screenshot.py` |
| Recording captured | `wf-recorder` file exists and is non-empty (screencopy path only) |

The screenshot gate (`tests/vm/lib/check_screenshot.py`, standard library
only) rejects blank or truncated frames: fewer than 16 distinct colors or
a luminance standard deviation below 3.0 fails the run.

## Artifacts

Everything lands under `tests/vm/artifacts/` (gitignored):

```text
artifacts/
├── console.log                  # VM serial console (boot plus cloud-init)
├── assertions.json              # machine-readable PASS/FAIL report
├── monitor.sock                 # QEMU monitor (framebuffer fallback)
├── screenshots/desktop-final.png
├── recordings/desktop-recording.mp4
└── logs/
    ├── hyprland.log
    └── shell.log
```

The base image (`cache/arch-cloudimg.qcow2`, verified every run and never
written), the boot overlay (`cache/vm-overlay.qcow2`, all guest writes),
and the cloud-init seed are cached: later runs boot in seconds. SSH keys
are ephemeral per checkout (`ssh/`, gitignored) and baked into a fresh
seed ISO automatically.

## Configuration

All knobs are environment variables (see `tests/vm/lib/env.sh`):

| Variable | Default | Description |
|---|---|---|
| `VM_SSH_PORT` | `2222` | Host port forwarded to guest SSH |
| `VM_SSH_USER` | `hornero` | Guest login user |
| `VM_MEM` | `3072` | VM RAM in MB |
| `VM_SMP` | `2` | VM vCPUs |
| `VM_FPS` | `10` | Recording frame rate |
| `VM_CLOUD_IMAGE_URL` | Arch geo mirror | Cloud image source |
| `VM_CLOUD_IMAGE` | `tests/vm/cache/arch-cloudimg.qcow2` | Pristine verified base (never booted directly) |
| `VM_OVERLAY` | `tests/vm/cache/vm-overlay.qcow2` | Ephemeral boot disk (backing file = base) |
| `VM_ARTIFACTS_DIR` | `tests/vm/artifacts` | Capture and report output |
| `VM_CACHE_DIR` | `tests/vm/cache` | Base image, overlay, seed, and pidfile |
| `VM_DRY_RUN` | `0` | `1` prints the plan without side effects |
| `VM_GUEST_DNS` | `1.1.1.1` | DNS server advertised to the guest over DHCP; `provision.sh` also pins it in the guest when the DHCP resolver does not answer |
| `HX_CONFIG_PIN` | empty (shell-local) | `"<repo-url> <sha>"` HorneroOS/config pin, fetched like `hornero scripts/compose.sh`, then materialized in the guest |
| `HX_MATERIALIZE_BIN` | empty | Direct path to a `materialize.sh` (default: the fetched pin's script) |
| `HX_HOREROCTL_BIN` | empty | `horneroctl` binary copied to the guest for composition validation (unset: script-only materialize with a warning) |
| `HX_MANIFEST` | `shell-local` | Manifest name recorded in the `composition` block of `assertions.json` |

## Pinned composition

Unset `HX_*` keeps the shell-local loop: only this checkout is deployed.
Set `HX_CONFIG_PIN` (or `HX_MATERIALIZE_BIN`) and `deploy-shell.sh`
additionally copies the config pin to `~/hx-config` in the guest,
materializes it to `~/hx-root`, validates the root with `horneroctl`
(`config paths/validate/show`, mirroring `hornero scripts/compose.sh`),
and fails when the guest holds a personal dotfiles clone (no `~/dotfiles`
directory, no checkout with that origin; the pin travels as a file copy,
never a clone). `vm-smoke.sh` records the pins in the `composition`
block (`manifest`, `shell_sha`, `config_sha`) of `assertions.json`;
existing keys are unchanged.

## Continuous integration

CI never boots a graphical VM: KVM is unavailable on runners and a
compositor job would flake. The `VM harness` workflow
(`.github/workflows/vm-harness.yml`) is `workflow_dispatch`-only and runs
exactly the checks that are deterministic without hardware:

- `shellcheck` (plus `-x` follow mode) over every harness script
- `pytest tests/vm/` for the screenshot helpers and dry-run contract
- `vm-smoke.sh --dry-run` as the end-to-end coherence probe
- markdown and yaml lint over the harness docs and workflow

## Troubleshooting

| Symptom | Fix |
|---|---|
| `SSH did not come up` | check `artifacts/console.log`; first boot plus cloud-init needs minutes |
| `pacman: Could not resolve host` in the guest | host LAN DNS is unreachable from slirp: `provision.sh` probes and pins `VM_GUEST_DNS` automatically; override the knob on filtered networks |
| Hyprland fails to start | `seatd` must run and the user needs the `seat` group (`provision.sh` does both); inspect `artifacts/logs/hyprland.log` |
| `grim` probe hangs | expected on some virtio stacks; the scenario falls back to `qemu-screenshot.sh` automatically |
| Recording is header-only | `wlr-screencopy` emits frames on damage only; the scenario switches workspaces while recording, do the same when driving `record.sh` manually |
| Blank-screenshot failure | the compositor or shell rendered nothing; read the guest logs before rerunning |
| Push shows harness state | never commit `artifacts/`, `cache/`, or `ssh/` (gitignored by design) |

## Known limits

- The VM has no GPU acceleration beyond `virtio-vga`; pixels differ from
  real hardware, so the gate checks non-blankness, not pixel equality.
- The guest uses a minimal test-only `hyprland.conf` from
  `tests/vm/guest/`; compositor bindings and theming live in
  HorneroOS/config and are out of scope here.
- Quickshell comes from the AUR (`quickshell-git`), so first provisioning
  tracks upstream tip rather than a pinned release.
- Video capture needs a `wlr-screencopy` compositor (Hyprland qualifies)
  and must stop with SIGINT (`record.sh stop` does this); SIGTERM leaves
  a truncated file.
- Host-gated coverage: booting, provisioning, session start, capture, and
  the full `vm-smoke.sh` run require KVM plus network and are
  documented-only in CI. Runnable anywhere: `shellcheck`, `pytest
  tests/vm/`, every `--dry-run` path, and the repo lint guards.

## What ran here versus what needs hardware

Verified on the authoring host (no KVM): `shellcheck` clean in both
default and `-x` modes, `pytest tests/` fully green, every stage plus the
scenario in `--dry-run`, and the PNG helpers against synthetic blank,
two-tone, gradient, gray, Sub-filtered, truncated, and PPM fixtures.

A real boot, guest provisioning, session start, and capture still need a
KVM host with network access; the runbook above is the procedure, and
`assertions.json` from such a host is the acceptance evidence.
