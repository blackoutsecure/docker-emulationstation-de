# syntax=docker/dockerfile:1.7
#
# Unified Dockerfile for EmulationStation-DE
#
# Two build targets:
#   default  — Local display / kiosk (KMSDRM, X11, hardware passthrough)
#   selkies  — Selkies WebRTC remote access (stream to web browser)
#
# Build examples:
#   docker build --target default -t esde:latest .
#   docker build --target selkies -t esde:latest-selkies .

ARG BASE_IMAGE_REGISTRY=ghcr.io
ARG BASE_IMAGE_NAME=linuxserver/baseimage-ubuntu
ARG BASE_IMAGE_VARIANT=noble
ARG BASE_IMAGE=${BASE_IMAGE_REGISTRY}/${BASE_IMAGE_NAME}:${BASE_IMAGE_VARIANT}

# Selkies runtime base (only used by the "selkies" target)
ARG SELKIES_BASE_IMAGE_REGISTRY=ghcr.io
ARG SELKIES_BASE_IMAGE_NAME=linuxserver/baseimage-selkies
ARG SELKIES_BASE_IMAGE_VARIANT=ubuntunoble
ARG SELKIES_BASE_IMAGE=${SELKIES_BASE_IMAGE_REGISTRY}/${SELKIES_BASE_IMAGE_NAME}:${SELKIES_BASE_IMAGE_VARIANT}

ARG BUILD_OUTPUT_DIR=/out
ARG ESDE_REPO=https://gitlab.com/es-de/emulationstation-de.git
ARG ESDE_VERSION=stable-3.4
ARG ESDE_GIT_DEPTH=1
ARG ESDE_CMAKE_BUILD_TYPE=Release
ARG ESDE_STRIP_BINARIES=1
ARG ESDE_APPLICATION_UPDATER=off
ARG ESDE_DEINIT_ON_LAUNCH=off
ARG ESDE_GLES=on
ARG ESDE_VIDEO_HW_DECODING=off
ARG ESDE_EXTRA_CMAKE_ARGS=
ARG VCS_URL=https://github.com/blackoutsecure/docker-emulationstation-de

FROM ${BASE_IMAGE} AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_OUTPUT_DIR
ARG ESDE_REPO
ARG ESDE_VERSION
ARG ESDE_GIT_DEPTH
ARG ESDE_CMAKE_BUILD_TYPE
ARG ESDE_STRIP_BINARIES
ARG ESDE_APPLICATION_UPDATER
ARG ESDE_DEINIT_ON_LAUNCH
ARG ESDE_GLES
ARG ESDE_VIDEO_HW_DECODING
ARG ESDE_EXTRA_CMAKE_ARGS
ARG VCS_URL

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      cmake \
      git \
      gettext \
      libharfbuzz-dev \
      libicu-dev \
      libsdl2-dev \
      libavcodec-dev \
      libavfilter-dev \
      libavformat-dev \
      libavutil-dev \
      libfreeimage-dev \
      libfreetype6-dev \
      libgit2-dev \
      libcurl4-openssl-dev \
      libpugixml-dev \
      libasound2-dev \
      libbluetooth-dev \
      libgl1-mesa-dev \
      libpoppler-cpp-dev && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth "${ESDE_GIT_DEPTH}" --branch "${ESDE_VERSION}" \
  "${ESDE_REPO}" /tmp/esde && \
    BUILD_DATE="$(git -C /tmp/esde log -1 --format=%cI 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ)" && \
    VERSION="$(git -C /tmp/esde describe --tags --always --dirty 2>/dev/null || echo "${ESDE_VERSION}")" && \
    VCS_REF="$(git -C /tmp/esde rev-parse HEAD 2>/dev/null || echo unknown)" && \
    printf 'BUILD_DATE=%s\nVERSION=%s\nVCS_REF=%s\nVCS_URL=%s\nESDE_VERSION=%s\nESDE_CMAKE_BUILD_TYPE=%s\nESDE_APPLICATION_UPDATER=%s\nESDE_DEINIT_ON_LAUNCH=%s\nESDE_GLES=%s\nESDE_VIDEO_HW_DECODING=%s\nESDE_EXTRA_CMAKE_ARGS=%s\n' "${BUILD_DATE}" "${VERSION}" "${VCS_REF}" "${VCS_URL}" "${ESDE_VERSION}" "${ESDE_CMAKE_BUILD_TYPE}" "${ESDE_APPLICATION_UPDATER}" "${ESDE_DEINIT_ON_LAUNCH}" "${ESDE_GLES}" "${ESDE_VIDEO_HW_DECODING}" "${ESDE_EXTRA_CMAKE_ARGS}" > /tmp/esde-build-metadata.env && \
    cmake -S /tmp/esde -B /tmp/esde/build \
      -DAPPLICATION_UPDATER="${ESDE_APPLICATION_UPDATER}" \
      -DDEINIT_ON_LAUNCH="${ESDE_DEINIT_ON_LAUNCH}" \
      -DGLES="${ESDE_GLES}" \
      -DVIDEO_HW_DECODING="${ESDE_VIDEO_HW_DECODING}" \
      -DCMAKE_BUILD_TYPE="${ESDE_CMAKE_BUILD_TYPE}" \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      ${ESDE_EXTRA_CMAKE_ARGS} && \
    cmake --build /tmp/esde/build -j"$(nproc)" && \
    mkdir -p "${BUILD_OUTPUT_DIR}/usr/local/share/es-de" && \
    install -D -m 0644 /tmp/esde-build-metadata.env "${BUILD_OUTPUT_DIR}/usr/local/share/es-de/build-metadata.env" && \
    if [ "${ESDE_STRIP_BINARIES}" = "1" ]; then \
      DESTDIR="${BUILD_OUTPUT_DIR}" cmake --install /tmp/esde/build --strip; \
    else \
      DESTDIR="${BUILD_OUTPUT_DIR}" cmake --install /tmp/esde/build; \
    fi

# --- Download bundled homebrew ROMs ---
# "Libbet and the Magic Floor" by Damian Yerrick (pinobatch) - zlib license
# Source: https://github.com/pinobatch/libbet  License: zlib
RUN mkdir -p "${BUILD_OUTPUT_DIR}/defaults/roms/gb" && \
    curl -fsSL -o "${BUILD_OUTPUT_DIR}/defaults/roms/gb/Libbet and the Magic Floor.gb" \
      https://github.com/pinobatch/libbet/releases/download/v0.08/libbet.gb

# ============================================================================
# Stage 2a — Runtime: Local display (default target)
#   docker build --target default .
# ============================================================================
FROM ${BASE_IMAGE} AS default
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_DATE
ARG VERSION
ARG ESDE_VERSION
ARG VCS_URL
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Blackout Secure - https://blackoutsecure.app/"
LABEL org.opencontainers.image.title="docker-emulationstation-de" \
  org.opencontainers.image.description="LinuxServer.io style Ubuntu containerized build of EmulationStation-DE for local display and arcade-oriented hardware passthrough." \
    org.opencontainers.image.url="${VCS_URL}" \
    org.opencontainers.image.source="${VCS_URL}" \
    org.opencontainers.image.revision="unknown" \
    org.opencontainers.image.created="unknown" \
    org.opencontainers.image.version="unknown" \
    org.opencontainers.image.licenses="MIT"

ENV \
  HOME="/config" \
  ESDE_HOME="/config" \
  XDG_RUNTIME_DIR="/run/esde" \
  APP_USER="abc"

RUN echo "**** install runtime dependencies ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      libsdl2-2.0-0 \
      libavcodec60 \
      libavfilter9 \
      libavformat60 \
      libavutil58 \
      libfreeimage3 \
      libfreetype6 \
      libgit2-1.7 \
      libcurl4t64 \
      libpugixml1v5 \
      libasound2t64 \
      libbluetooth3 \
      libharfbuzz0b \
      libicu74 \
      libgl1 \
      libopengl0 \
      libegl1 \
      libgbm1 \
      libdrm2 \
      libxkbcommon0 \
      libpoppler-cpp0t64 \
      libgles2 \
      libgl1-mesa-dri \
      udev \
      dbus \
      dbus-daemon \
      dbus-system-bus-common \
      dbus-x11 \
      pulseaudio \
      pulseaudio-utils \
      alsa-utils \
      xinit \
      x11-xserver-utils \
      xserver-xorg \
      xserver-xorg-input-evdev \
      xserver-xorg-input-libinput \
      xserver-xorg-legacy \
      xserver-xorg-video-fbdev \
      xinput \
      xfonts-base \
      xfonts-100dpi \
      xfonts-75dpi \
      xfonts-cyrillic \
      xfonts-scalable && \
  echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
      /tmp/* \
      /var/lib/apt/lists/* \
      /var/tmp/*

COPY --from=builder /out/usr/local/ /usr/local/
COPY --from=builder /out/defaults/roms/ /defaults/roms/

COPY /root/usr/local/bin/esde-startx-session /usr/local/bin/esde-startx-session
COPY /root/etc/s6-overlay/s6-rc.d /etc/s6-overlay/s6-rc.d
COPY /root/defaults/roms/LICENSE-bundled-roms.txt /defaults/roms/LICENSE-bundled-roms.txt

RUN set -eux; \
  echo "**** record build version ****"; \
  if [ -r /usr/local/share/es-de/build-metadata.env ]; then . /usr/local/share/es-de/build-metadata.env; fi; \
  echo "Linuxserver.io version:- ${VERSION:-unknown} Build-date:- ${BUILD_DATE:-unknown} Revision:- ${VCS_REF:-unknown} ES-DE:- ${ESDE_VERSION:-unknown}" > /build_version; \
  echo "**** set permissions ****"; \
  chown -R root:root /etc/s6-overlay/s6-rc.d; \
  chmod 755 /etc/s6-overlay/s6-rc.d/svc-esde /etc/s6-overlay/s6-rc.d/svc-esde/dependencies.d; \
  chmod 755 /etc/s6-overlay/s6-rc.d/user/contents.d; \
  chmod 644 /etc/s6-overlay/s6-rc.d/svc-esde/type /etc/s6-overlay/s6-rc.d/svc-esde/dependencies.d/init-services /etc/s6-overlay/s6-rc.d/user/contents.d/svc-esde; \
  chmod 755 /etc/s6-overlay/s6-rc.d/svc-esde/run /usr/local/bin/esde-startx-session

VOLUME /config

# ============================================================================
# Stage 2b — Runtime: Selkies WebRTC (selkies target)
#   docker build --target selkies .
#
# Streams the ES-DE UI to a web browser via WebRTC.
# Ports: 3000 (HTTP), 3001 (HTTPS)
# ============================================================================
FROM ${SELKIES_BASE_IMAGE} AS selkies

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_DATE
ARG VERSION
ARG ESDE_VERSION
ARG VCS_URL
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Blackout Secure - https://blackoutsecure.app/"
LABEL org.opencontainers.image.title="docker-emulationstation-de-selkies" \
  org.opencontainers.image.description="Selkies WebRTC remote-access build of EmulationStation-DE. Stream the ES-DE frontend to any web browser." \
  org.opencontainers.image.url="${VCS_URL}" \
  org.opencontainers.image.source="${VCS_URL}" \
  org.opencontainers.image.revision="unknown" \
  org.opencontainers.image.created="unknown" \
  org.opencontainers.image.version="unknown" \
  org.opencontainers.image.licenses="MIT"

ENV \
  HOME="/config" \
  ESDE_HOME="/config" \
  APP_USER="abc" \
  # --- Selkies defaults (can be overridden at runtime) ---
  TITLE="EmulationStation-DE" \
  NO_DECOR="true" \
  START_DOCKER="false"

# Install ES-DE runtime dependencies not already in the Selkies base.
# The Selkies base provides: Mesa GL, PulseAudio, X11, fonts, dbus, etc.
RUN echo "**** install ES-DE runtime dependencies ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      libsdl2-2.0-0 \
      libavcodec60 \
      libavfilter9 \
      libavformat60 \
      libavutil58 \
      libfreeimage3 \
      libfreetype6 \
      libgit2-1.7 \
      libcurl4t64 \
      libpugixml1v5 \
      libasound2t64 \
      libbluetooth3 \
      libharfbuzz0b \
      libicu74 \
      libgl1 \
      libopengl0 \
      libegl1 \
      libgbm1 \
      libdrm2 \
      libxkbcommon0 \
      libpoppler-cpp0t64 \
      libgles2 \
      gstreamer1.0-tools \
      gstreamer1.0-plugins-base \
      gstreamer1.0-plugins-good \
      gstreamer1.0-plugins-bad \
      ffmpeg \
      x11-utils \
      xclip \
      alsa-utils && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
      /tmp/* \
      /var/lib/apt/lists/* \
      /var/tmp/*

# Copy ES-DE binary and resources from builder
COPY --from=builder /out/usr/local/ /usr/local/
COPY --from=builder /out/defaults/roms/ /defaults/roms/

# Copy bundled ROM license
COPY /root/defaults/roms/LICENSE-bundled-roms.txt /defaults/roms/LICENSE-bundled-roms.txt

# Selkies autostart — the command Openbox runs inside the WebRTC session
COPY /root/defaults/autostart /defaults/autostart

# ES-DE launch wrapper for Selkies environment
COPY /root/usr/local/bin/esde-selkies-launch /usr/local/bin/esde-selkies-launch

# Selkies s6-overlay init service for root-level setup before app launch
COPY /root/etc/s6-overlay/s6-rc.d/init-esde-config /etc/s6-overlay/s6-rc.d/init-esde-config

# Optional HDMI mirror service (set HDMI_MIRROR=true to enable)
COPY /root/usr/local/bin/esde-hdmi-mirror /usr/local/bin/esde-hdmi-mirror
COPY /root/etc/s6-overlay/s6-rc.d/svc-hdmi-mirror /etc/s6-overlay/s6-rc.d/svc-hdmi-mirror

RUN set -eux; \
  echo "**** record build version ****"; \
  if [ -r /usr/local/share/es-de/build-metadata.env ]; then . /usr/local/share/es-de/build-metadata.env; fi; \
  echo "Linuxserver.io version:- ${VERSION:-unknown} Build-date:- ${BUILD_DATE:-unknown} Revision:- ${VCS_REF:-unknown} ES-DE:- ${ESDE_VERSION:-unknown} (Selkies)" > /build_version; \
  echo "**** create volume mount points ****"; \
  mkdir -p /roms /bios; \
  chown abc:abc /roms /bios; \
  echo "**** set permissions ****"; \
  chmod 755 /usr/local/bin/esde-selkies-launch; \
  chmod 755 /usr/local/bin/esde-hdmi-mirror; \
  chmod 755 /etc/s6-overlay/s6-rc.d/init-esde-config; \
  chmod 644 /etc/s6-overlay/s6-rc.d/init-esde-config/type; \
  chmod 644 /etc/s6-overlay/s6-rc.d/init-esde-config/up; \
  chmod 755 /etc/s6-overlay/s6-rc.d/init-esde-config/run; \
  chmod 644 /etc/s6-overlay/s6-rc.d/init-esde-config/dependencies.d/*; \
  chmod 755 /etc/s6-overlay/s6-rc.d/svc-hdmi-mirror; \
  chmod 755 /etc/s6-overlay/s6-rc.d/svc-hdmi-mirror/run; \
  chmod 644 /etc/s6-overlay/s6-rc.d/svc-hdmi-mirror/type; \
  chmod 755 /etc/s6-overlay/s6-rc.d/svc-hdmi-mirror/dependencies.d; \
  chmod 644 /etc/s6-overlay/s6-rc.d/svc-hdmi-mirror/dependencies.d/*; \
  echo "**** register init service with s6 ****"; \
  mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d; \
  touch /etc/s6-overlay/s6-rc.d/user/contents.d/init-esde-config; \
  touch /etc/s6-overlay/s6-rc.d/user/contents.d/svc-hdmi-mirror

EXPOSE 3000 3001

VOLUME /config
