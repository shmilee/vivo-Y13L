#################### Setting ####################
#ro.product.cpu.abi=armeabi-v7a
#ro.product.cpu.abi2=armeabi
abi=armeabi-v7a
abi2=armeabi

APK_DIR="./update-20160501"
Overlay='NO'

# 无lib冲突 -> system/app/
# 有lib冲突 -> system/vivo-apps/
extra_apps=(BaiduMaps::BaiduMaps_Android_9-2-0_1009179g.apk \
    BubbleUPnP::BubbleUPnP-2.6.1.apk \
    ezPDF_Reader::ezPDF_Reader_v2.6.6.1.apk \
    Firefox_Browser::Firefox_Browser_v46.0.apk \
    ForaDictionary::ForaDictionary_v17.2.apk \
    kiwix::kiwix-1.97.apk \
    wpsoffice::moffice_9.6.2_1033.apk \
    ProxyDroid::ProxyDroid_v2.7.4.apk \
    rootexplorer::rootexplorer_3.3.8_109.apk \
    smart_tools::smart_tools_v1.7.9_83.apk \
    TerminalEmulator::TerminalEmulator_v1.0.70.apk \
    weixin::weixin6316android780.apk \
    BaiduIME::百度输入法小米V6版+6.0.5.3.apk)

# base包已有的库文件
# 即使 app 中包含这些库文件，也不算冲突
# 默认保留使用 base 的库，删除 app带的
lib_ignore=(libentryexstd.so)

# -> system/vivo-apps/
extra_vivoapps=(goldendict::GoldenDict-1.6.5-Android-4.4+-free.apk \
    MX_Player_Pro::MX_Player_Pro_1.8.4_20160125_AC3_crk.apk)

#################### Setting ####################
