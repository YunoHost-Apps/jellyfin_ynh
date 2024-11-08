#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

debian=$(lsb_release --codename --short)
debian_number=$(lsb_release --release --short)
pkg_version="10.10.1"
version=$(echo "$pkg_version" | cut -d '-' -f 1)

ffmpeg_pkg_version="7.0.2-5"

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

#=================================================
# PERSONAL HELPERS
#=================================================

install_jellyfin_packages() {
	# Get version numbers from manifest UNUSED because update_version.py uses the hard-coded variables
	# pkg_version="$(ynh_app_upstream_version)"
	# ffmpeg_url="$(ynh_read_manifest --manifest_key="resources.sources.ffmpeg_${debian}.${YNH_ARCH}.url")"
	# ffmpeg_pkg_version="$(echo "$ffmpeg_url" | sed "s/.*\/jellyfin-ffmpeg[0-9]*_\([0-9.-]*\)-${debian}_${YNH_ARCH}.deb/\1/")"

	# We need to workaround yunohost passing --no-remove to replace jellyfin-ffmpeg5 and 6...
	for ffmpeg_installed_version in "jellyfin-ffmpeg5" "jellyfin-ffmpeg6"
	do
		if ynh_package_is_installed "$ffmpeg_installed_version"; then
			ynh_package_remove "=$ffmpeg_installed_version"
		fi
	done

	# This should only run on upgrade, to fix https://github.com/YunoHost-Apps/jellyfin_ynh/issues/163
	# Previously the package depended on exact package versions, so upgrade was broken.
	if ynh_package_is_installed --package="$app-ynh-deps" && ynh_package_is_installed --package="jellyfin-server"; then
		ynh_install_app_dependencies jellyfin-web jellyfin-ffmpeg7 jellyfin-server
	fi

	# Create the temporary directory
	tempdir="$(mktemp -d)"

	# If there is a new version, the web and server resources are moved to archive
	server_url="$(ynh_read_manifest --manifest_key="resources.sources.server_${debian}.${YNH_ARCH}.url")"
	server_resource="server_$debian"
	if ! curl --output /dev/null --silent --head --fail "$server_url"; then
		server_resource="server_archive_$debian"
	fi
	web_url="$(ynh_read_manifest --manifest_key="resources.sources.web_${debian}.url")"
	web_resource="web_$debian"
	if ! curl --output /dev/null --silent --head --fail "$web_url"; then
		web_resource="web_archive_$debian"
	fi
	# Download the deb files
	ynh_setup_source --dest_dir="$tempdir" --source_id="$web_resource"
	ynh_setup_source --dest_dir="$tempdir" --source_id="ffmpeg_$debian"
	ynh_setup_source --dest_dir="$tempdir" --source_id="$server_resource"

	# Install the packages. Allow downgrades because apt decided bullseye > bookworm
	ynh_package_install --allow-downgrades \
		"$tempdir/jellyfin-web.deb" \
		"$tempdir/jellyfin-server.deb"

	# Install the packages. Allow downgrades because apt decided bullseye > bookworm
	ynh_package_install --allow-downgrades \
		"${tempdir}/jellyfin-ffmpeg7.deb"

	# The doc says it should be called only once,
	# but the code says multiple calls are supported.
	# Also, they're already installed so that should be quasi instantaneous.
	ynh_install_app_dependencies jellyfin-web jellyfin-ffmpeg7 jellyfin-server

	# Mark packages as dependencies, to allow automatic removal
	apt-mark auto jellyfin-server jellyfin-web jellyfin-ffmpeg7
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
			ynh_print_warn --message="Invalid script calling configure_jellyfin_discovery_ports with args (should be install|remove): $@"
			;;
	esac
}

remove_jellyfin_discovery_ports() {
	if [[ $discovery_service -eq 1 ]] && yunohost firewall list | grep -q "\- $discovery_service_port$"
then
	ynh_exec_warn_less yunohost firewall disallow UDP $discovery_service_port
fi

if [[ $discovery_client -eq 1 ]] && yunohost firewall list | grep -q "\- $discovery_client_port$"
then
	ynh_exec_warn_less yunohost firewall disallow UDP $discovery_client_port
fi

}

install_jellyfin_discovery_ports() {
	discovery_service=$discovery
	discovery_client=$discovery

	if [ "$discovery" -eq 1 ]; then
		opened_ports=($discovery_service_port $discovery_client_port)

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
