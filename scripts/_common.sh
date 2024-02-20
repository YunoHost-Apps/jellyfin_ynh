#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

debian=$(lsb_release --codename --short)
pkg_version="10.8.13-1"
version=$(echo "$pkg_version" | cut -d '-' -f 1)

ffmpeg_pkg_version="6.0.1-3"
ldap_pkg_version="17.0.0.0"

discovery_service_port=1900
discovery_client_port=7359

# Those directories are handled by the deb package
data_path="/var/lib/$app"
config_path="/etc/$app"
log_path="/var/log/$app"
cache_path="/var/cache/$app"


#=================================================
# PERSONAL HELPERS
#=================================================

install_jellyfin_packages() {
	# Create the temporary directory
	tempdir="$(mktemp -d)"

	# Download the deb files
	ynh_setup_source --dest_dir="$tempdir" --source_id="web"
	ynh_setup_source --dest_dir="$tempdir" --source_id="ffmpeg_$debian"
	ynh_setup_source --dest_dir="$tempdir" --source_id="server"

	# Install the packages
	ynh_package_install \
		"$tempdir/jellyfin-web.deb" \
		"$tempdir/jellyfin-server.deb"

	# We need to workaround yunohoost passing --no-remove to replace jellyfin-ffmpeg5...
	if ynh_package_is_installed "jellyfin-ffmpeg5"; then
		ynh_package_remove "jellyfin-ffmpeg5"
	fi
	ynh_package_install \
		"$tempdir/jellyfin-ffmpeg6.deb"

	# The doc says it should be called only once,
	# but the code says multiple calls are supported.
	# Also, they're already installed so that should be quasi instantaneous.
	ynh_install_app_dependencies \
		jellyfin-web="$pkg_version" \
		jellyfin-ffmpeg6="$ffmpeg_pkg_version-$debian" \
		jellyfin-server="$pkg_version"

	# Mark packages as dependencies, to allow automatic removal
	apt-mark auto jellyfin-server jellyfin-web jellyfin-ffmpeg6
}

open_jellyfin_discovery_ports() {
	discovery_service=$discovery
	discovery_client=$discovery

	if [ "$discovery" -eq 1 ]; then

		# Open port $discovery_service_port for service auto-discovery
		if ynh_port_available --port=$discovery_service_port; then
			ynh_exec_warn_less yunohost firewall allow UDP $discovery_service_port
		else
			discovery_service=0
			ynh_print_warn --message="Port $discovery_service_port (for service auto-discovery) is not available. Continuing nonetheless."
		fi

		# Open port $discovery_client_port for client auto-discovery
		if ynh_port_available --port=$discovery_client_port; then
			ynh_exec_warn_less yunohost firewall allow UDP $discovery_client_port
		else
			discovery_client=0
			ynh_print_warn --message="Port $discovery_client_port (for client auto-discovery) is not available. Continuing nonetheless."
		fi
	fi

	ynh_app_setting_set --app="$app" --key=discovery_service --value="$discovery_service"
	ynh_app_setting_set --app="$app" --key=discovery_client --value="$discovery_client"
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
