#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

debian=$(lsb_release --codename --short)
pkg_version="10.8.0~beta2"
version=10.8.0-beta2
# version=$(echo "$pkg_version" | cut -d '-' -f 1)

ffmpeg_pkg_version="5.0.1-3"
ldap_pkg_version="14.0.0.0"

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

install_jellyfin_packages() {
    # In case of a new version, the url change from
    # https://repo.jellyfin.org/releases/server/debian/versions/stable/server/X.X.X/jellyfin-server_X.X.X-1_$architecture.deb to
    # https://repo.jellyfin.org/archive/debian/stable/X.X.X/server/jellyfin-server_X.X.X-1_$architecture.deb
    src_url=$(grep 'SOURCE_URL=' "../conf/server.$debian.$architecture.src" | cut -d= -f2-)
    if ! curl --output /dev/null --silent --head --fail "$src_url"; then
        ynh_replace_string \
            --match_string="releases/server/debian/versions/stable/server/$version/" \
            --replace_string="archive/debian/stable/$version/server/" \
            --target_file="../conf/server.$debian.$architecture.src"
    fi

    # Same for web
    src_url=$(grep 'SOURCE_URL=' "../conf/web.$debian.$architecture.src" | cut -d= -f2-)
    if ! curl --output /dev/null --silent --head --fail "$src_url"; then
        ynh_replace_string \
            --match_string="releases/server/debian/versions/stable/web/$version/" \
            --replace_string="archive/debian/stable/$version/web/" \
            --target_file="../conf/web.$debian.$architecture.src"
    fi

    # Create the temporary directory
    tempdir="$(mktemp -d)"

    # Download the deb files
    ynh_setup_source --dest_dir=$tempdir --source_id="ffmpeg.$debian.$architecture"
    ynh_setup_source --dest_dir=$tempdir --source_id="server.$debian.$architecture"
    ynh_setup_source --dest_dir=$tempdir --source_id="web.$debian.$architecture"

    # Install the packages
    ynh_exec_warn_less dpkg --force-confdef --force-confnew -i $tempdir/jellyfin-ffmpeg5.deb
    ynh_exec_warn_less dpkg --force-confdef --force-confnew -i $tempdir/jellyfin-server.deb
    ynh_exec_warn_less dpkg --force-confdef --force-confnew -i $tempdir/jellyfin-web.deb

    # The doc says it should be called only once,
    # but the code says multiple calls are supported.
    # Also, they're already installed so that should be quasi instantaneous.
    ynh_install_app_dependencies \
        jellyfin-ffmpeg="$ffmpeg_pkg_version-$debian" \
        jellyfin-server="$pkg_version" \
        jellyfin-web="$pkg_version"
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
