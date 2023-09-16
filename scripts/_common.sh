#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

debian=$(lsb_release --codename --short)
pkg_version="10.8.10-1"
version=$(echo "$pkg_version" | cut -d '-' -f 1)

ffmpeg_pkg_version="5.1.2-6"
ldap_pkg_version="16.0.0.0"

discovery_service_port=1900
discovery_client_port=7359

ffmpeg_deps_bullseye=(
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
	libllvm13
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
	libxcb-randr0
	libzvbi0
	zlib1g
	libvpx6
	libx264-160
	libx265-192
)

ffmpeg_deps_bookworm=(
	libass9
	libbluray2
	libc6
	libelf1
	libexpat1
	libfontconfig1
	libfreetype6
	libfribidi0
	libgcc-s1
	libgmp10
	libgnutls30
	libllvm15
	libmp3lame0
	libopenmpt0
	libopus0
	libpciaccess0
	libstdc++6
	libtheora0
	libudev1
	libvorbis0a
	libvorbisenc2
	libvpx7
	libwebp7
	libwebpmux3
	libx11-xcb1
	libx264-164
	libx265-199
	libxcb-dri2-0
	libxcb-dri3-0
	libxcb-present0
	libxcb-randr0
	libxcb-shm0
	libxcb-sync1
	libxcb-xfixes0
	libxcb1
	libxshmfence1
	libzstd1
	libzvbi0
	zlib1g
)

case "$debian" in
	bullseye) ffmpeg_deps=$ffmpeg_deps_bullseye ;;
 	bookworm) ffmpeg_deps=$ffmpeg_deps_bookworm ;;
	*) echo "Unknown release: $debian" >&2; exit 1 ;;
esac
case "$YNH_ARCH" in
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
	# https://repo.jellyfin.org/releases/server/debian/versions/stable/server/X.X.X/jellyfin-server_X.X.X-1_$YNH_ARCH.deb to
	# https://repo.jellyfin.org/archive/debian/stable/X.X.X/server/jellyfin-server_X.X.X-1_$YNH_ARCH.deb
	for pkg in web server; do
		src_url=$(grep 'SOURCE_URL=' "$YNH_APP_BASEDIR/conf/$pkg.$debian.$YNH_ARCH.src" | cut -d= -f2-)
		if ! curl --output /dev/null --silent --head --fail "$src_url"; then
			ynh_replace_string \
				--match_string="releases/server/debian/versions/stable/$pkg/$version/" \
				--replace_string="archive/debian/stable/$version/$pkg/" \
				--target_file="$YNH_APP_BASEDIR/conf/$pkg.$debian.$YNH_ARCH.src"
		fi
	done

	# Create the temporary directory
	tempdir="$(mktemp -d)"

	# Download the deb files
	ynh_setup_source --dest_dir=$tempdir --source_id="ffmpeg.$debian.$YNH_ARCH"
	ynh_setup_source --dest_dir=$tempdir --source_id="server.$debian.$YNH_ARCH"
	ynh_setup_source --dest_dir=$tempdir --source_id="web.$debian.$YNH_ARCH"

	# Install the packages
	ynh_exec_warn_less dpkg --force-confdef --force-confnew -i $tempdir/jellyfin-web.deb
	ynh_exec_warn_less dpkg --force-confdef --force-confnew -i $tempdir/jellyfin-ffmpeg5.deb
	ynh_exec_warn_less dpkg --force-confdef --force-confnew -i $tempdir/jellyfin-server.deb

	ynh_secure_remove --file="$tempdir"

	# The doc says it should be called only once,
	# but the code says multiple calls are supported.
	# Also, they're already installed so that should be quasi instantaneous.
	ynh_install_app_dependencies \
		jellyfin-web="$pkg_version" \
		jellyfin-ffmpeg5="$ffmpeg_pkg_version-$debian" \
		jellyfin-server="$pkg_version"
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
