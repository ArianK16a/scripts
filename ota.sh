#!/bin/sh
file_path="$(ls out/target/product/*/Havoc-OS-* | grep -v Changelog | grep -v md5sum | grep -v json)"
file_name="$(cd out/target/product/*/ && ls Havoc-OS-* | grep -v Changelog | grep -v md5sum | grep -v json)"
file_size="$(ls -l "$file_path" | awk '{print $5}')"
md5="$(cat "$file_path".md5sum | awk '{print $1}')"
date="$(date '+%Y%m%d')"

cd OTA
git add -A && git stash && git reset
git fetch git@github.com:Havoc-OS/OTA.git
git checkout FETCH_HEAD
cd ..
echo "resetted ota"
echo -e "{
   \"website_url\":\"https://sourceforge.net/projects/havoc-os/\",
   \"news_url\":\"https://t.me/Havoc_OS\",
   \"addons\": [
   {
      \"title\":\"GApps\",
      \"summary\":\"Official Open GApps\",
      \"url\":\"http://opengapps.org\"
   },
   {
      \"title\":\"Magisk\",
      \"summary\":\"Systemless Root Installer\",
      \"url\":\"https://forum.xda-developers.com/apps/magisk/official-magisk-v7-universal-systemless-t3473445\"
   },
   {
     \"title\":\"VantomKernel\",
     \"summary\":\"Maximum of Features and a great optimization\",
     \"url\":\"http://159.65.193.144/vantom\"
   },
   {
     \"title\":\"TWRP\",
     \"summary\":\"Recommended TWRP 3.2.3\",
     \"url\":\"https://github.com/xiaomi-msm8998/device_xiaomi_sagit/releases/tag/3.2.3\"
   },
   {
     \"title\":\"Firmware\",
     \"summary\":\"Firmware 8.4.19\",
     \"url\":\"https://sourceforge.net/projects/xiaomi-firmware-updater/files/Developer/8.4.19/sagit/fw_sagit_miui_MI6Global_8.4.19_49003fef39_8.0.zip/download\"
   }
   ],
   \"forum_url\":\"https://forum.xda-developers.com/mi-6/development/rom-havoc-os-t3807517\",
   \"build_date\":\"$date-0000\",
   \"url\":\"https://sourceforge.net/projects/havoc-os/files/sagit/$file_name/download\",
   \"file_name\":\"$file_name\",
   \"file_size\":\"$file_size\",
   \"md5\":\"$file_checksum\"
}
" > OTA/sagit
echo "update OTA"
cd OTA
git add -A
git commit -S -m "sagit: $date"
cd ..
echo "Updated OTA succesfully"
