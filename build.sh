#!/bin/bash

script_dir="$(pwd)"
tgbot_path="$script_dir/TGBot"

# Add colors variables
red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
purple='\033[1;35m'
cyan='\033[0;36m'
nc='\033[0m'

if [ ! -f $script_dir/build.sh ]; then
  echo -e "${red}Script not found at $script_dir/build.sh${nc}"
  return
fi

function setup() {
  while :; do
    echo -e "Setup"
    echo -e " "
    echo -e "${cyan}[1] ROM${nc}"
    echo -e "${blue}[2] Building${nc}"

    read choice_setup
    case $choice_setup in
      1 ) setup_rom;;
      2 ) setup_build;;
    esac
  done
}

function setup_rom() {
	echo -e " "
  echo "Setup - ROM"
  echo -e " "
  echo -ne "Your Devices Codename : "
  read device_codename
  echo -ne "ROM name : "
  read rom_name
  echo -ne "Path to your ROM : "
  read rom_dir
  echo -ne "Use CCache? [y/n] : "
  read use_ccache
  if [ "$use_ccache" = "y" ] || [ "$use_ccache" = "Y" ]; then
    use_ccache_display="Yes"
    echo -ne "How much space is available for CCache? [gigabyte] : "
    read ccache_size
  else
    use_ccache_display="No"
  fi

  echo -e " "
  echo -e "${blue}-- Review your Settings! --${nc}"
	echo -e " "
	echo -e "${green}Device Name - ${nc}$device_codename"
	echo -e "${green}Rom name - ${nc}$rom_name"
	echo -e "${green}Rom path - ${nc}$rom_dir"
  echo -e "${green}Use ccache - ${nc}$use_ccache_display"
  if [ "$use_ccache" = "y" ] || [ "$use_ccache" = "Y" ]; then
    echo -ne "${green}Use ccache - ${nc}$ccache_size gigabyte"
  fi

  echo -e " "
  echo -ne "Save Settings? [y/n] : "
  echo -e " "
  read save_setup_rom
  if [ "$save_setup_rom" = "y" ] || [ "$save_setup_rom" = "Y" ]; then
	  echo -e " "
    echo "Cleaning currect Config"
    echo -e " "
    sed --in-place '/device_codename/d' $script_dir/${curr_conf}
    sed --in-place '/rom_name/d' $script_dir/${curr_conf}
    sed --in-place '/rom_dir/d' $script_dir/${curr_conf}
    sed --in-place '/use_ccache/d' $script_dir/${curr_conf}
    sed --in-place '/use_ccache_display/d' $script_dir/${curr_conf}
    sed --in-place '/ccache_size/d' $script_dir/${curr_conf}
    echo -e " "
    echo -e "Saving Configurations"
    echo -e " "
    echo "device_codename=$device_codename" > $script_dir/${curr_conf}
    echo "rom_name=$rom_name" >> $script_dir/${curr_conf}
    echo "rom_dir=$rom_dir" >> $script_dir/${curr_conf}
    echo "use_ccache=$use_ccache" >> $script_dir/${curr_conf}
    echo "use_ccache_display=$use_ccache_display" >> $script_dir/${curr_conf}
    if [ "$use_ccache" = "y" ] || [ "$use_ccache" = "Y" ]; then
      echo "ccache_size=$ccache_size" >> $script_dir/${curr_conf}
    fi
    echo -e " "
    echo "Settings saved!"
    echo -e " "
  else
    echo "Settings not changed!"
    source $script_dir/${curr_conf}
  fi
}

function setup_build() {
	echo -e " "
  echo "Setup - Build"
  echo -ne "Sync the repo before build? [y/n] : "
  read build_sync
  echo -ne "Clean the out before build? [y/n] : "
  read build_clean
  if [ "$build_clean" = "y" ]; then
   echo -ne "[1]installclean or [2]clobber? : "
   read build_clean_type
  fi
  if [ "$build_clean_type" = "1" ]; then
    build_clean_command="installclean"
  elif [ "$build_clean_type" = "2" ]; then
    build_clean_command="clobber"
  fi
  echo -ne "additional commands to execute? [y/n]"
  read build_additional
  if [ "$build_additional" = "y" ]; then
    echo -ne "Insert the command : "
    read build_additional_command
  fi

  echo -e "${blue}-- Review your Settings! --${nc}"
  echo -e "${green}Sync the repo before build - ${nc}$build_sync"
  echo -e "${green}Make clean before build - ${nc}$build_clean_command"
  echo -e "${green}You wish another command to be executed - ${nc}$build_additional_command"

	echo -e " "
  echo -ne "Save Settings? [y/n] : "
  echo -e " "
  read save_setup_build

  if [ "$save_setup_build" = "y" ] || [ "$save_setup_build" = "Y" ]; then
    echo "Cleaning currect Config"
    sed --in-place '/build_sync/d' $script_dir/${curr_conf}
    sed --in-place '/build_clean/d' $script_dir/${curr_conf}
    sed --in-place '/build_clean_command/d' $script_dir/${curr_conf}
    sed --in-place '/build_additional/d' $script_dir/${curr_conf}
    sed --in-place '/build_additional_command/d' $script_dir/${curr_conf}
    echo -e " "
    echo -e "Saving Configurations"
    echo -e " "
    echo "build_sync=$build_sync" >> $script_dir/${curr_conf}
    echo "build_clean=$build_clean" >> $script_dir/${curr_conf}
    echo "build_clean_command=$build_clean_command" >> $script_dir/${curr_conf}
    echo "build_additional=$build_additional" >> $script_dir/${curr_conf}
    echo "build_additional_command=\"$build_additional_command\"" >> $script_dir/${curr_conf}
  else
    echo "Settings not changed!"
    source $script_dir/${curr_conf}
  fi
}







# Prepare the script
if [ -f $script_dir/script_conf.txt ]; then
  source $script_dir/script_conf.txt
  if [ -z ${curr_conf} ];then
	   echo -e "${purple}WARNING:${nc} variable curr_conf is unset. Setting current config to configs/conf0.txt"
	   echo "curr_conf=\"configs/conf0.txt\"" >> $script_dir/script_conf.txt
	   source $script_dir/script_conf.txt
  fi
else
  echo -e "${green}$script_dir/script_conf.txt is missing. Creating new one!${nc}"
  echo "curr_conf=\"configs/conf0.txt\"" > $script_dir/script_conf.txt
  source $script_dir/script_conf.txt
fi

if [ -f $script_dir/$curr_conf ]; then
  source $script_dir/${curr_conf}
else
  if [ ! -e $script_dir/configs ]; then
	   mkdir $script_dir/configs
  fi
  echo -e "${green}$script_dir/${curr_conf} is missing. Creating new one!${nc}"
  touch $script_dir/${curr_conf}
  setup_rom

  source $script_dir/${curr_conf}
fi

setup
