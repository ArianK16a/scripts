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

    read choice_setup
    case $choice_setup in
      1 ) setup_rom;;
    esac
  done
}

function setup_rom() {
  echo "Setup - ROM"
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
  echo -e "${blue}Review your Settings!${nc}"
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
  read save_setup_rom
  if [ "$save_setup_rom" = "y" ] || [ "$save_setup_rom" = "Y" ]; then
    echo "Cleaning currect Config"
    sed --in-place '/device_codename/d' $script_dir/${curr_conf}
    sed --in-place '/rom_name/d' $script_dir/${curr_conf}
    sed --in-place '/rom_dir/d' $script_dir/${curr_conf}
    sed --in-place '/use_ccache/d' $script_dir/${curr_conf}
    sed --in-place '/use_ccache_display/d' $script_dir/${curr_conf}
    sed --in-place '/ccache_size/d' $script_dir/${curr_conf}
    echo -e "Saving Configurations"
    echo "device_codename=$device_codename" > $script_dir/${curr_conf}
    echo "rom_name=$rom_name" >> $script_dir/${curr_conf}
    echo "rom_dir=$rom_dir" >> $script_dir/${curr_conf}
    echo "use_ccache=$use_ccache" >> $script_dir/${curr_conf}
    echo "use_ccache_display=$use_ccache_display" >> $script_dir/${curr_conf}
    if [ "$use_ccache" = "y" ] || [ "$use_ccache" = "Y" ]; then
      echo "ccache_size=$ccache_size" >> $script_dir/${curr_conf}
    fi
    echo "Settings saved!"
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
