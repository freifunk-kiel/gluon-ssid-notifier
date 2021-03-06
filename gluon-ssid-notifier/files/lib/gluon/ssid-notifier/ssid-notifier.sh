#!/bin/sh

#################
# safety checks #
#################
safety_exit() {
	echo $1, exiting with error code 2
	exit 2
}
pgrep -f autoupdater >/dev/null && safety_exit 'autoupdater running'
[ $(cat /proc/uptime | sed 's/\..*//g') -gt 180 ] || safety_exit 'less than 3 minutes'
[ $(find /var/run -name hostapd-phy* | wc -l) -gt 0 ] || safety_exit 'no hostapd-phy*'

# use something short to leave space for the nodename (no "/" allowed!)
OFFLINE_PREFIX='FF kein Netz:'

# Above this limit the offline SSID will be off
UPPER_LIMIT='55'
# Below this limit the offline SSID will be on
LOWER_LIMIT='45'
# In-between these two values the SSID will never be changed. prevents from toggeling every cron call

HOSTAPD=/var/run/hostapd-phy0.conf
OI=wireless.client_radio0_offline

GWL="$(batctl gwl)"
if [ "$?" == "1" ]; then 
	echo "wifi button off?"
	exit
fi

# connection quality of the currently used gateway
TQ=$(echo "$GWL" | grep "^=>" | awk -F '[('')]' '{print $2}' | tr -d " ")
if [ ! $TQ ]; then
	echo "TQ: '$TQ', wifi still running? do nothing"
	exit
elif [ $TQ -ge ${LOWER_LIMIT} -a $TQ -le ${UPPER_LIMIT} ]; then 
	# this is just get a clean run if we are in-between the grace periode
	echo "TQ: $TQ, this is between ${LOWER_LIMIT} and ${UPPER_LIMIT}; do nothing"
	exit
fi

IF_EXISTS=$(uci get -q $OI)
NODENAME=`uname -n`
if [ ${#NODENAME} -gt $((32 - ${#OFFLINE_PREFIX})) ] ; then
	HALF=$(( (30 - ${#OFFLINE_PREFIX} ) / 2 ))
	# jump to this character for the last part of the name
	SKIP=$(( ${#NODENAME} - $HALF ))
	# start .. end
	OFFLINE_SSID="${OFFLINE_PREFIX}${NODENAME:0:$HALF}..${NODENAME:$SKIP:${#NODENAME}}"
else
	# full nodename
	OFFLINE_SSID="${OFFLINE_PREFIX}${NODENAME}"
fi

if [ ! $IF_EXISTS ]; then
	uci set $OI=wifi-iface
	uci set $OI.network='client'
	uci set $OI.device='radio0'
	uci set $OI.mode='ap'
	uci set $OI.disabled='1'
	uci set $OI.ssid="${OFFLINE_SSID}"
	uci commit $OI; wifi; exit
elif [ "$(uci get -q $OI.ssid)" != "${OFFLINE_SSID}" ]; then
	#hostname changed
	uci set $OI.ssid="${OFFLINE_SSID}"
	uci commit $OI; wifi; exit
fi

OI_IS_DISABLED=$(uci get -q $OI.disabled)
LINE_IN_HOSTAPD=$(grep -n "ssid=${OFFLINE_SSID}" ${HOSTAPD} | cut -d':' -f1)
if [ "${LINE_IN_HOSTAPD}" == "" ]; then
	echo "the offline SSID is not in hostapd file"
	OI_IS_DISABLED=1
elif [ "$(head -n $LINE_IN_HOSTAPD $HOSTAPD | tail -n 11|grep "ignore_broadcast_ssid=1")" != "" ]; then
	echo "the offline SSID is in hostapd file but disabled there"
	OI_IS_DISABLED=1
fi

HUP_NEEDED=0
LINE=$(grep -n "wlan0-" ${HOSTAPD} | cut -d':' -f1)
if [ $TQ -gt $UPPER_LIMIT ]; then
	if [ $OI_IS_DISABLED == 1 ]; then
		echo "Gateway TQ: $TQ; node is still online"
	else
		logger -s -t "ssid-notifier" -p 5 "node is online; Gateway TQ: $TQ; disable offline-SSID"
		if [ "${LINE_IN_HOSTAPD}" == "" ]; then
			uci set $OI.disabled='1'
			uci commit $OI; wifi; exit
		else
			echo "$(awk -v RS= -v ORS='\n\n' '/ssid='"${OFFLINE_SSID}"'/{sub(/ignore_broadcast_ssid=0/,"ignore_broadcast_ssid=1")} 1' $HOSTAPD)" > $HOSTAPD
			HUP_NEEDED=1
		fi
	fi
else
	if [ $OI_IS_DISABLED == 0 ]; then
		echo "Gateway TQ: $TQ; node is still considered offline"
	else
		logger -s -t "ssid-notifier" -p 5 "node is offline; Gateway TQ: $TQ; enable offline-SSID"
		if [ "${LINE_IN_HOSTAPD}" == "" ]; then
			uci set $OI.disabled='0'
			uci commit $OI; wifi; exit
		else
			echo "$(awk -v RS= -v ORS='\n\n' '/ssid='"${OFFLINE_SSID}"'/{sub(/ignore_broadcast_ssid=1/,"ignore_broadcast_ssid=0")} 1' $HOSTAPD)" > $HOSTAPD
			HUP_NEEDED=1
		fi
	fi
fi

if [ $HUP_NEEDED == 1 ]; then
	# Send HUP to all hostapd um die neue SSID zu laden
	killall -SIGHUP hostapd
	HUP_NEEDED=0
	echo "SIGHUP!"
fi
