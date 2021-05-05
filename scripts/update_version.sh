#!/bin/bash

source _common.sh
source /usr/share/yunohost/helpers

#=================================================
# META HELPER FOR PACKAGE RELEASES
#=================================================

# This script is meant to be manually run by the app packagers
# to automatically update the source files.
# Edit version numbers in _common.sh before running the script.

prepare_source () {
    # Declare an array to define the options of this helper.
    local legacy_args=tdv
    local -A args_array=( [t]=template= [d]=destination= )
    local template
    local destination
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"
    local template_path

    if [ -f "../conf/$template" ]; then
        template_path="../conf/$template"
    elif [ -f "../settings/conf/$template" ]; then
        template_path="../settings/conf/$template"
    elif [ -f "$template" ]; then
        template_path=$template
    else
        ynh_die --message="The provided template $template doesn't exist"
    fi

    cp "$template_path" "$destination"

    ynh_replace_vars --file="$destination"

    local official_checksum
    local official_checksum_url
    local filename
    local checksum
    local url

    # Create the temporary directory
    tempdir="$(mktemp -d)"

    official_checksum_url=$(grep "SOURCE_SUM=" "$destination" | cut -d "=" -f 2)
    official_checksum=$(curl -L -s "${official_checksum_url}" | cut -d ' ' -f 1)
    echo $official_checksum

    url=$(grep "SOURCE_URL=" "$destination" | cut -d "=" -f 2)
    echo $url
    filename=${url##*/}
    echo $filename
    curl -s -4 -L $url -o "$tempdir/$filename"
    checksum=$(sha256sum "$tempdir/$filename" | head -c 64)

    ynh_secure_remove $tempdir

    if [[ "$official_checksum" != "$checksum" ]]; then
      echo "Downloaded file checksum ($checksum) does not match official checksum ($official_checksum)"
      exit 1
    else
      sed -i "s/SOURCE_SUM=.*/SOURCE_SUM=${checksum}/" "$destination"
      echo "$destination updated"
    fi
}

prepare_source --template="../conf/ffmpeg.src.default" --destination="../conf/ffmpeg.src"
prepare_source --template="../conf/web.src.default" --destination="../conf/web.src"
prepare_source --template="../conf/server.src.default" --destination="../conf/server.src"

sed -i "s#\*\*Shipped version:\*\*.*#\*\*Shipped version:\*\* ${version}#" ../README.md
sed -i "s#\*\*Version incluse :\*\*.*#\*\*Version incluse :\*\* ${version}#" ../README_fr.md
sed -i "s#    \"version\": \".*#    \"version\": \"${version}\~ynh1\",#" ../manifest.json

git commit ../README.md ../README_fr.md ../manifest.json ../conf/ffmpeg.src ../conf/web.src ../conf/server.src -m "Upgrade to v$version"
