#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

debian=$(lsb_release --codename --short)
debian_number=$(lsb_release --release --short)
pkg_version="10.9.9"
version=$(echo "$pkg_version" | cut -d '-' -f 1)

ffmpeg_pkg_version="6.0.1-8"

# "targetAbi" line in plugin's meta.json, to check for outdated plugins
plugin_abi="10.9.0.0"
ldap_pkg_version="19.0.0.0"

discovery_service_port=1900
discovery_client_port=7359

# Those directories are handled by the deb package
data_path="/var/lib/$app"
config_path="/etc/$app"
log_path="/var/log/$app"
cache_path="/var/cache/$app"

install_jellyfin_packages() {
	# Get version numbers from manifest UNUSED because update_version.py uses the hard-coded variables
	# pkg_version="$(ynh_app_upstream_version)"
	# ffmpeg_url="$(ynh_read_manifest
	# ffmpeg_pkg_version="$(echo "$ffmpeg_url" | sed "s/.*\/jellyfin-ffmpeg[0-9]*_\([0-9.-]*\)-${debian}_${YNH_ARCH}.deb/\1/")"

	# This should only run on upgrade, to fix https://github.com/YunoHost-Apps/jellyfin_ynh/issues/163
	# Previously the package depended on exact package versions, so upgrade was broken.
	if _ynh_apt_package_is_installed"$app-ynh-deps" && _ynh_apt_package_is_installed"jellyfin-server"; then
		ynh_apt_install_dependencies jellyfin-web jellyfin-ffmpeg6 jellyfin-server
	fi

	# Create the temporary directory
	tempdir="$(mktemp -d)"

	# Download the deb files
	ynh_setup_source --dest_dir="$tempdir" --source_id="web_$debian"
	ynh_setup_source --dest_dir="$tempdir" --source_id="ffmpeg_$debian"
	ynh_setup_source --dest_dir="$tempdir" --source_id="server_$debian"

	# Install the packages. Allow downgrades because apt decided bullseye > bookworm
	_ynh_apt_install --allow-downgrades \
		"$tempdir/jellyfin-web.deb" \
		"$tempdir/jellyfin-server.deb"

	# We need to workaround yunohoost passing --no-remove to replace jellyfin-ffmpeg5...
	if _ynh_apt_package_is_installed"jellyfin-ffmpeg5"; then
		ynh_package_remove "jellyfin-ffmpeg5"
	fi

	# Install the packages. Allow downgrades because apt decided bullseye > bookworm
	_ynh_apt_install --allow-downgrades \
		"${tempdir}/jellyfin-ffmpeg6.deb"

	# The doc says it should be called only once,
	# but the code says multiple calls are supported.
	# Also, they're already installed so that should be quasi instantaneous.
	ynh_apt_install_dependencies jellyfin-web jellyfin-ffmpeg6 jellyfin-server

	# Mark packages as dependencies, to allow automatic removal
	apt-mark auto jellyfin-server jellyfin-web jellyfin-ffmpeg6
}

configure_jellyfin_discovery_ports() {
	case $1 in
		"install")
			install_jellyfin_discovery_ports
			;;
		"remove")
			remove_jellyfin_discovery_ports
			;;
		*)
			ynh_print_warn "Invalid script calling configure_jellyfin_discovery_ports with args (should be install|remove): $@"
			;;
	esac
}

remove_jellyfin_discovery_ports() {
	if [[ $discovery_service -eq 1 ]] && yunohost firewall list | grep -q "\- $discovery_service_port$"
then
	ynh_hide_warnings yunohost firewall disallow UDP $discovery_service_port
fi

if [[ $discovery_client -eq 1 ]] && yunohost firewall list | grep -q "\- $discovery_client_port$"
then
	ynh_hide_warnings yunohost firewall disallow UDP $discovery_client_port
fi

}

install_jellyfin_discovery_ports() {
	discovery_service=$discovery
	discovery_client=$discovery

	if [ "$discovery" -eq 1 ]; then
		opened_ports=($discovery_service_port $discovery_client_port)

		# Open port $discovery_service_port for service auto-discovery
		if #REMOVEME? ynh_port_available --port=$discovery_service_port; then
			ynh_hide_warnings yunohost firewall allow UDP $discovery_service_port
		else
			discovery_service=0
			ynh_print_warn "Port $discovery_service_port (for service auto-discovery) is not available. Continuing nonetheless."
		fi

		# Open port $discovery_client_port for client auto-discovery
		if #REMOVEME? ynh_port_available --port=$discovery_client_port; then
			ynh_hide_warnings yunohost firewall allow UDP $discovery_client_port
		else
			discovery_client=0
			ynh_print_warn "Port $discovery_client_port (for client auto-discovery) is not available. Continuing nonetheless."
		fi
	fi

	ynh_app_setting_set --key=discovery_service --value="$discovery_service"
	ynh_app_setting_set --key=discovery_client --value="$discovery_client"
}
