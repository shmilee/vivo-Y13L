#!/bin/bash

#################### Setting ####################
#ro.product.cpu.abi=armeabi-v7a
#ro.product.cpu.abi2=armeabi
abi=armeabi-v7a
abi2=armeabi

# 无lib冲突 -> system/app/
# 有lib冲突 -> system/vivo-apps/
extra_apps=(BaiduMaps::BaiduMaps_Android_9-1-5_1009179g.apk \
    BubbleUPnP::BubbleUPnP-2.6.1.apk \
    ezPDF_Reader::ezPDF_Reader_v2.6.6.1.apk \
    Firefox_Browser::Firefox_Browser_v45.0.1.apk \
    ForaDictionary::ForaDictionary_v17.1.apk \
    kiwix::kiwix-1.97.apk \
    wpsoffice::moffice_v9.6.1.apk \
    rootexplorer::rootexplorer_3.3.8_109.apk \
    smart_tools::smart_tools_v1.7.9_83.apk \
    TerminalEmulator::TerminalEmulator_v1.0.70.apk \
    weixin::weixin6315android760.apk \
    BaiduIME::百度输入法小米V6版+6.0.5.3.apk)

# base包已有的库文件
# 即使 app 中包含这些库文件，也不算冲突
# 默认保留使用 base 的库，删除 app带的
lib_ignore=(libentryexstd.so)

# -> system/vivo-apps/
extra_vivoapps=(goldendict::GoldenDict-1.6.5-Android-4.4+-free.apk \
    MX_Player_Pro::MX_Player_Pro_1.8.4_20160125_AC3_crk.apk)

#################### Setting ####################

usage() {
    cat <<EOF
Usage: $0  <operation>
operations:
  analyse <root-dir-path/of/base-rom>
  deploy  <root-dir-path/for/update.zip>
          default: ./extra-app-$(date +%F)/
  zip     <update-apps.zip> <root-dir-path/for/update.zip>
          generate zip file
          default: extra-app-$(date +%Y%m%d).zip
EOF
    exit 0
}

check_conflict() {
    local dir1="$1" dir2="$2" file
    for file in $(ls "$dir1"/); do
        [ -f "$dir2"/$file ] && return 0  #conflict
    done
    return 1 
}

analyse_app() {
    abi_apk=()
    abi2_apk=()
    nolib_apk=()
    lib_num=""
    vivo_apk=()
    lost_apk=()
    [ -d ./tmp_app_files ] && rm -rv ./tmp_app_files
    mkdir -pv ./tmp_app_files/{lib_result,file_list}
    for app in ${extra_vivoapps[@]}; do
        apk=${app/%::*/}
        file=${app/#*::/}
        if [ -f ./$file ]; then
            vivo_apk+=($apk)
            echo "/system/vivo-apps/${apk}.apk" > ./tmp_app_files/file_list/${apk}.list
        else
            lost_apk+=($apk)
        fi
    done
    for app in ${extra_apps[@]}; do
        apk=${app/%::*/}
        file=${app/#*::/}
        if [ ! -f ./$file ]; then
            lost_apk+=($apk)
            continue
        fi
        mkdir ./tmp_app_files/$apk
        if unzip -qq $file "lib/$abi/*" -d ./tmp_app_files/$apk; then
            for so in ${lib_ignore[@]}; do
                if [ -f ./tmp_app_files/$apk/lib/$abi/$so ]; then
                    echo "==== remove (base)$so from $file ===="
                    rm -v ./tmp_app_files/$apk/lib/$abi/$so
                fi
            done
            libfiles=($(ls ./tmp_app_files/$apk/lib/$abi/))
            if check_conflict ./tmp_app_files/$apk/lib/$abi/ "$rom_dir"/system/lib; then
                vivo_apk+=("${apk}(lib-conflict)")
                echo "/system/vivo-apps/${apk}.apk" > ./tmp_app_files/file_list/${apk}.list
            else
                abi_apk+=("${apk}(${#libfiles[@]})")
                lib_num+="${#libfiles[@]}+"
                cp -vi ./tmp_app_files/$apk/lib/$abi/* ./tmp_app_files/lib_result/
                echo "/system/app/${apk}.apk ${libfiles[@]/#/\/system\/lib\/}" \
                    | sed 's/ /\n/g'> ./tmp_app_files/file_list/${apk}.list
            fi
        elif unzip -qq $file "lib/$abi2/*" -d ./tmp_app_files/$apk; then
            for so in ${lib_ignore[@]}; do
                if [ -f ./tmp_app_files/$apk/lib/$abi2/$so ]; then
                    echo "==== remove (base)$so from $file ===="
                    rm -v ./tmp_app_files/$apk/lib/$abi2/$so
                fi
            done
            libfiles2=($(ls ./tmp_app_files/$apk/lib/$abi2/))
            if check_conflict ./tmp_app_files/$apk/lib/$abi2/ "$rom_dir"/system/lib; then
                vivo_apk+=("${apk}(lib-conflict)")
                echo "/system/vivo-apps/${apk}.apk" > ./tmp_app_files/file_list/${apk}.list
            else
                abi2_apk+=("${apk}(${#libfiles2[@]})")
                lib_num+="${#libfiles2[@]}+"
                cp -vi ./tmp_app_files/$apk/lib/$abi2/* ./tmp_app_files/lib_result/
                echo "/system/app/${apk}.apk ${libfiles2[@]/#/\/system\/lib\/}" \
                    | sed 's/ /\n/g'> ./tmp_app_files/file_list/${apk}.list
            fi
        else
            nolib_apk+=(${apk})
            rmdir ./tmp_app_files/$apk
            echo "/system/app/${apk}.apk" > ./tmp_app_files/file_list/${apk}.list
        fi
    done
    echo -e "\n------------------------------------------------------"
    echo -e "\nsystem/app: libfiles(${lib_num/%+/} = $(echo ${lib_num}0|bc))"
    echo -e "\tapp($abi): ${abi_apk[@]}"
    echo -e "\tapp($abi2): ${abi2_apk[@]}"
    echo -e "\tapp(no-lib): ${nolib_apk[@]}"
    echo -e "\nsystem/vivo-apps: ${vivo_apk[@]}"
    if [ ${#lost_apk[@]} -gt 0 ]; then
        echo -e "\n\e[1;1m\e[1;31m!!! Check lost apps: ${lost_apk[@]}\e[1;0m"
    fi
}

deploy_app() {
    mkdir -pv "$deploy_dir"/system/{app,lib,vivo-apps,extra-app-list}
    cp -vi ./tmp_app_files/file_list/* "$deploy_dir"/system/extra-app-list/
    cp -vi ./tmp_app_files/lib_result/* "$deploy_dir"/system/lib/
    for app in ${extra_apps[@]} ${extra_vivoapps[@]}; do
        apk=${app/%::*/}
        file=${app/#*::/}
        list=./tmp_app_files/file_list/${apk}.list
        if [ -f ./$file ]; then
            cp -vi $file "$deploy_dir"/$(head -n1 $list)
        else
            echo -e "\e[1;1m\e[1;31m!!! lost ${file}. \e[1;0m"
        fi
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

mount("ext4", "EMMC", "/dev/block/bootdevice/by-name/system", "/system");
show_progress(0.200000, 10);

ui_print("extract system...");
assert(package_extract_dir("system", "/system"));
show_progress(0.400000, 60);

set_metadata_recursive("/system/app", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
set_metadata_recursive("/system/lib", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
set_metadata_recursive("/system/vivo-apps", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
set_metadata_recursive("/system/extra-app-list", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
show_progress(0.300000, 20);

ui_print("Unmounting system...");
unmount("/system");
EOF
}

action=$1
[[ x"$1" == x ]] && usage

if [ x"$action" == xanalyse ]; then
    rom_dir="$2"
    if [ ! -d "$rom_dir"/system ]; then
        echo "<base-rom-dir>/system not found"
        exit 1
    fi
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
    if [ -d ./tmp_app_files/file_list/ ]; then
        deploy_app
    else
        echo ""echo "'./tmp_app_files/' not found."
        echo "Please run '$0 analyse' first."
        exit 1
    fi
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
