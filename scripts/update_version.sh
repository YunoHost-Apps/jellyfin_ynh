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
	local legacy_args=tda
	local -A args_array=( [t]=template= [d]=destination= [a]=architecture= )
	local template
	local destination
	local architecture
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

	url=$(grep "SOURCE_URL=" "$destination" | cut -d "=" -f 2)
	echo $url
	filename=${url##*/}
	echo $filename
	curl -s -4 -L $url -o "$tempdir/$filename"
	checksum=$(sha256sum "$tempdir/$filename" | head -c 64)

	ynh_secure_remove $tempdir

	official_checksum_url=$(grep "SOURCE_SUM=" "$destination" | cut -d "=" -f 2)
	if [[ "$official_checksum_url" != "none" ]]; then
	  official_checksum=$(curl -L -s "${official_checksum_url}" | cut -d ' ' -f 1)
	  echo $official_checksum
	fi

	if [[ "$official_checksum_url" != "none" && "$official_checksum" != "$checksum" ]]; then
	  echo "Downloaded file checksum ($checksum) does not match official checksum ($official_checksum)"
	  exit 1
	else
	  sed -i "s/SOURCE_SUM=.*/SOURCE_SUM=${checksum}/" "$destination"
	  echo "$destination updated"
	fi
}

debians=("buster" "bullseye")
architectures=("amd64" "arm64" "armhf")
for debian in "${debians[@]}"; do
  for architecture in "${architectures[@]}"; do
	prepare_source --template="../conf/ffmpeg.src.default" --destination="../conf/ffmpeg.$debian.$architecture.src" --architecture="$architecture"
	prepare_source --template="../conf/web.src.default" --destination="../conf/web.$debian.$architecture.src" --architecture="$architecture"
	prepare_source --template="../conf/server.src.default" --destination="../conf/server.$debian.$architecture.src" --architecture="$architecture"
  done
done

prepare_source --template="../conf/ldap.src.default" --destination="../conf/ldap.src"

sed -i "s#	\"version\": \".*#	\"version\": \"${version}\~ynh1\",#" ../manifest.json

git add _common.sh ../manifest.json ../conf/ffmpeg.*.src ../conf/web.*.src ../conf/server.*.src ../conf/ldap.src
git commit -m "Upgrade to v$version"
