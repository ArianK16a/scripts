#!/bin/bash

script_dir="$(pwd)"
tgbot_path="$script_dir/TGBot"

# Add colors variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[33m'
blue='\033[0;34m'
purple='\033[1;35m'
cyan='\033[0;36m'
inverse='\033[7m'
nc='\033[0m'

function header() {
  clear
     echo -e "${red} ____        _ _     _ ____            _       _   ${nc}"
   echo -e "${green}| __ ) _   _(_) | __| / ___|  ___ _ __(_)_ __ | |_ ${nc}"
  echo -e "${yellow}|  _ \| | | | | |/ _\` \___ \ / __| '__| | '_ \| __|${nc}"
    echo -e "${blue}| |_) | |_| | | | (_| |___) | (__| |  | | |_) | |_ ${nc}"
  echo -e "${purple}|____/ \__,_|_|_|\__,_|____/ \___|_|  |_| .__/ \__|${nc}"
    echo -e "${cyan}                                        |_|        ${nc}"
}

if [ ! -f $script_dir/build.sh ]; then
  echo -e "${red}Script not found at $script_dir/build.sh${nc}"
  return
fi

function start() {
  while :; do
    header
    echo -e "${green}You are on : ${nc}${red}$rom_name${nc}"
    echo -e "\n${cyan}[1] Setup${nc}"
    echo -e "\n${cyan}[2] Tools${nc}"
    echo -e "\n${blue}[B] Build${nc}"
    echo -e "\n${red}[Q] Quit${nc}"
    echo -ne "\n${purple}(i)Please enter a choice[1-2/B/Q]:${nc}"

    read choice
    case $choice in
        1 ) setup;;
        2 ) tools;;
        3 ) push_ota;;
        b | B ) build;;
        Q | q )
          clear
          echo -e "${cyan}  ____                 _ _                "
                  echo -e " / ___| ___   ___   __| | |__  _   _  ___ "
                  echo -e "| |  _ / _ \ / _ \ / _\` | '_ \| | | |/ _ \\"
                  echo -e "| |_| | (_) | (_) | (_| | |_) | |_| |  __/"
                  echo -e " \____|\___/ \___/ \__,_|_.__/ \__, |\___|"
                  echo -e "                               |___/      ${nc}"
          exit 0;;
    esac
  done
}

function setup() {
  while :; do
    header
    echo -e "${green}You are on : ${nc}${red}$rom_name${nc}"
    echo -e "\n${inverse}Setup${nc}"
    echo -e "\n${cyan}[1] ROM${nc}"
    echo -e "${blue}[2] Building${nc}"
    echo -e "${yellow}[3] Upload${nc}"
    echo -e "${green}[4] Profiles${nc}"
    echo -e "${cyan}[5] Telegram${nc}"
    echo -e "${red}[Q] Quit${nc}"
    echo -ne "\n${purple}(i)Please enter a choice[1-4/Q]:${nc}"


    read choice_setup
    case $choice_setup in
      1 ) setup_rom;;
      2 ) setup_build;;
      3 ) setup_upload;;
      4 ) show_config_settings;;
      5 ) telegram_setup;;
      q | Q ) start;;
    esac
  done
}

function setup_rom() {
  header
  echo "Setup - ROM"
  echo -ne "\nYour Devices Codename : "
  read device_codename
  echo -ne "ROM name : "
  read rom_name
  echo -ne "Path to your ROM : "
  read rom_dir

  echo -e "\n${blue}-- Review your Settings! --${nc}"
	echo -e "\n${green}Device Name - ${nc}$device_codename"
	echo -e "\n${green}Rom name - ${nc}$rom_name"
	echo -e "\n${green}Rom path - ${nc}$rom_dir"

  echo -e "\nSave Settings? [y/n] : "
  read save_setup_rom
  if [ "$save_setup_rom" = "y" ] || [ "$save_setup_rom" = "Y" ]; then
    echo "\nCleaning currect Config"
    sed --in-place '/device_codename/d' $script_dir/${curr_conf}
    sed --in-place '/rom_name/d' $script_dir/${curr_conf}
    sed --in-place '/rom_dir/d' $script_dir/${curr_conf}
    echo -e "\nSaving Configurations"
    echo "device_codename=$device_codename" > $script_dir/${curr_conf}
    echo "rom_name=$rom_name" >> $script_dir/${curr_conf}
    echo "rom_dir=$rom_dir" >> $script_dir/${curr_conf}
    echo "\nSettings saved!"
  else
    echo "\nSettings not changed!"
    source $script_dir/${curr_conf}
  fi
}

function setup_build() {
	header
  echo "Setup - Build"
  echo -ne "\nSync the repo before build? [y/n] : "
  read build_sync
  echo -ne "\nClean the out before build? [y/n] : "
  read build_clean
  if [ "$build_clean" = "y" ]; then
   echo -ne "    [1]installclean or [2]clobber? : "
   read build_clean_type
  fi
  if [ "$build_clean_type" = "1" ]; then
    build_clean_command="installclean"
  elif [ "$build_clean_type" = "2" ]; then
    build_clean_command="clobber"
  fi
  echo -ne "\nadditional commands to execute? [y/n] : "
  read build_additional
  if [ "$build_additional" = "y" ]; then
    echo -ne "    Insert the command : "
    read build_additional_command
  fi
  echo -ne "\nUse CCache? [y/n] : "
  read use_ccache
  if [ "$use_ccache" = "y" ] || [ "$use_ccache" = "Y" ]; then
    use_ccache_display="Yes"
    echo -ne "    How much space is available for CCache? [in GB] : "
    read ccache_size
    echo -ne "    Do you want to set a custom CCache directory? [y/n] : "
    read ccache_custom_dir
    if [ "$ccache_custom_dir" = "y" ] || [ "$ccache_custom_dir" = "Y" ]; then
      echo -ne "        Enter the path : "
      read ccache_dir
    fi
  else
    use_ccache_display="No"
  fi

  echo -e "${blue}-- Review your Settings! --${nc}"
  echo -e "${green}Sync the repo before build - ${nc}$build_sync"
  echo -e "${green}Make clean before build - ${nc}$build_clean_command"
  echo -e "${green}You wish another command to be executed - ${nc}$build_additional_command"
  echo -e "\n${green}Use ccache - ${nc}$use_ccache_display"
  if [ "$use_ccache" = "y" ] || [ "$use_ccache" = "Y" ]; then
    echo -e "${green}Use ccache - ${nc}$ccache_size gigabyte"
  fi
  if [ "$ccache_custom_dir" = "y" ] || [ "$ccache_custom_dir" = "Y" ]; then
    echo -e "${green}CCache Directory - ${nc}$ccache_dir"
  fi

  echo -ne "\nSave Settings? [y/n] : "
  read save_setup_build

  if [ "$save_setup_build" = "y" ] || [ "$save_setup_build" = "Y" ]; then
    echo "\nCleaning currect Config"
    sed --in-place '/build_sync/d' $script_dir/${curr_conf}
    sed --in-place '/build_clean/d' $script_dir/${curr_conf}
    sed --in-place '/build_clean_command/d' $script_dir/${curr_conf}
    sed --in-place '/build_additional/d' $script_dir/${curr_conf}
    sed --in-place '/build_additional_command/d' $script_dir/${curr_conf}
    sed --in-place '/use_ccache/d' $script_dir/${curr_conf}
    sed --in-place '/use_ccache_display/d' $script_dir/${curr_conf}
    sed --in-place '/ccache_size/d' $script_dir/${curr_conf}
    sed --in-place '/ccache_dir/d' $script_dir/${curr_conf}
    echo -e "\nSaving Configurations"
    echo "build_sync=$build_sync" >> $script_dir/${curr_conf}
    echo "build_clean=$build_clean" >> $script_dir/${curr_conf}
    echo "build_clean_command=$build_clean_command" >> $script_dir/${curr_conf}
    echo "build_additional=$build_additional" >> $script_dir/${curr_conf}
    echo "build_additional_command=\"$build_additional_command\"" >> $script_dir/${curr_conf}
    echo "use_ccache=$use_ccache" >> $script_dir/${curr_conf}
    echo "use_ccache_display=$use_ccache_display" >> $script_dir/${curr_conf}
    if [ "$use_ccache" = "y" ] || [ "$use_ccache" = "Y" ]; then
      echo "ccache_size=$ccache_size" >> $script_dir/${curr_conf}
    fi
    if [ "$ccache_custom_dir" = "y" ] || [ "$ccache_custom_dir" = "Y" ]; then
      echo "ccache_dir=$ccache_dir" >> $script_dir/${curr_conf}
      echo "ccache_custom_dir=$ccache_custom_dir" >> $script_dir/${curr_conf}
    fi
  else
    echo "\nSettings not changed!"
    source $script_dir/${curr_conf}
  fi
}

function create_conf() {
	touch $script_dir/configs/conf$N.txt
	echo -e "Created"
	show_config_settings
}

function del_conf() {
	let "G = $N - 1"
	rm /$script_dir/configs/conf$G.txt
	echo -e "Removed"
	echo "curr_conf=\"configs/conf1.txt\"" > $script_dir/script_conf.txt
	show_config_settings
}

function show_config_settings() {
while :; do
  header
	echo -e "${blue}Change script config"
	echo -e "${cyan}Current config: ${rom_name}${green}"
	N="1"

	for i in $( ls $script_dir/configs )
	do
		. $script_dir/configs/conf$N.txt
		#Highlight current config
		if [ "${curr_conf}" = "configs/conf$N.txt" ];then
			echo -e "${inverse}[$N]: ${rom_name}${nc}"
		else
    		echo -e "${red}[$N]: ${nc}${rom_name}"
		fi
		#Add 1 in var for end of cycle
		let "N = $N + 1"
	done

	#Read current configs
	. $script_dir/${curr_conf}

	echo -e "${blue}Current config settings: ${nc}"
	echo
	echo -e "${green}Device Name - ${nc}$device_codename"
	echo -e "${green}Rom name - ${nc}$rom_name"
	echo -e "${green}Rom path - ${nc}$rom_dir"
	echo -e "${green}Use ccache - ${nc}$use_ccache_display"
  echo -e "${green}Upload Builds - ${nc}$upload"
  if [ "$upload" = "sf" ]; then
    echo -e "${green}sf Username - ${nc}$sf_user"
    echo -e "${green}sf Password - ${nc}$sf_pass"
    echo -e "${green}sf Project - ${nc}$sf_project"
  elif [ "$upload" = "mega" ]; then
    echo -e "${green}Mega Username - ${nc}$mega_user"
    echo -e "${green}Mega Password - ${nc}$mega_pass"
  fi
	echo -e "${blue}Commands avaible: ${nc}"
	echo -e "${cyan}Q - for go back"
  echo -e "S - for setting current config"
  echo -e "C - create new config"
  echo -e "R - Remove current config"
  echo -e "[1/~] For change config file${nc}"

	echo -ne "${blue}Your command: ${nc}"
	read curr_cmd

	case "$curr_cmd" in
		S | s ) setup ;;
		C | c ) create_conf ;;
		R | r ) del_conf ;;
		Q | q ) start ;;
	esac

	if [[ $curr_cmd =~ $re && $curr_cmd -gt 0 && $curr_cmd -le $N ]] ; then
		echo "curr_conf=\"configs/conf$curr_cmd.txt\"" > $script_dir/script_conf.txt
		source $script_dir/script_conf.txt
    source $script_dir/tgbot_conf.txt
    source $script_dir/${curr_conf}
	fi
done
}

function setup_upload() {
  echo -e "Setup - Upload"
  sed --in-place '/upload/d' $script_dir/${curr_conf}
  echo -ne "\nDo you want to upload your builds? [y/n] : "
  read upload_wish
  if [ "$upload_wish" = "y" ] || [ "$upload_wish" = "Y" ]; then
    echo -ne "\nUpload to Sourceforge [1] or Mega [2] : "
    read upload_provider
  elif [ "$upload_wish" = "n" ] || [ "$upload_wish" = "N" ]; then
    sed --in-place '/upload_wish/d' $script_dir/${curr_conf}
    echo "upload_wish=$upload_wish" >> $script_dir/${curr_conf}
  fi
  if [ "$upload_provider" = "1" ]; then
    echo -ne "What is your SourceForge Username? : "
    read sf_user
    echo -ne "\nDo you use SSH keys? [y/n] : "
    read ssh_keys
    if [ "$ssh_keys" = "n" ] || [ "$ssh_keys" = "N" ]; then
      echo -ne "\nWhat is your Sourceforge Password? : "
      read sf_pass
    fi
    echo -ne "\nWhat is your SourceForge Projects name? : "
    read sf_project
    echo -ne "\nWhere should the File get placed? : "
    read sf_path
    echo -ne "\nDo you want automated OTA updates? : "
    read build_push_ota

    echo -e "${RED}Review your Settings!${nc}"
    echo -e "Username=$sf_user"
    if [ "$ssh_keys" = "n" ] || [ "$ssh_keys" = "N" ]; then
      echo -e "Password=$sf_pass"
    elif [ "$ssh_keys" = "y" ] || [ "$ssh_keys" = "Y" ]; then
      echo -e "Using SSH Keys, no Password needed"
    fi
    echo -e "sf_project=$sf_project"
    echo -e "sf_path=$sf_path"
    echo -e "OTA update=$build_push_ota"

    echo -ne "${blue}Do you want to save this? [y/n] : ${nc}"
    read save_setup_sf
    if [ "$save_setup_sf" = "y" ] || [ "$save_setup_sf" = "Y" ]; then
      sed --in-place '/upload/d' $script_dir/${curr_conf}
      sed --in-place '/sf/d' $script_dir/${curr_conf}
      #sed --in-place '/sf/d' $script_dir/${curr_conf}
      echo "upload=sf" >> $script_dir/${curr_conf}
      echo "sf_user=$sf_user" >> $script_dir/${curr_conf}
      if [ "$ssh_keys" = "n" ] || [ "$ssh_keys" = "N" ]; then
        echo "sf_pass=$sf_pass" >> $script_dir/${curr_conf}
      elif [ "$ssh_keys" = "y" ] || [ "$ssh_keys" = "Y" ]; then
        echo "ssh_keys=$ssh_keys" >> $script_dir/${curr_conf}
      fi
      echo "sf_project=$sf_project" >> $script_dir/${curr_conf}
      echo "sf_path=$sf_path" >> $script_dir/${curr_conf}
      sed --in-place '/OTA/d' $script_dir/${curr_conf}
      echo "build_push_ota=$build_push_ota" >> $script_dir/${curr_conf}
    else
      echo "Settings not changed!"
      source $script_dir/${curr_conf}
    fi
  fi
  if [ "$upload_provider" = "2" ]; then
     echo -ne "What is your Mega Username? : "
     read mega_user
     echo -ne "\nWhat is your Mega Password? : "
     read mega_pass
     echo -ne "\nWhere should the File get placed? : "
     read mega_path

     echo -e "${RED}Review your Settings!${nc}"
     echo -e "mega_user=$mega_user"
     echo -e "mega_pass=$mega_pass"
     echo -e "mega_path=$mega_path"

     echo -ne "${blue}Do you want to save this? [yes/no] : ${nc}"
     read save_setup_mega
     if [[ "$save_setup_mega" = "yes" ]]; then
       sed --in-place '/upload/d' $script_dir/${curr_conf}
       sed --in-place '/mega/d' $script_dir/${curr_conf}
       sed --in-place '/mega/d' $script_dir/${curr_conf}
       sed --in-place '/mega/d' $script_dir/${curr_conf}
       echo "upload=mega" >> $script_dir/${curr_conf}
       echo "mega_user=$mega_user" >> $script_dir/${curr_conf}
       echo "mega_pass=$mega_pass" >> $script_dir/${curr_conf}
       echo "mega_path=$mega_path" >> $script_dir/${curr_conf}
     else
       echo "Settings not changed!"
       source $script_dir/${curr_conf}
     fi
   fi
}

function upload() {
  cd $rom_dir
  source "$script_dir"/${curr_conf}
  prepare_device
  set_out
  echo "zip_path=$zip_path"
  echo "zip_name=$zip_name"


  changelog=$(ls $OUT/*.txt | grep Changelog)
  tg_file=$changelog
  send_tg_file
  if [ "$upload" = "sf" ]; then
    echo -e "Uploading to $sf_project/$sf_path on sourceforge"
    tg_msg="*$zip_name* is uploading to $sf_project/$sf_path on sourceforge"
    send_tg_notification
    cd $rom_dir
    if [ "$ssh_keys" = "y" ] || [ "$ssh_keys" = "Y" ]; then
      scp "$zip_path" "$sf_user"@frs.sourceforge.net:/home/frs/project/"$sf_project"/"$sf_path"
    else
      sshpass -p "$sf_pass" scp "$zip_path" "$sf_user"@frs.sourceforge.net:/home/frs/project/"$sf_project"/"$sf_path"
    fi
    sflink="https://sourceforge.net/projects/$sf_project/files/$sf_path/$zip_name/download"
    tg_msg="*$zip_name is up!* It can be downloaded [here]($sflink) in few minutes!"
    send_tg_notification
    cd $script_dir
    if [ "$ota" = "y" ]; then
      push_ota
    fi
  elif [ "$upload" = "mega" ]; then
    echo -e "$zip_name is uploading to mega.nz"
    tg_msg="$zip_name is uploading to mega.nz"
    send_tg_notification
    cd $rom_dir
    mega-login "$mega_user" "$mega_pass"
    mega-put $zip_path /$mega_path
    megaout=$(mega-export -a /$mega_path/$zip_name)
    mega-logout
    megalink=$(echo $megaout | grep -Eo '(http|https)://[^"]+')
    tg_msg="*$zip_name is up!* It can be downloaded [here]($megalink)"
    send_tg_notification
    cd $script_dir
  fi

}

function sync() {
  echo -e "Syncing the source of $rom_name"
  tg_msg="Syncing the source of $rom_name"
  send_tg_notification
  cd $rom_dir && repo sync  -f --force-sync --no-clone-bundle --no-tags && cd $script_dir
}

function installclean() {
  echo -e "make installclean for $rom_name"
  cd $rom_dir && source build/envsetup.sh && make installclean && cd $script_dir
}

function clean() {
  echo -e "make clean && clobber for $rom_name"
  cd $rom_dir && source build/envsetup.sh && make clean && make clobber && cd $script_dir
}

function tools() {
  while :; do
    header
    echo -e "${green}You are on : ${nc}${red}$rom_name${nc}"
    echo -e "\n${cyan}[1] Sync${nc}"
    echo -e "${yellow}[2] make installclean${nc}"
    echo -e "${red}[3] make clean${nc}"
    echo -e "${green}[4] Test telegram${nc}"
    echo -e "${cyan}[5] Upload${nc}"
    echo -e "${yellow}[6] Push the rom to /sdcard via adb"
    echo -e "${red}[7] Sideload the rom via adb"
    echo -e "\n${blue}[Q] Quit${nc}"
    echo -ne "${purple}[1-7/Q] : ${nc}"
    read choice_tools
    case $choice_tools in
      1 ) sync;;
      2 ) installclean;;
      3 ) clean;;
      4 ) telegram_test;;
      5 ) upload;;
      6 ) push_rom_adb;;
      7 ) sideload_rom_adb;;
      q | Q ) start;;
    esac
  done
}

function setup_ccache() {
  source $script_dir/${curr_conf}
  if [ "$use_ccache" = "y" ] || [ "$use_ccache" = "Y" ]; then
    echo -e "${blue}CCache is enabled for this build${nc}"
    export USE_CCACHE=1
    if [ "$ccache_custom_dir" = "y" ] || [ "$ccache_custom_dir" = "Y" ]; then
      echo -e "Using $ccache_dir as directory for ccache!"
      export CCACHE_DIR="$ccache_dir"
    fi
    ccache -M "$ccache_size"G
  else
    echo -e "${red}CCache is disabled for this build${nc}"
  fi
}

function additional_command() {
  if [ "$build_additional" = "y" ] || [ "$build_additional" = "Y" ]; then
    $build_additional_command
  fi
}

function prepare_device() {
  cd $rom_dir
  source build/envsetup.sh
  if [ "$rom_name" = "aex" ] || [ "$rom_name" = "ex" ]; then
    lunch aosp_"$device_codename"-userdebug
  elif [ "$rom_name" = "lineage" ] || [ "$rom_name" = "lineage-z3c" ]; then
    breakfast $device_codename
  else
    lunch "$rom_name"_"$device_codename"-userdebug
  fi
}

function compile_rom() {
  if [ "$rom_name" = "aex" ] || [ "$rom_name" = "ex" ]; then
    mka aex
  else
    brunch $device_codename
  fi
  build_result
}

function telegram_setup() {
  while :; do
    header
    echo
		echo -e "${blue}Current TG Bot settings: ${nc}"
		echo
		echo -e "${GREEN}User ID - ${nc}${tg_user_id}"
		echo -e "${GREEN}Run bot on script start-up - ${nc}${tgbot_autostart}"
		echo
		echo -e "${blue}Commands avaible: ${nc}"
		echo -e "${CYAN}[Q] - for go back \n[S] - for changing current settings"
		echo -ne "\n${blue}Your command: ${nc}"
		read curr_cmd

		case "$curr_cmd" in
			S | s ) edit_tgbot_settings ;;
			Q | q ) break ;;
		esac
	done
}

function tgbot_start() {
	cd $tgbot_path
	source bashbot.sh start
	bash bashbot.sh source && use_tgbot="true"
	cd $script_dir
}

function tgbot_kill() {
	proxy_set
	cd $tgbot_path
	bash $tgbot_path/bashbot.sh kill && use_tgbot="false"
	cd $script_dir
	proxy_unset
}

function edit_tgbot_settings() {
	echo "TG Bot settings"
	echo
	echo -ne "${blue}Enter your user ID: ${nc}"
	read tg_user_id
	echo -ne "${blue}Do you want to run bot on script start-up? [Y/n]: ${nc}"
	read tgbot_autostart
	if [ "$tgbot_autostart" = "y" ] || [ "$tgbot_autostart" = "Y" ]; then
		tgbot_autostart="true"
	else
		tgbot_autostart="false"
	fi
	echo -e "${cyan}Ok, done, please review your settings:${nc}"
	echo
	echo -e "${blue}User ID - ${nc}${tg_user_id}"
	echo -e "${blue}Run bot on script start-up - ${nc}${tgbot_autostart}"
	echo
	echo -ne "${blue}Save changes? [y/N]: ${nc}"
	read save
	if [ "$save" = "y" ] || [ "$save" = "Y" ]; then
		echo "Saving settings..."
    sed --in-place '/tg_user_id/d' $script_dir/tgbot_conf.txt
    echo "tg_user_id=$tg_user_id" >> $script_dir/tgbot_conf.txt
    sed --in-place '/tgbot_autostart/d' $script_dir/tgbot_conf.txt
    echo "tgbot_autostart=$tgbot_autostart" >> $script_dir/tgbot_conf.txt
		echo "Settings saved!"
	else
		echo "Settings don't changed!"
		. $script_dir/tgbot_conf.txt
	fi
}

function send_tg_notification() {
	if [ "$use_tgbot" = "true" ]; then
		cd $tgbot_path
    source bashbot.sh start
    source bashbot.sh source
		send_text "$tg_user_id" "markdown_parse_mode${tg_msg}"
	fi
}

function send_tg_file() {
	if [ "$use_tgbot" = "true" ]; then
		cd $tgbot_path
		send_file "${tg_user_id}" "$tg_file"
	fi
}

function build() {
  cd $rom_dir
  source build/envsetup.sh
  setup_ccache
  if [ "$build_clean_command" = "installclean" ]; then
    installclean
    cd $rom_dir
  elif [ "$build_clean_command" = "clobber" ]; then
    clean
    cd $rom_dir
  fi
  if [ "$build_sync" = "y" ]; then
    sync
    cd $rom_dir
  fi
  if [ "$build_additional" = "y" ]; then
    additional_command
  fi
  prepare_device

  # Build
  build_start=$(date +"%s")
  date=`date`
  echo -e "$rom_name build started at $date on $HOSTNAME"
  tg_msg="$rom_name build started at \`$date\` on  \`$HOSTNAME\`"
  send_tg_notification
  cd $rom_dir
  if [ "$target_build_signed" = "y" ]; then
    compile_rom_signed
  else
    compile_rom
  fi
  if [ "$result" = "0" ]; then
    if [ "$upload_wish" = "y" ]; then
      upload
    fi
  fi
}

function build_result() {
  result=$(echo $?)
  build_end=$(date +"%s")
  diff=$(($build_end - $build_start))
  if [ "$result" = "0" ]; then
    echo -e "\n${green}(i)ROM compilation completed successfully"
    echo -e "(i)Total time elapsed: $(($diff / 60)) minute(s) and $(($diff % 60)) seconds.${nc}"
    tg_msg="*(i) ($rom_name) compilation completed successfully on *\`$HOSTNAME\` | Total time elapsed: $(($diff / 60)) minute(s) and $(($diff % 60)) seconds."
    send_tg_notification
    cd "$script_dir"
  else
    echo -e "\n${red}(!)ROM compilation failed"
    echo -e "(i)Total time elapsed: $(($diff / 60)) minute(s) and $(($diff % 60)) seconds.${nc}"
    tg_msg="*(!) ($rom_name) compilation failed on *\`$HOSTNAME\` | Total time elapsed: $(($diff / 60)) minute(s) and $(($diff % 60)) seconds."
    send_tg_notification
    exit 0
  fi
}

function telegram_test() {
  tg_msg="test"
  send_tg_notification
}

function push_rom_adb() {
  set_out
  adb push "$zip_path" /sdcard
}

function sideload_rom_adb() {
  set_out
  adb sideload "$zip_path"
}

function set_out() {
  cd $rom_dir
  date="$(date '+%Y%m')"
  timestamp="$(date +%s)"
  zip_path_old="$(ls $OUT/*.zip | grep "$date" | grep "$device_codename")"
  zip_path="$(realpath $zip_path_old)"
  zip_name="$(basename "$zip_path")"
  zip_md5="$(cat $zip_path.md5sum | awk '{print $1}')"
  zip_size="$(ls -l "$zip_path" | awk '{print $5}')"
}

function push_ota() {
  cd $rom_dir
  source "$script_dir"/${curr_conf}
  set_out
  sflink="https://sourceforge.net/projects/$sf_project/files/$sf_path/$zip_name/download"
  cd OTA
  git add -A && git stash && git reset
  git fetch git@github.com:ArianK16a/OTA.git
  git checkout FETCH_HEAD
  rm "$device_codename".json
  echo"$ls"
  echo -e "{
  \"response\": [
    {
      \"datetime\": \"$timestamp\",
      \"filename\": \"$zip_name\",
      \"id\": \"$zip_md5\",
      \"romtype\": \"UNOFFICIAL\",
      \"size\": \"$zip_size\",
      \"url\": \"$sflink\",
      \"version\": \"16.0\"
    }
  ]
}" > "$device_codename".json
  git add "$device_codename".json
  git commit -S -m "$device_codename: Automatic OTA update"
  git push git@github.com:ArianK16a/OTA.git HEAD:lineage
  cd $script_dir
}

function compile_rom_signed() {
  cd $rom_dir
  prepare_device
  export $(breakfast $device_codename | grep LINEAGE_VERSION)
  LINEAGE_VERSION=$(echo "$LINEAGE_VERSION")
  mka target-files-package otatools
  build_result
  if [ "$result" = 0 ]; then
    croot
    echo -e "Signing of $rom_name on $HOSTNAME started"
    tg_msg="*(i) Signing of \`$rom_name\` on \`$HOSTNAME\` started"
    send_tg_notification
    cd $rom_dir
    export ANDROID_PW_FILE=$keys_password_file
    ./build/tools/releasetools/sign_target_files_apks -o -d ~/.android-certs \
      $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip \
      signed-target_files.zip
    ./build/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey \
      --block --backup=true \
      signed-target_files.zip \
      signed-ota_update.zip
    LINEAGE_TARGET_PACKAGE_NAME_SIGNED="lineage-$LINEAGE_VERSION-signed.zip"
    mv $rom_dir/signed-ota_update.zip $OUT/$LINEAGE_TARGET_PACKAGE_NAME_SIGNED
    echo -e "Signing of $LINEAGE_TARGET_PACKAGE_NAME_SIGNED on $HOSTNAME finished"
    tg_msg="*(i) Signing of \`$LINEAGE_TARGET_PACKAGE_NAME_SIGNED\` on \`$HOSTNAME\` finished"
    send_tg_notification
    set_out
    md5sum $zip_path | awk '{print $1}' > "$zip_path".md5sum
  fi
}

# Prepare the script
if [ -f $script_dir/script_conf.txt ]; then
  source $script_dir/script_conf.txt
  if [ -z ${curr_conf} ];then
	   echo -e "${purple}WARNING:${nc} variable curr_conf is unset. Setting current config to configs/conf1.txt"
	   echo "curr_conf=\"configs/conf1.txt\"" >> $script_dir/script_conf.txt
	   source $script_dir/script_conf.txt
  fi
else
  echo -e "${green}$script_dir/script_conf.txt is missing. Creating new one!${nc}"
  echo "curr_conf=\"configs/conf1.txt\"" > $script_dir/script_conf.txt
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

#TG Bot config
#Autostart TGBot
source $script_dir/tgbot_conf.txt
cd $script_dir
if [ "$tgbot_autostart" = "true" ]; then
	tgbot_start
fi

if [ ! -f $script_dir/tgbot_conf.txt ];then
	echo -e "Creating tgbot_conf.txt..."
	touch $script_dir/tgbot_conf.txt
fi

start
