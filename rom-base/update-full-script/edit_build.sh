#!/bin/bash
usage() {
    echo "Usage: $0 <rom.zip/extract/directory>"
    exit 0
}

rom_dir="$1"

if [ $# == 0 ]; then
    usage
    exit 0
fi
if [ ! -d "$rom_dir/META-INF" -o ! -d "$rom_dir/system" -o ! -f "$rom_dir"/system/build.prop ]; then
    echo "!!! $rom_dir is not a rom directory."
    usage
    exit 1
fi

if [ ! -f ./updater-script-template ]; then
    echo "!!! lost ./updater-script-template."
    usage
    exit 1
fi

# Funtouch OS_1.2

echo "==> 1. edit system/build.prop ..."
cp -i -v "$rom_dir"/system/build.prop{,.bk}
sed -e '/persist.sys.usb.config=/ s/^#//' \
    -e 's/\(persist.vivo.phone.usb_otg=\)No\(_usb_otg\)/\1Have\2/' \
    -e 's/\(persist.vivo.phone.glove_mode=\)No\(_glove_mode\)/\1Have\2/' \
    -e 's/\(persist.vivo.phone.num_battery=\)No\(_battery_percentage\)/\1Have\2/' \
    -e 's/\(persist.vivo.phone.hifi=\)No\(_hifi\)/\1Have\2/' \
    -e 's/\(persist.vivo.phone.wfd=\)No\(_wfd\)/\1Have\2/' \
    -i "$rom_dir"/system/build.prop
echo "==> 1. check the result ..."
diff -Nu "$rom_dir"/system/build.prop{,.bk}
rm -i -v "$rom_dir"/system/build.prop.bk

echo "==> 2. edit META-INF/com/google/android/updater-script ..."
mv -i -v "$rom_dir"/META-INF/com/google/android/updater-script{,.bk}

version=$(sed -n 's/^ro.vivo.product.version.*_\([0-9.]*\)$/\1/ p' "$rom_dir"/system/build.prop)
sed -e "s/vivo-Y13L-base-VERSION/vivo-Y13L-base-${version}/" \
    ./updater-script-template > "$rom_dir"/META-INF/com/google/android/updater-script
echo "==> 2. check the result ..."
diff -Nu "$rom_dir"/META-INF/com/google/android/updater-script{,.bk}
rm -i -v "$rom_dir"/META-INF/com/google/android/updater-script.bk
