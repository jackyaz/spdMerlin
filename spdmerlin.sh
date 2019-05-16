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
readonly SCRIPT_VERSION="v1.2.0"
readonly SPD_VERSION="v1.2.0"
readonly SCRIPT_BRANCH="develop"
readonly SCRIPT_REPO="https://raw.githubusercontent.com/jackyaz/spdMerlin/""$SCRIPT_BRANCH"
readonly SCRIPT_CONF="/jffs/configs/$SCRIPT_NAME_LOWER.config"
readonly SCRIPT_DIR="/jffs/scripts/$SCRIPT_NAME_LOWER.d"
readonly SCRIPT_WEB_DIR="$(readlink /www/ext)/$SCRIPT_NAME_LOWER"
readonly SHARED_DIR="/jffs/scripts/shared-jy"
[ -z "$(nvram get odmpid)" ] && ROUTER_MODEL=$(nvram get productid) || ROUTER_MODEL=$(nvram get odmpid)
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

### Code for this function courtesy of https://github.com/decoderman- credit to @thelonelycoder ###
Firmware_Version_Check(){
	echo "$1" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}
############################################################################

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
		
		Update_File "spdcli.py"
		Update_File "spdstats_www.asp"
		Modify_WebUI_File
		
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
			Update_File "spdcli.py"
			Update_File "spdstats_www.asp"
			Modify_WebUI_File
			/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" -o "/jffs/scripts/$SCRIPT_NAME_LOWER" && Print_Output "true" "$SCRIPT_NAME successfully updated"
			chmod 0755 /jffs/scripts/"$SCRIPT_NAME_LOWER"
			Clear_Lock
			exit 0
		;;
	esac
}
############################################################################

Update_File(){
	if [ "$1" = "spdcli.py" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SCRIPT_REPO/$1" "$tmpfile"
		if [ -f "/jffs/scripts/$1" ]; then
			mv "/jffs/scripts/$1" "$SCRIPT_DIR/$1"
		fi
		if ! diff -q "$tmpfile" "$SCRIPT_DIR/$1" >/dev/null 2>&1; then
			Download_File "$SCRIPT_REPO/$1" "$SCRIPT_DIR/$1"
			chmod 0755 "$SCRIPT_DIR/$1"
			Print_Output "true" "New version of $1 downloaded to $SCRIPT_DIR/$1" "$PASS"
		fi
		rm -f "$tmpfile"
	elif [ "$1" = "spdstats_www.asp" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SCRIPT_REPO/$1" "$tmpfile"
		if [ -f "/jffs/scripts/$1" ]; then
			mv "/jffs/scripts/$1" "$SCRIPT_DIR/$1"
		fi
		if ! diff -q "$tmpfile" "$SCRIPT_DIR/$1" >/dev/null 2>&1; then
			Print_Output "true" "New version of $1 downloaded" "$PASS"
			rm -f "$SCRIPT_DIR/$1"
			Mount_SPD_WebUI
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

Create_Dirs(){
	if [ ! -d "$SCRIPT_DIR" ]; then
		mkdir -p "$SCRIPT_DIR"
	fi
	
	if [ ! -d "$SHARED_DIR" ]; then
		mkdir -p "$SHARED_DIR"
	fi
	
	if [ ! -d "$SCRIPT_WEB_DIR" ]; then
		mkdir -p "$SCRIPT_WEB_DIR"
	fi
}

Conf_Exists(){
	if [ -f "$SCRIPT_CONF" ]; then
		dos2unix "$SCRIPT_CONF"
		chmod 0644 "$SCRIPT_CONF"
		sed -i -e 's/"//g' "$SCRIPT_CONF"
		if [ "$(wc -l < "$SCRIPT_CONF")" -lt 6 ]; then
			{ echo "AUTOMATED=true" ; echo "SCHEDULEMIN=*" ; echo "SCHEDULEHOUR=*"; } >> "$SCRIPT_CONF"
		fi
		return 0
	else
		{ echo "PREFERREDSERVER=0|None configured"; echo "USEPREFERRED=false"; echo "USESINGLE=false"; echo "AUTOMATED=true" ; echo "SCHEDULEMIN=*" ; echo "SCHEDULEHOUR=*"; } >> "$SCRIPT_CONF"
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
			Auto_Cron delete 2>/dev/null
			cru a "$SCRIPT_NAME" "12,42 * * * * /jffs/scripts/$SCRIPT_NAME_LOWER generate"
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

RRD_Initialise(){
	if [ -f "/jffs/scripts/spdstats_rrd.rrd" ]; then
		mv "/jffs/scripts/spdstats_rrd.rrd" "$SCRIPT_DIR/spdstats_rrd.rrd"
	fi
	
	if [ ! -f "$SCRIPT_DIR/spdstats_rrd.rrd" ]; then
		Download_File "$SCRIPT_REPO/spdstats_xml.xml" "$SCRIPT_DIR/spdstats_xml.xml"
		rrdtool restore -f "$SCRIPT_DIR/spdstats_xml.xml" "$SCRIPT_DIR/spdstats_xml.rrd"
		rm -f "$SCRIPT_DIR/spdstats_xml.xml"
	fi
}

Get_CONNMON_UI(){
	if [ -f /www/AdaptiveQoS_ROG.asp ]; then
		echo "AdaptiveQoS_ROG.asp"
	else
		echo "AiMesh_Node_FirmwareUpgrade.asp"
	fi
}

Mount_SPD_WebUI(){
	umount /www/Advanced_Feedback.asp 2>/dev/null
	
	if [ -f "/jffs/scripts/spdstats_www.asp" ]; then
		mv "/jffs/scripts/spdstats_www.asp" "$SCRIPT_DIR/spdstats_www.asp"
	fi
	
	if [ ! -f "$SCRIPT_DIR/spdstats_www.asp" ]; then
		Download_File "$SCRIPT_REPO/spdstats_www.asp" "$SCRIPT_DIR/spdstats_www.asp"
	fi
	
	mount -o bind "$SCRIPT_DIR/spdstats_www.asp" /www/Advanced_Feedback.asp
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
	
	if [ -f "/jffs/scripts/connmon" ]; then
		sed -i '/{url: "'"$(Get_CONNMON_UI)"'", tabName: /d' "$tmpfile"
		sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "'"$(Get_CONNMON_UI)"'", tabName: "Uptime Monitoring"},' "$tmpfile"
		sed -i '/retArray.push("'"$(Get_CONNMON_UI)"'");/d' "$tmpfile"
	fi
	
	sed -i '/{url: "Advanced_Feedback.asp", tabName: /d' "$tmpfile"
	sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "Advanced_Feedback.asp", tabName: "SpeedTest"},' "$tmpfile"
	sed -i '/retArray.push("Advanced_Feedback.asp");/d' "$tmpfile"
	
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
		sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("Advanced_MultiSubnet_Content.asp") != -1){'"\\r\\n"'parent.showLoading(restart_time, "waiting");'"\\r\\n"'setTimeout(function(){ getXMLAndRedirect(); alert("Please force-reload this page (e.g. Ctrl+F5)");}, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	fi
	
	if [ -f /jffs/scripts/connmon ]; then
		sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("'"$(Get_CONNMON_UI)"'") != -1){'"\\r\\n"'parent.showLoading(restart_time, "waiting");'"\\r\\n"'setTimeout(function(){ getXMLAndRedirect(); alert("Please force-reload this page (e.g. Ctrl+F5)");}, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	fi
	
	if [ -f /jffs/scripts/ntpmerlin ]; then
		sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("Feedback_Info.asp") != -1){'"\\r\\n"'parent.showLoading(restart_time, "waiting");'"\\r\\n"'setTimeout(function(){ getXMLAndRedirect(); alert("Please force-reload this page (e.g. Ctrl+F5)");}, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	fi
	
	sed -i -e '/else if(current_page.indexOf("Feedback") != -1){/i else if(current_page.indexOf("Advanced_Feedback.asp") != -1){'"\\r\\n"'parent.showLoading(restart_time, "waiting");'"\\r\\n"'setTimeout(function(){ getXMLAndRedirect(); alert("Please force-reload this page (e.g. Ctrl+F5)");}, restart_time*1000);'"\\r\\n"'}' "$tmpfile"
	
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

CacheGraphImages(){
	case "$1" in
		cache)
			if [ "$(ls "$SCRIPT_WEB_DIR" 2>/dev/null | wc -l)" -ge "1" ]; then
				CACHEPATH="/tmp/""$SCRIPT_NAME""Cache"
				mkdir -p "$CACHEPATH"
				cp "$SCRIPT_WEB_DIR"/* "$CACHEPATH"
				rm -f "$SCRIPT_DIR/$SCRIPT_NAME""_cache.tar.gz" 2>/dev/null
				tar -czf "$SCRIPT_DIR/$SCRIPT_NAME""_cache.tar.gz" -C "$CACHEPATH" .
				rm -rf "$CACHEPATH" 2>/dev/null
			fi
		;;
		extract)
			if [ -f "$SCRIPT_DIR/$SCRIPT_NAME""_cache.tar.gz" ] && [ "$(ls "$SCRIPT_WEB_DIR" 2>/dev/null | wc -l)" -lt "3" ]; then
				tar -C "$SCRIPT_WEB_DIR" -xzf "$SCRIPT_DIR/$SCRIPT_NAME""_cache.tar.gz"
			fi
		;;
	esac
}

GenerateServerList(){
	printf "Generating list of 25 closest servers...\\n\\n"
	serverlist="$($SCRIPT_DIR/spdcli.py --secure --list | sed '1d' | head -n 25)"
	COUNTER=1
	until [ $COUNTER -gt 25 ]; do
		serverdetails="$(echo "$serverlist" | sed "$COUNTER!d" | cut -f2- -d')' | awk '{$1=$1};1')"
		if [ "$COUNTER" -lt "10" ]; then
			printf "%s)  %s\\n" "$COUNTER" "$serverdetails"
		else
			printf "%s) %s\\n" "$COUNTER" "$serverdetails"
		fi
		COUNTER=$((COUNTER + 1))
	done
	
	printf "\\ne)  Go back\\n"
	
	while true; do
		printf "\\n\\e[1mPlease select a server from the list above (1-25):\\e[0m\\n"
		read -r "server"
		
		if [ "$server" = "e" ]; then
			serverno="exit"
			break
		elif ! Validate_Number "" "$server" "silent"; then
			printf "\\n\\e[31mPlease enter a valid number (1-25)\\e[0m\\n"
		else
			if [ "$server" -lt 1 ] || [ "$server" -gt 25 ]; then
				printf "\\n\\e[31mPlease enter a number between 1 and 25\\e[0m\\n"
			else
				serverno="$(echo "$serverlist" | sed "$server!d" | cut -f1 -d')' | awk '{$1=$1};1')"
				servername="$(echo "$serverlist" | sed "$server!d" | cut -f2 -d')' | awk '{$1=$1};1')"")"
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
			"$SCRIPT_DIR"/spdcli.py --secure --list > /tmp/spdServers.txt
			sed -i -e 's/^[ \t]*//;s/[ \t]*$//' /tmp/spdServers.txt
			if grep -q "^$PREFERREDSERVERNO)" /tmp/spdServers.txt; then
				rm -f /tmp/spdServers.txt
				return 0
			else
				rm -f /tmp/spdServers.txt
				return 1
			fi
	esac
}

SingleMode(){
	case "$1" in
		enable)
			sed -i 's/^USESINGLE.*$/USESINGLE=true/' "$SCRIPT_CONF"
		;;
		disable)
			sed -i 's/^USESINGLE.*$/USESINGLE=false/' "$SCRIPT_CONF"
		;;
		check)
			USESINGLE=$(grep "USESINGLE" "$SCRIPT_CONF" | cut -f2 -d"=")
			if [ "$USESINGLE" = "true" ]; then return 0; else return 1; fi
		;;
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

Generate_SPDStats(){
	# This script is adapted from http://www.wraith.sf.ca.us/ntp
	# This function originally written by kvic, further adapted by JGrana
	# to display Internet Speedtest results and maintained by Jack Yaz
	# The original is part of a set of scripts written by Steven Bjork.
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	Create_Dirs
	Conf_Exists
	mkdir -p "$(readlink /www/ext)"
	
	mode="$1"
	speedtestserverno=""
	speedtestservername=""
	
	if Check_Swap ; then
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
		
		if [ "$mode" = "auto" ]; then
			if SingleMode check; then
				Print_Output "true" "Starting speedtest using auto-selected server in single connection mode" "$PASS"
				"$SCRIPT_DIR"/spdcli.py --secure --simple --no-pre-allocate --single >> /tmp/spd-rrdstats.$$
			else
				Print_Output "true" "Starting speedtest using auto-selected server in multi-connection mode" "$PASS"
				"$SCRIPT_DIR"/spdcli.py --secure --simple --no-pre-allocate >> /tmp/spd-rrdstats.$$
			fi
		else
			if [ "$mode" != "onetime" ]; then
				if ! PreferredServer validate; then
					Print_Output "true" "Preferred server no longer valid, please choose another" "$ERR"
					Clear_Lock
					return 1
				fi
			fi
			
			if SingleMode check; then
				Print_Output "true" "Starting speedtest using $speedtestservername in single connection mode" "$PASS"
				"$SCRIPT_DIR"/spdcli.py --secure --simple --no-pre-allocate --single --server "$speedtestserverno" >> /tmp/spd-rrdstats.$$
			else
				Print_Output "true" "Starting speedtest using $speedtestservername in multi-connection mode" "$PASS"
				"$SCRIPT_DIR"/spdcli.py --secure --simple --no-pre-allocate --server "$speedtestserverno" >> /tmp/spd-rrdstats.$$
			fi
		fi
		
		NPING=$(grep Ping /tmp/spd-rrdstats.$$ | awk 'BEGIN{FS=" "}{print $2}')
		NDOWNLD=$(grep Download /tmp/spd-rrdstats.$$ | awk 'BEGIN{FS=" "}{print $2}')
		NUPLD=$(grep Upload /tmp/spd-rrdstats.$$ | awk 'BEGIN{FS=" "}{print $2}')
		
		TZ=$(cat /etc/TZ)
		export TZ
		DATE=$(date "+%a %b %e %H:%M %Y")
		DATE_TEST=$(date "+%Y-%m-%d %H:%M")
		
		spdtestresult="$(grep Download /tmp/spd-rrdstats.$$) - $(grep Upload /tmp/spd-rrdstats.$$)"
		echo 'document.getElementById("spdtestresult").innerHTML="Latest Speedtest Result: '"$DATE_TEST - $spdtestresult"'"' > "$SCRIPT_WEB_DIR"/spdtestresult.js
		Print_Output "true" "Speedtest results - $spdtestresult" "$PASS"
		
		RDB="$SCRIPT_DIR/spdstats_rrd.rrd"
		rrdtool update $RDB N:"$NPING":"$NDOWNLD":"$NUPLD"
		rm /tmp/spd-rrdstats.$$
		
		COMMON="-c SHADEA#475A5F -c SHADEB#475A5F -c BACK#475A5F -c CANVAS#92A0A520 -c AXIS#92a0a520 -c FONT#ffffff -c ARROW#475A5F -n TITLE:9 -n AXIS:8 -n LEGEND:9 -w 650 -h 200"
		
		D_COMMON='--start -86400 --x-grid MINUTE:20:HOUR:2:HOUR:2:0:%H:%M'
		W_COMMON='--start -604800 --x-grid HOUR:3:DAY:1:DAY:1:0:%Y-%m-%d'
		
		#shellcheck disable=SC2086
		rrdtool graph --imgformat PNG "$SCRIPT_WEB_DIR/downld.png" \
			$COMMON $D_COMMON \
			--title "Download - $DATE" \
			--vertical-label "Mbps" \
			DEF:download="$RDB":download:LAST \
			CDEF:ndownld=download,1000,/ \
			AREA:download#c4fd3d:"download" \
			GPRINT:download:MIN:"Min\: %3.2lf Mbps" \
			GPRINT:download:MAX:"Max\: %3.2lf Mbps" \
			GPRINT:download:AVERAGE:"Avg\: %3.2lf Mbps" \
			GPRINT:download:LAST:"Curr\: %3.2lf Mbps\n" >/dev/null 2>&1
		
		#shellcheck disable=SC2086
		rrdtool graph --imgformat PNG "$SCRIPT_WEB_DIR/upld.png" \
			$COMMON $D_COMMON \
			--title "Upload - $DATE" \
			--vertical-label "Mbps" \
			DEF:upload="$RDB":upload:LAST \
			CDEF:nupld=upload,1000,/ \
			AREA:upload#96e78a:"upload" \
			GPRINT:upload:MIN:"Min\: %3.2lf Mbps" \
			GPRINT:upload:MAX:"Max\: %3.2lf Mbps" \
			GPRINT:upload:AVERAGE:"Avg\: %3.2lf Mbps" \
			GPRINT:upload:LAST:"Curr\: %3.2lf Mbps\n" >/dev/null 2>&1
		
		#shellcheck disable=SC2086
		rrdtool graph --imgformat PNG "$SCRIPT_WEB_DIR/week-downld.png" \
			$COMMON $W_COMMON --alt-autoscale-max \
			--title "Download - $DATE" \
			--vertical-label "Mbps" \
			DEF:download="$RDB":download:LAST \
			CDEF:ndownlad=download,1000,/ \
			AREA:download#c4fd3d:"download" \
			GPRINT:download:MIN:"Min\: %3.2lf Mbps" \
			GPRINT:download:MAX:"Max\: %3.2lf Mbps" \
			GPRINT:download:AVERAGE:"Avg\: %3.2lf Mbps" \
			GPRINT:download:LAST:"Curr\: %3.2lf Mbps\n" >/dev/null 2>&1
		
		#shellcheck disable=SC2086
		rrdtool graph --imgformat PNG "$SCRIPT_WEB_DIR/week-upld.png" \
			$COMMON $W_COMMON --alt-autoscale-max \
			--title "Upload - $DATE" \
			--vertical-label "Mbps" \
			DEF:upload="$RDB":upload:LAST \
			CDEF:nupld=upload,1000,/ \
			AREA:upload#96e78a:"uplad" \
			GPRINT:upload:MIN:"Min\: %3.2lf Mbps" \
			GPRINT:upload:MAX:"Max\: %3.2lf Mbps" \
			GPRINT:upload:AVERAGE:"Avg\: %3.2lf Mbps" \
			GPRINT:upload:LAST:"Curr\: %3.2lf Mbps\n" >/dev/null 2>&1
			
		CacheGraphImages cache 2>/dev/null
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
	SINGLEMODE_ENABLED=""
	AUTOMATIC_ENABLED=""
	#TEST_SCHEDULE=""
	if PreferredServer check; then PREFERREDSERVER_ENABLED="Enabled"; else PREFERREDSERVER_ENABLED="Disabled"; fi
	if SingleMode check; then SINGLEMODE_ENABLED="Enabled"; else SINGLEMODE_ENABLED="Disabled"; fi
	if AutomaticMode check; then AUTOMATIC_ENABLED="Enabled"; else AUTOMATIC_ENABLED="Disabled"; fi
	
	printf "1.    Run a speedtest now (auto select server)\\n"
	printf "2.    Run a speedtest now (use preferred server)\\n"
	printf "3.    Run a speedtest (select a server)\\n\\n"
	printf "4.    Choose a preferred server(for automatic tests)\\n      Current server: %s\\n\\n" "$(PreferredServer list | cut -f2 -d"|")"
	printf "5.    Toggle preferred server (for automatic tests)\\n      Currently %s\\n\\n" "$PREFERREDSERVER_ENABLED"
	printf "6.    Toggle single connection mode (for all tests)\\n      Currently %s\\n\\n" "$SINGLEMODE_ENABLED"
	printf "7.    Toggle automatic tests\\n      Currently %s\\n\\n" "$AUTOMATIC_ENABLED"
	#printf "8.    Configure schedule for automatic tests\\n      Currently %s\\n\\n" "$TEST_SCHEDULE"
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
				Menu_ToggleSingle
				break
			;;
			7)
				printf "\\n"
				Menu_ToggleAutomated
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
	
	if [ "$CHECKSFAILED" = "false" ]; then
		return 0
	else
		return 1
	fi
}

Menu_Install(){
	Print_Output "true" "Welcome to $SCRIPT_NAME $SCRIPT_VERSION, a script by JackYaz"
	sleep 1
	
	Print_Output "true" "WARNING: Using $SCRIPT_NAME with Internet speeds over 250Mbps can cause router memory/stability issues" "$WARN"
	
	while true; do
		printf "\\n\\e[1mDo you want to continue? (y/n)\\e[0m\\n"
		read -r "confirm"
		case "$confirm" in
			y|Y)
				break
			;;
			*)
				exit 1
			;;
		esac
	done
	
	Print_Output "true" "Checking your router meets the requirements for $SCRIPT_NAME"
	
	if ! Check_Requirements; then
		Print_Output "true" "Requirements for $SCRIPT_NAME not met, please see above for the reason(s)" "$CRIT"
		PressEnter
		Clear_Lock
		rm -f "/jffs/scripts/$SCRIPT_NAME_LOWER" 2>/dev/null
		exit 1
	fi
	
	opkg update
	opkg install python
	opkg install rrdtool
	opkg install ca-certificates
	
	Create_Dirs
	
	Download_File "$SCRIPT_REPO/spdcli.py" "$SCRIPT_DIR/spdcli.py"
	chmod 0755 "$SCRIPT_DIR"/spdcli.py
	
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	Conf_Exists
	
	Mount_SPD_WebUI
	Modify_WebUI_File
	RRD_Initialise
	
	while true; do
		printf "\\n\\e[1mWould you like to run a speedtest now? (y/n)\\e[0m\\n"
		read -r "confirm"
		case "$confirm" in
			y|Y)
				Menu_GenerateStats "auto"
			;;
			*)
				break
			;;
		esac
	done
	Clear_Lock
}

Menu_Startup(){
	Auto_Startup create 2>/dev/null
	if AutomaticMode check; then Auto_Cron create 2>/dev/null; else Auto_Cron delete 2>/dev/null; fi
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	Create_Dirs
	Mount_SPD_WebUI
	Modify_WebUI_File
	RRD_Initialise
	CacheGraphImages extract 2>/dev/null
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

Menu_ToggleSingle(){
	if SingleMode check; then
		SingleMode disable
	else
		SingleMode enable
	fi
}

Menu_ToggleAutomated(){
	if AutomaticMode check; then
		AutomaticMode disable
	else
		AutomaticMode enable
	fi
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
		printf "\\n\\e[1mDo you want to delete %s stats? (y/n)\\e[0m\\n" "$SCRIPT_NAME"
		read -r "confirm"
		case "$confirm" in
			y|Y)
				rm -f "$SCRIPT_DIR/spdstats_rrd.rrd" 2>/dev/null
				break
			;;
			*)
				break
			;;
		esac
	done
	Shortcut_spdMerlin delete
	opkg remove --autoremove python
	umount /www/Advanced_Feedback.asp 2>/dev/null
	sed -i '/{url: "Advanced_Feedback.asp", tabName: "SpeedTest"}/d' "$SHARED_DIR/custom_menuTree.js"
	umount /www/require/modules/menuTree.js 2>/dev/null
	umount /www/start_apply.htm 2>/dev/null
	if [ ! -f "/jffs/scripts/ntpmerlin" ] && [ ! -f "/jffs/scripts/connmon" ]; then
		opkg remove --autoremove rrdtool
		rm -f "$SHARED_DIR/custom_menuTree.js" 2>/dev/null
		rm -f "$SHARED_DIR/custom_start_apply.htm" 2>/dev/null
	else
		mount -o bind "$SHARED_DIR/custom_menuTree.js" "/www/require/modules/menuTree.js"
		mount -o bind "$SHARED_DIR/custom_start_apply.htm" "/www/start_apply.htm"
	fi
	rm -f "$SHARED_DIR/custom_state.js" 2>/dev/null
	rm -f "$SCRIPT_DIR/spdstats_www.asp" 2>/dev/null
	rm -f "$SCRIPT_DIR/spdcli.py" 2>/dev/null
	rm -f "$SCRIPT_DIR/spdmerlin_images.tar.gz" 2>/dev/null
	rm -f "/jffs/scripts/$SCRIPT_NAME_LOWER" 2>/dev/null
	Clear_Lock
	Print_Output "true" "Uninstall completed" "$PASS"
}

if [ -z "$1" ]; then
	Create_Dirs
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_spdMerlin create
	Conf_Exists
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
			Menu_GenerateStats "schedule"
		fi
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
