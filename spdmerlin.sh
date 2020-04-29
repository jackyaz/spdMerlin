#!/bin/sh

############################################################
##                   _  __  __              _  _          ##
##                  | ||  \/  |            | |(_)         ##
##   ___  _ __    __| || \  / |  ___  _ __ | | _  _ __    ##
##  / __|| '_ \  / _` || |\/| | / _ \| '__|| || || '_ \   ##
##  \__ \| |_) || (_| || |  | ||  __/| |   | || || | | |  ##
##  |___/| .__/  \__,_||_|  |_| \___||_|   |_||_||_| |_|  ##
##       | |                                              ##
##       |_|                                              ##
##                                                        ##
##        https://github.com/jackyaz/spdMerlin            ##
##                                                        ##
############################################################

### Start of script variables ###
readonly SCRIPT_NAME="spdMerlin"
#shellcheck disable=SC2019
#shellcheck disable=SC2018
readonly SCRIPT_NAME_LOWER=$(echo $SCRIPT_NAME | tr 'A-Z' 'a-z')
readonly SCRIPT_VERSION="v3.5.1"
readonly SCRIPT_BRANCH="master"
readonly SCRIPT_REPO="https://raw.githubusercontent.com/jackyaz/spdMerlin/""$SCRIPT_BRANCH"
readonly SCRIPT_DIR="/jffs/addons/$SCRIPT_NAME_LOWER.d"
readonly SCRIPT_WEBPAGE_DIR="$(readlink /www/user)"
readonly SCRIPT_WEB_DIR="$SCRIPT_WEBPAGE_DIR/$SCRIPT_NAME_LOWER"
readonly SHARED_DIR="/jffs/addons/shared-jy"
readonly SHARED_REPO="https://raw.githubusercontent.com/jackyaz/shared-jy/master"
readonly SHARED_WEB_DIR="$SCRIPT_WEBPAGE_DIR/shared-jy"

readonly HOME_DIR="/$(readlink "$HOME")"
readonly OOKLA_DIR="$SCRIPT_DIR/ookla"
readonly OOKLA_LICENSE_DIR="$SCRIPT_DIR/ooklalicense"
readonly OOKLA_HOME_DIR="$HOME_DIR/.config/ookla"

[ -z "$(nvram get odmpid)" ] && ROUTER_MODEL=$(nvram get productid) || ROUTER_MODEL=$(nvram get odmpid)
[ -f /opt/bin/sqlite3 ] && SQLITE3_PATH=/opt/bin/sqlite3 || SQLITE3_PATH=/usr/sbin/sqlite3
[ "$(uname -m)" = "aarch64" ] && ARCH="aarch64" || ARCH="arm"
### End of script variables ###

### Start of output format variables ###
readonly CRIT="\\e[41m"
readonly ERR="\\e[31m"
readonly WARN="\\e[33m"
readonly PASS="\\e[32m"
### End of output format variables ###

### Start of Speedtest Server Variables ###
serverno=""
servername=""
schedulestart=""
scheduleend=""
minutestart=""
### End of Speedtest Server Variables ###

# $1 = print to syslog, $2 = message to print, $3 = log level
Print_Output(){
	if [ "$1" = "true" ]; then
		logger -t "$SCRIPT_NAME" "$2"
		printf "\\e[1m$3%s: $2\\e[0m\\n\\n" "$SCRIPT_NAME"
	else
		printf "\\e[1m$3%s: $2\\e[0m\\n\\n" "$SCRIPT_NAME"
	fi
}

Firmware_Version_Check(){
	if nvram get rc_support | grep -qF "am_addons"; then
		return 0
	else
		return 1
	fi
}

### Code for these functions inspired by https://github.com/Adamm00 - credit to @Adamm ###
Check_Lock(){
	if [ -f "/tmp/$SCRIPT_NAME.lock" ]; then
		ageoflock=$(($(date +%s) - $(date +%s -r /tmp/$SCRIPT_NAME.lock)))
		if [ "$ageoflock" -gt 600 ]; then
			Print_Output "true" "Stale lock file found (>600 seconds old) - purging lock" "$ERR"
			kill "$(sed -n '1p' /tmp/$SCRIPT_NAME.lock)" >/dev/null 2>&1
			Clear_Lock
			echo "$$" > "/tmp/$SCRIPT_NAME.lock"
			return 0
		else
			Print_Output "true" "Lock file found (age: $ageoflock seconds) - stopping to prevent duplicate runs" "$ERR"
			if [ -z "$1" ]; then
				exit 1
			else
				return 1
			fi
		fi
	else
		echo "$$" > "/tmp/$SCRIPT_NAME.lock"
		return 0
	fi
}

Clear_Lock(){
	rm -f "/tmp/$SCRIPT_NAME.lock" 2>/dev/null
	return 0
}

Check_Swap () {
	if [ "$(wc -l < /proc/swaps)" -ge "2" ]; then return 0; else return 1; fi
}

Set_Version_Custom_Settings(){
	SETTINGSFILE="/jffs/addons/custom_settings.txt"
	case "$1" in
		local)
			if [ -f "$SETTINGSFILE" ]; then
				if [ "$(grep -c "spdmerlin_version_local" $SETTINGSFILE)" -gt 0 ]; then
					if [ "$SCRIPT_VERSION" != "$(grep "spdmerlin_version_local" /jffs/addons/custom_settings.txt | cut -f2 -d' ')" ]; then
						sed -i "s/spdmerlin_version_local.*/spdmerlin_version_local $SCRIPT_VERSION/" "$SETTINGSFILE"
					fi
				else
					echo "spdmerlin_version_local $SCRIPT_VERSION" >> "$SETTINGSFILE"
				fi
			else
				echo "spdmerlin_version_local $SCRIPT_VERSION" >> "$SETTINGSFILE"
			fi
		;;
		server)
			if [ -f "$SETTINGSFILE" ]; then
				if [ "$(grep -c "spdmerlin_version_server" $SETTINGSFILE)" -gt 0 ]; then
					if [ "$2" != "$(grep "spdmerlin_version_server" /jffs/addons/custom_settings.txt | cut -f2 -d' ')" ]; then
						sed -i "s/spdmerlin_version_server.*/spdmerlin_version_server $2/" "$SETTINGSFILE"
					fi
				else
					echo "spdmerlin_version_server $2" >> "$SETTINGSFILE"
				fi
			else
				echo "spdmerlin_version_server $2" >> "$SETTINGSFILE"
			fi
		;;
	esac
}

Update_Check(){
	doupdate="false"
	localver=$(grep "SCRIPT_VERSION=" /jffs/scripts/"$SCRIPT_NAME_LOWER" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
	/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | grep -qF "jackyaz" || { Print_Output "true" "404 error detected - stopping update" "$ERR"; return 1; }
	serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
	if [ "$localver" != "$serverver" ]; then
		doupdate="version"
		Set_Version_Custom_Settings "server" "$serverver"
	else
		localmd5="$(md5sum "/jffs/scripts/$SCRIPT_NAME_LOWER" | awk '{print $1}')"
		remotemd5="$(curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | md5sum | awk '{print $1}')"
		if [ "$localmd5" != "$remotemd5" ]; then
			doupdate="md5"
			Set_Version_Custom_Settings "server" "$serverver-hotfix"
		fi
	fi
	echo "$doupdate,$localver,$serverver"
}

Update_Version(){
	if [ -z "$1" ] || [ "$1" = "unattended" ]; then
		updatecheckresult="$(Update_Check)"
		isupdate="$(echo "$updatecheckresult" | cut -f1 -d',')"
		localver="$(echo "$updatecheckresult" | cut -f2 -d',')"
		serverver="$(echo "$updatecheckresult" | cut -f3 -d',')"
		
		if [ "$isupdate" = "version" ]; then
			Print_Output "true" "New version of $SCRIPT_NAME available - updating to $serverver" "$PASS"
		elif [ "$isupdate" = "md5" ]; then
			Print_Output "true" "MD5 hash of $SCRIPT_NAME does not match - downloading updated $serverver" "$PASS"
		fi
		
		Update_File "shared-jy.tar.gz"
		
		if [ "$isupdate" != "false" ]; then
			Update_File "$ARCH.tar.gz"
			Update_File "spdstats_www.asp"
			
			/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" -o "/jffs/scripts/$SCRIPT_NAME_LOWER" && Print_Output "true" "$SCRIPT_NAME successfully updated"
			chmod 0755 /jffs/scripts/"$SCRIPT_NAME_LOWER"
			Clear_Lock
			if [ -z "$1" ]; then
				exec "$0"
			elif [ "$1" = "unattended" ]; then
				exec "$0" "setversion"
			fi
			exit 0
		else
			Print_Output "true" "No new version - latest is $localver" "$WARN"
			Clear_Lock
		fi
	fi
	
	if [ "$1" = "force" ]; then
		serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		Print_Output "true" "Downloading latest version ($serverver) of $SCRIPT_NAME" "$PASS"
		Update_File "$ARCH.tar.gz"
		Update_File "spdstats_www.asp"
		Update_File "shared-jy.tar.gz"
		/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" -o "/jffs/scripts/$SCRIPT_NAME_LOWER" && Print_Output "true" "$SCRIPT_NAME successfully updated"
		chmod 0755 /jffs/scripts/"$SCRIPT_NAME_LOWER"
		Clear_Lock
		if [ -z "$2" ]; then
			exec "$0"
		elif [ "$2" = "unattended" ]; then
			exec "$0" "setversion"
		fi
		exit 0
	fi
}
############################################################################

Update_File(){
	if [ "$1" = "$ARCH.tar.gz" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SCRIPT_REPO/$1" "$tmpfile"
		tar -xzf "$tmpfile" -C "/tmp"
		rm -f "$tmpfile"
		localmd5="$(md5sum "$OOKLA_DIR/speedtest" | awk '{print $1}')"
		tmpmd5="$(md5sum "/tmp/speedtest" | awk '{print $1}')"
		if [ "$localmd5" != "$tmpmd5" ]; then
			rm -f "$OOKLA_DIR/*"
			Download_File "$SCRIPT_REPO/$1" "$OOKLA_DIR/$1"
			tar -xzf "$OOKLA_DIR/$1" -C "$OOKLA_DIR"
			rm -f "$OOKLA_DIR/$1"
			chmod 0755 "$OOKLA_DIR/speedtest"
			Print_Output "true" "New version of Speedtest CLI downloaded to $OOKLA_DIR/speedtest" "$PASS"
		fi
		rm -f "/tmp/speedtest*"
	elif [ "$1" = "spdstats_www.asp" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SCRIPT_REPO/$1" "$tmpfile"
		if ! diff -q "$tmpfile" "$SCRIPT_DIR/$1" >/dev/null 2>&1; then
			if [ -f "$SCRIPT_DIR/$1" ]; then
				Get_WebUI_Page "$SCRIPT_DIR/$1"
				sed -i "\\~$MyPage~d" /tmp/menuTree.js
				rm -f "$SCRIPT_WEBPAGE_DIR/$MyPage" 2>/dev/null
			fi
			Download_File "$SCRIPT_REPO/$1" "$SCRIPT_DIR/$1"
			Print_Output "true" "New version of $1 downloaded" "$PASS"
			Mount_WebUI
		fi
		rm -f "$tmpfile"
	elif [ "$1" = "shared-jy.tar.gz" ]; then
		if [ ! -f "$SHARED_DIR/$1.md5" ]; then
			Download_File "$SHARED_REPO/$1" "$SHARED_DIR/$1"
			Download_File "$SHARED_REPO/$1.md5" "$SHARED_DIR/$1.md5"
			tar -xzf "$SHARED_DIR/$1" -C "$SHARED_DIR"
			rm -f "$SHARED_DIR/$1"
			Print_Output "true" "New version of $1 downloaded" "$PASS"
		else
			localmd5="$(cat "$SHARED_DIR/$1.md5")"
			remotemd5="$(curl -fsL --retry 3 "$SHARED_REPO/$1.md5")"
			if [ "$localmd5" != "$remotemd5" ]; then
				Download_File "$SHARED_REPO/$1" "$SHARED_DIR/$1"
				Download_File "$SHARED_REPO/$1.md5" "$SHARED_DIR/$1.md5"
				tar -xzf "$SHARED_DIR/$1" -C "$SHARED_DIR"
				rm -f "$SHARED_DIR/$1"
				Print_Output "true" "New version of $1 downloaded" "$PASS"
			fi
		fi
	else
		return 1
	fi
}

Validate_Number(){
	if [ "$2" -eq "$2" ] 2>/dev/null; then
		return 0
	else
		formatted="$(echo "$1" | sed -e 's/|/ /g')"
		if [ -z "$3" ]; then
			Print_Output "false" "$formatted - $2 is not a number" "$ERR"
		fi
		return 1
	fi
}

Process_Upgrade(){
	if [ -f "$SCRIPT_DIR/spdcli.py" ]; then
		rm -f "$SCRIPT_DIR/spdcli.py" 2>/dev/null
		opkg remove --autoremove python
		opkg install jq
		Download_File "$SCRIPT_REPO/$ARCH.tar.gz" "$OOKLA_DIR/$ARCH.tar.gz"
		tar -xzf "$OOKLA_DIR/$ARCH.tar.gz" -C "$OOKLA_DIR"
		rm -f "$OOKLA_DIR/$ARCH.tar.gz"
		chmod 0755 "$OOKLA_DIR/speedtest"
		License_Acceptance "accept"
		PressEnter
	fi
}

License_Acceptance(){
	case "$1" in
		check)
			if [ -f "$HOME_DIR/.config/ookla/speedtest-cli.json" ]; then
				return 0
			else
				return 1
			fi
		;;
		accept)
			while true; do
				printf "\\n\\n==============================================================================\\n"
				printf "\\nYou may only use this Speedtest software and information generated\\n"
				printf "from it for personal, non-commercial use, through a command line\\n"
				printf "interface on a personal computer. Your use of this software is subject\\n"
				printf "to the End User License Agreement, Terms of Use and Privacy Policy at\\n"
				printf "these URLs:\\n"
				printf "\\n    https://www.speedtest.net/about/eula\\n"
				printf "    https://www.speedtest.net/about/terms\\n"
				printf "    https://www.speedtest.net/about/privacy\\n\\n"
				printf "==============================================================================\\n\\n"
				printf "Ookla collects certain data through Speedtest that may be considered\\n"
				printf "personally identifiable, such as your IP address, unique device\\n"
				printf "identifiers or location. Ookla believes it has a legitimate interest\\n"
				printf "to share this data with internet providers, hardware manufacturers and\\n"
				printf "industry regulators to help them understand and create a better and\\n"
				printf "faster internet. For further information including how the data may be\\n"
				printf "shared, where the data may be transferred and Ookla's contact details,\\n"
				printf "please see our Privacy Policy at:\\n"
				printf "\\n    http://www.speedtest.net/privacy\\n"
				printf "\\n==============================================================================\\n\\n"
				
				printf "\\n\\e[1mYou must accept the license agreements for Speedtest CLI. Do you want to continue? (y/n)\\e[0m\\n"
				printf "\\e[1mNote: This will require an initial speedtest to run, please be patient\\e[0m\\n"
				read -r "confirm"
				case "$confirm" in
					y|Y)
						"$OOKLA_DIR"/speedtest --accept-license >/dev/null 2>&1
						"$OOKLA_DIR"/speedtest --accept-gdpr >/dev/null 2>&1
						License_Acceptance "save"
						return 0
					;;
					*)
						Print_Output "true" "Licenses not accepted, stopping" "$ERR"
						return 1
					;;
				esac
			done
		;;
		save)
			if [ ! -f "$OOKLA_LICENSE_DIR/speedtest-cli.json" ]; then
				cp "$HOME_DIR/.config/ookla/speedtest-cli.json" "$OOKLA_LICENSE_DIR/speedtest-cli.json"
				Print_Output "true" "Licenses accepted and saved to persistent storage" "$PASS"
			fi
		;;
		load)
			if [ -f "$OOKLA_LICENSE_DIR/speedtest-cli.json" ]; then
				cp "$OOKLA_LICENSE_DIR/speedtest-cli.json" "$HOME_DIR/.config/ookla/speedtest-cli.json"
				return 0
			else
				Print_Output "true" "Licenses haven't been accepted previously, nothing to load" "$ERR"
				return 1
			fi
		;;
	esac
}

Create_Dirs(){
	if [ ! -d "$SCRIPT_DIR" ]; then
		mkdir -p "$SCRIPT_DIR"
	fi
	
	if [ ! -d "$SCRIPT_STORAGE_DIR" ]; then
		mkdir -p "$SCRIPT_STORAGE_DIR"
	fi
	
	if [ ! -d "$CSV_OUTPUT_DIR" ]; then
		mkdir -p "$CSV_OUTPUT_DIR"
	fi
	
	if [ ! -d "$OOKLA_DIR" ]; then
		mkdir -p "$OOKLA_DIR"
	fi
	
	if [ ! -d "$OOKLA_LICENSE_DIR" ]; then
		mkdir -p "$OOKLA_LICENSE_DIR"
	fi
	
	if [ ! -d "$OOKLA_HOME_DIR" ]; then
		mkdir -p "$OOKLA_HOME_DIR"
	fi
	
	if [ ! -d "$SHARED_DIR" ]; then
		mkdir -p "$SHARED_DIR"
	fi
	
	if [ ! -d "$SCRIPT_WEBPAGE_DIR" ]; then
		mkdir -p "$SCRIPT_WEBPAGE_DIR"
	fi
		
	if [ ! -d "$SCRIPT_WEB_DIR" ]; then
		mkdir -p "$SCRIPT_WEB_DIR"
	fi
}

Create_Symlinks(){
	printf "WAN\\n" > "$SCRIPT_INTERFACES"
	
	for index in 1 2 3 4 5; do
		comment=""
		if ! ifconfig "tun1$index" > /dev/null 2>&1 ; then
			comment=" #excluded - interface not up#"
		fi
		if [ "$index" -lt 5 ]; then
			printf "VPNC%s%s\\n" "$index" "$comment" >> "$SCRIPT_INTERFACES"
		else
			printf "VPNC%s%s\\n" "$index" "$comment" >> "$SCRIPT_INTERFACES"
		fi
	done
	
	if [ "$1" = "force" ]; then
		rm -f "$SCRIPT_INTERFACES_USER"
	fi
	
	if [ ! -f "$SCRIPT_INTERFACES_USER" ]; then
		touch "$SCRIPT_INTERFACES_USER"
	fi
	
	while IFS='' read -r line || [ -n "$line" ]; do
		if [ "$(grep -c "$(echo "$line" | cut -f1 -d"#" | sed 's/ *$//')" "$SCRIPT_INTERFACES_USER")" -eq 0 ]; then
			printf "%s\\n" "$line" >> "$SCRIPT_INTERFACES_USER"
		fi
	done < "$SCRIPT_INTERFACES"
	
	interfacecount="$(wc -l < "$SCRIPT_INTERFACES_USER")"
	COUNTER=1
	until [ $COUNTER -gt "$interfacecount" ]; do
		Set_Interface_State "$COUNTER"
		COUNTER=$((COUNTER + 1))
	done
	
	rm -rf "${SCRIPT_WEB_DIR:?}/"* 2>/dev/null
	
	ln -s "$SCRIPT_INTERFACES_USER"  "$SCRIPT_WEB_DIR/interfaces.htm" 2>/dev/null
	
	ln -s "$SCRIPT_STORAGE_DIR/spdjs.js" "$SCRIPT_WEB_DIR/spdjs.js" 2>/dev/null
	
	ln -s "$CSV_OUTPUT_DIR" "$SCRIPT_WEB_DIR/csv" 2>/dev/null
	
	if [ ! -d "$SHARED_WEB_DIR" ]; then
		ln -s "$SHARED_DIR" "$SHARED_WEB_DIR" 2>/dev/null
	fi
}

Conf_Exists(){
	if [ -f "$SCRIPT_CONF" ]; then
		dos2unix "$SCRIPT_CONF"
		chmod 0644 "$SCRIPT_CONF"
		sed -i -e 's/"//g' "$SCRIPT_CONF"
		if [ "$(wc -l < "$SCRIPT_CONF")" -eq 7 ]; then
			{ echo "OUTPUTDATAMODE=raw"; echo "OUTPUTTIMEMODE=unix"; } >> "$SCRIPT_CONF"
		fi
		if [ "$(wc -l < "$SCRIPT_CONF")" -eq 8 ]; then
			echo "OUTPUTTIMEMODE=unix" >> "$SCRIPT_CONF"
		fi
		if [ "$(wc -l < "$SCRIPT_CONF")" -eq 9 ]; then
			echo "STORAGELOCATION=jffs" >> "$SCRIPT_CONF"
		fi
		return 0
	else
		{ echo "PREFERREDSERVER=0|None configured"; echo "USEPREFERRED=false"; echo "USESINGLE=false"; echo "AUTOMATED=true" ; echo "SCHEDULESTART=*" ; echo "SCHEDULEEND=*"; echo "MINUTE=*"; echo "OUTPUTDATAMODE=raw"; echo "OUTPUTTIMEMODE=unix"; echo "STORAGELOCATION=jffs"; } >> "$SCRIPT_CONF"
		return 1
	fi
}

Auto_ServiceEvent(){
	case $1 in
		create)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/service-event)
				# shellcheck disable=SC2016
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME_LOWER service_event"' "$1" "$2" &'' # '"$SCRIPT_NAME" /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/service-event
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					# shellcheck disable=SC2016
					echo "/jffs/scripts/$SCRIPT_NAME_LOWER service_event"' "$1" "$2" &'' # '"$SCRIPT_NAME" >> /jffs/scripts/service-event
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/service-event
				echo "" >> /jffs/scripts/service-event
				# shellcheck disable=SC2016
				echo "/jffs/scripts/$SCRIPT_NAME_LOWER service_event"' "$1" "$2" &'' # '"$SCRIPT_NAME" >> /jffs/scripts/service-event
				chmod 0755 /jffs/scripts/service-event
			fi
		;;
		delete)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/service-event
				fi
			fi
		;;
	esac
}

Get_Interface_From_Name(){
	IFACE=""
	case "$1" in
		WAN)
			if [ "$(nvram get sw_mode)" -ne "1" ]; then
				IFACE="br0"
			elif [ "$(nvram get wan0_proto)" = "pppoe" ] || [ "$(nvram get wan0_proto)" = "pptp" ] || [ "$(nvram get wan0_proto)" = "l2tp" ]; then
				IFACE="ppp0"
			else
				IFACE="$(nvram get wan0_ifname)"
			fi
		;;
		VPNC1)
			IFACE="tun11"
		;;
		VPNC2)
			IFACE="tun12"
		;;
		VPNC3)
			IFACE="tun13"
		;;
		VPNC4)
			IFACE="tun14"
		;;
		VPNC5)
			IFACE="tun15"
		;;
	esac
	
	echo "$IFACE"
}

Set_Interface_State(){
	interfaceline="$(sed "$1!d" "$SCRIPT_INTERFACES_USER" | awk '{$1=$1};1')"
	if echo "$interfaceline" | grep -q "VPN" ; then
		if echo "$interfaceline" | grep -q "#excluded" ; then
			if ! ifconfig "$(Get_Interface_From_Name "$(echo "$interfaceline" | cut -f1 -d"#" | sed 's/ *$//')")" > /dev/null 2>&1 ; then
				sed -i "$1"'s/ #excluded#/ #excluded - interface not up#/' "$SCRIPT_INTERFACES_USER"
			else
				sed -i "$1"'s/ #excluded - interface not up#/ #excluded#/' "$SCRIPT_INTERFACES_USER"
			fi
		fi
	fi
}

Generate_Interface_List(){
	ScriptHeader
	goback="false"
	printf "Retrieving list of interfaces...\\n\\n"
	interfacecount="$(wc -l < "$SCRIPT_INTERFACES_USER")"
	COUNTER=1
	until [ $COUNTER -gt "$interfacecount" ]; do
		Set_Interface_State "$COUNTER"
		interfaceline="$(sed "$COUNTER!d" "$SCRIPT_INTERFACES_USER" | awk '{$1=$1};1')"
		if [ "$COUNTER" -lt "10" ]; then
			printf "%s)  %s\\n" "$COUNTER" "$interfaceline"
		else
			printf "%s) %s\\n" "$COUNTER" "$interfaceline"
		fi
		
		COUNTER=$((COUNTER + 1))
	done
	
	printf "\\ne)  Go back\\n"
	
	while true; do
	printf "\\n\\e[1mPlease select a chart to toggle inclusion in %s (1-%s):\\e[0m\\n" "$SCRIPT_NAME" "$interfacecount"
	read -r "interface"
	
	if [ "$interface" = "e" ]; then
		goback="true"
		break
	elif ! Validate_Number "" "$interface" "silent"; then
		printf "\\n\\e[31mPlease enter a valid number (1-%s)\\e[0m\\n" "$interfacecount"
	else
		if [ "$interface" -lt 1 ] || [ "$interface" -gt "$interfacecount" ]; then
			printf "\\n\\e[31mPlease enter a number between 1 and %s\\e[0m\\n" "$interfacecount"
		else
			interfaceline="$(sed "$interface!d" "$SCRIPT_INTERFACES_USER" | awk '{$1=$1};1')"
			if echo "$interfaceline" | grep -q "#excluded" ; then
				if ! ifconfig "$(Get_Interface_From_Name "$(echo "$interfaceline" | cut -f1 -d"#" | sed 's/ *$//')")" > /dev/null 2>&1 ; then
					sed -i "$interface"'s/ #excluded#/ #excluded - interface not up#/' "$SCRIPT_INTERFACES_USER"
				else
					sed -i "$interface"'s/ #excluded - interface not up#//' "$SCRIPT_INTERFACES_USER"
					sed -i "$interface"'s/ #excluded#//' "$SCRIPT_INTERFACES_USER"
				fi
			else
				if ! ifconfig "$(Get_Interface_From_Name "$(echo "$interfaceline" | cut -f1 -d"#" | sed 's/ *$//')")" > /dev/null 2>&1 ; then
					sed -i "$interface"'s/$/ #excluded - interface not up#/' "$SCRIPT_INTERFACES_USER"
				else
					sed -i "$interface"'s/$/ #excluded#/' "$SCRIPT_INTERFACES_USER"
				fi
			fi
			
			sed -i 's/ *$//' "$SCRIPT_INTERFACES_USER"
			printf "\\n"
			break
		fi
	fi
	done
	
	if [ "$goback" != "true" ]; then
		Generate_Interface_List
	fi
}

Auto_Startup(){
	case $1 in
		create)
			if [ -f /jffs/scripts/services-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/services-start)
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME_LOWER startup &"' # '"$SCRIPT_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo "/jffs/scripts/$SCRIPT_NAME_LOWER startup &"' # '"$SCRIPT_NAME" >> /jffs/scripts/services-start
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/services-start
				echo "" >> /jffs/scripts/services-start
				echo "/jffs/scripts/$SCRIPT_NAME_LOWER startup &"' # '"$SCRIPT_NAME" >> /jffs/scripts/services-start
				chmod 0755 /jffs/scripts/services-start
			fi
		;;
		delete)
			if [ -f /jffs/scripts/services-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
				fi
			fi
		;;
	esac
}

Auto_Cron(){
	case $1 in
		create)
		STARTUPLINECOUNT=$(cru l | grep -c "$SCRIPT_NAME")
		
		if [ "$STARTUPLINECOUNT" -eq 0 ]; then
				SCHEDULESTART=$(grep "SCHEDULESTART" "$SCRIPT_CONF" | cut -f2 -d"=")
				SCHEDULEEND=$(grep "SCHEDULEEND" "$SCRIPT_CONF" | cut -f2 -d"=")
				MINUTESTART=$(grep "MINUTE" "$SCRIPT_CONF" | cut -f2 -d"=")
				if [ "$MINUTESTART" = "*" ]; then
					MINUTESTART=12
				fi
				MINUTEEND=$((MINUTESTART + 30))
				[ "$MINUTEEND" -gt 60 ] && MINUTEEND=$((MINUTEEND - 60))
				
				if [ "$SCHEDULESTART" = "*" ] || [ "$SCHEDULEEND" = "*" ]; then
					cru a "$SCRIPT_NAME" "$MINUTESTART,$MINUTEEND * * * * /jffs/scripts/$SCRIPT_NAME_LOWER generate"
				else
					if [ "$SCHEDULESTART" -lt "$SCHEDULEEND" ]; then
						cru a "$SCRIPT_NAME" "$MINUTESTART,$MINUTEEND ""$SCHEDULESTART-$SCHEDULEEND"" * * * /jffs/scripts/$SCRIPT_NAME_LOWER generate"
					else
						cru a "$SCRIPT_NAME" "$MINUTESTART,$MINUTEEND ""$SCHEDULESTART-23,0-$SCHEDULEEND"" * * * /jffs/scripts/$SCRIPT_NAME_LOWER generate"
					fi
				fi
			fi
		;;
		delete)
			STARTUPLINECOUNT=$(cru l | grep -c "$SCRIPT_NAME")
			
			if [ "$STARTUPLINECOUNT" -gt 0 ]; then
				cru d "$SCRIPT_NAME"
			fi
		;;
	esac
}

Download_File(){
	/usr/sbin/curl -fsL --retry 3 "$1" -o "$2"
}

Get_WebUI_Page () {
	for i in 1 2 3 4 5 6 7 8 9 10; do
		page="$SCRIPT_WEBPAGE_DIR/user$i.asp"
		if [ ! -f "$page" ] || [ "$(md5sum < "$1")" = "$(md5sum < "$page")" ]; then
			MyPage="user$i.asp"
			return
		fi
	done
	MyPage="none"
}

Mount_WebUI(){
	Get_WebUI_Page "$SCRIPT_DIR/spdstats_www.asp"
	if [ "$MyPage" = "none" ]; then
		Print_Output "true" "Unable to mount $SCRIPT_NAME WebUI page, exiting" "$CRIT"
		exit 1
	fi
	Print_Output "true" "Mounting $SCRIPT_NAME WebUI page as $MyPage" "$PASS"
	cp -f "$SCRIPT_DIR/spdstats_www.asp" "$SCRIPT_WEBPAGE_DIR/$MyPage"
	echo "SpeedTest" > "$SCRIPT_WEBPAGE_DIR/$(echo $MyPage | cut -f1 -d'.').title"
	
	if [ "$(uname -o)" = "ASUSWRT-Merlin" ]; then
		if [ ! -f "/tmp/index_style.css" ]; then
			cp -f "/www/index_style.css" "/tmp/"
		fi
		
		if ! grep -q '.menu_Addons' /tmp/index_style.css ; then
			echo ".menu_Addons { background: url(ext/shared-jy/addons.png); }" >> /tmp/index_style.css
		fi
		
		umount /www/index_style.css 2>/dev/null
		mount -o bind /tmp/index_style.css /www/index_style.css
		
		if [ ! -f "/tmp/menuTree.js" ]; then
			cp -f "/www/require/modules/menuTree.js" "/tmp/"
		fi
		
		sed -i "\\~$MyPage~d" /tmp/menuTree.js
		
		if ! grep -q 'menuName: "Addons"' /tmp/menuTree.js ; then
			lineinsbefore="$(( $(grep -n "exclude:" /tmp/menuTree.js | cut -f1 -d':') - 1))"
			sed -i "$lineinsbefore"'i,\n{\nmenuName: "Addons",\nindex: "menu_Addons",\ntab: [\n{url: "ext/shared-jy/redirect.htm", tabName: "Help & Support"},\n{url: "NULL", tabName: "__INHERIT__"}\n]\n}' /tmp/menuTree.js
		fi
		
		if ! grep -q "javascript:window.open('/ext/shared-jy/redirect.htm'" /tmp/menuTree.js ; then
			sed -i "s~ext/shared-jy/redirect.htm~javascript:window.open('/ext/shared-jy/redirect.htm','_blank')~" /tmp/menuTree.js
		fi
		sed -i "/url: \"javascript:window.open('\/ext\/shared-jy\/redirect.htm'/i {url: \"$MyPage\", tabName: \"SpeedTest\"}," /tmp/menuTree.js
		
		umount /www/require/modules/menuTree.js 2>/dev/null
		mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
	fi
}

GenerateServerList(){
	printf "Generating list of closest servers...\\n\\n"
	serverlist="$("$OOKLA_DIR"/speedtest --servers --format="json")"
	servercount="$(echo "$serverlist" | jq '.servers | length')"
	COUNTER=1
	until [ $COUNTER -gt "$servercount" ]; do
		serverdetails="$(echo "$serverlist" | jq -r --argjson index "$((COUNTER-1))" '.servers[$index] | .name + " (" + .location + ", " + .country + ")"')"
		
		if [ "$COUNTER" -lt 10 ]; then
			printf "%s)  %s\\n" "$COUNTER" "$serverdetails"
		elif [ "$COUNTER" -ge 10 ]; then
			printf "%s) %s\\n" "$COUNTER" "$serverdetails"
		fi
		COUNTER=$((COUNTER + 1))
	done
	
	printf "\\ne)  Go back\\n"
	
	while true; do
		printf "\\n\\e[1mPlease select a server from the list above (1-%s):\\e[0m\\n" "$servercount"
		printf "\\n\\e[1mOr press c to enter a known server ID\\e[0m\\n"
		read -r "server"
		
		if [ "$server" = "e" ]; then
			serverno="exit"
			break
		elif [ "$server" = "c" ]; then
				while true; do
					printf "\\n\\e[1mPlease enter server ID (WARNING: this is not validated) or e to go back\\e[0m\\n"
					read -r "customserver"
					if [ "$customserver" = "e" ]; then
						break
					elif ! Validate_Number "" "$customserver" "silent"; then
						printf "\\n\\e[31mPlease enter a valid number\\e[0m\\n"
					else
						serverno="$customserver"
						servername="Custom"
						printf "\\n"
						return 0
					fi
				done
		elif ! Validate_Number "" "$server" "silent"; then
			printf "\\n\\e[31mPlease enter a valid number (1-%s)\\e[0m\\n" "$servercount"
		else
			if [ "$server" -lt 1 ] || [ "$server" -gt "$servercount" ]; then
				printf "\\n\\e[31mPlease enter a number between 1 and %s\\e[0m\\n" "$servercount"
			else
				serverno="$(echo "$serverlist" | jq -r --argjson index "$((server-1))" '.servers[$index] | .id')"
				servername="$(echo "$serverlist" | jq -r --argjson index "$((server-1))" '.servers[$index] | .name + " (" + .location + ", " + .country + ")"')"
				printf "\\n"
				break
			fi
		fi
	done
}

PreferredServer(){
	case "$1" in
		update)
			GenerateServerList
			if [ "$serverno" != "exit" ]; then
				sed -i 's/^PREFERREDSERVER.*$/PREFERREDSERVER='"$serverno""|""$servername"'/' "$SCRIPT_CONF"
			else
				return 1
			fi
		;;
		enable)
			sed -i 's/^USEPREFERRED.*$/USEPREFERRED=true/' "$SCRIPT_CONF"
		;;
		disable)
			sed -i 's/^USEPREFERRED.*$/USEPREFERRED=false/' "$SCRIPT_CONF"
		;;
		check)
			USEPREFERRED=$(grep "USEPREFERRED" "$SCRIPT_CONF" | cut -f2 -d"=")
			if [ "$USEPREFERRED" = "true" ]; then return 0; else return 1; fi
		;;
		list)
			PREFERREDSERVER=$(grep "PREFERREDSERVER" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$PREFERREDSERVER"
		;;
		validate)
			#TODO: validate against XML here: https://c.speedtest.net/speedtest-servers-static.php
			PREFERREDSERVERNO="$(grep "PREFERREDSERVER" "$SCRIPT_CONF" | cut -f2 -d"=" | cut -f1 -d"|")"
			"$OOKLA_DIR"/speedtest --servers --format="csv" > /tmp/spdServers.txt
			if grep -q "^\"$PREFERREDSERVERNO" /tmp/spdServers.txt; then
				rm -f /tmp/spdServers.txt
				return 0
			else
				rm -f /tmp/spdServers.txt
				return 1
			fi
	esac
}

AutomaticMode(){
	case "$1" in
		enable)
			sed -i 's/^AUTOMATED.*$/AUTOMATED=true/' "$SCRIPT_CONF"
			Auto_Cron create 2>/dev/null
		;;
		disable)
			sed -i 's/^AUTOMATED.*$/AUTOMATED=false/' "$SCRIPT_CONF"
			Auto_Cron delete 2>/dev/null
		;;
		check)
			AUTOMATED=$(grep "AUTOMATED" "$SCRIPT_CONF" | cut -f2 -d"=")
			if [ "$AUTOMATED" = "true" ]; then return 0; else return 1; fi
		;;
	esac
}

TestSchedule(){
	case "$1" in
		update)
			sed -i 's/^'"SCHEDULESTART"'.*$/SCHEDULESTART='"$2"'/' "$SCRIPT_CONF"
			sed -i 's/^'"SCHEDULEEND"'.*$/SCHEDULEEND='"$3"'/' "$SCRIPT_CONF"
			sed -i 's/^'"MINUTE"'.*$/MINUTE='"$4"'/' "$SCRIPT_CONF"
			Auto_Cron delete 2>/dev/null
			Auto_Cron create 2>/dev/null
		;;
		check)
			SCHEDULESTART=$(grep "SCHEDULESTART" "$SCRIPT_CONF" | cut -f2 -d"=")
			SCHEDULEEND=$(grep "SCHEDULEEND" "$SCRIPT_CONF" | cut -f2 -d"=")
			MINUTESTART=$(grep "MINUTE" "$SCRIPT_CONF" | cut -f2 -d"=")
			if [ "$SCHEDULESTART" != "*" ] && [ "$SCHEDULEEND" != "*" ] && [ "$MINUTESTART" != "*" ]; then
				schedulestart="$SCHEDULESTART"
				scheduleend="$SCHEDULEEND"
				minutestart="$MINUTESTART"
				return 0
			else
				return 1
			fi
		;;
	esac
}

ScriptStorageLocation(){
	case "$1" in
		usb)
			sed -i 's/^STORAGELOCATION.*$/STORAGELOCATION=usb/' "$SCRIPT_CONF"
			mv "/jffs/addons/$SCRIPT_NAME_LOWER.d/csv" "/opt/share/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME_LOWER.d/.interfaces" "/opt/share/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME_LOWER.d/.interfaces_user" "/opt/share/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME_LOWER.d/config" "/opt/share/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME_LOWER.d/spdjs.js" "/opt/share/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			mv "/jffs/addons/$SCRIPT_NAME_LOWER.d/spdstats.db" "/opt/share/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			SCRIPT_CONF="/opt/share/$SCRIPT_NAME_LOWER.d/config"
			ScriptStorageLocation "load"
		;;
		jffs)
			sed -i 's/^STORAGELOCATION.*$/STORAGELOCATION=jffs/' "$SCRIPT_CONF"
			mv "/opt/share/$SCRIPT_NAME_LOWER.d/csv" "/jffs/addons/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME_LOWER.d/.interfaces" "/jffs/addons/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME_LOWER.d/.interfaces_user" "/jffs/addons/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME_LOWER.d/config" "/jffs/addons/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME_LOWER.d/spdjs.js" "/jffs/addons/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			mv "/opt/share/$SCRIPT_NAME_LOWER.d/spdstats.db" "/jffs/addons/$SCRIPT_NAME_LOWER.d/" 2>/dev/null
			SCRIPT_CONF="/jffs/addons/$SCRIPT_NAME_LOWER.d/config"
			ScriptStorageLocation "load"
		;;
		check)
			STORAGELOCATION=$(grep "STORAGELOCATION" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$STORAGELOCATION"
		;;
		load)
			STORAGELOCATION=$(grep "STORAGELOCATION" "$SCRIPT_CONF" | cut -f2 -d"=")
			if [ "$STORAGELOCATION" = "usb" ]; then
				SCRIPT_STORAGE_DIR="/opt/share/$SCRIPT_NAME_LOWER.d"
			elif [ "$STORAGELOCATION" = "jffs" ]; then
				SCRIPT_STORAGE_DIR="/jffs/addons/$SCRIPT_NAME_LOWER.d"
			fi
			
			SCRIPT_INTERFACES="$SCRIPT_STORAGE_DIR/.interfaces"
			SCRIPT_INTERFACES_USER="$SCRIPT_STORAGE_DIR/.interfaces_user"
			CSV_OUTPUT_DIR="$SCRIPT_STORAGE_DIR/csv"
		;;
	esac
}

OutputDataMode(){
	case "$1" in
		raw)
			sed -i 's/^OUTPUTDATAMODE.*$/OUTPUTDATAMODE=raw/' "$SCRIPT_CONF"
			Generate_CSVs
		;;
		average)
			sed -i 's/^OUTPUTDATAMODE.*$/OUTPUTDATAMODE=average/' "$SCRIPT_CONF"
			Generate_CSVs
		;;
		check)
			OUTPUTDATAMODE=$(grep "OUTPUTDATAMODE" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$OUTPUTDATAMODE"
		;;
	esac
}

OutputTimeMode(){
	case "$1" in
		unix)
			sed -i 's/^OUTPUTTIMEMODE.*$/OUTPUTTIMEMODE=unix/' "$SCRIPT_CONF"
			Generate_CSVs
		;;
		non-unix)
			sed -i 's/^OUTPUTTIMEMODE.*$/OUTPUTTIMEMODE=non-unix/' "$SCRIPT_CONF"
			Generate_CSVs
		;;
		check)
			OUTPUTTIMEMODE=$(grep "OUTPUTTIMEMODE" "$SCRIPT_CONF" | cut -f2 -d"=")
			echo "$OUTPUTTIMEMODE"
		;;
	esac
}

WritePlainData_ToJS(){
	inputfile="$1"
	outputfile="$2"
	shift;shift
	i="0"
	for var in "$@"; do
		i=$((i+1))
		{ echo "var $var;"
			echo "$var = [];"
			echo "${var}.unshift('$(awk -v i=$i '{printf t $i} {t=","}' "$inputfile" | sed "s~,~\\',\\'~g")');"
			echo; } >> "$outputfile"
	done
}

WriteStats_ToJS(){
	echo "function $3(){" >> "$2"
	html='document.getElementById("'"$4"'").innerHTML="'
	while IFS='' read -r line || [ -n "$line" ]; do
		html="$html""$line""\\r\\n"
	done < "$1"
	html="$html"'"'
	printf "%s\\r\\n}\\r\\n" "$html" >> "$2"
}

#$1 fieldname $2 tablename $3 frequency (hours) $4 length (days) $5 outputfile $6 outputfrequency $7 interfacename $8 sqlfile $9 timestamp
WriteSql_ToFile(){
	timenow="$9"
	maxcount="$(echo "$3" "$4" | awk '{printf ((24*$2)/$1)}')"
	multiplier="$(echo "$3" | awk '{printf (60*60*$1)}')"
	{
		echo ".mode csv"
		echo ".headers on"
		echo ".output $5$6""_$7.htm"
	} >> "$8"
	
	echo "SELECT '$1' Metric, Min([Timestamp]) Time, IFNULL(Avg([$1]),'NaN') Value FROM $2 WHERE ([Timestamp] >= $timenow - ($multiplier*$maxcount)) GROUP BY ([Timestamp]/($multiplier));" >> "$8"
}

#$1 iface name
Generate_LastXResults(){
	{
		echo ".mode csv"
		echo ".output /tmp/spd-lastx.csv"
	} > /tmp/spd-lastx.sql
	echo "select[Timestamp],[Download],[Upload] from spdstats_$1 order by [Timestamp] desc limit 10;" >> /tmp/spd-lastx.sql
	"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/spdstats.db" < /tmp/spd-lastx.sql
	sed -i 's/,/ /g' "/tmp/spd-lastx.csv"
	WritePlainData_ToJS "/tmp/spd-lastx.csv" "$SCRIPT_STORAGE_DIR/spdjs.js" "DataTimestamp_$1" "DataDownload_$1" "DataUpload_$1"
	rm -f /tmp/spd-lastx.sql
	rm -f /tmp/spd-lastx.csv
}

Run_Speedtest(){
	Create_Dirs
	Conf_Exists
	Set_Version_Custom_Settings "local"
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	ScriptStorageLocation "load"
	Create_Symlinks
	License_Acceptance "load"
	
	mode="$1"
	speedtestserverno=""
	speedtestservername=""
	
	tmpfile=/tmp/spd-stats.txt
	
	if Check_Swap ; then
		if [ "$mode" != "webui" ]; then
			if ! License_Acceptance "check" ; then
				if [ "$mode" != "schedule" ]; then
					if ! License_Acceptance "accept"; then
						Clear_Lock
						return 1
					fi
				else
					Print_Output "true" "Licenses not accepted, please run spdMerlin to accept them" "$ERR"
					return 1
				fi
			fi
		else
			mode="schedule"
		fi
		
		if [ "$mode" = "schedule" ]; then
			USEPREFERRED=$(grep "USEPREFERRED" "$SCRIPT_CONF" | cut -f2 -d"=")
			if PreferredServer check; then
				speedtestserverno="$(PreferredServer list | cut -f1 -d"|")"
				speedtestservername="$(PreferredServer list | cut -f2 -d"|")"
			else
				mode="auto"
			fi
		elif [ "$mode" = "onetime" ]; then
			GenerateServerList
			if [ "$serverno" != "exit" ]; then
				speedtestserverno="$serverno"
				speedtestservername="$servername"
			else
				Clear_Lock
				return 1
			fi
		elif [ "$mode" = "user" ]; then
			speedtestserverno="$(PreferredServer list | cut -f1 -d"|")"
			speedtestservername="$(PreferredServer list | cut -f2 -d"|")"
		fi
		
		IFACELIST=""
		
		while IFS='' read -r line || [ -n "$line" ]; do
			if [ "$(echo "$line" | grep -c "#")" -eq 0 ]; then
				IFACELIST="$IFACELIST"" ""$line"
			fi
		done < "$SCRIPT_INTERFACES_USER"
		
		IFACELIST="$(echo "$IFACELIST" | cut -c2-)"
		
		if [ "$IFACELIST" != "" ]; then
			
			for IFACE_NAME in $IFACELIST; do
				
				IFACE="$(Get_Interface_From_Name "$IFACE_NAME")"
				
				if ! ifconfig "$IFACE" > /dev/null 2>&1 ; then
					Print_Output "true" "$IFACE not up, please check. Skipping speedtest for $IFACE_NAME" "$WARN"
					continue
				else
					
					for proto in tcp udp; do
						iptables -A OUTPUT -p "$proto" -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
						iptables -t mangle -A OUTPUT -p "$proto" -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
						iptables -t mangle -A POSTROUTING -p "$proto" -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
					done
					
					if [ "$mode" = "auto" ]; then
						Print_Output "true" "Starting speedtest using auto-selected server for $IFACE_NAME interface" "$PASS"
						"$OOKLA_DIR"/speedtest --interface="$IFACE" --format="human-readable" --unit="Mbps" --progress="yes" --accept-license --accept-gdpr | tee "$tmpfile"
					else
						#if [ "$mode" != "onetime" ]; then
						#	if ! PreferredServer validate; then
						#		Print_Output "true" "Preferred server no longer valid, please choose another" "$ERR"
						#		Clear_Lock
						#		return 1
						#	fi
						#fi
						
						if [ "$IFACE_NAME" = "WAN" ]; then
							Print_Output "true" "Starting speedtest using $speedtestservername for $IFACE_NAME interface" "$PASS"
							"$OOKLA_DIR"/speedtest --interface="$IFACE" --server-id="$speedtestserverno" --format="human-readable" --unit="Mbps" --progress="yes" --accept-license --accept-gdpr | tee "$tmpfile"
						else
							Print_Output "true" "Starting speedtest using using auto-selected server for $IFACE_NAME interface" "$PASS"
							"$OOKLA_DIR"/speedtest --interface="$IFACE" --format="human-readable" --unit="Mbps" --progress="yes" --accept-license --accept-gdpr | tee "$tmpfile"
						fi
					fi
					
					for proto in tcp udp; do
						iptables -D OUTPUT -p "$proto" -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
						iptables -t mangle -D OUTPUT -p "$proto" -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
						iptables -t mangle -D POSTROUTING -p "$proto" -j MARK --set-xmark 0x80000000/0xC0000000 2>/dev/null
					done
					
					TZ=$(cat /etc/TZ)
					export TZ
					
					timenow=$(date +"%s")
					timenowfriendly=$(date +"%c")
					
					download=$(grep Download "$tmpfile" | awk 'BEGIN { FS = "\r" } ;{print $NF};' | awk 'BEGIN{FS=" "}{print $2}')
					upload=$(grep Upload "$tmpfile" | awk 'BEGIN { FS = "\r" } ;{print $NF};' | awk 'BEGIN{FS=" "}{print $2}')
					
					{
					echo "CREATE TABLE IF NOT EXISTS [spdstats_$IFACE_NAME] ([StatID] INTEGER PRIMARY KEY NOT NULL, [Timestamp] NUMERIC NOT NULL, [Download] REAL NOT NULL,[Upload] REAL NOT NULL);"
					echo "INSERT INTO spdstats_$IFACE_NAME ([Timestamp],[Download],[Upload]) values($timenow,$download,$upload);"
					} > /tmp/spd-stats.sql
					"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/spdstats.db" < /tmp/spd-stats.sql
					
					echo "DELETE FROM [spdstats_$IFACE_NAME] WHERE [Timestamp] < ($timenow - (86400*30));" > /tmp/spd-stats.sql
					"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/spdstats.db" < /tmp/spd-stats.sql
					rm -f /tmp/spd-stats.sql
					
					spdtestresult="$(grep Download "$tmpfile" | awk 'BEGIN { FS = "\r" } ;{print $NF};'| awk '{$1=$1};1') - $(grep Upload "$tmpfile" | awk 'BEGIN { FS = "\r" } ;{print $NF};'| awk '{$1=$1};1')"
					
					printf "\\n"
					Print_Output "true" "Speedtest results - $spdtestresult" "$PASS"
					rm -f "$tmpfile"
					
					#extStats
					extStats="/jffs/addons/extstats.d/mod_spdstats.sh"
					if [ -f "$extStats" ]; then
						sh "$extStats" "ext" "$download" "$upload"
					fi
				fi
			done
			
			Generate_CSVs
			
			echo "Stats last updated: $timenowfriendly" > "/tmp/spdstatstitle.txt"
			WriteStats_ToJS "/tmp/spdstatstitle.txt" "$SCRIPT_STORAGE_DIR/spdjs.js" "SetSPDStatsTitle" "statstitle"
			
			rm -f "/tmp/spdstatstitle.txt"
		else
			Print_Output "true" "No interfaces enabled, exiting" "$CRIT"
			Clear_Lock
			return 1
		fi
		Clear_Lock
	else
		Print_Output "true" "Swap file not active, exiting" "$CRIT"
		Clear_Lock
		return 1
	fi
}

Generate_CSVs(){
	OUTPUTDATAMODE="$(OutputDataMode "check")"
	OUTPUTTIMEMODE="$(OutputTimeMode "check")"
	IFACELIST=""
	
	while IFS='' read -r line || [ -n "$line" ]; do
		if [ "$(echo "$line" | grep -c "#")" -eq 0 ]; then
			IFACELIST="$IFACELIST"" ""$line"
		fi
	done < "$SCRIPT_INTERFACES_USER"
	
	IFACELIST="$(echo "$IFACELIST" | cut -c2-)"
	
	if [ "$IFACELIST" != "" ]; then
		rm -f "$SCRIPT_STORAGE_DIR/spdjs.js"
		
		for IFACE_NAME in $IFACELIST; do
			
			IFACE="$(Get_Interface_From_Name "$IFACE_NAME")"
				
			TZ=$(cat /etc/TZ)
			export TZ
			
			timenow=$(date +"%s")
			timenowfriendly=$(date +"%c")
			
			metriclist="Download Upload"
			
			for metric in $metriclist; do
				{
					echo ".mode csv"
					echo ".headers on"
					echo ".output $CSV_OUTPUT_DIR/$metric""daily_$IFACE_NAME"".htm"
					echo "select '$metric' Metric,[Timestamp] Time,[$metric] Value from spdstats_$IFACE_NAME WHERE [Timestamp] >= ($timenow - 86400);"
				} > /tmp/spd-stats.sql
				
				"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/spdstats.db" < /tmp/spd-stats.sql
				rm -f /tmp/spd-stats.sql
				
				if [ "$OUTPUTDATAMODE" = "raw" ]; then
					{
						echo ".mode csv"
						echo ".headers on"
						echo ".output $CSV_OUTPUT_DIR/$metric""weekly_$IFACE_NAME"".htm"
						echo "select '$metric' Metric,[Timestamp] Time,[$metric] Value from spdstats_$IFACE_NAME WHERE [Timestamp] >= ($timenow - 86400*7);"
					} > /tmp/spd-stats.sql
					"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/spdstats.db" < /tmp/spd-stats.sql
					rm -f /tmp/spd-stats.sql
					
					{
						echo ".mode csv"
						echo ".headers on"
						echo ".output $CSV_OUTPUT_DIR/$metric""monthly_$IFACE_NAME"".htm"
						echo "select '$metric' Metric,[Timestamp] Time,[$metric] Value from spdstats_$IFACE_NAME WHERE [Timestamp] >= ($timenow - 86400*30);"
					} > /tmp/spd-stats.sql
					"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/spdstats.db" < /tmp/spd-stats.sql
					rm -f /tmp/spd-stats.sql
				elif [ "$OUTPUTDATAMODE" = "average" ]; then
					WriteSql_ToFile "$metric" "spdstats_$IFACE_NAME" 1 7 "$CSV_OUTPUT_DIR/$metric" "weekly" "$IFACE_NAME" "/tmp/spd-stats.sql" "$timenow"
					"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/spdstats.db" < /tmp/spd-stats.sql
					rm -f /tmp/spd-stats.sql
					
					WriteSql_ToFile "$metric" "spdstats_$IFACE_NAME" 3 30 "$CSV_OUTPUT_DIR/$metric" "monthly" "$IFACE_NAME" "/tmp/spd-stats.sql" "$timenow"
					"$SQLITE3_PATH" "$SCRIPT_STORAGE_DIR/spdstats.db" < /tmp/spd-stats.sql
					rm -f /tmp/spd-stats.sql
				fi
			done
			
			Generate_LastXResults "$IFACE_NAME"
			rm -f "/tmp/spd-stats.sql"
		done
		
		dos2unix "$CSV_OUTPUT_DIR/"*.htm
		
		tmpoutputdir="/tmp/""$SCRIPT_NAME_LOWER""results"
		mkdir -p "$tmpoutputdir"
		cp "$CSV_OUTPUT_DIR/"*.htm "$tmpoutputdir/."
		
		if [ "$OUTPUTTIMEMODE" = "unix" ]; then
			find "$tmpoutputdir/" -name '*.htm' -exec sh -c 'i="$1"; mv -- "$i" "${i%.htm}.csv"' _ {} \;
		elif [ "$OUTPUTTIMEMODE" = "non-unix" ]; then
			for i in "$tmpoutputdir/"*".htm"; do
				awk -F"," 'NR==1 {OFS=","; print} NR>1 {OFS=","; $2=strftime("%Y-%m-%d %H:%M:%S", $2); print }' "$i" > "$i.out"
			done
			
			find "$tmpoutputdir/" -name '*.htm.out' -exec sh -c 'i="$1"; mv -- "$i" "${i%.htm.out}.csv"' _ {} \;
			rm -f "$tmpoutputdir/"*.htm
		fi
		
		if [ ! -f /opt/bin/7z ]; then
			opkg update
			opkg install p7zip
		fi
		/opt/bin/7z a -y -bsp0 -bso0 -tzip "/tmp/""$SCRIPT_NAME_LOWER""data.zip" "$tmpoutputdir/*"
		mv "/tmp/""$SCRIPT_NAME_LOWER""data.zip" "$CSV_OUTPUT_DIR"
		rm -rf "$tmpoutputdir"
	fi
}

Shortcut_spdMerlin(){
	case $1 in
		create)
			if [ -d "/opt/bin" ] && [ ! -f "/opt/bin/$SCRIPT_NAME_LOWER" ] && [ -f "/jffs/scripts/$SCRIPT_NAME_LOWER" ]; then
				ln -s /jffs/scripts/"$SCRIPT_NAME_LOWER" /opt/bin
				chmod 0755 /opt/bin/"$SCRIPT_NAME_LOWER"
			fi
		;;
		delete)
			if [ -f "/opt/bin/$SCRIPT_NAME_LOWER" ]; then
				rm -f /opt/bin/"$SCRIPT_NAME_LOWER"
			fi
		;;
	esac
}

PressEnter(){
	while true; do
		printf "Press enter to continue..."
		read -r "key"
		case "$key" in
			*)
				break
			;;
		esac
	done
	return 0
}

ScriptHeader(){
	clear
	
	printf "\\n"
	printf "\\e[1m############################################################\\e[0m\\n"
	printf "\\e[1m##                   _  __  __              _  _          ##\\e[0m\\n"
	printf "\\e[1m##                  | ||  \/  |            | |(_)         ##\\e[0m\\n"
	printf "\\e[1m##   ___  _ __    __| || \  / |  ___  _ __ | | _  _ __    ##\\e[0m\\n"
	printf "\\e[1m##  / __|| '_ \  / _  || |\/| | / _ \| '__|| || || '_ \   ##\\e[0m\\n"
	printf "\\e[1m##  \__ \| |_) || (_| || |  | ||  __/| |   | || || | | |  ##\\e[0m\\n"
	printf "\\e[1m##  |___/| .__/  \__,_||_|  |_| \___||_|   |_||_||_| |_|  ##\\e[0m\\n"
	printf "\\e[1m##      | |                                               ##\\e[0m\\n"
	printf "\\e[1m##      |_|                                               ##\\e[0m\\n"
	printf "\\e[1m##                                                        ##\\e[0m\\n"
	printf "\\e[1m##                 %s on %-9s                    ##\\e[0m\\n" "$SCRIPT_VERSION" "$ROUTER_MODEL"
	printf "\\e[1m##                                                        ##\\e[0m\\n"
	printf "\\e[1m##        https://github.com/jackyaz/spdMerlin            ##\\e[0m\\n"
	printf "\\e[1m##                                                        ##\\e[0m\\n"
	printf "\\e[1m############################################################\\e[0m\\n"
	printf "\\n"
}

MainMenu(){
	PREFERREDSERVER_ENABLED=""
	AUTOMATIC_ENABLED=""
	TEST_SCHEDULE=""
	OUTPUTDATAMODE_MENU="$(OutputDataMode "check")"
	OUTPUTTIMEMODE_MENU="$(OutputTimeMode "check")"
	SCRIPTSTORAGE_MENU="$(ScriptStorageLocation "check")"
	if PreferredServer check; then PREFERREDSERVER_ENABLED="Enabled"; else PREFERREDSERVER_ENABLED="Disabled"; fi
	if AutomaticMode check; then AUTOMATIC_ENABLED="Enabled"; else AUTOMATIC_ENABLED="Disabled"; fi
	if TestSchedule check; then
		TEST_SCHEDULE="Start: $schedulestart    -    End: $scheduleend"
		minuteend=$((minutestart + 30))
		[ "$minuteend" -gt 60 ] && minuteend=$((minuteend - 60))
		if [ "$minutestart" -lt "$minuteend" ]; then
			TEST_SCHEDULE2="Tests will run at $minutestart and $minuteend past the hour"
		else
			TEST_SCHEDULE2="Tests will run at $minuteend and $minutestart past the hour"
		fi
	else
		TEST_SCHEDULE="No defined schedule - tests run every hour"
		TEST_SCHEDULE2="Tests will run at 12 and 42 past the hour"
	fi
	
	printf "1.    Run a speedtest now (auto select server)\\n"
	printf "2.    Run a speedtest now (use preferred server - applies to WAN only)\\n"
	printf "3.    Run a speedtest (select a server - applies to WAN only)\\n\\n"
	printf "4.    Choose a preferred server for WAN (for automatic speedtests)\\n      Current server: %s\\n\\n" "$(PreferredServer list | cut -f2 -d"|")"
	printf "5.    Toggle preferred server for WAN (for automatic speedtests)\\n      Currently %s\\n\\n" "$PREFERREDSERVER_ENABLED"
	printf "6.    Toggle automatic speedtests\\n      Currently %s\\n\\n" "$AUTOMATIC_ENABLED"
	printf "7.    Configure schedule for automatic speedtests\\n      %s\\n      %s\\n\\n" "$TEST_SCHEDULE" "$TEST_SCHEDULE2"
	printf "8.    Toggle data output mode\\n      Currently \\e[1m%s\\e[0m values will be used for weekly and monthly charts\\n\\n" "$OUTPUTDATAMODE_MENU"
	printf "9.    Toggle time output mode\\n      Currently \\e[1m%s\\e[0m time values will be used for CSV exports\\n\\n" "$OUTPUTTIMEMODE_MENU"
	printf "c.    Customise list of interfaces for automatic speedtests\\n\\n"
	printf "r.    Reset list of interfaces for automatic speedtests to default\\n\\n"
	printf "s.    Toggle storage location for stats and config\\n      Current location is \\e[1m%s\\e[0m \\n\\n" "$SCRIPTSTORAGE_MENU"
	printf "u.    Check for updates\\n"
	printf "uf.   Update %s with latest version (force update)\\n\\n" "$SCRIPT_NAME"
	printf "e.    Exit %s\\n\\n" "$SCRIPT_NAME"
	printf "z.    Uninstall %s\\n" "$SCRIPT_NAME"
	printf "\\n"
	printf "\\e[1m############################################################\\e[0m\\n"
	printf "\\n"
	
	while true; do
		printf "Choose an option:    "
		read -r "menu"
		case "$menu" in
			1)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_GenerateStats "auto"
				fi
				PressEnter
				break
			;;
			2)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_GenerateStats "user"
				fi
				PressEnter
				break
			;;
			3)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_GenerateStats "onetime"
				fi
				PressEnter
				break
			;;
			4)
				printf "\\n"
				PreferredServer "update"
				PressEnter
				break
			;;
			5)
				printf "\\n"
				Menu_TogglePreferred
				break
			;;
			6)
				printf "\\n"
				Menu_ToggleAutomated
				break
			;;
			7)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_EditSchedule
				fi
				PressEnter
				break
			;;
			8)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_ToggleOutputDataMode
				fi
				break
			;;
			9)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_ToggleOutputTimeMode
				fi
				break
			;;
			c)
				if Check_Lock "menu"; then
					Menu_CustomiseInterfaceList
				fi
				Menu_ProcessInterfaces
				PressEnter
				break
			;;
			r)
				if Check_Lock "menu"; then
					Menu_ProcessInterfaces "force"
				fi
				PressEnter
				break
			;;
			s)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_ToggleStorageLocation
				fi
				break
			;;
			u)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_Update
				fi
				PressEnter
				break
			;;
			uf)
				printf "\\n"
				if Check_Lock "menu"; then
					Menu_ForceUpdate
				fi
				PressEnter
				break
			;;
			e)
				ScriptHeader
				printf "\\n\\e[1mThanks for using %s!\\e[0m\\n\\n\\n" "$SCRIPT_NAME"
				exit 0
			;;
			z)
				while true; do
					printf "\\n\\e[1mAre you sure you want to uninstall %s? (y/n)\\e[0m\\n" "$SCRIPT_NAME"
					read -r "confirm"
					case "$confirm" in
						y|Y)
							Menu_Uninstall
							exit 0
						;;
						*)
							break
						;;
					esac
				done
			;;
			*)
				printf "\\nPlease choose a valid option\\n\\n"
			;;
		esac
	done
	
	ScriptHeader
	MainMenu
}

Check_Requirements(){
	CHECKSFAILED="false"
	
	if [ "$(nvram get jffs2_scripts)" -ne 1 ]; then
		nvram set jffs2_scripts=1
		nvram commit
		Print_Output "true" "Custom JFFS Scripts enabled" "$WARN"
	fi
	
	if ! Check_Swap; then
		Print_Output "true" "No Swap file detected!" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if [ ! -f "/opt/bin/opkg" ]; then
		Print_Output "true" "Entware not detected!" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if ! Firmware_Version_Check; then
		Print_Output "true" "Unsupported firmware version detected" "$ERR"
		Print_Output "true" "$SCRIPT_NAME requires Merlin 384.15/384.13_4 or Fork 43E5 (or later)" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if [ "$CHECKSFAILED" = "false" ]; then
		Print_Output "true" "Installing required packages from Entware" "$PASS"
		opkg update
		opkg install sqlite3-cli
		opkg install jq
		opkg install p7zip
		return 0
	else
		return 1
	fi
}

Menu_Install(){
	Print_Output "true" "Welcome to $SCRIPT_NAME $SCRIPT_VERSION, a script by JackYaz"
	sleep 1
	
	Print_Output "true" "Checking your router meets the requirements for $SCRIPT_NAME"
	
	if ! Check_Requirements; then
		Print_Output "true" "Requirements for $SCRIPT_NAME not met, please see above for the reason(s)" "$CRIT"
		PressEnter
		Clear_Lock
		rm -f "/jffs/scripts/$SCRIPT_NAME_LOWER" 2>/dev/null
		exit 1
	fi
	
	Create_Dirs
	Conf_Exists
	Set_Version_Custom_Settings "local"
	ScriptStorageLocation "load"
	Create_Symlinks
	
	Download_File "$SCRIPT_REPO/$ARCH.tar.gz" "$OOKLA_DIR/$ARCH.tar.gz"
	tar -xzf "$OOKLA_DIR/$ARCH.tar.gz" -C "$OOKLA_DIR"
	rm -f "$OOKLA_DIR/$ARCH.tar.gz"
	chmod 0755 "$OOKLA_DIR/speedtest"
	
	Update_File "spdstats_www.asp"
	Update_File "shared-jy.tar.gz"
	
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	
	License_Acceptance "accept"
	
	Clear_Lock
}

Menu_CustomiseInterfaceList(){
	Generate_Interface_List
	printf "\\n"
	Clear_Lock
}

Menu_ProcessInterfaces(){
	Create_Symlinks "$1"
	printf "\\n"
	Clear_Lock
}

Menu_Startup(){
	Create_Dirs
	Create_Symlinks
	Conf_Exists
	Set_Version_Custom_Settings "local"
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	License_Acceptance "load"
	Mount_WebUI
	Clear_Lock
}

Menu_GenerateStats(){
	Run_Speedtest "$1"
	Clear_Lock
}

Menu_TogglePreferred(){
	if PreferredServer check; then
		PreferredServer disable
	else
		PreferredServer enable
	fi
}

Menu_ToggleAutomated(){
	if AutomaticMode check; then
		AutomaticMode disable
	else
		AutomaticMode enable
	fi
}

Menu_ToggleOutputDataMode(){
	if [ "$(OutputDataMode "check")" = "raw" ]; then
		OutputDataMode "average"
	elif [ "$(OutputDataMode "check")" = "average" ]; then
		OutputDataMode "raw"
	fi
	Clear_Lock
}

Menu_ToggleOutputTimeMode(){
	if [ "$(OutputTimeMode "check")" = "unix" ]; then
		OutputTimeMode "non-unix"
	elif [ "$(OutputTimeMode "check")" = "non-unix" ]; then
		OutputTimeMode "unix"
	fi
	Clear_Lock
}

Menu_ToggleStorageLocation(){
	if [ "$(ScriptStorageLocation "check")" = "jffs" ]; then
		ScriptStorageLocation "usb"
	elif [ "$(ScriptStorageLocation "check")" = "usb" ]; then
		ScriptStorageLocation "jffs"
	fi
	Clear_Lock
}

Menu_EditSchedule(){
	exitmenu="false"
	starthour=""
	startminute=""
	ScriptHeader
	
	while true; do
		printf "\\n\\e[1mPlease enter a start hour (0-23):\\e[0m\\n"
		read -r "hour"
		
		if [ "$hour" = "e" ]; then
			exitmenu="exit"
			break
		elif ! Validate_Number "" "$hour" "silent"; then
			printf "\\n\\e[31mPlease enter a valid number (0-23)\\e[0m\\n"
		else
			if [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]; then
				printf "\\n\\e[31mPlease enter a number between 0 and 23\\e[0m\\n"
			else
				starthour="$hour"
				printf "\\n"
				break
			fi
		fi
	done
	
	if [ "$exitmenu" != "exit" ]; then
		while true; do
			printf "\\n\\e[1mPlease enter an end hour (0-23):\\e[0m\\n"
			read -r "hour"
			
			if [ "$hour" = "e" ]; then
				exitmenu="exit"
				break
			elif ! Validate_Number "" "$hour" "silent"; then
				printf "\\n\\e[31mPlease enter a valid number (0-23)\\e[0m\\n"
			else
				if [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]; then
					printf "\\n\\e[31mPlease enter a number between 0 and 23\\e[0m\\n"
				else
					endhour="$hour"
					printf "\\n"
					break
				fi
			fi
		done
	fi
	
	if [ "$exitmenu" != "exit" ]; then
		while true; do
			printf "\\n\\e[1mPlease enter the minute to run the test on (0-59):\\e[0m"
			printf "\\n\\e[1mN.B. the test will run at half hour intervals\\e[0m\\n"
			read -r "minute"
			
			if [ "$minute" = "e" ]; then
				exitmenu="exit"
				break
			elif ! Validate_Number "" "$minute" "silent"; then
				printf "\\n\\e[31mPlease enter a valid number (0-59)\\e[0m\\n"
			else
				if [ "$minute" -lt 0 ] || [ "$minute" -gt 59 ]; then
					printf "\\n\\e[31mPlease enter a number between 0 and 59\\e[0m\\n"
				else
					startminute="$minute"
					printf "\\n"
					break
				fi
			fi
		done
	fi
	
	if [ "$exitmenu" != "exit" ]; then
		TestSchedule "update" "$starthour" "$endhour" "$startminute"
	fi
	
	Clear_Lock
}

Menu_Update(){
	Update_Version
	Clear_Lock
}

Menu_ForceUpdate(){
	Update_Version "force"
	Clear_Lock
}

Menu_Uninstall(){
	Print_Output "true" "Removing $SCRIPT_NAME..." "$PASS"
	Auto_Startup delete 2>/dev/null
	Auto_Cron delete 2>/dev/null
	Auto_ServiceEvent delete 2>/dev/null
	
	Get_WebUI_Page "$SCRIPT_DIR/spdstats_www.asp"
	if [ -n "$MyPage" ] && [ "$MyPage" != "none" ] && [ -f "/tmp/menuTree.js" ]; then
		sed -i "\\~$MyPage~d" /tmp/menuTree.js
		umount /www/require/modules/menuTree.js
		mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
		rm -f "$SCRIPT_WEBPAGE_DIR/$MyPage"
	fi
	
	rm -f "$SCRIPT_DIR/spdstats_www.asp" 2>/dev/null
	
	while true; do
		printf "\\n\\e[1mDo you want to delete %s stats and config? (y/n)\\e[0m\\n" "$SCRIPT_NAME"
		read -r "confirm"
		case "$confirm" in
			y|Y)
				rm -rf "$SCRIPT_DIR" 2>/dev/null
				rm -rf "$SCRIPT_STORAGE_DIR" 2>/dev/null
				break
			;;
			*)
				break
			;;
		esac
	done
	Shortcut_spdMerlin delete
	
	rm -rf "$SCRIPT_WEB_DIR" 2>/dev/null
	rm -rf "$OOKLA_DIR" 2>/dev/null
	rm -rf "$OOKLA_LICENSE_DIR" 2>/dev/null
	rm -f "/jffs/scripts/$SCRIPT_NAME_LOWER" 2>/dev/null
	Clear_Lock
	Print_Output "true" "Uninstall completed" "$PASS"
}

NTP_Ready(){
	if [ "$1" = "service_event" ]; then
		if [ -n "$2" ] && [ "$(echo "$3" | grep -c "$SCRIPT_NAME_LOWER")" -eq 0 ]; then
			exit 0
		fi
	fi
	if [ "$(nvram get ntp_ready)" = "0" ]; then
		ntpwaitcount="0"
		while [ "$(nvram get ntp_ready)" = "0" ] && [ "$ntpwaitcount" -lt "300" ]; do
			Check_Lock
			ntpwaitcount="$((ntpwaitcount + 1))"
			if [ "$ntpwaitcount" = "60" ]; then
				Print_Output "true" "Waiting for NTP to sync..." "$WARN"
			fi
			sleep 1
		done
		if [ "$ntpwaitcount" -ge "300" ]; then
			Print_Output "true" "NTP failed to sync after 5 minutes. Please resolve!" "$CRIT"
			Clear_Lock
			exit 1
		else
			Print_Output "true" "NTP synced, $SCRIPT_NAME will now continue" "$PASS"
			Clear_Lock
		fi
	fi
}

### function based on @Adamm00's Skynet USB wait function ###
Entware_Ready(){
	if [ "$1" = "service_event" ]; then
		if [ -n "$2" ] && [ "$(echo "$3" | grep -c "$SCRIPT_NAME_LOWER")" -eq 0 ]; then
			exit 0
		fi
	fi
		
	if [ ! -f "/opt/bin/opkg" ] && ! echo "$@" | grep -wqE "(install|uninstall|update|forceupdate)"; then
		Check_Lock
		sleepcount=1
		while [ ! -f "/opt/bin/opkg" ] && [ "$sleepcount" -le 10 ]; do
			Print_Output "true" "Entware not found, sleeping for 10s (attempt $sleepcount of 10)" "$ERR"
			sleepcount="$((sleepcount + 1))"
			sleep 10
		done
		if [ ! -f "/opt/bin/opkg" ]; then
			Print_Output "true" "Entware not found and is required for $SCRIPT_NAME to run, please resolve" "$CRIT"
			Clear_Lock
			exit 1
		else
			Print_Output "true" "Entware found, $SCRIPT_NAME will now continue" "$PASS"
			Clear_Lock
		fi
	fi
}
### ###

NTP_Ready "$@"
Entware_Ready "$@"

if [ -f "/opt/share/$SCRIPT_NAME_LOWER.d/config" ]; then
	SCRIPT_CONF="/opt/share/$SCRIPT_NAME_LOWER.d/config"
	SCRIPT_STORAGE_DIR="/opt/share/$SCRIPT_NAME_LOWER.d"
else
	SCRIPT_CONF="/jffs/addons/$SCRIPT_NAME_LOWER.d/config"
	SCRIPT_STORAGE_DIR="/jffs/addons/$SCRIPT_NAME_LOWER.d"
fi

SCRIPT_INTERFACES="$SCRIPT_STORAGE_DIR/.interfaces"
SCRIPT_INTERFACES_USER="$SCRIPT_STORAGE_DIR/.interfaces_user"
CSV_OUTPUT_DIR="$SCRIPT_STORAGE_DIR/csv"

if [ -z "$1" ]; then
	if [ ! -f /opt/bin/sqlite3 ]; then
		Print_Output "true" "Installing required version of sqlite3 from Entware" "$PASS"
		opkg update
		opkg install sqlite3-cli
	fi
	rm -f "spdstatsdata.js" 2>/dev/null
	rm -f "spdstatstext.js" 2>/dev/null
	rm -f "spdlastx.js" 2>/dev/null
	
	Create_Dirs
	Process_Upgrade
	Conf_Exists
	Set_Version_Custom_Settings "local"
	ScriptStorageLocation "load"
	Create_Symlinks
	
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	License_Acceptance "load"
	ScriptHeader
	MainMenu
	exit 0
fi

case "$1" in
	install)
		Check_Lock
		Menu_Install
		exit 0
	;;
	startup)
		Check_Lock
		Menu_Startup
		exit 0
	;;
	generate)
		Check_Lock
		Menu_GenerateStats "schedule"
		exit 0
	;;
	service_event)
		if [ "$2" = "start" ] && [ "$3" = "$SCRIPT_NAME_LOWER" ]; then
			Check_Lock
			Menu_GenerateStats "webui"
			exit 0
		elif [ "$2" = "start" ] && [ "$3" = "$SCRIPT_NAME_LOWER""checkupdate" ]; then
			Check_Lock
			updatecheckresult="$(Update_Check)"
			Clear_Lock
			exit 0
		elif [ "$2" = "start" ] && [ "$3" = "$SCRIPT_NAME_LOWER""doupdate" ]; then
			Check_Lock
			Update_Version "force" "unattended"
			Clear_Lock
			exit 0
		fi
		exit 0
	;;
	outputcsv)
		Check_Lock
		Generate_CSVs
		Clear_Lock
		exit 0
	;;
	automatic)
		Check_Lock
		Menu_ToggleAutomated
		Clear_Lock
		exit 0
	;;
	update)
		Check_Lock
		Update_Version "unattended"
		Clear_Lock
		exit 0
	;;
	forceupdate)
		Check_Lock
		Update_Version "force" "unattended"
		Clear_Lock
		exit 0
	;;
	setversion)
		Check_Lock
		Set_Version_Custom_Settings "local"
		Set_Version_Custom_Settings "server" "$SCRIPT_VERSION"
		Clear_Lock
	;;
	checkupdate)
		Check_Lock
		updatecheckresult="$(Update_Check)"
		Clear_Lock
		exit 0
	;;
	uninstall)
		Check_Lock
		Menu_Uninstall
		exit 0
	;;
	develop)
		Check_Lock
		sed -i 's/^readonly SCRIPT_BRANCH.*$/readonly SCRIPT_BRANCH="develop"/' "/jffs/scripts/$SCRIPT_NAME_LOWER"
		Clear_Lock
		exec "$0" "update"
		exit 0
	;;
	stable)
		Check_Lock
		sed -i 's/^readonly SCRIPT_BRANCH.*$/readonly SCRIPT_BRANCH="master"/' "/jffs/scripts/$SCRIPT_NAME_LOWER"
		Clear_Lock
		exec "$0" "update"
		exit 0
	;;
	*)
		Check_Lock
		echo "Command not recognised, please try again"
		Clear_Lock
		exit 1
	;;
esac
