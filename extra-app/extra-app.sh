#!/bin/bash

#################### Setting ####################
#ro.product.cpu.abi=armeabi-v7a
#ro.product.cpu.abi2=armeabi
abi=armeabi-v7a
abi2=armeabi

# -> system/app/
extra_apps=(AutonaviMap::Amap_V7.6.4.2043.apk \
    ezPDF_Reader::ezPDF_Reader_v2.6.6.1.apk \
    ForaDictionary::ForaDictionary_v17.1.apk \
    kiwix::kiwix-1.97.apk \
    OperaClassic::Mobile_Classic_12_1_9_Generic_Opera_ARMv5v7.apk \
    mobileQQ::mobileqq_v6.2.3.apk \
    wpsoffice::moffice_cn00563.apk \
    rootexplorer::rootexplorer_3.3.8_109.apk \
    smart_tools::smart_tools_v1.7.9_83.apk \
    TerminalEmulator::TerminalEmulator_v1.0.70.apk \
    BaiduIME::百度输入法小米V6版+6.0.5.3.apk)

# -> data/app/
extra_dataapps=(goldendict::GoldenDict-1.6.5-Android-4.4+-free.apk \
    MX_Player_Pro::MX_Player_Pro_1.8.4_20160125_AC3_crk.apk)

#################### Setting ####################

usage() {
    cat <<EOF
Usage: $0  <operation>
operations:
  analyse
  deploy <root-dir-path/for/update.zip>
         default: ./extra-app-$(date +%F)}/
  zip    <update-apps.zip> <root-dir-path/for/update.zip>
         generate zip file
         default: extra-app-$(date +%Y%m%d).zip
EOF
    exit 0
}

analyse_app() {
    abi_apk=()
    abi2_apk=()
    nolib_apk=()
    [ -d ./tmp_app_files ] && rm -rv ./tmp_app_files
    mkdir -pv ./tmp_app_files/lib_result/
    for app in ${extra_apps[@]}; do
        apk=${app/%::*/}
        file=${app/#*::/}
        mkdir ./tmp_app_files/$apk
        if unzip $file "lib/$abi/*" -d ./tmp_app_files/$apk; then
            number=$(ls ./tmp_app_files/$apk/lib/$abi/ |wc -l)
            abi_apk+=("${apk} ($number)")
            cp -vi ./tmp_app_files/$apk/lib/$abi/* ./tmp_app_files/lib_result/
        elif unzip $file "lib/$abi2/*" -d ./tmp_app_files/$apk; then
            number2=$(ls ./tmp_app_files/$apk/lib/$abi2/ |wc -l)
            abi2_apk+=("${apk} ($number2)")
            cp -vi ./tmp_app_files/$apk/lib/$abi2/* ./tmp_app_files/lib_result/
        else
            nolib_apk+=(${apk})
            rmdir ./tmp_app_files/$apk
        fi
    done
    echo -e "\napk(armeabi-v7a): ${abi_apk[@]}"
    echo -e "\napk(armeabi): ${abi2_apk[@]}"
    echo -e "\napk(no-lib): ${nolib_apk[@]}"
}

deploy_app() {
    mkdir -pv "$deploy_dir"/{data/app,system/{app,lib}}
    for app in ${extra_apps[@]}; do
        apk=${app/%::*/}
        file=${app/#*::/}
        cp -vi $file "$deploy_dir"/system/app/${apk}.apk
    done
    cp -vi ./tmp_app_files/lib_result/* "$deploy_dir"/system/lib/
    for app in ${extra_dataapps[@]}; do
        apk=${app/%::*/}
        file=${app/#*::/}
        cp -vi $file "$deploy_dir"/data/app/${apk}.apk
    done

    #add_meta()
    mkdir -pv "$deploy_dir"/META-INF/com/google/android/
    cp -vi ./update-binary "$deploy_dir"/META-INF/com/google/android/
    cat >"$deploy_dir"/META-INF/com/google/android/updater-script <<EOF
ui_print("=======================");
ui_print("***vivo-Y13L-apps*****");
ui_print("***By shmilee*****");
ui_print("***$(date +%F)*****");
ui_print("=======================");

mount("ext4", "EMMC", "/dev/block/bootdevice/by-name/userdata", "/data");
mount("ext4", "EMMC", "/dev/block/bootdevice/by-name/system", "/system");
show_progress(0.200000, 10);

ui_print("extract system...");
assert(package_extract_dir("system", "/system"));
show_progress(0.400000, 60);

ui_print("extract data...");
assert(package_extract_dir("data", "/data"));
show_progress(0.300000, 30);

set_metadata_recursive("/system/app", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
set_metadata_recursive("/system/lib", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
show_progress(0.100000, 10);

ui_print("Unmounting system...");
unmount("/data");
unmount("/system");
EOF
}

action=$1
[[ x"$1" == x ]] && usage

if [ x"$action" == xanalyse ]; then
    analyse_app
elif [ x"$action" == xdeploy ]; then
    deploy_dir="${2:-./extra-app-$(date +%F)}"
    if [ -d "$deploy_dir" ]; then
        echo "'$deploy_dir' exists. Try another one."
        exit 1
    fi
    if [ ! -f update-binary ]; then
        echo "'update-binary' not found."
        exit 2
    fi
    [ -d ./tmp_app_files/lib_result/ ] || analyse_app
    deploy_app
elif [ x"$action" == xzip ]; then
    deploy_dir="${3:-./extra-app-$(date +%F)}"
    update_zipfile="${2:-./extra-app-$(date +%Y%m%d).zip}"
    if [ -d "$deploy_dir" ]; then
        workdir="$PWD"
        cd $deploy_dir/
        zip -r -X -9 "$workdir"/${update_zipfile} *
    else
        echo "'$deploy_dir' not found."
        echo "Please run '$0 deploy' first."
        exit 1
    fi
    
else
    usage
fi
