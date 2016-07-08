#!/bin/bash
shopt -s extglob

slim_base_dir=${1:-~/android/Y13L-base-1.18.9-shmilee}
update_dir=${2:-../PD1304CLMA-update-patch_1.19.1_for_1.18.9}

patch_dir="$update_dir/patch"
updater_script="$update_dir/META-INF/com/google/android/updater-script"

in_array() {
    local s
    for s in ${@:2}; do
        if [[ $s == $1 ]];then
            return 0
        fi
    done
    return 1
}

lost_f=()
>lost.list
for f in $(find $patch_dir -type f); do
    _tfile=$(echo $f|sed -e "s|^$patch_dir||" -e 's/\.p$//')
    if [ -f "${slim_base_dir}"/$_tfile ]; then
        printf '\e[1m\e[32m ok \e[0m %s\n' $f
    else
        printf '\e[1m\e[31mlost\e[0m %s\n' $f
        echo $f >>lost.list
        lost_f+=("$_tfile")
    fi
done

>change.list
for line in $(grep apply_patch_check $updater_script | grep -v EMMC | awk -F\" '{print $6"::"$2}'); do
    sha1_x=${line/%::*/}
    file=${line/#*::/}
    if in_array $file ${lost_f[@]}; then
        continue
    fi

    sha1_f=$(sha1sum "${slim_base_dir}"/$file | cut -d' ' -f1)
    if [ x$sha1_x == x$sha1_f ]; then
        printf '\e[1m\e[32m ok \e[0m %s %s\n' $sha1_x $file
    else
        printf '\e[1m\e[31m ~= \e[0m %s %s (%s)\n' $sha1_x $file $sha1_f
        echo $file >>change.list
    fi
done
