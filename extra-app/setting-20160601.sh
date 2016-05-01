#################### Setting ####################
#ro.product.cpu.abi=armeabi-v7a
#ro.product.cpu.abi2=armeabi
abi=armeabi-v7a
abi2=armeabi

APK_DIR="./update-20160601"
Overlay='YES'

# 无lib冲突 -> system/app/
# 有lib冲突 -> system/vivo-apps/
extra_apps=()
        
    
    
# base包已有的库文件
# 即使 app 中包含这些库文件，也不算冲突
# 默认保留使用 base 的库，删除 app带的
lib_ignore=(libentryexstd.so)

# -> system/vivo-apps/
extra_vivoapps=()

#################### Setting ####################
