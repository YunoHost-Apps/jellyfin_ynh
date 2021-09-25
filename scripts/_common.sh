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

#=================================================
# PERSONAL HELPERS
#=================================================

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
