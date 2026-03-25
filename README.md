<p align="center">
  <img src="https://raw.githubusercontent.com/blackoutsecure/docker-emulationstation-de/main/logo.png" alt="emulationstation-de logo" width="200">
</p>

# docker-emulationstation-de

[![GitHub Stars](https://img.shields.io/github/stars/blackoutsecure/docker-emulationstation-de?style=flat-square&color=E7931D&logo=github)](https://github.com/blackoutsecure/docker-emulationstation-de/stargazers)
[![Docker Pulls](https://img.shields.io/docker/pulls/blackoutsecure/docker-emulationstation-de?style=flat-square&color=E7931D&logo=docker&logoColor=FFFFFF)](https://hub.docker.com/r/blackoutsecure/emulationstation-de)
[![GitHub Release](https://img.shields.io/github/release/blackoutsecure/docker-emulationstation-de.svg?style=flat-square&color=E7931D&logo=github&logoColor=FFFFFF)](https://github.com/blackoutsecure/docker-emulationstation-de/releases)
[![Release CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-emulationstation-de/release.yml?style=flat-square&label=release%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-emulationstation-de/actions/workflows/release.yml)
[![Docker CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-emulationstation-de/dockerhub-publish.yml?style=flat-square&label=docker%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-emulationstation-de/actions/workflows/dockerhub-publish.yml)
[![Balena CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-emulationstation-de/balenablock-publish.yml?style=flat-square&label=balena%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-emulationstation-de/actions/workflows/balenablock-publish.yml)
[![License](https://img.shields.io/github/license/blackoutsecure/docker-emulationstation-de?style=flat-square)](LICENSE)

Unofficial community image for [ES-DE Frontend](https://gitlab.com/es-de/emulationstation-de), built with LinuxServer.io-style container patterns for Debian, hardened runtime defaults, direct local-display operation, and optional Balena publishing.

Sponsored and maintained by [Blackout Secure](https://blackoutsecure.app).

> [!IMPORTANT]
> This repository is not an official LinuxServer.io image release.

## Overview

This project packages upstream [ES-DE Frontend](https://gitlab.com/es-de/emulationstation-de) into an easy-to-run container image for cabinets, desktops, HTPCs, and handheld Linux systems where direct GPU and input passthrough matters more than browser remoting.

Quick links:

- Docker Hub listing: [blackoutsecure/docker-emulationstation-de](https://hub.docker.com/r/blackoutsecure/docker-emulationstation-de)
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

**5-minute local X11 setup:**

```bash
xhost +local:docker
docker compose up -d
```

If your host display is not `:0`, update [docker-compose.yml](docker-compose.yml) before starting.

This image assumes:

- a running X server on the host
- `DISPLAY` passed into the container
- `/tmp/.X11-unix` mounted into the container

```bash
# Pull latest
docker pull blackoutsecure/docker-emulationstation-de

# Pull specific version
docker pull blackoutsecure/docker-emulationstation-de:latest-dev
```

For compose examples, device passthrough, Balena deployment, and local build options, see [Usage](#usage) below.

---

## Image Availability

**Docker Hub (Recommended):**

- All images are published to [Docker Hub](https://hub.docker.com/r/blackoutsecure/docker-emulationstation-de)
- Simple pull command: `docker pull blackoutsecure/docker-emulationstation-de:latest`
- Multi-arch support: amd64, arm64
- No registry prefix needed when pulling from Docker Hub

```bash
# Pull latest
docker pull blackoutsecure/docker-emulationstation-de

# Pull specific version
docker pull blackoutsecure/docker-emulationstation-de:latest-dev

# Pull architecture-specific tags
docker pull blackoutsecure/docker-emulationstation-de:latest-amd64
docker pull blackoutsecure/docker-emulationstation-de:latest-arm64
```

---

## About The ES-DE Application

[ES-DE Frontend](https://gitlab.com/es-de/emulationstation-de) is an EmulationStation-derived frontend used to browse ROM libraries, present metadata and media, and launch external emulators from a controller-friendly interface.

This container packages ES-DE for direct local-display environments rather than browser delivery. The runtime is tuned around X11 socket mounting, writable config persistence, and optional passthrough for GPU, input, and USB devices.

Upstream project details:

- Main project site: [es-de.org](https://es-de.org)
- Source repository: [es-de/emulationstation-de](https://gitlab.com/es-de/emulationstation-de)
- Upstream user guide: [USERGUIDE.md](https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE.md)
- Upstream development user guide: [USERGUIDE-DEV.md](https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE-DEV.md?ref_type=heads)
- Upstream build and install documentation: [INSTALL.md](https://gitlab.com/es-de/emulationstation-de/-/blob/master/INSTALL.md#building-on-linux-and-unix)

---

## Supported Architectures

This image is published as a multi-arch manifest. Pulling `blackoutsecure/docker-emulationstation-de:latest` retrieves the correct image for your host architecture.

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | latest-amd64 |
| arm64 | latest-arm64 |

---

## Usage

### Docker Compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

```yaml
---
services:
  emulationstation:
    image: blackoutsecure/docker-emulationstation-de:latest
    container_name: emulationstation
    read_only: false
    environment:
      - TZ=Etc/UTC
      - DISPLAY=:0
      - ESDE_ARGS=
      # - APP_USER=abc        # Optional: set to override the default container user (default: abc)
      # - ESDE_HOME=/config   # Optional: set to override ES-DE home directory
    volumes:
      - /path/to/config:/config
      - /path/to/roms:/roms:ro
      - /path/to/bios:/bios:ro
      - /tmp/.X11-unix:/tmp/.X11-unix:ro
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
    image: blackoutsecure/docker-emulationstation-de:latest
    container_name: emulationstation
    read_only: false
    environment:
      - TZ=Etc/UTC
      - DISPLAY=:0
      - ESDE_ARGS=
      # - APP_USER=abc        # Optional: set to override the default container user (default: abc)
      # - ESDE_HOME=/config   # Optional: set to override ES-DE home directory
    volumes:
      - /path/to/config:/config
      - /path/to/roms:/roms:ro
      - /path/to/bios:/bios:ro
      - /tmp/.X11-unix:/tmp/.X11-unix:ro
    devices:
      - /dev/dri:/dev/dri
      - /dev/input:/dev/input
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp:exec,nosuid,nodev,size=512m
      - /var/tmp:nosuid,nodev,size=256m
      - /run:exec,nosuid,nodev,size=64m
    shm_size: 1gb
    restart: unless-stopped
```

**Nvidia GPU:**

```yaml
---
services:
  emulationstation:
    image: blackoutsecure/docker-emulationstation-de:latest
    container_name: emulationstation
    read_only: false
    environment:
      - TZ=Etc/UTC
      - DISPLAY=:0
      - ESDE_ARGS=
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all
      # - APP_USER=abc        # Optional: set to override the default container user (default: abc)
      # - ESDE_HOME=/config   # Optional: set to override ES-DE home directory
    volumes:
      - /path/to/config:/config
      - /path/to/roms:/roms:ro
      - /path/to/bios:/bios:ro
      - /tmp/.X11-unix:/tmp/.X11-unix:ro
    gpus: all
    devices:
      - /dev/input:/dev/input
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp:exec,nosuid,nodev,size=512m
      - /var/tmp:nosuid,nodev,size=256m
      - /run:exec,nosuid,nodev,size=64m
    shm_size: 1gb
    restart: unless-stopped
```

**Arcade input and USB passthrough:**

```yaml
---
services:
  emulationstation:
    image: blackoutsecure/docker-emulationstation-de:latest
    container_name: emulationstation
    read_only: false
    environment:
      - TZ=Etc/UTC
      - DISPLAY=:0
      - ESDE_ARGS=
      # - APP_USER=abc        # Optional: set to override the default container user (default: abc)
      # - ESDE_HOME=/config   # Optional: set to override ES-DE home directory
    volumes:
      - /path/to/config:/config
      - /path/to/roms:/roms:ro
      - /path/to/bios:/bios:ro
      - /tmp/.X11-unix:/tmp/.X11-unix:ro
    devices:
      - /dev/input:/dev/input
      - /dev/uinput:/dev/uinput
      - /dev/dri:/dev/dri
      - /dev/bus/usb:/dev/bus/usb
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp:exec,nosuid,nodev,size=512m
      - /var/tmp:nosuid,nodev,size=256m
      - /run:exec,nosuid,nodev,size=64m
    shm_size: 1gb
    restart: unless-stopped
```

### Docker CLI ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

Leave the root filesystem writable for LSIO init ownership setup. Do not add `--read-only` for this image.

```bash
docker run -d \
  --name=emulationstation \
  --restart unless-stopped \
  --security-opt no-new-privileges:true \
  -e TZ=Etc/UTC \
  -e DISPLAY=:0 \
  -e ESDE_ARGS="" \
  -e APP_USER=abc \
  -e ESDE_HOME=/config \
  -v /path/to/config:/config \
  -v /path/to/roms:/roms:ro \
  -v /path/to/bios:/bios:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  --tmpfs /tmp:exec,nosuid,nodev,size=512m \
  --tmpfs /var/tmp:nosuid,nodev,size=256m \
  --tmpfs /run:exec,nosuid,nodev,size=64m \
  --shm-size=1gb \
  blackoutsecure/docker-emulationstation-de:latest
```

### Balena Deployment

This image can also be deployed to Balena-powered devices using the included [balena-compose.yml](balena-compose.yml) file.

- Block metadata: [balena.yml](balena.yml)
- Balena deployment compose: [balena-compose.yml](balena-compose.yml)
- Publish workflow: [.github/workflows/balenablock-publish.yml](.github/workflows/balenablock-publish.yml)

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

## Parameters

### Environment Variables

| Parameter | Function | Required |
| :----: | --- | :---: |
| `-e TZ=Etc/UTC` | Timezone | Optional |
| `-e DISPLAY=:0` | Host X11 display | Required |
| `-e ESDE_ARGS=` | Extra command line flags appended to `es-de --home /config` | Optional |
| `-e APP_USER=abc` | Container user for ES-DE process execution (default: `abc`; LinuxServer.io standard) | Optional |
| `-e ESDE_HOME=/config` | ES-DE home directory for configuration and persistent data | Optional |

### Storage Mounts

| Parameter | Function | Required |
| :----: | --- | :---: |
| `-v /config` | ES-DE persistent settings, themes, gamelists, scraped media, and application state | Recommended |
| `-v /roms` | ROM library mount | Recommended |
| `-v /bios` | BIOS files for emulator backends that need them | Optional |
| `-v /tmp/.X11-unix:/tmp/.X11-unix:ro` | X11 socket for local display | Required |

### Devices

| Parameter | Function | Required |
| :----: | --- | :---: |
| `--device=/dev/dri:/dev/dri` | GPU passthrough for Intel/AMD rendering | Optional |
| `--device=/dev/input:/dev/input` | Gamepad and input passthrough | Optional |
| `--device=/dev/uinput:/dev/uinput` | Virtual input device support | Optional |
| `--device=/dev/bus/usb:/dev/bus/usb` | USB passthrough for cabinet and peripheral workflows | Optional |

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
- Keep the X11 socket mount read-only and pair it with `DISPLAY`

---

## Application Setup

This image is designed for direct local display environments and expects a running X server on the host.

Required host integration:

- pass `DISPLAY` into the container
- mount `/tmp/.X11-unix` into the container
- allow the local Docker client to access the X server, for example with `xhost +local:docker`

Hardware passthrough guidance:

- add `/dev/dri` for Intel or AMD GPU rendering
- add `/dev/input` for controller and input passthrough
- add `/dev/uinput` for virtual input workflows
- add `/dev/bus/usb` for cabinet and peripheral passthrough
- use `gpus: all` plus the Nvidia environment variables when running with the Nvidia runtime

---

## Build Locally

```bash
docker build \
  --build-arg BASE_IMAGE_REGISTRY=ghcr.io \
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

- verify `DISPLAY`
- verify `/tmp/.X11-unix` is mounted
- ensure the host X server allows the container to connect

### Input devices not detected

- use one of the hardware passthrough compose examples in this README
- validate permissions for `/dev/input`, `/dev/uinput`, and any USB devices in use

### AArch64 systems with GLES-only drivers

- rebuild with `ESDE_GLES=on`
- if running on Balena arm64 devices, make sure the Balena build sets `ESDE_GLES=on` or use the repository's `balena-compose.yml` default
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

- Stable Docker publishing is handled by [.github/workflows/dockerhub-publish.yml](.github/workflows/dockerhub-publish.yml)
- GitHub release publishing is handled by [.github/workflows/release.yml](.github/workflows/release.yml)
- Upstream ES-DE stable release monitoring is handled by [.github/workflows/upstream-esde-release-monitor.yml](.github/workflows/upstream-esde-release-monitor.yml)
- Balena block publishing is handled by [.github/workflows/balenablock-publish.yml](.github/workflows/balenablock-publish.yml)

Stable builds follow upstream ES-DE release metadata. Dev builds follow the upstream `master` branch.

---

## Support & Getting Help

- GitHub repository: [blackoutsecure/docker-emulationstation-de](https://github.com/blackoutsecure/docker-emulationstation-de)
- Docker Hub image: [blackoutsecure/docker-emulationstation-de](https://hub.docker.com/r/blackoutsecure/docker-emulationstation-de)
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
- LSIO Debian base image: <https://docs.linuxserver.io/images/docker-baseimage-debian/>
