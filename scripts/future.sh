readonly app=$YNH_APP_INSTANCE_NAME

#======================================================================
# data/helpers.d/package
#======================================================================

# Define and install dependencies with a equivs control file
# This helper can/should only be called once per app
#
# usage: ynh_install_app_dependencies dep [dep [...]]
# | arg: dep - the package name to install in dependence
ynh_install_app_dependencies () {
    local old_dir=$(pwd)
    dependencies=$@
    manifest_path="../manifest.json"
    if [ ! -e "$manifest_path" ]; then
        manifest_path="../settings/manifest.json"   # Into the restore script, the manifest is not at the same place
    fi
    version=$(sudo python3 -c "import sys, json;print(json.load(open(\"$manifest_path\"))['version'])") # Retrieve the version number in the manifest file.
    dep_app=${app//_/-} # Replace all '_' by '-'

    if ynh_package_is_installed "${dep_app}-ynh-deps"; then
        echo "A package named ${dep_app}-ynh-deps is already installed" >&2
    else
        cat > ./${dep_app}-ynh-deps.control << EOF  # Make a control file for equivs-build
Section: misc
Priority: optional
Package: ${dep_app}-ynh-deps
Version: ${version}
Depends: ${dependencies// /, }
Architecture: all
Description: Fake package for ${app} (YunoHost app) dependencies
 This meta-package is only responsible of installing its dependencies.
EOF
        ynh_package_install_from_equivs ./${dep_app}-ynh-deps.control \
            || ynh_die "Unable to install dependencies" # Install the fake package and its dependencies
        ynh_app_setting_set $app apt_dependencies $dependencies
    fi
    cd $old_dir
}

# Remove fake package and its dependencies
#
# Dependencies will removed only if no other package need them.
#
# usage: ynh_remove_app_dependencies
ynh_remove_app_dependencies () {
    dep_app=${app//_/-} # Replace all '_' by '-'
    ynh_package_autoremove ${dep_app}-ynh-deps  # Remove the fake package and its dependencies if they not still used.
}

#=====================================================================
# data/helpers.d/filesystem
#=====================================================================

# Remove a file or a directory securely
#
# usage: ynh_secure_remove path_to_remove
# | arg: path_to_remove - File or directory to remove
ynh_secure_remove () {
    path_to_remove=$1
    forbidden_path=" \
    /var/www \
    /home/yunohost.app"

    if [[ "$forbidden_path" =~ "$path_to_remove" \
        # Match all paths or subpaths in $forbidden_path
        || "$path_to_remove" =~ ^/[[:alnum:]]+$ \
        # Match all first level paths from / (Like /var, /root, etc...)
        || "${path_to_remove:${#path_to_remove}-1}" = "/" ]]
        # Match if the path finishes by /. Because it seems there is an empty variable
    then
        echo "Avoid deleting $path_to_remove." >&2
    else
        if [ -e "$path_to_remove" ]
        then
            sudo rm -R "$path_to_remove"
        else
            echo "$path_to_remove wasn't deleted because it doesn't exist." >&2
        fi
    fi
}

#=====================================================================
# data/helpers.d/utils
#=====================================================================

# Download and uncompress the source from app.src
#
# The file conf/app.src need to contains:
# 
# SOURCE_URL=Address to download the app archive
# SOURCE_SUM=Control sum
# SOURCE_FORMAT=tar.gz # (Optional) default value: tar.gz
# SOURCE_IN_SUBDIR=false # (Optional) Put false if source are directly in the archive root
# SOURCE_FILENAME="example.tar.gz" (Optionnal) default value: ${src_id}.${src_format}
#
#
# usage: ynh_setup_source dest_dir [source_id]
# | arg: dest_dir  - Directory where to setup sources
# | arg: source_id - Name of the app, if the package contains more than one app
ynh_setup_source () {
    local dest_dir=$1
    local src_id=${2:-app} # If the argument is not given, source_id equal "app"
    # Load value from configuration file (see above for a small doc about this file
    # format)
    local src_url=$(grep 'SOURCE_URL=' "../conf/${src_id}.src" | cut -d= -f2-)
    local src_sum=$(grep 'SOURCE_SUM=' "../conf/${src_id}.src" | cut -d= -f2-)
    local src_sumprg=$(grep 'SOURCE_SUM_PRG=' "../conf/${src_id}.src" | cut -d= -f2-)
    local src_format=$(grep 'SOURCE_FORMAT=' "../conf/${src_id}.src" | cut -d= -f2-)
    local src_in_subdir=$(grep 'SOURCE_IN_SUBDIR=' "../conf/${src_id}.src" | cut -d= -f2-)
    local src_filename=$(grep 'SOURCE_FILENAME=' "../conf/${src_id}.src" | cut -d= -f2-)
    
    # Default value
    src_sumprg=${src_sumprg:-sha256sum}
    src_in_subdir=${src_in_subdir:-true}
    src_format=$(echo "$src_format" | tr '[:upper:]' '[:lower:]')
    if [ "$src_filename" = "" ] ; then
        src_filename="${src_id}.${src_format}"
    fi
    local local_src="/opt/yunohost-apps-src/${YNH_APP_ID}/${src_filename}"

    if test -e "$local_src"
    then    # Use the local source file if it is present
        cp $local_src $src_filename
    else    # If not, download the source
        wget -nv -O $src_filename $src_url
    fi

    # Check the control sum
    echo "${src_sum} ${src_filename}" | ${src_sumprg} -c --status \
        || ynh_die "Corrupt source"

    # Extract source into the app dir
    sudo mkdir -p "$dest_dir"
    if [ "$src_format" = "zip" ]
    then # Zip format
        # Using of a temp directory, because unzip doesn't manage --strip-components
        if $src_in_subdir ; then
            local tmp_dir=$(mktemp -d)
            unzip -quo $src_filename -d "$tmp_dir"
            sudo cp -a $tmp_dir/*/. "$dest_dir"
            ynh_secure_remove "$tmp_dir"
        else
            unzip -quo $src_filename -d "$dest_dir"
        fi
    else
        local strip=""
        if $src_in_subdir ; then
            strip="--strip-components 1"
        fi
        if [[ "$src_format" =~ ^tar.gz|tar.bz2|tar.xz$ ]] ; then
            sudo tar -xf $src_filename -C "$dest_dir" $strip
        else
            ynh_die "Archive format unrecognized."
        fi
    fi

    # Apply patches
    if (( $(find ../sources/patches/ -type f -name "${src_id}-*.patch" 2> /dev/null | wc -l) > "0" )); then
        local old_dir=$(pwd)
        (cd "$dest_dir" \
            && for p in $old_dir/../sources/patches/${src_id}-*.patch; do \
                sudo patch -p1 < $p; done) \
            || ynh_die "Unable to apply patches"
        cd $old_dir
    fi

    # Add supplementary files
    if test -e "../sources/extra_files"; then
        sudo cp -a ../sources/extra_files/. "$dest_dir"
    fi

}
