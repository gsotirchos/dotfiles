# Auto-brightness (iMac panel + LG UltraFine)

Unified brightness control for an iMac (`iMac14,1`), which can drive **either**
its internal Retina panel **or** an attached **24" LG UltraFine 4K** — only one
is the active output at a time (hardware limitation). A single tool detects
which display is live and uses the correct control path **and** ambient-light
sensor for it.

## Components

| Path | Role |
|------|------|
| `bin/brightness` | Bash orchestrator: CLI + background auto-adjust daemon. |
| `bin/lg-brightness` | Python (stdlib only) helper: get/set LG brightness over `hidraw`. |
| `etc/udev/90-lg-ultrafine.rules` | Grants the LG `hidraw` node to the logged-in user (no sudo). |
| `packages/autostart/.config/autostart/lg-ultrafine-brightness.desktop` | Starts `brightness daemon` at GNOME login. |

The iMac internal panel is driven via the [`light`](https://github.com/haikarainen/light)
utility; the LG is driven via a `hidraw` HID feature report (see
[LG UltraFine control](#lg-ultrafine-control)).

## Commands

```text
brightness get            print effective brightness (0-100)
brightness set <0-100>    set absolute brightness (switches to manual)
brightness up [step]      increase brightness (switches to manual)
brightness down [step]    decrease brightness (switches to manual)
brightness auto           resume sensor-driven auto-adjust
brightness daemon         run the background auto-adjust loop
brightness status         show display, mode, daemon state, sensor, curve target
```

`up`/`down`/`set` switch the mode to **manual**; `auto` switches it back. The
default step is 5 points.

## How it works

### Active-display detection

A real panel backlight registers under `/sys/class/backlight/` **only when the
iMac internal panel is the active output**. So:

- backlight present (e.g. `acpi_video0`, `*_backlight`) → **iMac**
- otherwise (LG `043e:9a63` USB device present) → **LG UltraFine**

### Ambient-light sensors

Both sensors are exposed via the kernel IIO subsystem. Resolve them by `name`
(the `iio:deviceN` index can swap across reboots), reading `in_illuminance_raw`:

| Display | IIO `name` | Notes |
|---------|-----------|-------|
| iMac internal | `acpi-als` | ACPI ambient light sensor. |
| LG UltraFine | `als` | HID sensor under USB device `043E:9A63`. |

**LG sensor warm-up:** the LG HID sensor uses runtime power management and reads
`0` while idle, waking after ~1 s of continuous reads. `bin/brightness` polls
briefly (`sensor_value`) so a one-shot read returns a woken value; a genuinely
dark room still falls through to `0`.

### LG UltraFine control

The LG 5K does **not** support DDC/CI; brightness is a single **6-byte HID
feature report**:

- USB device: `043e:9a63` ("LG UltraFine Display Controls").
- `hidraw` candidates: `hidraw6/7/8` all map to `043e:9a63`; `bin/lg-brightness`
  auto-probes and uses the one that answers the brightness report (here
  `hidraw7`; the others are the ALS/other interfaces and return `EPIPE`).
- Buffer layout (7 bytes): `[report_id=0, value_lo, value_hi, 0, 0, 0, 0]`.
  On **get**, the value is little-endian `uint16` at byte offset **1–2**.
- Raw range **0–54000 = 0–100 %**.

Access is granted without `sudo` by `etc/udev/90-lg-ultrafine.rules`
(`TAG+="uaccess"` for the active seat, plus `GROUP="plugdev"` fallback).

Debug the device directly with `lg-brightness probe` (dumps the GET bytes for
each candidate node).

### Daemon, modes and hysteresis

`brightness daemon` is the loop that actually reads the sensor and applies
brightness. State lives under `${XDG_RUNTIME_DIR}/brightness/`:

- `mode` — `auto` or `manual`. The daemon only adjusts in `auto`.

Tunables at the top of `bin/brightness`:

- `SLEEP_DELAY=1` — seconds between samples.
- `MIN_STEP=10` — ignore auto changes smaller than this many points.
- `MAX_CNT=4` — the new target must stay stable this many loops before it is
  applied (anti-flicker).

## The brightness curve

Ambient reading → brightness is a **logarithmic** interpolation between
`(x1, CURVE_Y1)` and `(x2, CURVE_Y2)`; readings `<= x1` clamp to `CURVE_Y1`,
readings `>= x2` clamp to `CURVE_Y2`. Each display has its own `x1`/`x2` because
the two sensors use different scales.

Constants in `bin/brightness`:

```bash
IMAC_X1=2      # iMac sensor reading -> minimum brightness
IMAC_X2=70     # iMac sensor reading -> maximum brightness
LG_X1=1        # LG sensor reading -> minimum brightness
LG_X2=80       # LG sensor reading -> maximum brightness
CURVE_Y1=10    # minimum brightness (%)
CURVE_Y2=100   # maximum brightness (%)
```

### Calibrating

1. In your **darkest** realistic condition run `brightness status`, note
   `sensor:`, and set `LG_X1` (or `IMAC_X1`) to it.
2. In your **brightest** condition note `sensor:` and set `LG_X2` / `IMAC_X2`.
3. Set the desired brightness range with `CURVE_Y1` (floor) and `CURVE_Y2`
   (ceiling).
4. **Restart the daemon** to load the new constants (a running daemon read them
   at startup):

   ```bash
   pkill -f "brightness daemon"; setsid -f brightness daemon
   ```

5. Iterate while watching the mapping live:

   ```bash
   watch -n1 brightness status
   ```

Observed reference: the LG sensor reads ~7 indoors and ~34 in brighter light, so
`LG_X1=1` is likely too low — start around `LG_X1≈4`, `LG_X2≈40–60`.

## Running the daemon

- **At login (default):** the autostart `.desktop` runs `brightness daemon`
  (symlinked into `~/.config/autostart/` by Stow; only stowed on `iMac14,1`).
  No terminal, no sudo.
- **Now, without re-login:**

  ```bash
  setsid -f brightness daemon
  ```

- **Inspect / stop:**

  ```bash
  brightness status              # mode, daemon running/stopped, sensor, target
  pkill -f "brightness daemon"
  ```

> Avoid duplicates: starting one manually and then logging in (autostart) yields
> two daemons. They compute the same target so it is harmless, just wasteful —
> `pkill -f "brightness daemon"` clears extras.

## Setup / install

`etc/setup_ubuntu.sh` handles the prerequisites:

- installs `light`;
- `video` group + backlight udev trigger (iMac panel access);
- copies `etc/udev/90-lg-ultrafine.rules` to `/etc/udev/rules.d/` and reloads
  udev (LG `hidraw` access).

After the rule is first installed, **replug the LG display or re-login** so the
`uaccess` ACL applies to your session. `python3` and `light` are the only
runtime dependencies (the helper uses Python stdlib `fcntl` — no `hidapi`).

## Troubleshooting

- **`lg-brightness: could not read a valid brightness report`** — the `hidraw`
  nodes are root-only; install the udev rule and replug/re-login.
- **`brightness status` shows `sensor: 0`** — LG sensor warm-up; usually
  transient. The daemon keeps it warm by polling continuously.
- **Auto mode "does nothing"** — `brightness auto` only sets the mode flag; make
  sure the daemon is running (`brightness status`).
- **Edited the curve but nothing changed** — restart the daemon (it reads the
  constants once at startup).

## References (protocol only — not used directly)

Both upstream tools are interactive ncurses/libusb TUIs that require `sudo` and
take no CLI arguments, so only their reverse-engineered protocol is reused here:

- <https://github.com/ycsos/LG-ultrafine-brightness>
- <https://github.com/velum/lguf-brightness>
