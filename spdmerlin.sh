#!/bin/sh

##########################################################
##                  _  __  __              _  _         ##
##                 | ||  \/  |            | |(_)        ##
##  ___  _ __    __| || \  / |  ___  _ __ | | _  _ __   ##
## / __|| '_ \  / _` || |\/| | / _ \| '__|| || || '_ \  ##
## \__ \| |_) || (_| || |  | ||  __/| |   | || || | | | ##
## |___/| .__/  \__,_||_|  |_| \___||_|   |_||_||_| |_| ##
##      | |                                             ##
##      |_|                                             ##
##                                                      ##
##       https://github.com/jackyaz/spdMerlin           ##
##                                                      ##
##########################################################

### Start of script variables ###
readonly SPD_NAME="spdMerlin"
#shellcheck disable=SC2019
#shellcheck disable=SC2018
readonly SPD_NAME_LOWER=$(echo $SPD_NAME | tr 'A-Z' 'a-z')
readonly SPD_VERSION="0.0.1"
readonly SPD_BRANCH="master"
readonly SPD_REPO="https://raw.githubusercontent.com/jackyaz/spdMerlin/""$SPD_BRANCH"
[ -z "$(nvram get odmpid)" ] && ROUTER_MODEL=$(nvram get productid) || ROUTER_MODEL=$(nvram get odmpid)
### End of script variables ###

### Start of output format variables ###
readonly CRIT="\\e[41m"
readonly ERR="\\e[31m"
readonly WARN="\\e[33m"
readonly PASS="\\e[32m"
### End of output format variables ###

# $1 = print to syslog, $2 = message to print, $3 = log level
Print_Output(){
	if [ "$1" = "true" ]; then
		logger -t "$SPD_NAME" "$2"
		printf "\\e[1m$3%s: $2\\e[0m\\n\\n" "$SPD_NAME"
	else
		printf "\\e[1m$3%s: $2\\e[0m\\n\\n" "$SPD_NAME"
	fi
}

### Code for this function courtesy of https://github.com/decoderman- credit to @thelonelycoder ###
Firmware_Version_Check(){
	echo "$1" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}
############################################################################

### Code for these functions inspired by https://github.com/Adamm00 - credit to @Adamm ###
Check_Lock(){
	if [ -f "/tmp/$SPD_NAME.lock" ]; then
		ageoflock=$(($(date +%s) - $(date +%s -r /tmp/$SPD_NAME.lock)))
		if [ "$ageoflock" -gt 120 ]; then
			Print_Output "true" "Stale lock file found (>120 seconds old) - purging lock" "$ERR"
			kill "$(sed -n '1p' /tmp/$SPD_NAME.lock)" >/dev/null 2>&1
			Clear_Lock
			echo "$$" > "/tmp/$SPD_NAME.lock"
			return 0
		else
			Print_Output "true" "Lock file found (age: $ageoflock seconds) - stopping to prevent duplicate runs" "$ERR"
			#if [ -z "$1" ]; then
				exit 1
			#else
			#	return 1
			#fi
		fi
	else
		echo "$$" > "/tmp/$SPD_NAME.lock"
		return 0
	fi
}

Clear_Lock(){
	rm -f "/tmp/$SPD_NAME.lock" 2>/dev/null
	return 0
}

Check_Swap () {
	if [ "$(wc -l < /proc/swaps)" -ge "2" ]; then
		return 0
	else
		return 1
	fi
}

Update_Version(){
	if [ -z "$1" ]; then
		doupdate="false"
		localver=$(grep "SPD_VERSION=" /jffs/scripts/"$SPD_NAME_LOWER" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		/usr/sbin/curl -fsL --retry 3 "$SPD_REPO/$SPD_NAME_LOWER.sh" | grep -qF "jackyaz" || { Print_Output "true" "404 error detected - stopping update" "$ERR"; return 1; }
		serverver=$(/usr/sbin/curl -fsL --retry 3 "$SPD_REPO/$SPD_NAME_LOWER.sh" | grep "SPD_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		if [ "$localver" != "$serverver" ]; then
			doupdate="version"
		else
			localmd5="$(md5sum "/jffs/scripts/$SPD_NAME_LOWER" | awk '{print $1}')"
			remotemd5="$(curl -fsL --retry 3 "$SPD_REPO/$SPD_NAME_LOWER.sh" | md5sum | awk '{print $1}')"
			if [ "$localmd5" != "$remotemd5" ]; then
				doupdate="md5"
			fi
		fi
		
		if [ "$doupdate" = "version" ]; then
			Print_Output "true" "New version of $SPD_NAME available - updating to $serverver" "$PASS"
		elif [ "$doupdate" = "md5" ]; then
			Print_Output "true" "MD5 hash of $SPD_NAME does not match - downloading updated $serverver" "$PASS"
		fi
		
		Update_File "spdcli.py"
		
		if [ "$doupdate" != "false" ]; then
			/usr/sbin/curl -fsL --retry 3 "$SPD_REPO/$SPD_NAME_LOWER.sh" -o "/jffs/scripts/$SPD_NAME_LOWER" && Print_Output "true" "$SPD_NAME successfully updated"
			chmod 0755 /jffs/scripts/"$SPD_NAME_LOWER"
			Clear_Lock
			/jffs/scripts/"$SPD_NAME_LOWER" generate
			exit 0
		else
			Print_Output "true" "No new version - latest is $localver" "$WARN"
			Clear_Lock
		fi
	fi
	
	case "$1" in
		force)
			serverver=$(/usr/sbin/curl -fsL --retry 3 "$SPD_REPO/$SPD_NAME_LOWER.sh" | grep "SPD_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
			Print_Output "true" "Downloading latest version ($serverver) of $SPD_NAME" "$PASS"
			Update_File "spdcli.py"
			/usr/sbin/curl -fsL --retry 3 "$SPD_REPO/$SPD_NAME_LOWER.sh" -o "/jffs/scripts/$SPD_NAME_LOWER" && Print_Output "true" "$SPD_NAME successfully updated"
			chmod 0755 /jffs/scripts/"$SPD_NAME_LOWER"
			Clear_Lock
			/jffs/scripts/"$SPD_NAME_LOWER" generate
			exit 0
		;;
	esac
}
############################################################################

Update_File(){
	if [ "$1" = "spdcli.py" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SPD_REPO/$1" "$tmpfile"
		if ! diff -q "$tmpfile" "/jffs/scripts/$1" >/dev/null 2>&1; then
			Download_File "$SPD_REPO/$1" "/jffs/scripts/$1"
			chmod 0755 /jffs/scripts/"$1"
			Print_Output "true" "New version of $1 downloaded to /jffs/scripts/$1" "$PASS"
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

Auto_Startup(){
	case $1 in
		create)
			if [ -f /jffs/scripts/services-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SPD_NAME" /jffs/scripts/services-start)
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SPD_NAME_LOWER startup"' # '"$SPD_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SPD_NAME"'/d' /jffs/scripts/services-start
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo "/jffs/scripts/$SPD_NAME_LOWER startup"' # '"$SPD_NAME" >> /jffs/scripts/services-start
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/services-start
				echo "" >> /jffs/scripts/services-start
				echo "/jffs/scripts/$SPD_NAME_LOWER startup"' # '"$SPD_NAME" >> /jffs/scripts/services-start
				chmod 0755 /jffs/scripts/services-start
			fi
		;;
		delete)
			if [ -f /jffs/scripts/services-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SPD_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SPD_NAME"'/d' /jffs/scripts/services-start
				fi
			fi
		;;
	esac
}

Auto_Cron(){
	case $1 in
		create)
			STARTUPLINECOUNT=$(cru l | grep -c "$SPD_NAME")
			
			if [ "$STARTUPLINECOUNT" -eq 0 ]; then
				cru a "$SPD_NAME" "10,40 * * * * /jffs/scripts/$SPD_NAME_LOWER generate"
			fi
		;;
		delete)
			STARTUPLINECOUNT=$(cru l | grep -c "$SPD_NAME")
			
			if [ "$STARTUPLINECOUNT" -gt 0 ]; then
				cru d "$SPD_NAME"
			fi
		;;
	esac
}

Download_File(){
	/usr/sbin/curl -fsL --retry 3 "$1" -o "$2"
}

RRD_Initialise(){
	if [ ! -f /jffs/scripts/spdstats_rrd.rrd ]; then
		Download_File "$SPD_REPO/spdstats_xml.xml" "/jffs/scripts/spdstats_xml.xml"
		rrdtool restore -f /jffs/scripts/spdstats_xml.xml /jffs/scripts/spdstats_rrd.rrd
		rm -f /jffs/scripts/spdstats_xml.xml
	fi
}

Mount_SPD_WebUI(){
	umount /www/Advanced_Feedback.asp 2>/dev/null
	sleep 1
	if [ ! -f /jffs/scripts/spdstats_www.asp ]; then
		Download_File "$SPD_REPO/spdstats_www.asp" "/jffs/scripts/spdstats_www.asp"
	fi
	
	mount -o bind /jffs/scripts/spdstats_www.asp /www/Advanced_Feedback.asp
}

Modify_WebUI_File(){
	umount /www/require/modules/menuTree.js 2>/dev/null
	sleep 1
	tmpfile=/tmp/menuTree.js
	cp "/www/require/modules/menuTree.js" "$tmpfile"
	
	sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "Advanced_Feedback.asp", tabName: "SpeedTest"},' "$tmpfile"
	sed -i '/{url: "Advanced_Feedback.asp", tabName: "<#2033#>"}/d' "$tmpfile"
	sed -i '/retArray.push("Advanced_Feedback.asp");/d' "$tmpfile"
	if [ -f "/jffs/scripts/ntpmerlin" ]; then
		sed -i '/"Tools_OtherSettings.asp", tabName: "Other Settings"/a {url: "Feedback_Info.asp", tabName: "NTP Daemon"},' "$tmpfile"
	fi
	
	if ! diff -q "$tmpfile" "/jffs/scripts/custom_menuTree.js" >/dev/null 2>&1; then
		cp "$tmpfile" "/jffs/scripts/custom_menuTree.js"
	fi
	
	rm -f "$tmpfile"
	
	mount -o bind "/jffs/scripts/custom_menuTree.js" "/www/require/modules/menuTree.js"
	
	umount /www/state.js 2>/dev/null
	sleep 1
	tmpfile=/tmp/state.js
	cp "/www/state.js" "$tmpfile"
	sed -i -e '/else if(location.pathname == "\/Advanced_Feedback.asp") {/,+4d' "$tmpfile"
	
	if [ ! -f /jffs/scripts/custom_state.js ]; then
		cp "/www/state.js" "/jffs/scripts/custom_state.js"
	fi
	
	if ! diff -q "$tmpfile" "/jffs/scripts/custom_state.js" >/dev/null 2>&1; then
		cp "$tmpfile" "/jffs/scripts/custom_state.js"
	fi
	
	rm -f "$tmpfile"
	
	mount -o bind /jffs/scripts/custom_state.js /www/state.js
}

Generate_SPDStats(){
	# This script is adapted from http://www.wraith.sf.ca.us/ntp
	# This function originally written by kvic, further adapted by JGrana
	# to display Internet Speedtest results and maintained by Jack Yaz
	# The original is part of a set of scripts written by Steven Bjork.
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	
	if Check_Swap ; then
		
		RDB=/jffs/scripts/spdstats_rrd.rrd
		
		/jffs/scripts/spdcli.py --simple --no-pre-allocate --secure >> /tmp/spd-rrdstats.$$
		
		NPING=$(grep Ping /tmp/spd-rrdstats.$$ | awk 'BEGIN{FS=" "}{print $2}')
		NDOWNLD=$(grep Download /tmp/spd-rrdstats.$$ | awk 'BEGIN{FS=" "}{print $2}')
		NUPLD=$(grep Upload /tmp/spd-rrdstats.$$ | awk 'BEGIN{FS=" "}{print $2}')
		
		rrdtool update $RDB N:"$NPING":"$NDOWNLD":"$NUPLD"
		rm /tmp/spd-rrdstats.$$
		
		TZ=$(cat /etc/TZ)
		export TZ
		DATE=$(date "+%a %b %e %H:%M %Y")
		
		COMMON="-c SHADEA#475A5F -c SHADEB#475A5F -c BACK#475A5F -c CANVAS#92A0A520 -c AXIS#92a0a520 -c FONT#ffffff -c ARROW#475A5F -n TITLE:9 -n AXIS:8 -n LEGEND:9 -w 650 -h 200"
		
		D_COMMON='--start -86400 --x-grid MINUTE:20:HOUR:2:HOUR:2:0:%H:%M'
		W_COMMON='--start -604800 --x-grid HOUR:3:DAY:1:DAY:1:0:%Y-%m-%d'
		
		mkdir -p "$(readlink /www/ext)"
		
		#shellcheck disable=SC2086
		rrdtool graph --imgformat PNG /www/ext/nstats-speed-ping.png \
			$COMMON $D_COMMON \
			--title "Ping - $DATE" \
			--vertical-label "mSec" \
			DEF:ping="$RDB":ping:LAST \
			CDEF:nping=ping,1000,/ \
			LINE1.5:ping#fc8500:"ping" \
			GPRINT:ping:MIN:"WAN Min\: %3.2lf %s" \
			GPRINT:ping:MAX:"WAN Max\: %3.2lf %s" \
			GPRINT:ping:LAST:"WAN Curr\: %3.2lf %s\n" >/dev/null 2>&1
		
		#shellcheck disable=SC2086
		rrdtool graph --imgformat PNG /www/ext/nstats-speed-downld.png \
			$COMMON $D_COMMON \
			--title "Download - $DATE" \
			--vertical-label "Mbits/sec" \
			DEF:download="$RDB":download:LAST \
			CDEF:ndownld=download,1000,/ \
			AREA:ndownld#c4fd3d:"download" \
			GPRINT:ndownld:MIN:"Min\: %3.2lf %s" \
			GPRINT:ndownld:MAX:"Max\: %3.2lf %s" \
			GPRINT:ndownld:AVERAGE:"Avg\: %3.2lf %s" \
			GPRINT:ndownld:LAST:"Curr\: %3.2lf %s\n" >/dev/null 2>&1
		
		#shellcheck disable=SC2086
		rrdtool graph --imgformat PNG /www/ext/nstats-speed-upld.png \
			$COMMON $D_COMMON \
			--title "Upload - $DATE" \
			--vertical-label "Mbits/sec" \
			DEF:upload="$RDB":upload:LAST \
			CDEF:nupld=upload,1000,/ \
			AREA:nupld#96e78a:"upload" \
			GPRINT:nupld:MIN:"Min\: %3.2lf %s" \
			GPRINT:nupld:MAX:"Max\: %3.2lf %s" \
			GPRINT:nupld:AVERAGE:"Avg\: %3.2lf %s" \
			GPRINT:nupld:LAST:"Curr\: %3.2lf %s\n" >/dev/null 2>&1
		
		#shellcheck disable=SC2086
		rrdtool graph --imgformat PNG /www/ext/nstats-week-speed-ping.png \
			$COMMON $W_COMMON \
			--title "Ping - $DATE" \
			--vertical-label "mSec" \
			DEF:ping="$RDB":ping:LAST \
			CDEF:nping=ping,1000,/ \
			LINE1.5:nping#fc8500:"ping" \
			GPRINT:nping:MIN:"WAN Min\: %3.1lf %s" \
			GPRINT:nping:MAX:"WAN Max\: %3.1lf %s" \
			GPRINT:nping:LAST:"WAN Curr\: %3.1lf %s\n" >/dev/null 2>&1
		
		#shellcheck disable=SC2086
		rrdtool graph --imgformat PNG /www/ext/nstats-week-speed-downld.png \
			$COMMON $W_COMMON --alt-autoscale-max \
			--title "Download - $DATE" \
			--vertical-label "Mbits/sec" \
			DEF:download="$RDB":download:LAST \
			CDEF:ndownlad=download,1000,/ \
			AREA:ndownlad#c4fd3d:"download" \
			GPRINT:ndownlad:MIN:"Min\: %3.1lf %s" \
			GPRINT:ndownlad:MAX:"Max\: %3.1lf %s" \
			GPRINT:ndownlad:AVERAGE:"Avg\: %3.1lf %s" \
			GPRINT:ndownlad:LAST:"Curr\: %3.1lf %s\n" >/dev/null 2>&1
		
		#shellcheck disable=SC2086
		rrdtool graph --imgformat PNG /www/ext/nstats-week-speed-upld.png \
			$COMMON $W_COMMON --alt-autoscale-max \
			--title "Upload - $DATE" \
			--vertical-label "Mbits/sec" \
			DEF:upload="$RDB":upload:LAST \
			CDEF:nupld=upload,1000,/ \
			AREA:nupld#96e78a:"uplad" \
			GPRINT:nupld:MIN:"Min\: %3.1lf %s" \
			GPRINT:nupld:MAX:"Max\: %3.1lf %s" \
			GPRINT:nupld:AVERAGE:"Avg\: %3.1lf %s" \
			GPRINT:nupld:LAST:"Curr\: %3.1lf %s\n" >/dev/null 2>&1
	else
		Print_Output "true" "Swap file not active, exiting" "$CRIT"
		return 1
	fi
}

Shortcut_spdMerlin(){
	case $1 in
		create)
			if [ -d "/opt/bin" ] && [ ! -f "/opt/bin/$SPD_NAME_LOWER" ] && [ -f "/jffs/scripts/$SPD_NAME_LOWER" ]; then
				ln -s /jffs/scripts/"$SPD_NAME_LOWER" /opt/bin
				chmod 0755 /opt/bin/"$SPD_NAME_LOWER"
			fi
		;;
		delete)
			if [ -f "/opt/bin/$SPD_NAME_LOWER" ]; then
				rm -f /opt/bin/"$SPD_NAME_LOWER"
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
	DST_ENABLED="$(nvram get time_zone_dst)"
	if ! Validate_Number "" "$DST_ENABLED" "silent"; then DST_ENABLED=0; fi
	if [ "$DST_ENABLED" -eq "0" ]; then
		DST_ENABLED="Inactive"
	else
		DST_ENABLED="Active"
	fi
	
	DST_SETTING="$(nvram get time_zone_dstoff)"
	DST_SETTING="$(echo "$DST_SETTING" | sed 's/M//g')"
	DST_START="$(echo "$DST_SETTING" | cut -f1 -d",")"
	DST_START="Month $(echo "$DST_START" | cut -f1 -d".") Week $(echo "$DST_START" | cut -f2 -d".") Weekday $(echo "$DST_START" | cut -f3 -d"." | cut -f1 -d"/") Hour $(echo "$DST_START" | cut -f3 -d"." | cut -f2 -d"/")"
	DST_END="$(echo "$DST_SETTING" | cut -f2 -d",")"
	DST_END="Month $(echo "$DST_END" | cut -f1 -d".") Week $(echo "$DST_END" | cut -f2 -d".") Weekday $(echo "$DST_END" | cut -f3 -d"." | cut -f1 -d"/") Hour $(echo "$DST_END" | cut -f3 -d"." | cut -f2 -d"/")"
	
	printf "\\n"
	printf "\\e[1m##########################################################\\e[0m\\n"
	printf "\\e[1m##                   _  __  __              _  _         ##\\e[0m\\n"
	printf "\\e[1m##                  | ||  \/  |            | |(_)        ##\\e[0m\\n"
	printf "\\e[1m##   ___  _ __    __| || \  / |  ___  _ __ | | _  _ __   ##\\e[0m\\n"
	printf "\\e[1m##  / __|| '_ \  / _  || |\/| | / _ \| '__|| || || '_ \  ##\\e[0m\\n"
	printf "\\e[1m##  \__ \| |_) || (_| || |  | ||  __/| |   | || || | | | ##\\e[0m\\n"
	printf "\\e[1m##  |___/| .__/  \__,_||_|  |_| \___||_|   |_||_||_| |_| ##\\e[0m\\n"
	printf "\\e[1m##      | |                                              ##\\e[0m\\n"
	printf "\\e[1m##      |_|                                              ##\\e[0m\\n"
	printf "\\e[1m##                                                      ##\\e[0m\\n"
	printf "\\e[1m##                  %s on %-9s                 ##\\e[0m\\n" "$SPD_VERSION" "$ROUTER_MODEL"
	printf "\\e[1m##                                                      ##\\e[0m\\n"
	printf "\\e[1m##       https://github.com/jackyaz/spdMerlin           ##\\e[0m\\n"
	printf "\\e[1m##                                                      ##\\e[0m\\n"
	printf "\\e[1m##########################################################\\e[0m\\n"
	printf "\\n"
}

MainMenu(){
	printf "1.    Generate updated %s graphs now\\n\\n" "$SPD_NAME"
	printf "3.    Edit %s config\\n\\n" "$SPD_NAME"
	printf "u.    Check for updates\\n"
	printf "uf.   Update %s with latest version (force update)\\n\\n" "$SPD_NAME"
	printf "e.    Exit %s\\n\\n" "$SPD_NAME"
	printf "z.    Uninstall %s\\n" "$SPD_NAME"
	printf "\\n"
	printf "\\e[1m##########################################################\\e[0m\\n"
	printf "\\n"
	
	while true; do
		printf "Choose an option:    "
		read -r "menu"
		case "$menu" in
			1)
				printf "\\n"
				Menu_GenerateStats
				PressEnter
				break
			;;
			3)
				printf "\\n"
				Menu_Edit
				break
			;;
			u)
				printf "\\n"
				Menu_Update
				PressEnter
				break
			;;
			uf)
				printf "\\n"
				Menu_ForceUpdate
				PressEnter
				break
			;;
			e)
				ScriptHeader
				printf "\\n\\e[1mThanks for using %s!\\e[0m\\n\\n\\n" "$SPD_NAME"
				exit 0
			;;
			z)
				while true; do
					printf "\\n\\e[1mAre you sure you want to uninstall %s? (y/n)\\e[0m\\n" "$SPD_NAME"
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

Menu_Install(){
	opkg install python
	opkg install rrdtool
	
	Download_File "$SPD_REPO/spdcli.py" "/jffs/scripts/spdcli.py"
	chmod 0755 /jffs/scripts/spdcli.py
	
	Mount_SPD_WebUI
	
	Modify_WebUI_File
	
	RRD_Initialise
	
	Shortcut_spdMerlin create
	
	Generate_SPDStats
}

Menu_Startup(){
	Check_Lock
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Mount_SPD_WebUI
	Modify_WebUI_File
	RRD_Initialise
	Clear_Lock
}

Menu_GenerateStats(){
	Check_Lock
	Generate_SPDStats
	Clear_Lock
}

Menu_Update(){
	Check_Lock
	sleep 1
	Update_Version
	Clear_Lock
}

Menu_ForceUpdate(){
	Check_Lock
	sleep 1
	Update_Version force
	Clear_Lock
}

Menu_Uninstall(){
	Check_Lock
	Print_Output "true" "Removing $SPD_NAME..." "$PASS"
	Auto_Startup delete 2>/dev/null
	Auto_Cron delete 2>/dev/null
	while true; do
		printf "\\n\\e[1mDo you want to delete %s stats? (y/n)\\e[0m\\n" "$SPD_NAME"
		read -r "confirm"
		case "$confirm" in
			y|Y)
				rm -f "/jffs/scripts/spdstats_rrd.rrd" 2>/dev/null
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
	if [ ! -f "/jffs/scripts/ntpmerlin" ]; then
		opkg remove --autoremove rrdtool
		umount /www/require/modules/menuTree.js 2>/dev/null
		rm -f "/jffs/scripts/custom_menuTree.js" 2>/dev/null
	fi
	rm -f "/jffs/scripts/custom_state.js" 2>/dev/null
	rm -f "/jffs/scripts/spdstats_www.asp" 2>/dev/null
	rm -f "/jffs/scripts/spdcli.py" 2>/dev/null
	rm -f "/jffs/scripts/$SPD_NAME_LOWER" 2>/dev/null
	Clear_Lock
	Print_Output "true" "Uninstall completed" "$PASS"
}

if [ -z "$1" ]; then
	Check_Lock
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Shortcut_spdMerlin create
	Clear_Lock
	ScriptHeader
	MainMenu
	exit 0
fi

case "$1" in
	install)
		Menu_Install
		exit 0
	;;
	startup)
		Menu_Startup
		exit 0
	;;
	generate)
		Menu_GenerateStats
		exit 0
	;;
	update)
		Menu_Update
		exit 0
	;;
	forceupdate)
		Menu_ForceUpdate
		exit 0
	;;
	uninstall)
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
