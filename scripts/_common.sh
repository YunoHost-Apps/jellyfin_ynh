#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

debian=$(lsb_release --codename --short)
pkg_version="10.7.0-1"
version=$(echo "$pkg_version" | cut -d '-' -f 1)

ffmpeg_pkg_version="4.3.1-4"

architecture=$(dpkg --print-architecture)

#=================================================
# PERSONAL HELPERS
#=================================================

#
# usage: ynh_setup_source_2 --dest_dir=dest_dir [--source_id=source_id]
# | arg: -d, --dest_dir=    - Directory where to setup sources
# | arg: -s, --source_id=   - Name of the app, if the package contains more than one app
#
# The file conf/app.src need to contains:
#
# SOURCE_URL=Address to download the app archive
# SOURCE_SUM can either be the SUM string, or a URL to a file containing the SUM.
# If a URL is provided, the contents of the file will be cut to the first space.
# SOURCE_SUM=Control sum
# # (Optional) Program to check the integrity (sha256sum, md5sum...)
# # default: sha256
# SOURCE_SUM_PRG=sha256
# # (Optional) Archive format
# # default: tar.gz
# SOURCE_FORMAT=tar.gz
# # (Optional) Put false if sources are directly in the archive root
# # default: true
# # Instead of true, SOURCE_IN_SUBDIR could be the number of sub directories
# # to remove.
# SOURCE_IN_SUBDIR=false
# # (Optionnal) Name of the local archive (offline setup support)
# # default: ${src_id}.${src_format}
# SOURCE_FILENAME=example.tar.gz
# # (Optional) If it set as false don't extract the source.
# # (Useful to get a debian package or a python wheel.)
# # default: true
# SOURCE_EXTRACT=(true|false)
#
# Details:
# This helper downloads sources from SOURCE_URL if there is no local source
# archive in /opt/yunohost-apps-src/APP_ID/SOURCE_FILENAME
#
# Next, it checks the integrity with "SOURCE_SUM_PRG -c --status" command.
#
# If it's ok, the source archive will be uncompressed in $dest_dir. If the
# SOURCE_IN_SUBDIR is true, the first level directory of the archive will be
# removed.
# If SOURCE_IN_SUBDIR is a numeric value, 2 for example, the 2 first level
# directories will be removed
#
# Finally, patches named sources/patches/${src_id}-*.patch and extra files in
# sources/extra_files/$src_id will be applied to dest_dir
#
# Requires YunoHost version 2.6.4 or higher.
ynh_setup_source_2 () {
    # Declare an array to define the options of this helper.
    local legacy_args=ds
    local -A args_array=( [d]=dest_dir= [s]=source_id= )
    local dest_dir
    local source_id
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"
    source_id="${source_id:-app}" # If the argument is not given, source_id equals "app"

    local src_file_path="$YNH_CWD/../conf/${source_id}.src"
    # In case of restore script the src file is in an other path.
    # So try to use the restore path if the general path point to no file.
    if [ ! -e "$src_file_path" ]; then
        src_file_path="$YNH_CWD/../settings/conf/${source_id}.src"
    fi

    # Load value from configuration file (see above for a small doc about this file
    # format)
    local src_url=$(grep 'SOURCE_URL=' "$src_file_path" | cut --delimiter='=' --fields=2-)
    local src_sum=$(grep 'SOURCE_SUM=' "$src_file_path" | cut --delimiter='=' --fields=2-)
    local src_sumprg=$(grep 'SOURCE_SUM_PRG=' "$src_file_path" | cut --delimiter='=' --fields=2-)
    local src_format=$(grep 'SOURCE_FORMAT=' "$src_file_path" | cut --delimiter='=' --fields=2-)
    local src_extract=$(grep 'SOURCE_EXTRACT=' "$src_file_path" | cut --delimiter='=' --fields=2-)
    local src_in_subdir=$(grep 'SOURCE_IN_SUBDIR=' "$src_file_path" | cut --delimiter='=' --fields=2-)
    local src_filename=$(grep 'SOURCE_FILENAME=' "$src_file_path" | cut --delimiter='=' --fields=2-)

    # Default value
    src_sumprg=${src_sumprg:-sha256sum}
    src_in_subdir=${src_in_subdir:-true}
    src_format=${src_format:-tar.gz}
    src_format=$(echo "$src_format" | tr '[:upper:]' '[:lower:]')
    src_extract=${src_extract:-true}
    if [ "$src_filename" = "" ]; then
        src_filename="${source_id}.${src_format}"
    fi
    local local_src="/opt/yunohost-apps-src/${YNH_APP_ID}/${src_filename}"

    if test -e "$local_src"
    then    # Use the local source file if it is present
        cp $local_src $src_filename
    else    # If not, download the source
        # NB. we have to declare the var as local first,
        # otherwise 'local foo=$(false) || echo 'pwet'" does'nt work
        # because local always return 0 ...
        local out
        # Timeout option is here to enforce the timeout on dns query and tcp connect (c.f. man wget)
        out=$(wget --tries 3 --no-dns-cache --timeout 900 --no-verbose --output-document=$src_filename $src_url 2>&1) \
            || ynh_die --message="$out"
    fi

    # Get the control sum if a URL was provided
    # Only retain the part before the first space
    if [[ "${src_sum}" =~ ^http[s+]:// ]]; then
        src_sum=$(curl -L -s "${src_sum}" | cut -d ' ' -f 1)
    fi

    # Check the control sum
    echo "${src_sum} ${src_filename}" | ${src_sumprg} --check --status \
        || ynh_die --message="Corrupt source"

    # Extract source into the app dir
    mkdir --parents "$dest_dir"

    if ! "$src_extract"
    then
        mv $src_filename $dest_dir
    elif [ "$src_format" = "zip" ]
    then
        # Zip format
        # Using of a temp directory, because unzip doesn't manage --strip-components
        if $src_in_subdir
        then
            local tmp_dir=$(mktemp --directory)
            unzip -quo $src_filename -d "$tmp_dir"
            cp --archive $tmp_dir/*/. "$dest_dir"
            ynh_secure_remove --file="$tmp_dir"
        else
            unzip -quo $src_filename -d "$dest_dir"
        fi
    else
        local strip=""
        if [ "$src_in_subdir" != "false" ]
        then
            if [ "$src_in_subdir" == "true" ]
            then
                local sub_dirs=1
            else
                local sub_dirs="$src_in_subdir"
            fi
            strip="--strip-components $sub_dirs"
        fi
        if [[ "$src_format" =~ ^tar.gz|tar.bz2|tar.xz$ ]]
        then
            tar --extract --file=$src_filename --directory="$dest_dir" $strip
        else
            ynh_die --message="Archive format unrecognized."
        fi
    fi

    # Apply patches
    if (( $(find $YNH_CWD/../sources/patches/ -type f -name "${source_id}-*.patch" 2> /dev/null | wc --lines) > "0" ))
    then
        (cd "$dest_dir"
        for p in $YNH_CWD/../sources/patches/${source_id}-*.patch
        do
            patch --strip=1 < $p
        done) || ynh_die --message="Unable to apply patches"
    fi

    # Add supplementary files
    if test -e "$YNH_CWD/../sources/extra_files/${source_id}"; then
        cp --archive $YNH_CWD/../sources/extra_files/$source_id/. "$dest_dir"
    fi
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
