<p align="center">
  <img src="https://raw.githubusercontent.com/blackoutsecure/docker-emulationstation-de/main/logo.png" alt="emulationstation-de logo" width="200">
</p>

# docker-emulationstation-de

[![GitHub Stars](https://img.shields.io/github/stars/blackoutsecure/docker-emulationstation-de?style=flat-square&color=E7931D&logo=github)](https://github.com/blackoutsecure/docker-emulationstation-de/stargazers)
[![Docker Pulls](https://img.shields.io/docker/pulls/blackoutsecure/emulationstation-de?style=flat-square&color=E7931D&logo=docker&logoColor=FFFFFF)](https://hub.docker.com/r/blackoutsecure/emulationstation-de)
[![GitHub Release](https://img.shields.io/github/release/blackoutsecure/docker-emulationstation-de.svg?style=flat-square&color=E7931D&logo=github&logoColor=FFFFFF)](https://github.com/blackoutsecure/docker-emulationstation-de/releases)
[![Release CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-emulationstation-de/release.yml?style=flat-square&label=release%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-emulationstation-de/actions/workflows/release.yml)
[![Docker CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-emulationstation-de/publish.yml?style=flat-square&label=docker%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-emulationstation-de/actions/workflows/publish.yml)
[![License](https://img.shields.io/github/license/blackoutsecure/docker-emulationstation-de?style=flat-square)](LICENSE)

Unofficial community image for [ES-DE Frontend](https://gitlab.com/es-de/emulationstation-de), built with LinuxServer.io-style container patterns for Ubuntu, hardened runtime defaults, direct local-display operation, and optional Balena publishing. Available in two base image variants: standard (local X) and Selkies (browser-based streaming).

Sponsored and maintained by [Blackout Secure](https://blackoutsecure.app).

> [!IMPORTANT]
> This repository is not an official LinuxServer.io image release.

## Overview

This project packages upstream [ES-DE Frontend](https://gitlab.com/es-de/emulationstation-de) into an easy-to-run container image for cabinets, desktops, HTPCs, and handheld Linux systems where direct GPU and input passthrough matters more than browser remoting.

Quick links:

- Docker Hub listing: [blackoutsecure/emulationstation-de](https://hub.docker.com/r/blackoutsecure/emulationstation-de)
- GitHub repository: [blackoutsecure/docker-emulationstation-de](https://github.com/blackoutsecure/docker-emulationstation-de)
- Upstream application: [es-de/emulationstation-de](https://gitlab.com/es-de/emulationstation-de)
- Application Developer Site: [es-de.org](https://es-de.org/)
- Balena block metadata: [balena.yml](balena.yml)

[![balena deploy button](https://www.balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/blackoutsecure/docker-emulationstation-de&configUrl=https://raw.githubusercontent.com/blackoutsecure/docker-emulationstation-de/main/balena.yml)

---

## Table of Contents

- [docker-emulationstation-de](#docker-emulationstation-de)
  - [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Quick Start](#quick-start)
  - [Image Availability](#image-availability)
  - [About The ES-DE Application](#about-the-es-de-application)
  - [Supported Architectures](#supported-architectures)
  - [Usage](#usage)
    - [Docker Compose (recommended, click here for more info)](#docker-compose-recommended-click-here-for-more-info)
    - [Docker Compose Hardware Examples](#docker-compose-hardware-examples)
    - [Docker CLI (click here for more info)](#docker-cli-click-here-for-more-info)
    - [Balena Deployment](#balena-deployment)
  - [RetroStack Emulator Integration](#retrostack-emulator-integration)
    - [Control Pipe Protocol](#control-pipe-protocol)
    - [Supported Emulators](#supported-emulators)
    - [RetroStack Environment Variables](#retrostack-environment-variables)
  - [Parameters](#parameters)
    - [Compose Profiles](#compose-profiles)
    - [Environment Variables](#environment-variables)
      - [Default (Local Display) Service](#default-local-display-service)
      - [Selkies (WebRTC Streaming) Service](#selkies-webrtc-streaming-service)
      - [Audio Configuration (Default Service)](#audio-configuration-default-service)
    - [Storage Mounts](#storage-mounts)
    - [Devices](#devices)
    - [Runtime Security Defaults](#runtime-security-defaults)
  - [Configuration](#configuration)
    - [`/config` - Configuration and Persistence](#config---configuration-and-persistence)
    - [`/roms` - Content Library](#roms---content-library)
    - [`/bios` - Emulator Support Files](#bios---emulator-support-files)
    - [Best Practices](#best-practices)
  - [Application Setup](#application-setup)
  - [Build Locally](#build-locally)
  - [Troubleshooting](#troubleshooting)
    - [Display errors on startup](#display-errors-on-startup)
    - [Input devices not detected](#input-devices-not-detected)
    - [Gamepad Mapping](#gamepad-mapping)
    - [AArch64 systems with GLES-only drivers](#aarch64-systems-with-gles-only-drivers)
  - [Release \& Versioning](#release--versioning)
  - [Support \& Getting Help](#support--getting-help)
  - [References](#references)

---

## Quick Start

**5-minute standalone setup (internal X server — no host X required):**

```bash
docker compose up -d
```

The default [docker-compose.yml](docker-compose.yml) starts its own Xorg server inside the container (`ESDE_USE_INTERNAL_X=1`), so no host display server is needed. This is ideal for kiosk, cabinet, HTPC, and Balena deployments.

**Alternative: use an existing host X server:**

```bash
xhost +local:docker
docker run -d \
  --name=emulationstation \
  -e TZ=Etc/UTC \
  -e DISPLAY=:0 \
  -v /path/to/config:/config \
  -v /path/to/roms:/roms:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  --device=/dev/dri:/dev/dri \
  --device=/dev/input:/dev/input \
  --shm-size=1gb \
  --restart unless-stopped \
  blackoutsecure/emulationstation-de:latest
```

For compose examples, device passthrough, Balena deployment, and local build options, see [Usage](#usage) below.

---

## Image Availability

**Docker Hub (Recommended):**

- All images are published to [Docker Hub](https://hub.docker.com/r/blackoutsecure/emulationstation-de)
- Simple pull command: `docker pull blackoutsecure/emulationstation-de:latest`
- Multi-arch support: amd64, arm64
- No registry prefix needed when pulling from Docker Hub
- Two base image variants: **default** (local X) and **selkies** (browser-based streaming via [docker-baseimage-selkies](https://github.com/linuxserver/docker-baseimage-selkies))

**Default variant** — based on `linuxserver/baseimage-ubuntu:noble`:

```bash
# Pull latest stable
docker pull blackoutsecure/emulationstation-de:latest

# Pull specific upstream version
docker pull blackoutsecure/emulationstation-de:<version>

# Pull dev channel
docker pull blackoutsecure/emulationstation-de:latest-dev
```

**Selkies variant** — based on `linuxserver/baseimage-selkies:ubuntunoble`:

```bash
# Pull latest stable selkies
docker pull blackoutsecure/emulationstation-de:latest-selkies

# Pull specific upstream version selkies
docker pull blackoutsecure/emulationstation-de:<version>-selkies

# Pull dev channel selkies
docker pull blackoutsecure/emulationstation-de:latest-dev-selkies
```

---

## About The ES-DE Application

[ES-DE Frontend](https://gitlab.com/es-de/emulationstation-de) is an EmulationStation-derived frontend used to browse ROM libraries, present metadata and media, and launch external emulators from a controller-friendly interface.

This container packages ES-DE for direct local-display environments. The default mode starts an internal Xorg server inside the container, requiring no host display server. Alternatively, it can connect to an existing host X11 server via socket mounting. The runtime supports writable config persistence and optional passthrough for GPU, input, audio, and USB devices.

Upstream project details:

- Main project site: [es-de.org](https://es-de.org)
- Source repository: [es-de/emulationstation-de](https://gitlab.com/es-de/emulationstation-de)
- Upstream user guide: [USERGUIDE.md](https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE.md)
- Upstream development user guide: [USERGUIDE-DEV.md](https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE-DEV.md?ref_type=heads)
- Upstream build and install documentation: [INSTALL.md](https://gitlab.com/es-de/emulationstation-de/-/blob/master/INSTALL.md#building-on-linux-and-unix)

---

## Supported Architectures

This image is published as a multi-arch manifest. Pulling `blackoutsecure/emulationstation-de:latest` retrieves the correct image for your host architecture.

The architectures supported by this image are:

| Architecture | Default Tags | Selkies Tags |
| :----: | --- | --- |
| x86-64 | latest, latest-dev | latest-selkies, latest-dev-selkies |
| arm64 | latest, latest-dev | latest-selkies, latest-dev-selkies |

**Tag scheme:**

| Variant | Stable | Dev | Pinned |
| --- | --- | --- | --- |
| Default | `latest`, `<version>` | `latest-dev` | `sha-<commit>-stable`, `sha-<commit>-dev` |
| Selkies | `latest-selkies`, `<version>-selkies` | `latest-dev-selkies` | `sha-<commit>-stable-selkies`, `sha-<commit>-dev-selkies` |

---

## Usage

### Docker Compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

**Standalone (internal X server — recommended for dedicated devices):**

```yaml
---
services:
  emulationstation:
    image: blackoutsecure/emulationstation-de:latest
    container_name: emulationstation
    environment:
      - TZ=Etc/UTC
      - DISPLAY_NUM=0
      - XDG_RUNTIME_DIR=/run/esde
      - ESDE_USE_INTERNAL_X=1
      - UDEV=1
    volumes:
      - /path/to/config:/config
      - /path/to/roms:/roms:ro
      - /path/to/bios:/bios:ro
    devices:
      - /dev/dri:/dev/dri
      - /dev/input:/dev/input
      - /dev/uinput:/dev/uinput
      - /dev/snd:/dev/snd
    privileged: true
    tmpfs:
      - /var/tmp
      - /run:exec
    shm_size: 1gb
    restart: unless-stopped
```

**Using an existing host X server:**

```yaml
---
services:
  emulationstation:
    image: blackoutsecure/emulationstation-de:latest
    container_name: emulationstation
    environment:
      - TZ=Etc/UTC
      - DISPLAY=:0
      - UDEV=1
    volumes:
      - /path/to/config:/config
      - /path/to/roms:/roms:ro
      - /path/to/bios:/bios:ro
      - /tmp/.X11-unix:/tmp/.X11-unix:ro
    devices:
      - /dev/dri:/dev/dri
      - /dev/input:/dev/input
    privileged: true
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp:exec,nosuid,nodev,size=512m
      - /var/tmp:nosuid,nodev,size=256m
      - /run:exec,nosuid,nodev,size=64m
    shm_size: 1gb
    restart: unless-stopped
```

### Docker Compose Hardware Examples

**Intel/AMD GPU + input:**

```yaml
---
services:
  emulationstation:
    image: blackoutsecure/emulationstation-de:latest
    container_name: emulationstation
    environment:
      - TZ=Etc/UTC
      - DISPLAY_NUM=0
      - XDG_RUNTIME_DIR=/run/esde
      - ESDE_USE_INTERNAL_X=1
      - UDEV=1
    volumes:
      - /path/to/config:/config
      - /path/to/roms:/roms:ro
      - /path/to/bios:/bios:ro
    devices:
      - /dev/dri:/dev/dri
      - /dev/input:/dev/input
      - /dev/snd:/dev/snd
    privileged: true
    tmpfs:
      - /var/tmp
      - /run:exec
    shm_size: 1gb
    restart: unless-stopped
```

**Nvidia GPU:**

```yaml
---
services:
  emulationstation:
    image: blackoutsecure/emulationstation-de:latest
    container_name: emulationstation
    environment:
      - TZ=Etc/UTC
      - DISPLAY_NUM=0
      - XDG_RUNTIME_DIR=/run/esde
      - ESDE_USE_INTERNAL_X=1
      - UDEV=1
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all
    volumes:
      - /path/to/config:/config
      - /path/to/roms:/roms:ro
      - /path/to/bios:/bios:ro
    gpus: all
    devices:
      - /dev/input:/dev/input
      - /dev/snd:/dev/snd
    privileged: true
    tmpfs:
      - /var/tmp
      - /run:exec
    shm_size: 1gb
    restart: unless-stopped
```

**Arcade input and USB passthrough:**

```yaml
---
services:
  emulationstation:
    image: blackoutsecure/emulationstation-de:latest
    container_name: emulationstation
    environment:
      - TZ=Etc/UTC
      - DISPLAY_NUM=0
      - XDG_RUNTIME_DIR=/run/esde
      - ESDE_USE_INTERNAL_X=1
      - UDEV=1
    volumes:
      - /path/to/config:/config
      - /path/to/roms:/roms:ro
      - /path/to/bios:/bios:ro
    devices:
      - /dev/dri:/dev/dri
      - /dev/input:/dev/input
      - /dev/uinput:/dev/uinput
      - /dev/bus/usb:/dev/bus/usb
      - /dev/snd:/dev/snd
    privileged: true
    tmpfs:
      - /var/tmp
      - /run:exec
    shm_size: 1gb
    restart: unless-stopped
```

### Docker CLI ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

**Standalone (internal X server):**

```bash
docker run -d \
  --name=emulationstation \
  --restart unless-stopped \
  --privileged \
  -e TZ=Etc/UTC \
  -e DISPLAY_NUM=0 \
  -e XDG_RUNTIME_DIR=/run/esde \
  -e ESDE_USE_INTERNAL_X=1 \
  -e UDEV=1 \
  -v /path/to/config:/config \
  -v /path/to/roms:/roms:ro \
  -v /path/to/bios:/bios:ro \
  --device=/dev/dri:/dev/dri \
  --device=/dev/input:/dev/input \
  --device=/dev/snd:/dev/snd \
  --tmpfs /var/tmp \
  --tmpfs /run:exec \
  --shm-size=1gb \
  blackoutsecure/emulationstation-de:latest
```

**Using an existing host X server:**

```bash
xhost +local:docker
docker run -d \
  --name=emulationstation \
  --restart unless-stopped \
  --privileged \
  -e TZ=Etc/UTC \
  -e DISPLAY=:0 \
  -e UDEV=1 \
  -v /path/to/config:/config \
  -v /path/to/roms:/roms:ro \
  -v /path/to/bios:/bios:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  --device=/dev/dri:/dev/dri \
  --device=/dev/input:/dev/input \
  --device=/dev/snd:/dev/snd \
  --shm-size=1gb \
  blackoutsecure/emulationstation-de:latest
```

### Balena Deployment

This image can also be deployed to Balena-powered devices using the included [docker-compose.yml](docker-compose.yml) file (Balena labels are included and harmlessly ignored by standard Docker).

- Block metadata: [balena.yml](balena.yml)
- Compose file: [docker-compose.yml](docker-compose.yml)
- Publish workflow: [.github/workflows/publish.yml](.github/workflows/publish.yml) (balena-block-publish job)

```bash
balena push <your-app-slug>
```

**Recommended Balena fleet variables for Raspberry Pi 4:**

Set these via the Balena dashboard or CLI to ensure proper GPU and audio support:

```bash
# Allocate GPU memory for OpenGL rendering (default is only 16MB)
balena env set RESIN_HOST_CONFIG_gpu_mem 128 --fleet <your-fleet>

# Force HDMI output even if no display is detected at boot
balena env set BALENA_HOST_CONFIG_hdmi_force_hotplug 1 --fleet <your-fleet>

# Ensure audio device tree overlay is enabled
balena env set RESIN_HOST_CONFIG_dtparam '"i2c_arm=on","spi=on","audio=on"' --fleet <your-fleet>
```

For deployment via the web interface, use the deploy button in this repository. See [Balena documentation](https://docs.balena.io/) for details.

---

## RetroStack Emulator Integration

> [!IMPORTANT]
> ES-DE is a **frontend only** — it browses your game library and provides a controller-friendly UI, but it does **not** include any emulator. It launches emulators (typically RetroArch) as child processes. Without an emulator running, games will fail to launch with:
> ```
> Error: %EMULATOR_RETROARCH% -L %CORE_RETROARCH%/gambatte_libretro.so %ROM%
> ```

Emulators are provided by [RetroStack](https://github.com/blackoutsecure/docker-retrostack) — a companion project that packages RetroArch, PPSSPP, and Dolphin as separate Docker containers. Each RetroStack image can run standalone (starting its own internal Xorg server and launching the emulator GUI directly — no host X required) or in daemon mode for integration with ES-DE. In daemon mode, both containers share a control volume and the same X11 display. ES-DE communicates with emulator containers via FIFO control pipes. The emulator container exits automatically after the emulator process ends, or after an idle timeout (default 10 minutes, configurable via `RETROSTACK_IDLE_TIMEOUT`).

```
┌──────────────────────────────┐                 ┌──────────────────────────┐
│  RetroStack                  │                 │  emulationstation-de     │
│  (docker-retrostack)         │                 │  (this repo)             │
│                              │                 │                          │
│  Emulator binary stays here  │  control pipe   │  User selects game       │
│  Listens on FIFO for launch  │◀────────────────│  retrostack-emulator-    │
│  commands, runs emulator on  │  /run/retro*/   │  launch writes to FIFO   │
│  shared X11 display          │────────────────▶│  reads exit code back    │
│                              │  exit status    │                          │
└──────────────────────────────┘                 └──────────────────────────┘
```

```bash
# Start ES-DE + RetroStack emulators
docker compose --profile default --profile retrostack up -d
```

How it works:
1. **Startup**: RetroStack emulator containers create FIFO pipes at `/run/retrostack-emulators/<name>.cmd` and `.status`, then wait for a launch command (or time out after `RETROSTACK_IDLE_TIMEOUT` seconds)
2. **Discovery**: ES-DE discovers the pipes on startup and symlinks `retrostack-emulator-launch` as each emulator name on PATH
3. **Game launch**: When the user selects a game, ES-DE calls the symlink. `retrostack-emulator-launch` writes the args to the `.cmd` pipe
4. **Play**: The emulator container reads it and runs the game on the shared X11 display
5. **Return**: When the game exits, the emulator writes the exit code to the `.status` pipe, giving control back to ES-DE. The emulator container then stops

**Startup logs when RetroStack is connected:**
```
[svc-esde] Emulator: RetroStack [retroarch]
[svc-esde] RetroStack: retroarch (FIFO @ /run/retrostack-emulators)
```

**Startup logs when no emulators are found:**
```
[svc-esde] Emulator: WARNING no emulators found — games will fail
[svc-esde]   Start RetroStack: docker compose --profile retrostack up -d
```

### Control Pipe Protocol

Both containers share a volume at `/run/retrostack-emulators/`. Each emulator creates:

| File | Direction | Purpose |
|------|-----------|---------|
| `<name>.cmd` | ES-DE → Emulator | FIFO — write emulator args (one line, shell-quoted) |
| `<name>.status` | Emulator → ES-DE | FIFO — read exit code after game finishes |

### Supported Emulators

ES-DE supports [many emulators](https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE.md). RetroStack currently packages:

| Emulator | Docker Image Tag | What It Runs |
|----------|-----------------|-------------|
| RetroArch | `retrostack:retroarch` | Multi-system via libretro cores (recommended) |
| PPSSPP | `retrostack:ppsspp` | PlayStation Portable |
| Dolphin | `retrostack:dolphin-emu` | GameCube / Wii |

See [docker-retrostack](https://github.com/blackoutsecure/docker-retrostack) for adding new emulators.

### RetroStack Environment Variables

These variables are set in the `x-retrostack-common` anchor and inherited by all RetroStack services:

| Parameter | Default | Function |
|-----------|---------|----------|
| `DISPLAY` | `:0` | X11 display for emulator rendering |
| `PULSE_SERVER` | `unix:/run/pulse/native` | PulseAudio server socket |
| `RETROSTACK_IDLE_TIMEOUT` | `600` | Seconds to wait for a launch command before the container exits (default: `600`, set to `0` to disable) |
| `RETROSTACK_FRONTEND_MODE` | `daemon` | `standalone` (default in RetroStack) launches the emulator's own GUI; `daemon` listens on FIFO for ES-DE integration. Set to `daemon` here for integration mode |
| `RETROSTACK_EMULATORS_CONTROL` | `/run/retrostack-emulators` | Control pipe directory (client-side) |
| `RETROSTACK_USE_INTERNAL_X` | `1` | Start an internal Xorg server in standalone mode (`1`=auto, `0`=disabled — use external X socket). Not used in daemon mode |

---

## Parameters

### Compose Profiles

| Profile | Command | Description |
| --- | --- | --- |
| `default` | `docker compose --profile default up -d` | Local display / kiosk — direct output to a connected monitor via KMSDRM or X11. Best for arcade cabinets, HTPC, and Balena with a physical display. |
| `selkies` | `docker compose --profile selkies up -d` | Selkies WebRTC streaming — stream ES-DE to any web browser. Access at `https://<host>:3001` (default user: `abc` / password: `abc`). Best for remote play, headless servers, and cloud deployments. |
| `retrostack` | `docker compose --profile retrostack up -d` | RetroStack emulators (RetroArch). Also included in `retrostack-all`. Combine with `default` or `selkies`. |
| `retrostack-ppsspp` | `docker compose --profile retrostack-ppsspp up -d` | RetroStack PPSSPP emulator. |
| `retrostack-dolphin` | `docker compose --profile retrostack-dolphin up -d` | RetroStack Dolphin emulator. |
| `retrostack-all` | `docker compose --profile retrostack-all up -d` | All RetroStack emulators. |

**Combined example:**

```bash
docker compose --profile default --profile retrostack up -d
docker compose --profile selkies --profile retrostack up -d
```

**Build locally:**

```bash
docker compose --profile default build
docker compose --profile selkies build
```

### Environment Variables

#### Default (Local Display) Service

| Parameter | Function | Required |
| :----: | --- | :---: |
| `-e TZ=Etc/UTC` | Timezone | Optional |
| `-e DISPLAY_NUM=0` | X11 display number (used with internal X server) | Optional |
| `-e ESDE_USE_INTERNAL_X=1` | Start an internal Xorg server via startx (`1` for standalone/balena; `0` to use an external host X11 socket) | Optional |
| `-e UDEV=1` | Enable udev for input device discovery (keyboard, mouse, gamepad) | Recommended |
| `-e DISPLAY=:0` | Host X11 display (only needed when `ESDE_USE_INTERNAL_X=0`) | Conditional |
| `-e ESDE_ARGS=` | Extra command line flags appended to `es-de --home /config` | Optional |
| `-e APP_USER=abc` | Container user for ES-DE process execution (default: `abc`; LinuxServer.io standard) | Optional |
| `-e ESDE_HOME=/config` | ES-DE home directory for configuration and persistent data | Optional |
| `-e SDL_GAMECONTROLLERCONFIG=` | Manual SDL2 GameController mapping override for specific gamepads (see [Gamepad Mapping](#gamepad-mapping)) | Optional |
| `-e ESDE_AUDIO_OUTPUT=auto` | Audio output selection: `auto` (USB > 3.5mm > HDMI), `analog` (RPi 3.5mm jack), `hdmi`, `usb` | Optional |
| `-e LOCAL_AUDIO_SINK=` | Override auto-detect with a specific PulseAudio sink name | Optional |

#### Selkies (WebRTC Streaming) Service

| Parameter | Default | Function |
| :----: | :----: | --- |
| `TITLE` | `EmulationStation-DE` | Browser tab / window title |
| `NO_DECOR` | `true` | Fullscreen with no window borders |
| `CUSTOM_USER` | `abc` | WebRTC authentication username — **change this** |
| `PASSWORD` | `abc` | WebRTC authentication password — **change this** |
| `ESDE_ARGS` | | Optional extra flags for es-de |
| `HARDEN_DESKTOP` | `true` | Disables sudo, terminals, xdg-open (kiosk mode) |
| `HARDEN_OPENBOX` | `true` | Disables close button, right-click, Alt+F4 |
| `RESTART_APP` | `true` | Auto-restart ES-DE if closed |
| `START_DOCKER` | `false` | Docker-in-Docker (not needed) |
| `SELKIES_ENCODER` | `x264enc` | Video encoder for WebRTC stream |
| `SELKIES_FRAMERATE` | `60` | Streaming framerate |
| `SELKIES_AUDIO_ENABLED` | `true` | Enable audio streaming |
| `SELKIES_GAMEPAD_ENABLED` | `true` | Enable gamepad input via browser |
| `SELKIES_IS_MANUAL_RESOLUTION_MODE` | `true` | Lock resolution — dynamic resize can destroy the GLES context and crash ES-DE |
| `SELKIES_MANUAL_WIDTH` | `1920` | Locked stream width |
| `SELKIES_MANUAL_HEIGHT` | `1080` | Locked stream height |
| `SELKIES_CLIPBOARD_ENABLED` | `false` | Clipboard disabled — xclip hangs with no owner and floods logs |
| `SELKIES_CLIPBOARD_IN_ENABLED` | `false` | Clipboard input disabled |
| `SELKIES_CLIPBOARD_OUT_ENABLED` | `false` | Clipboard output disabled |
| `SELKIES_UI_SIDEBAR_SHOW_FILES` | `false` | Hide file browser panel |
| `SELKIES_UI_SIDEBAR_SHOW_APPS` | `false` | Hide apps panel |
| `SELKIES_UI_SIDEBAR_SHOW_CLIPBOARD` | `false` | Hide clipboard panel |
| `SELKIES_FILE_TRANSFERS` | | File transfers disabled |
| `SELKIES_COMMAND_ENABLED` | `false` | Command execution disabled |
| `HDMI_MIRROR` | `true` | Mirror output to physical HDMI display |
| `MIRROR_FRAMERATE` | `30` | Mirror FPS |
| `MIRROR_CONNECTOR_ID` | | DRM connector ID (auto-detect if empty) |
| `LOCAL_AUDIO` | `true` | Mirror audio to local USB/HDMI speakers |
| `LOCAL_AUDIO_SINK` | | PulseAudio sink name (auto-detect USB/ALSA) |
| `LOCAL_INPUT` | `true` | Forward local USB keyboard/mouse to Xvfb |
| `LOCAL_INPUT_GRAB` | `true` | Grab input exclusively (`false` to share with console) |

Selkies WebRTC access: port `3000` (HTTP) and port `3001` (HTTPS, primary access).

#### Audio Configuration (Default Service)

`ESDE_AUDIO_OUTPUT` controls which audio output to use:

| Value | Description |
| --- | --- |
| `auto` | USB > 3.5mm analog > HDMI (default) |
| `analog` | Force 3.5mm headphone jack (RPi only) |
| `hdmi` | Force HDMI audio |
| `usb` | Force USB audio device |

**Raspberry Pi audio notes:**
- For RPi 3.5mm audio, you **must** set the Balena device variable: `BALENA_HOST_CONFIG_dtparam = "audio=on"`
- For RPi HDMI audio, if no sound plays set: `BALENA_HOST_CONFIG_hdmi_drive = 2`

### Storage Mounts

| Parameter | Function | Required |
| :----: | --- | :---: |
| `-v /config` | ES-DE persistent settings, themes, gamelists, scraped media, and application state | Recommended |
| `-v /roms` | ROM library mount | Recommended |
| `-v /bios` | BIOS files for emulator backends that need them | Optional |
| `-v /tmp/.X11-unix:/tmp/.X11-unix:ro` | X11 socket for local display (only needed when `ESDE_USE_INTERNAL_X=0`) | Conditional |

**Named volumes (compose):**

| Volume | Purpose |
| --- | --- |
| `emulationstation-config` | ES-DE configuration and persistent data |
| `emulationstation-roms` | ROM library |
| `emulationstation-bios` | BIOS files for emulators |
| `retrostack-emulator-control` | FIFO control pipes shared with RetroStack containers |
| `retrostack-shared` | Gamepad DB and Xauthority shared with RetroStack containers |
| `x11-unix` | X11 socket shared between ES-DE and RetroStack containers |
| `pulse-socket` | PulseAudio socket shared between ES-DE and RetroStack containers |

### Devices

| Parameter | Function | Required |
| :----: | --- | :---: |
| `--device=/dev/dri:/dev/dri` | GPU passthrough for Intel/AMD rendering | Optional |
| `--device=/dev/input:/dev/input` | Gamepad and input passthrough | Optional |
| `--device=/dev/uinput:/dev/uinput` | Virtual input device support | Optional |
| `--device=/dev/bus/usb:/dev/bus/usb` | USB passthrough for cabinet and peripheral workflows | Optional |
| `--device=/dev/snd:/dev/snd` | Audio device passthrough | Optional |

### Runtime Security Defaults

| Parameter | Function |
| :----: | --- |
| `read_only: false` | Keep root filesystem writable for LSIO init ownership setup |
| `no-new-privileges:true` | Prevent privilege escalation |
| `tmpfs /tmp /var/tmp /run` | Writable runtime scratch paths |
| `shm_size: 1gb` | Shared memory for SDL and rendering stability |

---

## Configuration

The container expects persistent application data to live under `/config`, with ES-DE using `/config/ES-DE/` for its own files.

### `/config` - Configuration and Persistence

- Required: No, but recommended if you want settings and media to survive restarts
- Purpose: Stores ES-DE settings, themes, gamelists, scraped media, and other persistent application data
- Example: `-v /path/to/config:/config` or a named volume mapped to `/config`

### `/roms` - Content Library

- Required: Recommended
- Purpose: Mount your ROM library read-only into the container
- Example: `-v /path/to/roms:/roms:ro`

### `/bios` - Emulator Support Files

- Required: Optional
- Purpose: Supply BIOS files used by emulator backends outside the containerized frontend
- Example: `-v /path/to/bios:/bios:ro`

### Best Practices

- Keep `/config` persistent so ES-DE metadata and preferences survive container recreation
- Mount `/roms` and `/bios` read-only unless you have a specific reason to allow writes
- When using external X mode (`ESDE_USE_INTERNAL_X=0`), keep the X11 socket mount read-only and pair it with `DISPLAY`

---

## Application Setup

This image supports two display modes:

**Internal X server (default):** Set `ESDE_USE_INTERNAL_X=1` (the default in [docker-compose.yml](docker-compose.yml)). The container starts its own Xorg server — no host X server is required. This is the recommended mode for kiosk, cabinet, HTPC, and Balena deployments.

**External host X server:** Set `ESDE_USE_INTERNAL_X=0`, pass `DISPLAY`, and mount `/tmp/.X11-unix` from the host. Allow the local Docker client to access the X server with `xhost +local:docker`.

Hardware passthrough guidance:

- add `/dev/dri` for Intel or AMD GPU rendering
- add `/dev/input` for controller and input passthrough
- add `/dev/uinput` for virtual input workflows
- add `/dev/bus/usb` for cabinet and peripheral passthrough
- add `/dev/snd` for audio device passthrough
- use `gpus: all` plus the Nvidia environment variables when running with the Nvidia runtime
- set `UDEV=1` (default) and ensure the container is privileged for keyboard/mouse/gamepad discovery

---

## Build Locally

**Default base image (local X):**

```bash
docker build \
  --build-arg BASE_IMAGE_REGISTRY=ghcr.io \
  --build-arg BASE_IMAGE_NAME=linuxserver/baseimage-ubuntu \
  --build-arg BASE_IMAGE_VARIANT=noble \
  --build-arg ESDE_VERSION=stable-3.4 \
  --build-arg ESDE_CMAKE_BUILD_TYPE=Release \
  --build-arg ESDE_GIT_DEPTH=1 \
  --build-arg ESDE_STRIP_BINARIES=1 \
  --build-arg ESDE_APPLICATION_UPDATER=off \
  --build-arg ESDE_DEINIT_ON_LAUNCH=off \
  --build-arg ESDE_GLES=off \
  --build-arg ESDE_VIDEO_HW_DECODING=off \
  --build-arg ESDE_EXTRA_CMAKE_ARGS="" \
  --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --build-arg VERSION=local \
  -t docker-emulationstation-de:local .
```

**Selkies base image (browser-based streaming):**

```bash
docker build \
  --build-arg BASE_IMAGE_REGISTRY=ghcr.io \
  --build-arg BASE_IMAGE_NAME=linuxserver/baseimage-selkies \
  --build-arg BASE_IMAGE_VARIANT=ubuntunoble \
  --build-arg ESDE_VERSION=stable-3.4 \
  --build-arg ESDE_CMAKE_BUILD_TYPE=Release \
  --build-arg ESDE_GIT_DEPTH=1 \
  --build-arg ESDE_STRIP_BINARIES=1 \
  --build-arg ESDE_APPLICATION_UPDATER=off \
  --build-arg ESDE_DEINIT_ON_LAUNCH=off \
  --build-arg ESDE_GLES=off \
  --build-arg ESDE_VIDEO_HW_DECODING=off \
  --build-arg ESDE_EXTRA_CMAKE_ARGS="" \
  --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --build-arg VERSION=local-selkies \
  -t docker-emulationstation-de:local-selkies .
```

Optional build toggles:

- `ESDE_GLES=on`
- `ESDE_DEINIT_ON_LAUNCH=on`
- `ESDE_VIDEO_HW_DECODING=on`
- `ESDE_APPLICATION_UPDATER=off|on`
- `ESDE_EXTRA_CMAKE_ARGS`

Example for a GLES-first arm64 target:

```bash
docker build \
  --build-arg ESDE_VERSION=master \
  --build-arg ESDE_CMAKE_BUILD_TYPE=RelWithDebInfo \
  --build-arg ESDE_STRIP_BINARIES=0 \
  --build-arg ESDE_GLES=on \
  --build-arg ESDE_DEINIT_ON_LAUNCH=on \
  -t docker-emulationstation-de:dev-aarch64-gles .
```

---

## Troubleshooting

### Display errors on startup

**Internal X server (`ESDE_USE_INTERNAL_X=1`):**
- ensure the container is running with `privileged: true`
- check container logs for Xorg errors (`ESDE_XORG_VERBOSE=1` enables verbose X logging)
- verify `/dev/dri` is passed through for GPU access

**External host X server (`ESDE_USE_INTERNAL_X=0`):**
- verify `DISPLAY` matches your host display
- verify `/tmp/.X11-unix` is mounted
- ensure the host X server allows the container to connect (`xhost +local:docker`)

### Input devices not detected

- ensure `UDEV=1` is set (the default in [docker-compose.yml](docker-compose.yml)) — without udev, Xorg cannot discover keyboard, mouse, or gamepad devices
- the container must run in privileged mode for udev to access `/dev/input` devices
- use one of the hardware passthrough compose examples in this README
- validate permissions for `/dev/input`, `/dev/uinput`, and any USB devices in use
- check container logs for `[svc-esde] Starting udevd` to confirm udev started successfully

### Gamepad Mapping

ES-DE uses SDL2's **GameController API**, which requires a known button mapping to recognise a gamepad. Without a mapping, a gamepad may show up in the kernel (`/dev/input/js*`) but remain invisible to ES-DE.

This image handles gamepad mapping automatically with three layers (highest priority first):

| Priority | Source | Covers |
|----------|--------|--------|
| 1 | `SDL_GAMECONTROLLERCONFIG` env var | User manual overrides |
| 2 | Auto-generated generic mappings | Unknown/unmapped devices (e.g. DragonRise) |
| 3 | Bundled community [gamecontrollerdb.txt](https://github.com/gabomdq/SDL_GameControllerDB) | ~3000 known gamepads |
| 4 | SDL2 built-in DB | Major brand controllers (Xbox, PlayStation, Switch) |

**Most gamepads work out of the box.** If yours doesn't, or the auto-generated mapping has incorrect button assignments:

1. Find your gamepad's SDL2 GUID — check the startup logs for the `[gamepad-map]` lines, or run `sdl2-jstest --list` inside the container
2. Generate a correct mapping at [SDL_GameControllerDB](https://github.com/gabomdq/SDL_GameControllerDB) or [General Arcade Gamepad Tool](https://generalarcade.com/gamepadtool/)
3. Set the mapping in your compose environment:

```yaml
environment:
  SDL_GAMECONTROLLERCONFIG: "03000000790000001100000000000000,DragonRise Generic USB Joystick,a:b2,b:b1,x:b3,y:b0,back:b8,start:b9,leftshoulder:b4,rightshoulder:b5,dpup:-a1,dpdown:+a1,dpleft:-a0,dpright:+a0,platform:Linux,"
```

**Startup log example when auto-mapping works:**
```
[svc-esde] [gamepad-map] Auto-mapped: DragonRise Inc.   Generic   USB  Joystick   -> 03000000790000001100000000000000
[svc-esde] Input: 11 events, 4 joysticks [...] | 1 gamepad(s) auto-mapped
```

### AArch64 systems with GLES-only drivers

- rebuild with `ESDE_GLES=on`
- if running on Balena arm64 devices, make sure the Balena build sets `ESDE_GLES=on` or use the repository's `docker-compose.yml` default
- or try:

```bash
MESA_GL_VERSION_OVERRIDE=3.3 ./es-de
```

If you see `eglCreateContext failed` with `EGL_BAD_MATCH`, the image was typically built for desktop OpenGL while the device stack expects GLES.

- or use Zink if needed:

```bash
MESA_GL_VERSION_OVERRIDE=3.3 MESA_LOADER_DRIVER_OVERRIDE=zink ./es-de
```

---

## Release & Versioning

- Stable Docker and Balena block publishing is handled by [.github/workflows/publish.yml](.github/workflows/publish.yml)
- GitHub release publishing is handled by [.github/workflows/release.yml](.github/workflows/release.yml)
- Upstream ES-DE stable release monitoring is handled by [.github/workflows/upstream-esde-release-monitor.yml](.github/workflows/upstream-esde-release-monitor.yml)

Stable builds follow upstream ES-DE release metadata. Dev builds follow the upstream `master` branch.

---

## Support & Getting Help

- GitHub repository: [blackoutsecure/docker-emulationstation-de](https://github.com/blackoutsecure/docker-emulationstation-de)
- Docker Hub image: [blackoutsecure/emulationstation-de](https://hub.docker.com/r/blackoutsecure/emulationstation-de)
- Upstream ES-DE project: [es-de/emulationstation-de](https://gitlab.com/es-de/emulationstation-de)

---

## References

- ES-DE: <https://es-de.org>
- ES-DE source: <https://gitlab.com/es-de/emulationstation-de>
- ES-DE user guide: <https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE.md>
- ES-DE development user guide: <https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE-DEV.md?ref_type=heads>
- Linux build/install docs: <https://gitlab.com/es-de/emulationstation-de/-/blob/master/INSTALL.md#building-on-linux-and-unix>
- Linux dev build docs: <https://gitlab.com/es-de/emulationstation-de/-/blob/master/INSTALL-DEV.md>
- Linux AArch64 dev docs: <https://gitlab.com/es-de/emulationstation-de/-/blob/master/LINUX-AARCH64-DEV.md>
- LSIO Ubuntu base image: <https://docs.linuxserver.io/images/docker-baseimage-ubuntu/>
- LSIO Selkies base image: <https://github.com/linuxserver/docker-baseimage-selkies>
- SDL_GameControllerDB (community gamepad mappings): <https://github.com/gabomdq/SDL_GameControllerDB>
