#!/bin/bash

update_dir=${1:-../PD1304CLMA-update-patch_1.19.1_for_1.18.9}
build_prop='./build.prop-v1.19.1'

patch_dir="$update_dir/patch"
updater_script="$update_dir/META-INF/com/google/android/updater-script"

[ -f ./lost.list ] || echo "!!! run `./check_patch.sh` first."

mkdir ./rm_files
cp $updater_script  ./new-updater-script
for file in $(cat ./lost.list); do
    mv -v $file ./rm_files/
    _file_=$(echo $file|sed -e "s|^$patch_dir||" -e 's/\.p$//' -e 's/\//\\\//g')
    sed -i "/^apply_patch_check.*$_file_.*abort/{N; d}" ./new-updater-script
    sed -i "/^assert(apply_patch.*$_file_/{N;N;N; d}" ./new-updater-script
done

for file in $(cat ./change.list); do
    case $file in
        /system/build.prop)
            sed -i "/^apply_patch_check.*build.prop.*abort/{N; d}" ./new-updater-script
            sed -i "/^assert(apply_patch.*build.prop/{N;N; d}" ./new-updater-script
            install -Dv -m644 "$build_prop" "$update_dir"/system/build.prop
            mv -v "$patch_dir"/${file}.p ./rm_files/
            ;;
        *)
            echo "!!! 1. edit $file by yourself."
            echo "!!! 2. rm $file from:"
            echo "        1) $patch_dir"
            echo "        2) $updater_script"
            echo "!!! 3. copy new one to "$update_dir"/$file"
            ;;
    esac
done

mv -v $updater_script ./rm_files
cp -v ./new-updater-script $updater_script
