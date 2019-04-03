#! /bin/sh

# This script is adapted from http://www.wraith.sf.ca.us/ntp
# This function originally written by kvic, further adapted by JGrana
# to display Internet Speedtest results and maintained by Jack Yaz
# The original is part of a set of scripts written by Steven Bjork.

RDB=/jffs/scripts/speedtest_rrd.rrd

/jffs/scripts/spdcli/py --simple --no-pre-allocate >> /tmp/st1.$$

NPING=`grep Ping /tmp/st1 | awk 'BEGIN{FS=" "}{print $2}'`
NDOWNLD=`grep Download /tmp/st1 | awk 'BEGIN{FS=" "}{print $2}'`
NUPLD=`grep Upload /tmp/st1 | awk 'BEGIN{FS=" "}{print $2}'`

rrdtool update $RDB N:"$NPING":"$NDOWNLD":"$NUPLD"
rm /tmp/st1.$$

TZ=$(cat /etc/TZ)
export TZ
DATE=$(date "+%a %b %e %H:%M %Y")

COMMON="-c SHADEA#475A5F -c SHADEB#475A5F -c BACK#475A5F -c CANVAS#92A0A520 -c AXIS#92a0a520 -c FONT#ffffff -c ARROW#475A5F -n TITLE:9 -n AXIS:8 -n LEGEND:9 -w 650 -h 200"

D_COMMON='--start -86400 --x-grid MINUTE:20:HOUR:2:HOUR:2:0:%H:%M'
W_COMMON='--start -604800 --x-grid HOUR:3:DAY:1:DAY:1:0:%Y-%m-%d'

mkdir -p "$(readlink /www/ext)"

rrdtool graph --imgformat PNG /www/ext/nstats-speed-ping.png \
${COMMON} ${D_COMMON} \
--title "Ping - $DATE" \
--vertical-label "mSec" \
DEF:ping="$RDB":ping:LAST \
CDEF:nping=ping,1000,/ \
LINE1.5:ping#fc8500:"ping" \
GPRINT:ping:MIN:"WAN Min\: %3.2lf %s" \
GPRINT:ping:MAX:"WAN Max\: %3.2lf %s" \
GPRINT:ping:LAST:"WAN Curr\: %3.2lf %s\n" >/dev/null 2>&1

rrdtool graph --imgformat PNG /www/ext/nstats-speed-downld.png \
${COMMON} ${D_COMMON} \
--title "Download - $DATE" \
--vertical-label "Mbits/sec" \
DEF:download="$RDB":download:LAST \
CDEF:ndownld=download,1000,/ \
AREA:ndownld#c4fd3d:"download" \
GPRINT:ndownld:MIN:"Min\: %3.2lf %s" \
GPRINT:ndownld:MAX:"Max\: %3.2lf %s" \
GPRINT:ndownld:AVERAGE:"Avg\: %3.2lf %s" \
GPRINT:ndownld:LAST:"Curr\: %3.2lf %s\n" >/dev/null 2>&1

rrdtool graph --imgformat PNG /www/ext/nstats-speed-upld.png \
${COMMON} ${D_COMMON} \
--title "Upload - $DATE" \
--vertical-label "Mbits/sec" \
DEF:upload="$RDB":upload:LAST \
CDEF:nupld=upload,1000,/ \
AREA:nupld#96e78a:"upload" \
GPRINT:nupld:MIN:"Min\: %3.2lf %s" \
GPRINT:nupld:MAX:"Max\: %3.2lf %s" \
GPRINT:nupld:AVERAGE:"Avg\: %3.2lf %s" \
GPRINT:nupld:LAST:"Curr\: %3.2lf %s\n" >/dev/null 2>&1

# weekly graphs
rrdtool graph --imgformat PNG /www/ext/nstats-week-speed-ping.png \
${COMMON} ${W_COMMON} \
--title "Ping - $DATE" \
--vertical-label "mSec" \
DEF:ping="$RDB":ping:LAST \
CDEF:nping=ping,1000,/ \
LINE1.5:nping#fc8500:"ping" \
GPRINT:nping:MIN:"WAN Min\: %3.1lf %s" \
GPRINT:nping:MAX:"WAN Max\: %3.1lf %s" \
GPRINT:nping:LAST:"WAN Curr\: %3.1lf %s\n" >/dev/null 2>&1

rrdtool graph --imgformat PNG /www/ext/nstats-week-speed-downld.png \
${COMMON} ${W_COMMON} --alt-autoscale-max \
--title "Download - $DATE" \
--vertical-label "Mbits/sec" \
DEF:download="$RDB":download:LAST \
CDEF:ndownlad=download,1000,/ \
AREA:ndownlad#c4fd3d:"download" \
GPRINT:ndownlad:MIN:"Min\: %3.1lf %s" \
GPRINT:ndownlad:MAX:"Max\: %3.1lf %s" \
GPRINT:ndownlad:AVERAGE:"Avg\: %3.1lf %s" \
GPRINT:ndownlad:LAST:"Curr\: %3.1lf %s\n" >/dev/null 2>&1


rrdtool graph --imgformat PNG /www/ext/nstats-week-speed-upld.png \
${COMMON} ${W_COMMON} --alt-autoscale-max \
--title "Upload - $DATE" \
--vertical-label "Mbits/sec" \
DEF:upload="$RDB":upload:LAST \
CDEF:nupld=upload,1000,/ \
AREA:nupld#96e78a:"uplad" \
GPRINT:nupld:MIN:"Min\: %3.1lf %s" \
GPRINT:nupld:MAX:"Max\: %3.1lf %s" \
GPRINT:nupld:AVERAGE:"Avg\: %3.1lf %s" \
GPRINT:nupld:LAST:"Curr\: %3.1lf %s\n" >/dev/null 2>&1
