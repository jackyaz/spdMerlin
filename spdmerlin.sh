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
readonly SCRIPT_VERSION="v3.2.1"
#shellcheck disable=SC2034
readonly SPD_VERSION="v3.2.1"
readonly SCRIPT_BRANCH="master"
readonly SCRIPT_REPO="https://raw.githubusercontent.com/jackyaz/spdMerlin/""$SCRIPT_BRANCH"
readonly OLD_SCRIPT_DIR="/jffs/scripts/$SCRIPT_NAME_LOWER.d"
readonly SCRIPT_DIR="/jffs/addons/$SCRIPT_NAME_LOWER.d"
readonly OLD_SCRIPT_CONF="/jffs/configs/$SCRIPT_NAME_LOWER.config"
readonly SCRIPT_CONF="$SCRIPT_DIR/config"
readonly SCRIPT_PAGE_DIR="$(readlink /www/user)"
readonly SCRIPT_WEB_DIR="$SCRIPT_PAGE_DIR/$SCRIPT_NAME_LOWER"
readonly OLD_SHARED_DIR="/jffs/scripts/shared-jy"
readonly SHARED_DIR="/jffs/addons/shared-jy"
readonly SHARED_REPO="https://raw.githubusercontent.com/jackyaz/shared-jy/master"
readonly SHARED_WEB_DIR="$SCRIPT_PAGE_DIR/shared-jy"
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
	if [ "$1" = "install" ]; then
		if [ "$(uname -o)" = "ASUSWRT-Merlin" ] && [ "$(nvram get buildno | tr -d '.')" -ge "38400" ]; then
			return 0
		else
			return 1
		fi
	elif [ "$1" = "webui" ]; then
		if nvram get rc_support | grep -qF "am_addons"; then
			return 0
		else
			return 1
		fi
	fi
}

### Code for these functions inspired by https://github.com/Adamm00 - credit to @Adamm ###
Check_Lock(){
	if [ -f "/tmp/$SCRIPT_NAME.lock" ]; then
		ageoflock=$(($(date +%s) - $(date +%s -r /tmp/$SCRIPT_NAME.lock)))
		if [ "$ageoflock" -gt 120 ]; then
			Print_Output "true" "Stale lock file found (>120 seconds old) - purging lock" "$ERR"
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

Update_Version(){
	if [ -z "$1" ]; then
		doupdate="false"
		localver=$(grep "SCRIPT_VERSION=" /jffs/scripts/"$SCRIPT_NAME_LOWER" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | grep -qF "jackyaz" || { Print_Output "true" "404 error detected - stopping update" "$ERR"; return 1; }
		serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		if [ "$localver" != "$serverver" ]; then
			doupdate="version"
		else
			localmd5="$(md5sum "/jffs/scripts/$SCRIPT_NAME_LOWER" | awk '{print $1}')"
			remotemd5="$(curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | md5sum | awk '{print $1}')"
			if [ "$localmd5" != "$remotemd5" ]; then
				doupdate="md5"
			fi
		fi
		
		if [ "$doupdate" = "version" ]; then
			Print_Output "true" "New version of $SCRIPT_NAME available - updating to $serverver" "$PASS"
		elif [ "$doupdate" = "md5" ]; then
			Print_Output "true" "MD5 hash of $SCRIPT_NAME does not match - downloading updated $serverver" "$PASS"
		fi
		
		Update_File "$ARCH.tar.gz"
		Update_File "spdstats_www.asp"
		Update_File "chart.js"
		Update_File "chartjs-plugin-zoom.js"
		Update_File "chartjs-plugin-annotation.js"
		Update_File "chartjs-plugin-datasource.js"
		Update_File "hammerjs.js"
		Update_File "moment.js"
		
		if [ "$doupdate" != "false" ]; then
			/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" -o "/jffs/scripts/$SCRIPT_NAME_LOWER" && Print_Output "true" "$SCRIPT_NAME successfully updated"
			chmod 0755 /jffs/scripts/"$SCRIPT_NAME_LOWER"
			Clear_Lock
			exit 0
		else
			Print_Output "true" "No new version - latest is $localver" "$WARN"
			Clear_Lock
		fi
	fi
	
	case "$1" in
		force)
			serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
			Print_Output "true" "Downloading latest version ($serverver) of $SCRIPT_NAME" "$PASS"
			Update_File "$ARCH.tar.gz"
			Update_File "spdstats_www.asp"
			Update_File "chart.js"
			Update_File "chartjs-plugin-zoom.js"
			Update_File "chartjs-plugin-annotation.js"
			Update_File "chartjs-plugin-datasource.js"
			Update_File "hammerjs.js"
			Update_File "moment.js"
			/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" -o "/jffs/scripts/$SCRIPT_NAME_LOWER" && Print_Output "true" "$SCRIPT_NAME successfully updated"
			chmod 0755 /jffs/scripts/"$SCRIPT_NAME_LOWER"
			Clear_Lock
			exit 0
		;;
	esac
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
			Print_Output "true" "New version of $1 downloaded" "$PASS"
			Download_File "$SCRIPT_REPO/$1" "$SCRIPT_DIR/$1"
			Mount_WebUI
		fi
		rm -f "$tmpfile"
	elif [ "$1" = "chart.js" ] || [ "$1" = "chartjs-plugin-zoom.js" ] || [ "$1" = "chartjs-plugin-annotation.js" ] || [ "$1" = "moment.js" ] || [ "$1" =  "hammerjs.js" ] || [ "$1" = "chartjs-plugin-datasource.js" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SHARED_REPO/$1" "$tmpfile"
		if [ ! -f "$SHARED_DIR/$1" ]; then
			touch "$SHARED_DIR/$1"
		fi
		if ! diff -q "$tmpfile" "$SHARED_DIR/$1" >/dev/null 2>&1; then
			Print_Output "true" "New version of $1 downloaded" "$PASS"
			Download_File "$SHARED_REPO/$1" "$SHARED_DIR/$1"
		fi
		rm -f "$tmpfile"
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
	
	if [ -d "$OLD_SCRIPT_DIR" ]; then
		mv "$OLD_SCRIPT_DIR" "$(dirname "$SCRIPT_DIR")"
		rm -rf "$OLD_SCRIPT_DIR"
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
	
	if [ -d "$OLD_SHARED_DIR" ]; then
		mv "$OLD_SHARED_DIR" "$(dirname "$SHARED_DIR")"
		rm -rf "$OLD_SHARED_DIR"
	fi
	
	if [ ! -d "$SCRIPT_PAGE_DIR" ]; then
		mkdir -p "$SCRIPT_PAGE_DIR"
	fi
		
	if [ ! -d "$SCRIPT_WEB_DIR" ]; then
		mkdir -p "$SCRIPT_WEB_DIR"
	fi
	
	if [ ! -d "$SHARED_WEB_DIR" ]; then
		mkdir -p "$SHARED_WEB_DIR"
	fi
}

Create_Symlinks(){
	printf "WAN\\n" > "$SCRIPT_DIR/.interfaces"
	
	for index in 1 2 3 4 5; do
		comment=""
		if ! ifconfig "tun1$index" > /dev/null 2>&1 ; then
			comment=" #excluded - interface not up#"
		fi
		if [ "$index" -lt 5 ]; then
			printf "VPNC%s%s\\n" "$index" "$comment" >> "$SCRIPT_DIR/.interfaces"
		else
			printf "VPNC%s%s\\n" "$index" "$comment" >> "$SCRIPT_DIR/.interfaces"
		fi
	done
	
	if [ "$1" = "force" ]; then
		rm -f "$SCRIPT_DIR/.interfaces_user"
	fi
	
	if [ ! -f "$SCRIPT_DIR/.interfaces_user" ]; then
		touch "$SCRIPT_DIR/.interfaces_user"
	fi
	
	while IFS='' read -r line || [ -n "$line" ]; do
		if [ "$(grep -c "$(echo "$line" | cut -f1 -d"#" | sed 's/ *$//')" "$SCRIPT_DIR/.interfaces_user")" -eq 0 ]; then
			printf "%s\\n" "$line" >> "$SCRIPT_DIR/.interfaces_user"
		fi
	done < "$SCRIPT_DIR/.interfaces"
	
	interfacecount="$(wc -l < "$SCRIPT_DIR/.interfaces_user")"
	COUNTER=1
	until [ $COUNTER -gt "$interfacecount" ]; do
		Set_Interface_State "$COUNTER"
		COUNTER=$((COUNTER + 1))
	done
	
	rm -f "$SCRIPT_WEB_DIR/"* 2>/dev/null
	rm -f "$SHARED_WEB_DIR/"* 2>/dev/null
	
	ln -s "$SCRIPT_DIR/.interfaces_user"  "$SCRIPT_WEB_DIR/interfaces.htm" 2>/dev/null
	
	ln -s "$SCRIPT_DIR/spdstatsdata.js" "$SCRIPT_WEB_DIR/spdstatsdata.js" 2>/dev/null
	ln -s "$SCRIPT_DIR/spdlastx.js" "$SCRIPT_WEB_DIR/spdlastx.js" 2>/dev/null
	ln -s "$SCRIPT_DIR/spdstatstext.js" "$SCRIPT_WEB_DIR/spdstatstext.js" 2>/dev/null
	
	ln -s "$SHARED_DIR/chart.js" "$SHARED_WEB_DIR/chart.js" 2>/dev/null
	ln -s "$SHARED_DIR/chartjs-plugin-zoom.js" "$SHARED_WEB_DIR/chartjs-plugin-zoom.js" 2>/dev/null
	ln -s "$SHARED_DIR/chartjs-plugin-annotation.js" "$SHARED_WEB_DIR/chartjs-plugin-annotation.js" 2>/dev/null
	ln -s "$SHARED_DIR/chartjs-plugin-datasource.js" "$SHARED_WEB_DIR/chartjs-plugin-datasource.js" 2>/dev/null
	ln -s "$SHARED_DIR/hammerjs.js" "$SHARED_WEB_DIR/hammerjs.js" 2>/dev/null
	ln -s "$SHARED_DIR/moment.js" "$SHARED_WEB_DIR/moment.js" 2>/dev/null
}

Conf_Exists(){
	if [ -f "$OLD_SCRIPT_CONF" ]; then
		mv "$OLD_SCRIPT_CONF" "$SCRIPT_CONF"
	fi
	
	if [ -f "$SCRIPT_CONF" ]; then
		dos2unix "$SCRIPT_CONF"
		chmod 0644 "$SCRIPT_CONF"
		sed -i -e 's/"//g' "$SCRIPT_CONF"
		if [ "$(wc -l < "$SCRIPT_CONF")" -eq 6 ]; then
			{ echo "MINUTE=*"; } >> "$SCRIPT_CONF"
		fi
		return 0
	else
		{ echo "PREFERREDSERVER=0|None configured"; echo "USEPREFERRED=false"; echo "USESINGLE=false"; echo "AUTOMATED=true" ; echo "SCHEDULESTART=*" ; echo "SCHEDULEEND=*"; echo "MINUTE=*"; } >> "$SCRIPT_CONF"
		return 1
	fi
}

Auto_ServiceEvent(){
	case $1 in
		create)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/service-event)
				# shellcheck disable=SC2016
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME_LOWER generate"' "$1" "$2" &'' # '"$SCRIPT_NAME" /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/service-event
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					# shellcheck disable=SC2016
					echo "/jffs/scripts/$SCRIPT_NAME_LOWER generate"' "$1" "$2" &'' # '"$SCRIPT_NAME" >> /jffs/scripts/service-event
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/service-event
				echo "" >> /jffs/scripts/service-event
				# shellcheck disable=SC2016
				echo "/jffs/scripts/$SCRIPT_NAME_LOWER generate"' "$1" "$2" &'' # '"$SCRIPT_NAME" >> /jffs/scripts/service-event
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
			if [ "$(nvram get wan0_proto)" = "pppoe" ] || [ "$(nvram get wan0_proto)" = "pptp" ] || [ "$(nvram get wan0_proto)" = "l2tp" ]; then
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
	interfaceline="$(sed "$1!d" "$SCRIPT_DIR/.interfaces_user" | awk '{$1=$1};1')"
	if echo "$interfaceline" | grep -q "VPN" ; then
		if echo "$interfaceline" | grep -q "#excluded" ; then
			if ! ifconfig "$(Get_Interface_From_Name "$(echo "$interfaceline" | cut -f1 -d"#" | sed 's/ *$//')")" > /dev/null 2>&1 ; then
				sed -i "$1"'s/ #excluded#/ #excluded - interface not up#/' "$SCRIPT_DIR/.interfaces_user"
			else
				sed -i "$1"'s/ #excluded - interface not up#/ #excluded#/' "$SCRIPT_DIR/.interfaces_user"
			fi
		fi
	fi
}

Generate_Interface_List(){
	ScriptHeader
	goback="false"
	printf "Retrieving list of interfaces...\\n\\n"
	interfacecount="$(wc -l < "$SCRIPT_DIR/.interfaces_user")"
	COUNTER=1
	until [ $COUNTER -gt "$interfacecount" ]; do
		Set_Interface_State "$COUNTER"
		interfaceline="$(sed "$COUNTER!d" "$SCRIPT_DIR/.interfaces_user" | awk '{$1=$1};1')"
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
			interfaceline="$(sed "$interface!d" "$SCRIPT_DIR/.interfaces_user" | awk '{$1=$1};1')"
			if echo "$interfaceline" | grep -q "#excluded" ; then
				if ! ifconfig "$(Get_Interface_From_Name "$(echo "$interfaceline" | cut -f1 -d"#" | sed 's/ *$//')")" > /dev/null 2>&1 ; then
					sed -i "$interface"'s/ #excluded#/ #excluded - interface not up#/' "$SCRIPT_DIR/.interfaces_user"
				else
					sed -i "$interface"'s/ #excluded - interface not up#//' "$SCRIPT_DIR/.interfaces_user"
					sed -i "$interface"'s/ #excluded#//' "$SCRIPT_DIR/.interfaces_user"
				fi
			else
				if ! ifconfig "$(Get_Interface_From_Name "$(echo "$interfaceline" | cut -f1 -d"#" | sed 's/ *$//')")" > /dev/null 2>&1 ; then
					sed -i "$interface"'s/$/ #excluded - interface not up#/' "$SCRIPT_DIR/.interfaces_user"
				else
					sed -i "$interface"'s/$/ #excluded#/' "$SCRIPT_DIR/.interfaces_user"
				fi
			fi
			
			sed -i 's/ *$//' "$SCRIPT_DIR/.interfaces_user"
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
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME_LOWER startup"' # '"$SCRIPT_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo "/jffs/scripts/$SCRIPT_NAME_LOWER startup"' # '"$SCRIPT_NAME" >> /jffs/scripts/services-start
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/services-start
				echo "" >> /jffs/scripts/services-start
				echo "/jffs/scripts/$SCRIPT_NAME_LOWER startup"' # '"$SCRIPT_NAME" >> /jffs/scripts/services-start
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

Get_spdMerlin_UI(){
	if [ -f /www/AdaptiveQoS_ROG.asp ]; then
		echo "AdaptiveQoS_ROG.asp"
	else
		echo "AiMesh_Node_FirmwareUpgrade.asp"
	fi
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
	if Firmware_Version_Check "webui"; then
		Get_WebUI_Page "$SCRIPT_DIR/spdstats_www.asp"
		if [ "$MyPage" = "none" ]; then
			Print_Output "true" "Unable to mount $SCRIPT_NAME WebUI page, exiting" "$CRIT"
			exit 1
		fi
		Print_Output "true" "Mounting $SCRIPT_NAME WebUI page as $MyPage" "$PASS"
		cp -f "$SCRIPT_DIR/spdstats_www.asp" "$SCRIPT_PAGE_DIR/$MyPage"
		
		if [ ! -f "/tmp/menuTree.js" ]; then
			cp -f "/www/require/modules/menuTree.js" "/tmp/"
		fi
		
		sed -i "\\~$MyPage~d" /tmp/menuTree.js
		sed -i "/url: \"Tools_OtherSettings.asp\", tabName:/a {url: \"$MyPage\", tabName: \"SpeedTest\"}," /tmp/menuTree.js
		umount /www/require/modules/menuTree.js 2>/dev/null
		mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
	else
		Mount_SPD_WebUI_Old
		Modify_WebUI_File
	fi
}

Mount_SPD_WebUI_Old(){
		umount /www/AiMesh_Node_FirmwareUpgrade.asp 2>/dev/null
		umount /www/AdaptiveQoS_ROG.asp 2>/dev/null
		
		if [ ! -f "$SCRIPT_DIR/spdstats_www.asp" ]; then
			Download_File "$SCRIPT_REPO/spdstats_www.asp" "$SCRIPT_DIR/spdstats_www.asp"
		fi
		
		mount -o bind "$SCRIPT_DIR/spdstats_www.asp" /www/"$(Get_spdMerlin_UI)"
}

Modify_WebUI_File(){
	### menuTree.js ###
	umount /www/require/modules/menuTree.js 2>/dev/null
	tmpfile=/tmp/menuTree.js
	cp "/www/require/modules/menuTree.js" "$tmpfile"
	
	if [ -f "/jffs/scripts/uiDivStats" ]; then
		sed -i '/{url: "Advanced_MultiSubnet_Content.asp", tabName: /d' "$tmpfile"
		sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "Advanced_MultiSubnet_Content.asp", tabName: "Diversion Statistics"},' "$tmpfile"
		sed -i '/retArray.push("Advanced_MultiSubnet_Content.asp");/d' "$tmpfile"
	fi
	
	sed -i '/{url: "'"$(Get_spdMerlin_UI)"'", tabName: /d' "$tmpfile"
	sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "'"$(Get_spdMerlin_UI)"'", tabName: "SpeedTest"},' "$tmpfile"
	sed -i '/retArray.push("'"$(Get_spdMerlin_UI)"'");/d' "$tmpfile"
	
	if [ -f "/jffs/scripts/connmon" ]; then
		sed -i '/{url: "Advanced_Feedback.asp", tabName: /d' "$tmpfile"
		sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "Advanced_Feedback.asp", tabName: "Uptime Monitoring"},' "$tmpfile"
		sed -i '/retArray.push("Advanced_Feedback.asp");/d' "$tmpfile"
	fi
	
	if [ -f "/jffs/scripts/ntpmerlin" ]; then
		sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "Feedback_Info.asp", tabName: "NTP Daemon"},' "$tmpfile"
	fi
	
	if [ -f /jffs/scripts/custom_menuTree.js ]; then
		mv /jffs/scripts/custom_menuTree.js "$SHARED_DIR/custom_menuTree.js"
	fi
	
	if [ ! -f "$SHARED_DIR/custom_menuTree.js" ]; then
		cp "$tmpfile" "$SHARED_DIR/custom_menuTree.js"
	fi
	
	if ! diff -q "$tmpfile" "$SHARED_DIR/custom_menuTree.js" >/dev/null 2>&1; then
		cp "$tmpfile" "$SHARED_DIR/custom_menuTree.js"
	fi
	
	rm -f "$tmpfile"
	
	mount -o bind "$SHARED_DIR/custom_menuTree.js" "/www/require/modules/menuTree.js"
	### ###
	
	### state.js ###
	umount /www/state.js 2>/dev/null
	tmpfile=/tmp/state.js
	cp "/www/state.js" "$tmpfile"
	sed -i -e '/else if(location.pathname == "\/Advanced_Feedback.asp") {/,+4d' "$tmpfile"
	
	if [ -f /jffs/scripts/custom_state.js ]; then
		mv /jffs/scripts/custom_state.js "$SHARED_DIR/custom_state.js"
	fi
	
	if [ ! -f "$SHARED_DIR/custom_state.js" ]; then
		cp "$tmpfile" "$SHARED_DIR/custom_state.js"
	fi
	
	if ! diff -q "$tmpfile" "$SHARED_DIR/custom_state.js" >/dev/null 2>&1; then
		cp "$tmpfile" "$SHARED_DIR/custom_state.js"
	fi
	
	rm -f "$tmpfile"
	
	mount -o bind "$SHARED_DIR/custom_state.js" /www/state.js
	### ###
	
	### start_apply.htm ###
	umount /www/start_apply.htm 2>/dev/null
	tmpfile=/tmp/start_apply.htm
	cp "/www/start_apply.htm" "$tmpfile"
	
	if [ -f "/jffs/scripts/uiDivStats" ]; then
		sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("Advanced_MultiSubnet_Content.asp") != -1){'"\\r\\n"'setTimeout(getXMLAndRedirect, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	fi
	
	if [ -f /jffs/scripts/connmon ]; then
		sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("Advanced_Feedback.asp") != -1){'"\\r\\n"'setTimeout(getXMLAndRedirect, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	fi
	
	if [ -f /jffs/scripts/ntpmerlin ]; then
		sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("Feedback_Info.asp") != -1){'"\\r\\n"'setTimeout(getXMLAndRedirect, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	fi
	
	sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("'"$(Get_spdMerlin_UI)"'") != -1){'"\\r\\n"'setTimeout(getXMLAndRedirect, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	
	if [ -f /jffs/scripts/custom_start_apply.htm ]; then
		mv /jffs/scripts/custom_start_apply.htm "$SHARED_DIR/custom_start_apply.htm"
	fi
	
	if [ ! -f "$SHARED_DIR/custom_start_apply.htm" ]; then
		cp "/www/start_apply.htm" "$SHARED_DIR/custom_start_apply.htm"
	fi
	
	if ! diff -q "$tmpfile" "$SHARED_DIR/custom_start_apply.htm" >/dev/null 2>&1; then
		cp "$tmpfile" "$SHARED_DIR/custom_start_apply.htm"
	fi
	
	rm -f "$tmpfile"
	
	mount -o bind "$SHARED_DIR/custom_start_apply.htm" /www/start_apply.htm
	### ###
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
		read -r "server"
		
		if [ "$server" = "e" ]; then
			serverno="exit"
			break
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

WriteData_ToJS(){
	inputfile="$1"
	outputfile="$2"
	shift;shift
	
	for var in "$@"; do
	{
		echo "var $var;"
		echo "$var = [];"; } >> "$outputfile"
		contents="$var"'.unshift('
		while IFS='' read -r line || [ -n "$line" ]; do
			if echo "$line" | grep -q "NaN"; then continue; fi
			datapoint="{ x: moment.unix(""$(echo "$line" | awk 'BEGIN{FS=","}{ print $1 }' | awk '{$1=$1};1')""), y: ""$(echo "$line" | awk 'BEGIN{FS=","}{ print $2 }' | awk '{$1=$1};1')"" }"
			contents="$contents""$datapoint"","
		done < "$inputfile"
		contents=$(echo "$contents" | sed 's/,$//')
		contents="$contents"");"
		printf "%s\\r\\n\\r\\n" "$contents" >> "$outputfile"
	done
}

WriteStats_ToJS(){
	echo "function $3(){" > "$2"
	html='document.getElementById("'"$4"'").innerHTML="'
	while IFS='' read -r line || [ -n "$line" ]; do
		html="$html""$line""\\r\\n"
	done < "$1"
	html="$html"'"'
	printf "%s\\r\\n}\\r\\n" "$html" >> "$2"
}

#$1 fieldname $2 tablename $3 frequency (hours) $4 length (days) $5 outputfile $6 sqlfile
WriteSql_ToFile(){
	{
		echo ".mode csv"
		echo ".output $5"
	} >> "$6"
	COUNTER=0
	timenow="$(date '+%s')"
	until [ $COUNTER -gt "$((24*$4/$3))" ]; do
		echo "select $timenow - ((60*60*$3)*($COUNTER)),IFNULL(avg([$1]),'NaN') from $2 WHERE ([Timestamp] >= $timenow - ((60*60*$3)*($COUNTER+1))) AND ([Timestamp] <= $timenow - ((60*60*$3)*$COUNTER));" >> "$6"
		COUNTER=$((COUNTER + 1))
	done
}

#$1 iface name
Generate_LastXResults(){
	{
		echo ".mode csv"
		echo ".output /tmp/spd-lastx.csv"
	} > /tmp/spd-lastx.sql
	echo "select[Timestamp],[Download],[Upload] from spdstats_$1 order by [Timestamp] desc limit 10;" >> /tmp/spd-lastx.sql
	"$SQLITE3_PATH" "$SCRIPT_DIR/spdstats.db" < /tmp/spd-lastx.sql
	sed -i 's/,/ /g' "/tmp/spd-lastx.csv"
	WritePlainData_ToJS "/tmp/spd-lastx.csv" "$SCRIPT_DIR/spdlastx.js" "DataTimestamp_$1" "DataDownload_$1" "DataUpload_$1"
	rm -f /tmp/spd-lastx.sql
}

Generate_SPDStats(){
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	Create_Dirs
	Create_Symlinks
	Conf_Exists
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
		done < "$SCRIPT_DIR/.interfaces_user"
		
		IFACELIST="$(echo "$IFACELIST" | cut -c2-)"
		
		if [ "$IFACELIST" != "" ]; then
			rm -f "$SCRIPT_DIR/spdstatsdata.js"
			rm -f "$SCRIPT_DIR/spdlastx.js"
			
			for IFACE_NAME in $IFACELIST; do
				
				IFACE="$(Get_Interface_From_Name "$IFACE_NAME")"
				
				if ! ifconfig "$IFACE" > /dev/null 2>&1 ; then
					Print_Output "true" "$IFACE not up, please check. Skipping speedtest for $IFACE_NAME" "$WARN"
					continue
				else
					if [ "$mode" = "auto" ]; then
						Print_Output "true" "Starting speedtest using auto-selected server for $IFACE_NAME interface" "$PASS"
						"$OOKLA_DIR"/speedtest --interface="$IFACE" --format="human-readable" --unit="Mbps" --progress="yes" --accept-license --accept-gdpr | tee "$tmpfile"
					else
						if [ "$mode" != "onetime" ]; then
							if ! PreferredServer validate; then
								Print_Output "true" "Preferred server no longer valid, please choose another" "$ERR"
								Clear_Lock
								return 1
							fi
						fi
						
						if [ "$IFACE_NAME" = "WAN" ]; then
							Print_Output "true" "Starting speedtest using $speedtestservername for $IFACE_NAME interface" "$PASS"
							"$OOKLA_DIR"/speedtest --interface="$IFACE" --server-id="$speedtestserverno" --format="human-readable" --unit="Mbps" --progress="yes" --accept-license --accept-gdpr | tee "$tmpfile"
						else
							Print_Output "true" "Starting speedtest using using auto-selected server for $IFACE_NAME interface" "$PASS"
							"$OOKLA_DIR"/speedtest --interface="$IFACE" --format="human-readable" --unit="Mbps" --progress="yes" --accept-license --accept-gdpr | tee "$tmpfile"
						fi
					fi
					
					TZ=$(cat /etc/TZ)
					export TZ
					
					download=$(grep Download "$tmpfile" | awk 'BEGIN { FS = "\r" } ;{print $NF};' | awk 'BEGIN{FS=" "}{print $2}')
					upload=$(grep Upload "$tmpfile" | awk 'BEGIN { FS = "\r" } ;{print $NF};' | awk 'BEGIN{FS=" "}{print $2}')
					
					{
					echo "DROP TABLE IF EXISTS [spdstats];"
					echo "CREATE TABLE IF NOT EXISTS [spdstats_$IFACE_NAME] ([StatID] INTEGER PRIMARY KEY NOT NULL, [Timestamp] NUMERIC NOT NULL, [Download] REAL NOT NULL,[Upload] REAL NOT NULL);"
					echo "INSERT INTO spdstats_$IFACE_NAME ([Timestamp],[Download],[Upload]) values($(date '+%s'),$download,$upload);"
					} > /tmp/spd-stats.sql

					"$SQLITE3_PATH" "$SCRIPT_DIR/spdstats.db" < /tmp/spd-stats.sql
					
					{
						echo ".mode csv"
						echo ".output /tmp/spd-downloaddaily.csv"
						echo "select [Timestamp],[Download] from spdstats_$IFACE_NAME WHERE [Timestamp] >= (strftime('%s','now') - 86400);"
						echo ".output /tmp/spd-uploaddaily.csv"
						echo "select [Timestamp],[Upload] from spdstats_$IFACE_NAME WHERE [Timestamp] >= (strftime('%s','now') - 86400);"
					} > /tmp/spd-stats.sql
					
					"$SQLITE3_PATH" "$SCRIPT_DIR/spdstats.db" < /tmp/spd-stats.sql
					
					rm -f /tmp/spd-stats.sql
					
					WriteSql_ToFile "Download" "spdstats_$IFACE_NAME" 1 7 "/tmp/spd-downloadweekly.csv" "/tmp/spd-stats.sql"
					WriteSql_ToFile "Upload" "spdstats_$IFACE_NAME" 1 7 "/tmp/spd-uploadweekly.csv" "/tmp/spd-stats.sql"
					WriteSql_ToFile "Download" "spdstats_$IFACE_NAME" 3 30 "/tmp/spd-downloadmonthly.csv" "/tmp/spd-stats.sql"
					WriteSql_ToFile "Upload" "spdstats_$IFACE_NAME" 3 30 "/tmp/spd-uploadmonthly.csv" "/tmp/spd-stats.sql"
					
					"$SQLITE3_PATH" "$SCRIPT_DIR/spdstats.db" < /tmp/spd-stats.sql
					
					WriteData_ToJS "/tmp/spd-downloaddaily.csv" "$SCRIPT_DIR/spdstatsdata.js" "DataDownloadDaily_$IFACE_NAME"
					WriteData_ToJS "/tmp/spd-uploaddaily.csv" "$SCRIPT_DIR/spdstatsdata.js" "DataUploadDaily_$IFACE_NAME"
					
					WriteData_ToJS "/tmp/spd-downloadweekly.csv" "$SCRIPT_DIR/spdstatsdata.js" "DataDownloadWeekly_$IFACE_NAME"
					WriteData_ToJS "/tmp/spd-uploadweekly.csv" "$SCRIPT_DIR/spdstatsdata.js" "DataUploadWeekly_$IFACE_NAME"
					
					WriteData_ToJS "/tmp/spd-downloadmonthly.csv" "$SCRIPT_DIR/spdstatsdata.js" "DataDownloadMonthly_$IFACE_NAME"
					WriteData_ToJS "/tmp/spd-uploadmonthly.csv" "$SCRIPT_DIR/spdstatsdata.js" "DataUploadMonthly_$IFACE_NAME"
					
					Generate_LastXResults "$IFACE_NAME"
					
					spdtestresult="$(grep Download "$tmpfile" | awk 'BEGIN { FS = "\r" } ;{print $NF};'| awk '{$1=$1};1') - $(grep Upload "$tmpfile" | awk 'BEGIN { FS = "\r" } ;{print $NF};'| awk '{$1=$1};1')"
					
					printf "\\n"
					Print_Output "true" "Speedtest results - $spdtestresult" "$PASS"
					
					rm -f "$tmpfile"
					rm -f "/tmp/spd-"*".csv"
					rm -f "/tmp/spd-stats.sql"
					
					echo "Internet Speedtest generated on $(date +"%c")" > "/tmp/spdstatstitle.txt"
					WriteStats_ToJS "/tmp/spdstatstitle.txt" "$SCRIPT_DIR/spdstatstext.js" "SetSPDStatsTitle" "statstitle"
					
					rm -f "/tmp/spdstatstitle.txt"
				fi
			done
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
	printf "c.    Customise list of interfaces for automatic speedtests\\n\\n"
	printf "r.    Reset list of interfaces for automatic speedtests to default\\n\\n"
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
	
	if ! Firmware_Version_Check "install" ; then
		Print_Output "true" "Unsupported firmware version detected" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if [ "$CHECKSFAILED" = "false" ]; then
		Print_Output "true" "Installing required packages from Entware" "$PASS"
		opkg update
		opkg install sqlite3-cli
		opkg install jq
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
	Create_Symlinks
	
	Download_File "$SCRIPT_REPO/$ARCH.tar.gz" "$OOKLA_DIR/$ARCH.tar.gz"
	tar -xzf "$OOKLA_DIR/$ARCH.tar.gz" -C "$OOKLA_DIR"
	rm -f "$OOKLA_DIR/$ARCH.tar.gz"
	chmod 0755 "$OOKLA_DIR/speedtest"
	
	Update_File "spdstats_www.asp"
	Update_File "chart.js"
	Update_File "chartjs-plugin-zoom.js"
	Update_File "chartjs-plugin-annotation.js"
	Update_File "chartjs-plugin-datasource.js"
	Update_File "hammerjs.js"
	Update_File "moment.js"
	
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	Conf_Exists
	
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
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	Create_Dirs
	Create_Symlinks
	License_Acceptance "load"
	Mount_WebUI
	Clear_Lock
}

Menu_GenerateStats(){
	Generate_SPDStats "$1"
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
	Update_Version force
	Clear_Lock
}

Menu_Uninstall(){
	Print_Output "true" "Removing $SCRIPT_NAME..." "$PASS"
	Auto_Startup delete 2>/dev/null
	Auto_Cron delete 2>/dev/null
	Auto_ServiceEvent delete 2>/dev/null
	while true; do
		printf "\\n\\e[1mDo you want to delete %s stats and config? (y/n)\\e[0m\\n" "$SCRIPT_NAME"
		read -r "confirm"
		case "$confirm" in
			y|Y)
				rm -rf "$SCRIPT_DIR" 2>/dev/null
				break
			;;
			*)
				break
			;;
		esac
	done
	Shortcut_spdMerlin delete
	
	if Firmware_Version_Check "webui"; then
		Get_WebUI_Page "$SCRIPT_DIR/spdstats_www.asp"
		if [ -n "$MyPage" ] && [ "$MyPage" != "none" ] && [ -f "/tmp/menuTree.js" ]; then
			sed -i "\\~$MyPage~d" /tmp/menuTree.js
			umount /www/require/modules/menuTree.js
			mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
			rm -rf "{$SCRIPT_PAGE_DIR:?}/$MyPage"
		fi
	else
		umount /www/AiMesh_Node_FirmwareUpgrade.asp 2>/dev/null
		umount /www/AdaptiveQoS_ROG.asp 2>/dev/null
		sed -i '/{url: "'"$(Get_spdMerlin_UI)"'", tabName: "SpeedTest"}/d' "$SHARED_DIR/custom_menuTree.js"
		umount /www/require/modules/menuTree.js 2>/dev/null
		umount /www/start_apply.htm 2>/dev/null
		if [ ! -f "/jffs/scripts/ntpmerlin" ] && [ ! -f "/jffs/scripts/connmon" ]; then
			rm -f "$SHARED_DIR/custom_menuTree.js" 2>/dev/null
			rm -f "$SHARED_DIR/custom_start_apply.htm" 2>/dev/null
		else
			mount -o bind "$SHARED_DIR/custom_menuTree.js" "/www/require/modules/menuTree.js"
			mount -o bind "$SHARED_DIR/custom_start_apply.htm" "/www/start_apply.htm"
		fi
	fi
	
	rm -f "$SHARED_DIR/custom_state.js" 2>/dev/null
	rm -f "$SCRIPT_DIR/spdstats_www.asp" 2>/dev/null
	rm -rf "$SCRIPT_WEB_DIR" 2>/dev/null
	rm -rf "$OOKLA_DIR" 2>/dev/null
	rm -rf "$OOKLA_LICENSE_DIR" 2>/dev/null
	rm -f "/jffs/scripts/$SCRIPT_NAME_LOWER" 2>/dev/null
	Clear_Lock
	Print_Output "true" "Uninstall completed" "$PASS"
}

if [ -z "$1" ]; then
	if [ ! -f /opt/bin/sqlite3 ]; then
		Print_Output "true" "Installing required version of sqlite3 from Entware" "$PASS"
		opkg update
		opkg install sqlite3-cli
	fi
	Create_Dirs
	Create_Symlinks
	Process_Upgrade
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	Conf_Exists
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
		if [ -z "$2" ] && [ -z "$3" ]; then
			Check_Lock
			Menu_GenerateStats "schedule"
		elif [ "$2" = "start" ] && [ "$3" = "$SCRIPT_NAME_LOWER" ]; then
			Check_Lock
			Menu_GenerateStats "webui"
		fi
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
		Menu_Update
		exit 0
	;;
	forceupdate)
		Check_Lock
		Menu_ForceUpdate
		exit 0
	;;
	uninstall)
		Check_Lock
		Menu_Uninstall
		exit 0
	;;
	*)
		Check_Lock
		echo "Command not recognised, please try again"
		Clear_Lock
		exit 1
	;;
esac
