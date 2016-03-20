#!/bin/bash

#ro.product.cpu.abi=armeabi-v7a
#ro.product.cpu.abi2=armeabi
abi=armeabi-v7a
abi2=armeabi

#################### Set Slim Files ####################

mbn_files=(emmc_appsboot.mbn NON-HLOS.bin rpm.mbn sbl1.mbn tz.mbn)
rm_recovery='no'

##system/app/
app_files=(BBKAppStore.{apk,odex} \
    BBKCalculator.{apk,odex} \
    CuteImageAnim.{apk,odex} \
    Galaxy4.{apk,odex} \
    LiveWallpapers_gles20.{apk,odex} \
    LiveWallpapersPicker_gles20.{apk,odex} \
    NoiseField.{apk,odex} \
    PhaseBeam.{apk,odex} \
    VivoCollage.apk \
    vivogame.{apk,odex} \
    VIVO_MTTT.apk \
    vivospace-v2.{apk,odex})
#   BBKCloud.{apk,odex} \
#   BBKMusic.{apk,odex} \
#   BBKMusicEffectTest.{apk,odex} \
#   SimpleMusicAppWidget.{apk,odex} \
#   VivoDreamMusicApp.{apk,odex}

##system/media/
#should be bootaudio.mp3  shutaudio.mp3
_mp3s=(bootaudio_CN-YD.mp3  shutaudio_CN-YD.mp3)
_animations=(bootanimation_CN-YD.zip  shutanimation_CN-YD.zip)
_ringtones=(audio/ringtones/{A*,B*,C*,D*,H*,I*,J*,N*,Ra*,Rh*,V*,W*,X*})
_notifications=(audio/notifications/{A*,B*,F*,H*,L*,Message_0{2,3,4,5}.ogg})
_alarms=(audio/alarms/Alarm_{E*,F*,G*,J*,Little*,O*,T*,W*})
_uiaudio=(audio/ui/{Drum*,Glass*,Voice*,Xylophone*})
_uiaudio+=(audio/ui/{Gladius,Gome-With-Kalifi,Remix,Stereophony,Tropical-Dance}.ape)
media_files=(${_mp3s[@]} ${_animations[@]} \
    ${_ringtones[@]} ${_notifications[@]} ${_alarms[@]} ${_uiaudio[@]})

##others
#system/tts/lang_pico/
_langtts=(de-DE_gl0_sg.bin de-DE_ta.bin \
    es-ES_ta.bin es-ES_zl0_sg.bin \
    fr-FR_nk0_sg.bin fr-FR_ta.bin \
    it-IT_cm0_sg.bin it-IT_ta.bin)
other_files=(${_langtts[@]/#/system\/tts\/lang_pico\/} system/vivo-apps/)

#################### Set Slim Files ####################

usage() {
    cat <<EOF
 Usage: $0 <rom.zip/extract/directory>

 Log and removed files are put in ./rom_rmfiles directory.
EOF
}

##### BEGIN

rom_dir="$1"
work_dir="$PWD"
LOG="./rom_rmfiles/$(date +%F).log"

if [ $# == 0 ]; then
    usage
    exit 0
fi
if [ ! -d "$rom_dir/META-INF" -o ! -d "$rom_dir/system" ]; then
    echo "$rom_dir is not a rom directory."
    usage
    exit 1
fi

mkdir -pv ./rom_rmfiles/{mbn,system/{app,media,lib},other}
echo "ROM DIR: $rom_dir" >> $LOG
echo >> $LOG

for file in ${mbn_files[@]}; do
    mv -vi "$rom_dir"/$file ./rom_rmfiles/mbn/ | tee -a $LOG
done

if [ x$rm_recovery == xyes ]; then
    mv -vi "$rom_dir"/recovery ./rom_rmfiles/ | tee -a $LOG
fi

for file in ${app_files[@]}; do
    mv -vi "$rom_dir"/system/app/$file ./rom_rmfiles/system/app/ | tee -a $LOG
done
for apk in ./rom_rmfiles/system/app/*.apk; do
    mkdir ${apk/%.apk/}-lib/
    abi_lib=()
    abi2_lib=()
    if unzip $apk "lib/$abi/*" -d ${apk/%.apk/}-lib/; then
        abi_lib=(${apk/%.apk/}-lib/lib/$abi/*)
        echo -e "\n$(basename $apk)($abi): $(basename -a ${abi_lib[@]})\n" | tee -a $LOG
    fi
    if unzip $apk "lib/$abi2/*" -d ${apk/%.apk/}-lib/; then
        abi2_lib=(${apk/%.apk/}-lib/lib/$abi2/*)
        echo -e "\n $(basename $apk)($abi2): $(basename -a ${abi2_lib[@]}) \n" | tee -a $LOG
    fi
    if [ x$abi_lib == x -a x$abi2_lib == x ]; then
        rmdir ${apk/%.apk/}-lib/
    else
        read -p "remove all the $(basename $apk) libs? [y/n]" ANSW
        if [ x$ANSW == xy -o x$ANSW == xY ]; then
            for sofile in $(basename -a ${abi_lib[@]}) $(basename -a ${abi2_lib[@]}); do
                mv -vi "$rom_dir"/system/lib/$sofile ./rom_rmfiles/system/lib/ | tee -a $LOG
            done
        fi
    fi
done

for file in ${media_files[@]}; do
    mv -vi "$rom_dir"/system/media/$file ./rom_rmfiles/system/media/ | tee -a $LOG
done

for file in ${other_files[@]}; do
    mv -vi "$rom_dir"/$file ./rom_rmfiles/other/ | tee -a $LOG
done

echo "Done. (./rom_rmfiles/)"

read -p "To slim animation? [y/n]" ANSW
if [ $ANSW == y -o $ANSW == Y ]; then
    mkdir ./rom_rmfiles/animation-backup/
    cp -v "$rom_dir"/system/media/{bootanimation.zip,shutanimation.zip}  ./rom_rmfiles/animation-backup/
    bash ./slimanimation.sh ./rom_rmfiles/animation-backup/bootanimation.zip
    mv -vi new-bootanimation.zip "$rom_dir"/system/media/bootanimation.zip | tee -a $LOG
    bash ./slimanimation.sh ./rom_rmfiles/animation-backup/shutanimation.zip
    mv -vi new-shutanimation.zip "$rom_dir"/system/media/shutanimation.zip | tee -a $LOG
fi
echo "Done."
