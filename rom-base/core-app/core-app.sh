#!/bin/bash

#ro.product.cpu.abi=armeabi-v7a
#ro.product.cpu.abi2=armeabi
abi=armeabi-v7a
abi2=armeabi

core_apps=(BBKMusic.apk \
    LockScreen.apk \
    RealCalc_v2.3.1.apk)

override_apps=(BBKMusic.apk)

usage() {
    echo "Usage:"
    echo "  $0 analyse"
    echo "  $0 [install|unibstall] <path/to/system/dir>"
    exit 0
}

analyse_app() {
    abi_apk=()
    abi2_apk=()
    nolib_apk=()
    [ -d ./tmp_appcore_files ] && rm -rv ./tmp_appcore_files
    mkdir -pv ./tmp_appcore_files/lib_result/
    for apk in ${core_apps[@]}; do
        mkdir ./tmp_appcore_files/${apk/%.apk/}
        if unzip $apk "lib/$abi/*" -d ./tmp_appcore_files/${apk/%.apk/}; then
            number=$(ls ./tmp_appcore_files/${apk/%.apk/}/lib/$abi/ |wc -l)
            abi_apk+=("${apk}($number)")
            cp -vi ./tmp_appcore_files/${apk/%.apk/}/lib/$abi/* ./tmp_appcore_files/lib_result/
        elif unzip $apk "lib/$abi2/*" -d ./tmp_appcore_files/${apk/%.apk/}; then
            number2=$(ls ./tmp_appcore_files/${apk/%.apk/}/lib/$abi2/ |wc -l)
            abi2_apk+=("${apk}($number2)")
            cp -vi ./tmp_appcore_files/${apk/%.apk/}/lib/$abi2/* ./tmp_appcore_files/lib_result/
        else
            nolib_apk+=($apk)
        fi
    done
    echo -e "\napk(armeabi-v7a): ${abi_apk[@]}"
    echo -e "\napk(armeabi): ${abi2_apk[@]}"
    echo -e "\napk(no-lib): ${nolib_apk[@]}"
}

install_app() {
    for apk in ${override_apps[@]}; do
        [ -f $system_dir/app/$apk ] && rm -v $system_dir/app/$apk
        [ -f $system_dir/app/${apk/.apk/.odex} ] && rm -v $system_dir/app/${apk/.apk/.odex}
    done
    for apk in ${core_apps[@]}; do
        cp -vi $apk $system_dir/app/$apk
    done
    cp -vi ./tmp_appcore_files/lib_result/* $system_dir/lib/
}

uninstall_app() {
    for apk in ${core_apps[@]} ${core_odex[@]}; do
        rm -v $system_dir/app/$apk
    done
    for sofile in $(ls ./tmp_appcore_files/lib_result/); do
        rm -v $system_dir/lib/$sofile
    done
}

action=$1
system_dir="$2"

[[ x"$1" == x ]] && usage

if [ x"$action" == xanalyse ]; then
    analyse_app
else
    if [ ! -d "$system_dir" ]; then
        echo "$system_dir not found."
        exit 1
    fi
    if [ ! -d "$system_dir"/app -o  ! -d "$system_dir"/lib ]; then
        echo "$system_dir is not a rom/system/ directory."
        exit 1
    fi
    if [ x"$action" == xinstall ]; then
        [ -d ./tmp_appcore_files/lib_result/ ] || analyse_app
        install_app
    elif [ x"$action" == xuninstall ]; then
        [ -d ./tmp_appcore_files/lib_result/ ] || analyse_app
        uninstall_app
    else
        usage
    fi
fi
