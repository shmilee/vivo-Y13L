#!/bin/bash

ARCH='armv7l'
version='1.21.1'

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

# 2.chshell
cat >./busybox-update-dir/system/bin/chshell <<EOF
#!/system/bin/mksh

usage() {
    echo "Usage: chshell [-h] [-v] [</system/shell> <ENV-file>]"
    echo "  Default   Change to the shell of '/system/buysbox/ash'."
    echo "            use /system/etc/busybox_ashrc as ENV file."
    echo "            Add /system/buysbox to PATH."
    echo "   -h       Show this help."
    echo "   -v       Show buysbox version."
}

version() {
    echo 
    echo "BusyBox v$version $ARCH multi-call binary."
    echo "Licensed under GPLv2. See source distribution for detailed"
    echo "copyright notices."
    echo
}

if [ x\$1 == x-h ]; then
    usage
    exit 0
elif [ x\$1 == x-v ]; then
    version
    exit 0
else
    new_shell=\${1:-/system/busybox/ash}
    env_file=\${2:-/system/etc/busybox_ashrc}
    if [ ! -f \$new_shell ]; then
        echo "'!!! \$new_shell' not found."
        exit 1
    fi
    if [ x\$new_shell == x/system/busybox/ash -o x\$new_shell == x/system/busybox/sh ]; then
        version
        ENV=\$env_file exec \$new_shell
    else
        exec \$new_shell
    fi
fi
EOF

# 3.ashrc
cat > ./busybox-update-dir/system/etc/busybox_ashrc <<'EOF'
alias more='less'
alias df='df -h'
alias du='du -c -h'
alias c='clear'
alias path='echo -e ${PATH//:/\\n}'
alias cat='/system/bin/cat'

alias l=ls
alias ls='ls -hF --color=auto'
alias lr='ls -R'    # recursive ls
alias ll='ls -l'
alias la='ll -A'
alias lx='ll -X'    # sort by extension
alias lz='ll -rS'   # sort by size
alias lt='ll -rt'   # sort by date
alias lm='la | more'

PATH=/system/busybox:$PATH
PS1='$USER@$HOSTNAME:${PWD:-?} $ '
PS2='> '
HISTFILE=$EXTERNAL_STORAGE/.ash_history

alias history='/system/bin/cat -n $HISTFILE'

if [ -f $EXTERNAL_STORAGE/.ashrc ]; then
    source $EXTERNAL_STORAGE/.ashrc
fi
EOF

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

delete("/system/bin/chshell");
delete("/system/etc/busybox_ashrc");
delete_recursive("/system/busybox");

ui_print("extract system...");
assert(package_extract_dir("system", "/system"));
show_progress(0.300000, 60);

set_metadata("/system/bin/chshell", "uid", 0, "gid", 0, "mode", 06755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
set_metadata("/system/etc/busybox_ashrc", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
set_metadata_recursive("/system/busybox", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 06755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
show_progress(0.100000, 5);

run_program("/system/busybox/busybox", "--install", "-s", "/system/busybox");
show_progress(0.300000, 20);

ui_print("Unmounting system...");
unmount("/system");
EOF

# zip
cd ./busybox-update-dir/
zip -r -y -X -9 ../Update-Busybox-v${version}-${ARCH}-unsigned.zip *

msg "Done."
msg "Do not forget to sign the zip file."
