fastboot
=========

```
Platform: MSM8916
Version: PD1304CL_A_...
Device is lock
Device is umtampered
```
Unlock Device in windows(because the bbk driver):

```
adb reboot bootloader
fastboot devices
fastboot bbk unlock_vivo
```

## flash recovery:

```
Android system recovery <3e>
KTU84P dev-keys
```

* cwm_recovery.img: ugly, 7to, for third ROM
* vivo_recovery.img: official

```
adb reboot bootloader
fastboot devices
fastboot erase recovery
fastboot flash recovery recovery.img
```

## update radio image(from ROM1)

files:

* NON-HLOS.bin
* emmc_appsboot.mbn
* rpm.mbn
* tz.mbn
* sbl1.mbn

flash commands:

```
fastboot erase modem
fastboot flash modem NON-HLOS.bin
fastboot erase aboot
fastboot flash aboot emmc_appsboot.mbn
fastboot erase rpm
fastboot flash rpm rpm.mbn
fastboot erase tz
fastboot flash tz tz.mbn
fastboot erase sbl1
fastboot flash sbl1 sbl1.mbn

fastboot erase abootbak
fastboot flash abootbak emmc_appsboot.mbn
fastboot erase rpmbak
fastboot flash rpmbak rpm.mbn
fastboot erase tzbak
fastboot flash tzbak tz.mbn
fastboot erase sbl1bak
fastboot flash sbl1bak sbl1.mbn
```


ROM包
=========

## 官方升级包 ROM1

网址：http://www.vivo.com.cn/download/49.html  

升级包：http://www.vivo.com.cn/dl/151

## 线刷救砖 ROM2(备用)

vivoY13L移动4G_A_1.15.2_trunk线刷包(工具rom教程).rar

## 其他ROM

* [VIVO Y13L1.18.5精简](http://rom.7to.cn/romdetail/1005144)

* [FIRE Y13L MIUI7系列](http://rom.7to.cn/romlist/bbk-vivo-y13l?a=41)



基于 ROM1 定制
==============

* 官方升级包精简，少部分app，铃声 --> Y13L-base-version-shmilee.zip
* 常用app升级包 --> Update-apps-dateVersion.zip
* Root卡刷包    --> *SuperSU*.zip
* Busybox卡刷包 --> Update-Busybox-version-arch.zip
* kbox卡刷包    --> kbox3-dateVersion.zip


## Y13L-base-1.18.9-shmilee.zip

下载官方升级包 PD1304CL_A_1.18.9-update-full.zip

1. 精简与删除。(脚本 ``slim_Y13L_rom.sh`` )
  
  * 删除文件 emmc_appsboot.mbn  NON-HLOS.bin  rpm.mbn  sbl1.mbn  tz.mbn 。
  * ~~删除目录 recovery 。~~
  * 删除不需要的铃声、闹钟、短信提示音 ``system/media/audio/``
  * 精简不需要的tts语言包 ``system/tts/lang_pico``
  * 删除不需要的软件 ``system/app``, ``system/vivo-apps``
  * 精简开机动画 ``system/media/*animation.zip``  

2. 添加 core-app --> system/app/
  
  用脚本``core-app.sh``安装, 自动抽取和复制lib文件。
  
  * BBKMusic.apk (vivo更新, 更简洁)
  * LockScreen.apk (vivo-apps)
  * RealCalc_v2.3.1.apk (官网)
  
  添加铃声 --> system/media/audio/notifications/
  
  * BlackBerryOS7/EagerRemix.m4a
  * BlackBerryOS7/SanguineRemix.m4a

3. 编辑 system/build.prop。
  
  ```
  # Set composition for USB
  persist.sys.usb.config=diag,serial_smd,rmnet_bam,adb
  # ADDITIONAL_BUILD_PROPERTIES
  persist.vivo.phone.usb_otg=Have_usb_otg
  persist.vivo.phone.glove_mode=Have_glove_mode
  persist.vivo.phone.num_battery=Have_battery_percentage
  persist.vivo.phone.hifi=Have_hifi
  persist.vivo.phone.wfd=Have_wfd
  ```

4. 去广告。
  替换system/etc/hosts为 http://winhelp2002.mvps.org/hosts.htm 的hosts文件。

5. 修改脚本 META-INF/com/google/android/updater-script。
  
  * 添加个人信息。
  * 去除 ro.hardware.bbk 验证。
  * 去除 Writing radio image。
  * 调教进度条。show_progress。

6. 最后。删除META-INF目录下的签名，CERT.RSA  CERT.SF  MANIFEST.MF三个文件，
  然后打包，重新签名。复制 Y13L-base-1.18.9-shmilee.zip 到sd卡，刷机测试。
  
  ```
  cd <root-of-rom>/
  zip -r -X -9 ../Y13L-base.zip *
  cd ../Auto-sign/
  java -jar signapk.jar testkey.x509.pem testkey.pk8 ../Y13L-base.zip Y13L-base-1.18.9-shmilee.zip
  rm ../Y13L-base.zip
  ```

## Update-apps-$(date +%Y%m%d).zip

来源，首选官网，然后手机乐园、apkpure，最后论坛贴吧。

1. extra-app --> system/app/
  
  * BaiduMaps.apk (官网)
  * [BubbleUPnP.apk](http://bbs.zhiyoo.com/thread-12442204-1-1.html)  
    DLNA server and client, cooperates with XBMC on PC.
  * [ezPDF_Reader.apk](http://soft.shouji.com.cn/down/20236.html)
  * [Firefox_Browser.apk](https://apkpure.com/firefox-browser-for-android/org.mozilla.firefox)  
    addons: Adblock Plus, Network Preferences Add-on.  
    CAs: Import the CA file by downloading it in the browser.
  * ForaDictionary.apk ([官网](http://ng-comp.com/fora/android.htm))
  * kiwix.apk (官网)
  * ~~Mobile_Classic_12_1_9_Generic_Opera_ARMv5v7.apk ([官网](https://ftp.opera.com/pub/opera/android/classic/))~~
  * wpsoffice.apk (官网)
  * [rootexplorer.apk](http://soft.shouji.com.cn/down/17849.html)
  * [smart_tools.apk](http://soft.shouji.com.cn/down/20319.html)
  * [TerminalEmulator](https://github.com/jackpal/Android-Terminal-Emulator)
  * weixin.apk (官网)
  * ~~WI_IME_Android_2.5.apk (官网)~~
  * [百度输入法小米V6版+6.0.5.3.apk](http://bbs.zhiyoo.com/thread-12435967-1-1.html)

2. extra-app --> system/vivo-apps/
  
  在system/app/中无法工作的app，或是与系统的lib文件有冲突的app。
  在开机后，这些app通过 *设置-更多设置-应用程序-出厂应用程序管理* 安装到data/app下。
  
  * ~~[goldendict_1.6.2_A44_CR_HA.apk](http://bbs.mfunz.com/thread-956541-1-1.html)~~
  * GoldenDict-1.6.5-Android-4.4+-free.apk ([官网](http://goldendict.mobi/downloads/android/free/))
  * [MX_Player_Pro_1.8.4_20160125_AC3_crk.apk](http://www.miui.com/thread-3588261-1-1.html)

用脚本``extra-app.sh``自动抽取lib文件，部署软件和库，压缩为zip文件。

```
#link setting file. Overlay='NO', 首次添加; Overlay='YES', 覆盖升级.
./extra-app.sh analyse <root-of-base-rom>
./extra-app.sh deploy
./extra-app.sh zip Y13L-apps.zip
```

最后签名。复制 ``Update-apps-$(date +%Y%m%d).zip`` 到sd卡，刷机测试。

```
cd Auto-sign/
java -jar signapk.jar testkey.x509.pem testkey.pk8 Y13L-apps.zip Update-apps-$(date +%Y%m%d).zip
rm Y13L-apps.zip
```

* more-app --> sd卡。


## *SuperSU*.zip

* UPDATE-SuperSU-v2.14.zip (from other rom)
* Stable [UPDATE-SuperSU-v2.65-20151226141550.zip](http://forum.xda-developers.com/showthread.php?t=1538053)

## Update-Busybox-v1.24.2-armv7.zip

cpuinfo:

```
Processor	: ARMv7 Processor rev 0 (v7l)
Features	: swp half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt
Hardware	: Qualcomm Technologies, Inc MSM8916
```

* 官网最新二进制文件 [1.21.1](https://busybox.net/downloads/binaries/1.21.1/)
  
  自己动手编译新版 [busybox](https://github.com/meefik/busybox.git).
  当前最新版本 v1.24.2, NDK 选用 [android-ndk-r8e](https://dl.google.com/android/ndk/android-ndk-r8e-linux-x86_64.tar.bz2) 。
  
  ```
  cd <work/dir>
  git clone https://github.com/meefik/busybox.git
  cd busybox
  git checkout tags/1.24.2 -b v1.24.2
  cd contrib/
  export ANDROID_NDK_ROOT="<path/to/android-ndk-r8e>"
  sed -i 's/\(GCC_VERSION="\)4.9/\14.7/' bb-build.sh    #androideabi/gcc-4.7
  sed -i 's/\(ANDROID_NATIVE_API_LEVEL="android\)-9/\1-14/' bb-build.sh    #platforms/android-14, Android 4.0 or later
  sed -i '/EXTRAVERSION = -meefik.*Makefile/d' bb-build.sh    #no extraversion
  #根据 cpuinfo 优化
  sed -i 's/\(-march=arm\)v5te/\1v7/' bb-build.sh    #valid args: armv7 armv7-{a,m,r} armv7e-m
  sed -i 's/-msoft-float \(-mfloat-abi=softfp -mfpu=\)neon/\1neon-vfpv4/' bb-build.sh    #mfpu
  ./bb-build.sh arm static
  cp busybox-1.24.2/busybox <this/repository/path>/busybox/busybox-v1.24.2-armv7
  ```

* Better Terminal Emulator Pro v4.04 下载的 bettertermpro.zip, 提取 bash:
  
  ```
  bin/bash #(strings bash | grep bashrc --> /system/etc/bash/bashrc)
  etc/terminfo/l/linux
  etc/terminfo/v/vt100
  etc/terminfo/v/vt220
  etc/terminfo/x/xterm
  ```

* openssh.tar.gz 来自 https://github.com/shmilee/android-cli-openssh.git

* script/chmount: 将 mount 命令链接到 busybox，使 root 后可以挂载 system 为读写。

* script/chshell: 切换不同的 shell，主要为 ash 和 bash 。

* script/updater-script

* etc/bash/bashrc

* etc/busybox_ashrc

* etc/common_shell.profile

运行 ``mkbusybox.sh``, 然后签名。


