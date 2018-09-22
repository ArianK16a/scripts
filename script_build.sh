#!/bin/bash
#config
device="sagit"
username=arian

#upload
sourceforge="no"
sfpass="examplepassword"
sfpath="/home/pfs/project/havoc-os/"$device"
sfuser="exampleuser"

mega="no"
megamail="example@example.com"
megapass="examplaepassword"
megapath=/"$rom"/"$device"/"$rom"-$date-"$device"-"$buildtype".zip

# rarely changed variables
date="$(date '+%Y%m%d')"
use_ccache="yes"
make_clean="yes"
lunch_command="aosp"
target_command="mka aex"
buildtype="ALPHA"
romtype="AEX"
rom="AospExtended-v6.0"

# Colors makes things beautiful
export TERM=xterm

    red=$(tput setaf 1)             #  red
    grn=$(tput setaf 2)             #  green
    blu=$(tput setaf 4)             #  blue
    cya=$(tput setaf 6)             #  cyan
    txtrst=$(tput sgr0)             #  Reset

# CCACHE UMMM!!! Cooks my builds fast
if [ "$use_ccache" = "yes" ];
then
echo -e ${blu}"CCACHE is enabled for this build"${txtrst}
echo -e ${blu}"Fast as a lightning"${txtrst}
export USE_CCACHE=1
ccache -M 35G
fi

if [ "$use_ccache" = "clean" ];
then
export CCACHE_DIR=/home/ccache/$username
ccache -C
export USE_CCACHE=1
prebuilts/misc/linux-x86/ccache/ccache -M 35G
wait
echo -e ${red}"CCACHE Cleared"${txtrst};
fi

# Its Clean Time
if [ "$make_clean" = "yes" ];
then
make clean && make clobber
wait
echo -e ${red}"out dir from your repo deleted"${txtrst};
fi

if [ "$make_clean" = "dirty" ];
then
make installclean
wait
echo -e ${red}"deleted Images and staging directories"${txtrst};
fi

# Ubuntu 18.04
export LC_ALL=C

###############################################
####               Build ROM                ###
###############################################

repo sync --force-sync
. build/envsetup.sh
export "$romtype"_BUILD_TYPE="$buildtype"
lunch "$lunch_command"_"$device"-userdebug
make "$target_command"

###############################################
###                  Upload                 ###
###############################################

if [ "$mega" = "yes" ]
then
echo -e ${cya}"Uploading to mega.nz"
mega-login "$megamail" "$megapass"
mega-put out/target/product/"$device"/"$rom"-$date-"$device"-"$buildtype".zip "$megapath"
mega-logout
wait
echo -e ${grn}"Uploaded file successfully"
fi

if [ "$sourceforge" = "yes" ];
then
echo -e ${cya}"Uploading to official sourceforge"
sshpass -p "$sfpass" scp out/target/product/"$device"/"$rom"-$date-"$device"-"$buildtype".zip "$sfuser"@frs.sourceforge.net:"$sfpath"
wait
echo -e ${grn}"Uploaded file successfully"
fi
