#!/bin/bash
shopt -s extglob

in_array() {
    local s
    for s in ${@:2}; do
        if [[ $s == $1 ]];then
            return 0
        fi
    done
    return 1
}

mesge() {
	local arrow=$1 msg1="$2" msg2="$3"; shift; shift; shift
    if [[ $arrow == '1' ]]; then
        printf "==>\e[1m\e[32m ${msg1} \e[0m${msg2}" "$@" >&2
    else
        printf " ->\e[1m\e[32m ${msg1} \e[0m${msg2}" "$@" >&2
    fi
}

error() {
    local arrow=$1 msg1="$2" msg2="$3"; shift; shift; shift
    if [[ $arrow == '1' ]]; then
        printf "==>\e[1m\e[31m ${msg1} \e[0m${msg2}" "$@" >&2
    else
        printf " ->\e[1m\e[31m ${msg1} \e[0m${msg2}" "$@" >&2
    fi
}

full_zip_dir=${1:-./PD1304CL_A_1.19.1-update-full}
patch_zip_dir=${2:-./PD1304CL-PD1304CLMA-update-patch_1.19.3_for_1.19.1_201607121833576429}
#9446ed7ee0d21048389e68f650e01630  PD1304CL_A_1.19.1-update-full.zip
#188b12b2f1ee62424252c9970e9efacd  PD1304CL-PD1304CLMA-update-patch_1.19.3_for_1.19.1_201607121833576429.zip

new_zip_dir=${3:-./new-update-full-zip-dir}

patch_dir="$patch_zip_dir/patch"
updater_script="$patch_zip_dir/META-INF/com/google/android/updater-script"
patch_cmd='./applypatch'

mesge 1 '' '1. Check update-full-zip and update-patch-zip ...\n'
lost_f=()
>lost.list
for f in $(find $patch_dir -type f); do
    _tfile=$(echo $f|sed -e "s|^$patch_dir||" -e 's/\.p$//')
    if [ -f "${full_zip_dir}"/$_tfile ]; then
        mesge 2 ' ok ' '%s\n' $f
    else
        error 2 'lost' '%s\n' $f
        echo $f >>lost.list
        lost_f+=("$_tfile")
    fi
done

>change.list
boot_line="$(grep 'apply_patch_check.*EMMC' $updater_script | awk -F\: '{print $4}')::/boot.img"
for line in $(grep apply_patch_check $updater_script | grep -v EMMC | awk -F\" '{print $6"::"$2}') $boot_line; do
    sha1_x=${line/%::*/}
    file=${line/#*::/}
    if in_array $file ${lost_f[@]}; then
        continue
    fi

    sha1_f=$(sha1sum "${full_zip_dir}"/$file | cut -d' ' -f1)
    if [ x$sha1_x == x$sha1_f ]; then
        mesge 2 ' ok ' '%s %s\n' $sha1_x $file
    else
        error 2 ' ~= ' '%s %s (%s)\n' $sha1_x $file $sha1_f
        echo $file >>change.list
    fi
done

if [ x$(stat --format=%s lost.list) == x0 -a x$(stat --format=%s change.list) == x0 ]; then
    mesge 1 ' update-full-zip and update-patch-zip match well' '\n'
    rm lost.list change.list
else
    error 1 ' unmatched update-full-zip and update-patch-zip' '\n'
    error 1 ' Check info in file lost.list and change.list' '\n'
    exit 1
fi

mesge 1 '' '2. apply update-patch-zip/patch to update-full-zip ...\n'

if [ ! -d "$new_zip_dir" ]; then
    mesge 2 '' 'prepare a copy of update-full-zip ... '
    cp -r "$full_zip_dir" "$new_zip_dir"
    printf 'Done.\n'
else
    mesge 2 '' 'use existing %s \n' "$new_zip_dir"
fi

cp $updater_script updater-script.left2do
>patch-failed.list
for file in $(find $patch_dir -type f); do
    _tfile=$(echo $file|sed -e "s|^$patch_dir||" -e 's/\.p$//')
    mesge 2 'apply' '%s ... ' $file
    if [ -f "${new_zip_dir}"/$_tfile ]; then
        if [ $_tfile == '/boot.img' ]; then
            info=$(sed -n "/^assert(apply_patch.*EMMC.*by-name\/boot/{N;N;N; p}" updater-script.left2do)
            tgt_sha1=$(echo $info | sed 's/,//g'|awk '{printf $3}')
            tgt_size=$(echo $info | sed 's/,//g'|awk '{printf $4}')
            src_sha1=$(echo $info | sed 's/,//g'|awk '{printf $5}')
            if $patch_cmd "${new_zip_dir}"/$_tfile - $tgt_sha1 $tgt_size ${src_sha1}:$file; then
                mesge 2 'Done.' '\n'
                sed -i "/^apply_patch_check.*EMMC.*by-name\/boot.*abort/{N; d}" updater-script.left2do
                sed -i "/^assert(apply_patch.*EMMC.*by-name\/boot/{N;N;N; d}" updater-script.left2do
            else
                echo $file >>patch-failed.list
                error 2 'Failed.' '\n'
            fi
        else
            info=$(sed -n "/^assert(apply_patch.*$(echo $_tfile|sed 's/\//\\\//g')/{N;N;N; p}" updater-script.left2do)
            tgt_sha1=$(echo $info | sed 's/,//g'|awk '{printf $3}')
            tgt_size=$(echo $info | sed 's/,//g'|awk '{printf $4}')
            src_sha1=$(echo $info | sed 's/,//g'|awk '{printf $5}')
            if $patch_cmd "${new_zip_dir}"/$_tfile - $tgt_sha1 $tgt_size ${src_sha1}:$file; then
                mesge 2 'Done.' '\n'
                sed -i "/^apply_patch_check.*$(echo $_tfile|sed 's/\//\\\//g').*abort/{N; d}" updater-script.left2do
                sed -i "/^assert(apply_patch.*$(echo $_tfile|sed 's/\//\\\//g')/{N;N;N; d}" updater-script.left2do
            else
                echo $file >>patch-failed.list
                error 2 'Failed.' '\n'
            fi
        fi
    else
        echo $file >>patch-failed.list
        error 1 ' Never happen.' '\n'
        exit 1
    fi
done

if [ x$(stat --format=%s patch-failed.list) == x0 ]; then
    mesge 1 ' All patches are done.' '\n'
    rm patch-failed.list
else
    error 1 ' Some patches are failed.' '\n'
    error 1 ' Check info in file patch-failed.list' '\n'
fi

mesge 1 '' '3. copy update-patch-zip/{recovery,system} to update-full-zip ...\n'

>copy-failed.list
for file in $(find $patch_zip_dir/{recovery,system} -type f); do
    _tfile=$(echo $file|sed "s|^$patch_zip_dir||")
    mesge 2 'copy' '%s ... \n' $file
    if install -Dvm644 $file $new_zip_dir/$_tfile; then
        mesge 2 'Done.' '\n'
        sed -i "s|$_tfile||g" updater-script.left2do
    else
        echo $file >>copy-failed.list
        error 2 'Failed.' '\n'
    fi
done

mesge 1 '' '4. copy update-patch-zip/{*.bin,*.mbn} to update-full-zip ...\n'

for file in $(find $patch_zip_dir/{*.bin,*.mbn} -type f); do
    _tfile=$(echo $file|sed "s|^$patch_zip_dir||")
    mesge 2 'copy' '%s ... \n' $file
    if install -Dvm644 $file $new_zip_dir/$_tfile; then
        mesge 2 'Done.' '\n'
        sed -i "s|$_tfile||g" updater-script.left2do
        sed -i "/.*$(basename $_tfile).*dev\/block/d" updater-script.left2do
    else
        echo $file >>copy-failed.list
        error 2 'Failed.' '\n'
    fi
done

if [ x$(stat --format=%s copy-failed.list) == x0 ]; then
    mesge 1 ' All files are copied successfully.' '\n'
    rm copy-failed.list
else
    error 1 ' Some files are not copied.' '\n'
    error 1 ' Check info in file copy-failed.list' '\n'
fi

mesge 1 ' The merge is complete.' '\n'
exit 0
