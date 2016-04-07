#!/bin/bash

ARCH='armv7l'
version='1.21.1'
rm_cmds=(reboot su sulogin stty)

msg() {
    echo -e "$@"
}

binfile="./busybox-${ARCH}-v$version"
url="https://busybox.net/downloads/binaries/$version/busybox-$ARCH"

if [ -f $binfile ]; then
    msg "Using $binfile ..."
else
    msg "Downloading $binfile ..."
    if ! wget -c $url -O $binfile; then
        msg "Failed. Check url and version."
        rm $binfile
        exit 1
    fi
fi

[ -d ./busybox-update-dir/ ] && rm -r ./busybox-update-dir/
mkdir -pv ./busybox-update-dir/system/{bin,busybox,etc}
mkdir -pv ./busybox-update-dir/META-INF/com/google/android

# 1.busybox
cp -v $binfile ./busybox-update-dir/system/busybox/busybox

# 2.bettertermpro
mkdir /tmp/bettertermpro
unzip ./bettertermpro.zip `cat ./bettertermpro.list` -d /tmp/bettertermpro
chmod 755 -R /tmp/bettertermpro
cp -vr /tmp/bettertermpro/bin/* ./busybox-update-dir/system/busybox/
mv -v /tmp/bettertermpro/etc/terminfo ./busybox-update-dir/system/etc/
rm -r /tmp/bettertermpro

# 3.chshell chmount
cat ./script/chshell > ./busybox-update-dir/system/bin/chshell
cat ./script/chmount > ./busybox-update-dir/system/bin/chmount

# 3.etc/*
cp -rv ./etc/* ./busybox-update-dir/system/etc/

# 4.meta
uc_dir=./busybox-update-dir/META-INF/com/google/android
cp -v ./update-binary $uc_dir/update-binary
cat > $uc_dir/updater-script <<EOF
ui_print("=======================");
ui_print("***BusyBox v$version $ARCH*****");
ui_print("***By shmilee*****");
ui_print("***$(date +%F)*****");
ui_print("=======================");

mount("ext4", "EMMC", "/dev/block/bootdevice/by-name/system", "/system");
show_progress(0.200000, 10);

EOF

cat ./script/updater-script >> $uc_dir/updater-script

cat >> $uc_dir/updater-script <<EOF
run_program("/system/busybox/busybox", "--install", "-s", "/system/busybox");
EOF
for cmd in ${rm_cmds[@]}; do
    cat >> $uc_dir/updater-script <<EOF
run_program("/system/busybox/busybox", "rm", "/system/busybox/$cmd");
EOF
done

cat >> $uc_dir/updater-script <<EOF
show_progress(0.300000, 20);

ui_print("Unmounting system...");
unmount("/system");
EOF

# zip
cd ./busybox-update-dir/
zip -r -y -X -9 ../Update-Busybox-v${version}-${ARCH}-unsigned.zip *

msg "Done."
msg "Do not forget to sign the zip file."
