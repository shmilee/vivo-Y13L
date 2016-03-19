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
* 常用app升级包 --> Y13L-apps-dateVersion.zip
* Root卡刷包    --> *SuperSU*.zip
* Busybox卡刷包 --> Busybox-version-armv7.zip
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

## Y13L-apps-20160320.zip

TODO:

添加 extra-app
