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
  - [RetroArch \& Emulator Setup](#retroarch--emulator-setup)
    - [RetroArch Sidecar](#retroarch-sidecar)
    - [Using Other Emulators](#using-other-emulators)
  - [Parameters](#parameters)
    - [Environment Variables](#environment-variables)
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

## RetroArch & Emulator Setup

> [!IMPORTANT]
> ES-DE is a **frontend only** — it browses your game library and provides a controller-friendly UI, but it does **not** include any emulator. It launches emulators (typically RetroArch) as child processes. Without an emulator installed, games will fail to launch with:
> ```
> Error: %EMULATOR_RETROARCH% -L %CORE_RETROARCH%/gambatte_libretro.so %ROM%
> ```

We default to and support [linuxserver/docker-retroarch](https://docs.linuxserver.io/images/docker-retroarch/) as the RetroArch version. The RetroArch binary must be in the **same container filesystem** as ES-DE (ES-DE calls `exec()` — a direct process spawn that shares the display, GPU, audio, and input context).

> [!NOTE]
> The [linuxserver/docker-retroarch](https://docs.linuxserver.io/images/docker-retroarch/) image is a standalone Selkies-based streaming app with its own display server. It cannot be used as a backend for ES-DE directly. Our sidecar extracts the same RetroArch package and provisions it onto a shared volume that ES-DE can access.

### RetroArch Sidecar

The sidecar uses the official [linuxserver/docker-retroarch](https://docs.linuxserver.io/images/docker-retroarch/) image directly — **no RetroArch compilation or package install**. We only add libretro cores and a thin provision script on top. This gives you **independent update cycles** — update RetroArch without rebuilding ES-DE, and vice versa.

```bash
# Start ES-DE + emulator sidecar
docker compose --profile default --profile sidecar up -d
```

How it works:
1. `esde-emulator-provider` is based on `lscr.io/linuxserver/retroarch:latest` with libretro cores added. It copies the RetroArch binary, cores, and shared libraries to a volume at `/opt/emulators/retroarch/`, then exits
2. ES-DE container mounts the same volume at `/opt/emulators`
3. On startup, ES-DE scans `/opt/emulators/*/` and symlinks `esde-emuwrap` as each emulator name on PATH
4. `esde-emuwrap` resolves the emulator from its symlink name (`$0`), sets `LD_LIBRARY_PATH` to the sidecar's bundled libraries, then exec's the real binary

**Update RetroArch only** (pulls latest linuxserver image):
```bash
docker compose --profile sidecar build --pull esde-emulator-provider
docker compose --profile sidecar up esde-emulator-provider
# Next game launch uses the new version — no ES-DE restart needed
```

**Pin a specific RetroArch version:**
```bash
docker compose --profile sidecar build \
  --build-arg RETROARCH_IMAGE=lscr.io/linuxserver/retroarch:1.22.2 \
  esde-emulator-provider
```

**Update ES-DE only:**
```bash
docker compose --profile default build emulationstation
docker compose --profile default up -d emulationstation
# Emulator volume is untouched
```

**Startup logs when sidecar is working:**
```
[svc-esde] Sidecar retroarch detected; linked via esde-emuwrap as /usr/local/bin/retroarch
[svc-esde]   Version: RetroArch 1.22.2 (Git ...)
[svc-esde] RetroArch found (sidecar): RetroArch 1.22.2 (Git ...)
[svc-esde] Found 6 libretro core(s).
[svc-esde]   Core: gambatte_libretro.so
[svc-esde]   Core: mgba_libretro.so
[svc-esde]   Core: snes9x_libretro.so
...
```

**Startup logs when sidecar hasn't run:**
```
[svc-esde] Note: /opt/emulators volume is mounted but empty.
[svc-esde]   The esde-emulator-provider sidecar may not have run yet.
[svc-esde]   Start it: docker compose --profile sidecar up esde-emulator-provider
[svc-esde] ================================================
[svc-esde] WARNING: RetroArch is NOT installed.
...
```

**Game launch error when emulator wrapper can't find the binary:**
```
[esde-emuwrap:retroarch] ================================================
[esde-emuwrap:retroarch] ERROR: retroarch not found at /opt/emulators/retroarch/bin/retroarch
[esde-emuwrap:retroarch] Directory /opt/emulators/retroarch exists but appears empty.
[esde-emuwrap:retroarch] The emulator-provider sidecar has not run yet.
[esde-emuwrap:retroarch]
[esde-emuwrap:retroarch] To fix, start the sidecar:
[esde-emuwrap:retroarch]   docker compose --profile sidecar up esde-emulator-provider
...
```

### Using Other Emulators

The sidecar pattern is generic. ES-DE supports [many emulators](https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE.md) besides RetroArch:

| Emulator | ES-DE Variable | What It Runs |
|----------|---------------|-------------|
| RetroArch | `%EMULATOR_RETROARCH%` | Multi-system via libretro cores |
| PPSSPP | `%EMULATOR_PPSSPP%` | PlayStation Portable |
| Dolphin | `%EMULATOR_DOLPHIN%` | GameCube / Wii |
| PCSX2 | `%EMULATOR_PCSX2%` | PlayStation 2 |
| Flycast | `%EMULATOR_FLYCAST%` | Dreamcast |
| melonDS | `%EMULATOR_MELONDS%` | Nintendo DS |

Any emulator can be provisioned the same way: `esde-provision` copies the binary + libraries to `/opt/emulators/<name>/`, and `esde-emuwrap` on the ES-DE side resolves the emulator from its symlink name and handles `LD_LIBRARY_PATH` isolation automatically.

---

## Parameters

### Environment Variables

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

### Storage Mounts

| Parameter | Function | Required |
| :----: | --- | :---: |
| `-v /config` | ES-DE persistent settings, themes, gamelists, scraped media, and application state | Recommended |
| `-v /roms` | ROM library mount | Recommended |
| `-v /bios` | BIOS files for emulator backends that need them | Optional |
| `-v /tmp/.X11-unix:/tmp/.X11-unix:ro` | X11 socket for local display (only needed when `ESDE_USE_INTERNAL_X=0`) | Conditional |

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
