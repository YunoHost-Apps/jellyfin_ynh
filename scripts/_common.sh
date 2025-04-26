#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

debian=$(lsb_release --codename --short)
debian_number=$(lsb_release --release --short)
pkg_version="10.10.6"
version=$(echo "$pkg_version" | cut -d '-' -f 1)

ffmpeg_pkg_version="7.0.2-9"

# "targetAbi" line in plugin's meta.json, to check for outdated plugins
plugin_abi="10.9.0.0"
ldap_pkg_version="19.0.0.0"

# Those directories are handled by the deb package
data_path="/var/lib/$app"
config_path="/etc/$app"
log_path="/var/log/$app"
cache_path="/var/cache/$app"

install_jellyfin_packages() {
	# Get version numbers from manifest UNUSED because update_version.py uses the hard-coded variables
	# pkg_version="$(ynh_app_upstream_version)"
	# ffmpeg_url="$(ynh_read_manifest "resources.sources.ffmpeg_${debian}.${YNH_ARCH}.url")"
	# ffmpeg_pkg_version="$(echo "$ffmpeg_url" | sed "s/.*\/jellyfin-ffmpeg[0-9]*_\([0-9.-]*\)-${debian}_${YNH_ARCH}.deb/\1/")"

	# We need to workaround yunohost passing --no-remove to replace jellyfin-ffmpeg5 and 6...
	for ffmpeg_installed_version in "jellyfin-ffmpeg5" "jellyfin-ffmpeg6"
	do
		if _ynh_apt_package_is_installed "$ffmpeg_installed_version"; then
			ynh_apt_remove_dependencies "$ffmpeg_installed_version"
		fi
	done

	# This should only run on upgrade, to fix https://github.com/YunoHost-Apps/jellyfin_ynh/issues/163
	# Previously the package depended on exact package versions, so upgrade was broken.
	if _ynh_apt_package_is_installed "$app-ynh-deps" && _ynh_apt_package_is_installed "jellyfin-server"; then
		ynh_apt_install_dependencies jellyfin-web jellyfin-ffmpeg7 jellyfin-server
	fi

	# Create the temporary directory
	tempdir="$(mktemp -d)"

	# If there is a new version, the web and server resources are moved to archive
	server_url="$(ynh_read_manifest "resources.sources.server_${debian}.${YNH_ARCH}.url")"
	server_resource="server_$debian"
	if ! curl --output /dev/null --silent --head --fail "$server_url"; then
		server_resource="server_archive_$debian"
	fi
	web_url="$(ynh_read_manifest "resources.sources.web_${debian}.url")"
	web_resource="web_$debian"
	if ! curl --output /dev/null --silent --head --fail "$web_url"; then
		web_resource="web_archive_$debian"
	fi
	# Download the deb files
	ynh_setup_source --dest_dir="$tempdir" --source_id="$web_resource"
	ynh_setup_source --dest_dir="$tempdir" --source_id="ffmpeg_$debian"
	ynh_setup_source --dest_dir="$tempdir" --source_id="$server_resource"

	# Install the packages. Allow downgrades because apt decided bullseye > bookworm
	_ynh_apt_install --allow-downgrades \
		"$tempdir/jellyfin-web.deb" \
		"$tempdir/jellyfin-server.deb"

	# Install the packages. Allow downgrades because apt decided bullseye > bookworm
	_ynh_apt_install --allow-downgrades \
		"${tempdir}/jellyfin-ffmpeg7.deb"

	# The doc says it should be called only once,
	# but the code says multiple calls are supported.
	# Also, they're already installed so that should be quasi instantaneous.
	ynh_apt_install_dependencies jellyfin-web jellyfin-ffmpeg7 jellyfin-server

	# Mark packages as dependencies, to allow automatic removal
	apt-mark auto jellyfin-server jellyfin-web jellyfin-ffmpeg7
}
