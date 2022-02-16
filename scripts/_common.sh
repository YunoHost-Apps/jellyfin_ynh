#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

debian=$(lsb_release --codename --short)
pkg_version="10.7.7-1"
version=$(echo "$pkg_version" | cut -d '-' -f 1)

ffmpeg_pkg_version="4.3.2-1"
ldap_pkg_version="12.0.0.0"

architecture=$(dpkg --print-architecture)

discovery_service_port=1900
discovery_client_port=7359

ffmpeg_deps=(
    libass9
    libbluray2
    libc6
    libdrm2
    libfontconfig1
    libfreetype6
    libfribidi0
    libgcc1
    libgmp10
    libgnutls30
    libmp3lame0
    libopus0
    libstdc++6
    libtheora0
    libvdpau1
    libvorbis0a
    libvorbisenc2
    libwebp6
    libwebpmux3
    libx11-6
    libzvbi0
    zlib1g
)

case "$debian" in
    buster) ffmpeg_deps+=( libvpx5 libx264-155 libx265-165 ) ;;
    bullseye) ffmpeg_deps+=( libvpx6 libx264-160 libx265-192 ) ;;
    *) echo "Unknown release: $debian" >&2; exit 1 ;;
esac
case "$architecture" in
    arm64) : ;;
    armhf) : ;;
    *) ffmpeg_deps+=( libdrm-intel1 libopencl1 ) ;;
esac

jellyfin_deps=(at libsqlite3-0 libfontconfig1 libfreetype6 libssl1.1)

pkg_dependencies="${ffmpeg_deps[*]} ${jellyfin_deps[*]}"

#=================================================
# PERSONAL HELPERS
#=================================================

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
