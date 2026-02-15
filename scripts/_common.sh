#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

debian=$(lsb_release --codename --short)
debian_number=$(lsb_release --release --short)
pkg_version="10.11.6"
version=$(echo "$pkg_version" | cut -d '-' -f 1)

ffmpeg_pkg_version="7.1.3-1"

# "targetAbi" line in plugin's meta.json, to check for outdated plugins
# Usually, it should be the major version of the Jellyfin release (e.g. Jellyfin 10.10.7 -> plugin_abi 10.10.0)
plugin_abi="10.11.0"
ldap_pkg_version="22.0.0.0"

config_path="$install_dir/config"
log_path="/var/log/$app"
cache_path="$install_dir/cache"

install_jellyfin_packages() {
    # If there is a new version, the server resource is moved to archive
    main_url="$(ynh_read_manifest "resources.sources.main.${YNH_ARCH}.url")"
    main_resource="main"
    if ! curl --output /dev/null --silent --head --fail "$main_url"; then
    	main_resource="main_archive"
    fi

    ynh_setup_source --dest_dir="$install_dir/jellyfin" --source_id="$main_resource"
    ynh_setup_source --dest_dir="$install_dir/ffmpeg" --source_id="ffmpeg"
}

upgrade_jellyfin_packages() {
    # If there is a new version, the server resource is moved to archive
    main_url="$(ynh_read_manifest "resources.sources.main.${YNH_ARCH}.url")"
    main_resource="main"
    if ! curl --output /dev/null --silent --head --fail "$main_url"; then
    	main_resource="main_archive"
    fi

    ynh_setup_source --dest_dir="$install_dir/jellyfin/" --source_id="$main_resource" --full_replace --keep="config"
    ynh_setup_source --dest_dir="$install_dir/ffmpeg" --source_id="ffmpeg"
}

