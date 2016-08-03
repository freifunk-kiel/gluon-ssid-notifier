#!/bin/sh

# At first some Definitions:

ONLINE_SSID=$(uci get wireless.client_radio0.ssid -q)
: ${ONLINE_SSID:=FREIFUNK}   # if for whatever reason ONLINE_SSID is NULL
OFFLINE_PREFIX='FF kein Netz:' # Use something short to leave space for the nodename

UPPER_LIMIT='55' # Above this limit the offline SSID will be off
LOWER_LIMIT='45' # Below this limit the offline SSID will be on
# In-between these two values the SSID will never be changed to preven it from toggeling every Minute.

# Generate an Offline SSID with the first and last Part of the nodename to allow owner to recognise wich node is down
NODENAME=`uname -n`
if [ ${#NODENAME} -gt $((30 - ${#OFFLINE_PREFIX})) ] ; then # 32 would be possible as well
	HALF=$(( (28 - ${#OFFLINE_PREFIX} ) / 2 )) # calculate the length of the first part of the node identifier in the offline-ssid
	SKIP=$(( ${#NODENAME} - $HALF )) # jump to this charakter for the last part of the name
	OFFLINE_SSID="$OFFLINE_PREFIX${NODENAME:0:$HALF}..${NODENAME:$SKIP:${#NODENAME}}" # use the first and last part of the nodename for nodes with long name
else
	OFFLINE_SSID="$OFFLINE_PREFIX$NODENAME" # great! we are able to use the full nodename in the offline ssid
fi

#is there an active gateway?
GATEWAY_TQ=$(batctl gwl | grep "^=>" | awk -F '[()]' '{print $2}' | tr -d " ") # grep the connection quality of the currently used gateway

OI=wireless.client_radio0_offline

IF_EXISTS=$(uci get $OI -q)

if [ ! $IF_EXISTS ]; then
	uci set $OI=wifi-iface
	uci set $OI.network='client'
	uci set $OI.device='radio0'
	uci set $OI.mode='ap'
	uci set $OI.disabled='1'
	uci set $OI.ssid="${OFFLINE_SSID}"
fi

DISABLED=$(uci get $OI.disabled -q)
HUP_NEEDED=0

if [ ! $GATEWAY_TQ ]; then
	echo "TQ: '$GATEWAY_TQ', wifi still running? do nothing"
elif [ $GATEWAY_TQ -ge $LOWER_LIMIT -a $GATEWAY_TQ -le $UPPER_LIMIT ]; then 
	# this is just get a clean run if we are in-between the grace periode
	echo "TQ: $GATEWAY_TQ, this is between $LOWER_LIMIT and $UPPER_LIMIT; do nothing"
elif [ $GATEWAY_TQ -gt $UPPER_LIMIT ]; then
	if [ $DISABLED == 1 ]; then
		echo "Gateway TQ: $GATEWAY_TQ; node is still online"
	else
		logger -s -t "ssid-notifier" -p 5 "Gateway TQ is $GATEWAY_TQ node changed to online"
		uci set $OI.disabled='1'
		uci commit $OI
		HUP_NEEDED=1
	fi
else
	if [ $DISABLED == 0 ]; then
		echo "Gateway TQ: $GATEWAY_TQ; node is still considered offline"
	else
		logger -s -t "ssid-notifier" -p 5 "Gateway TQ is $GATEWAY_TQ node is considered offline"
		uci set $OI.disabled='0'
		uci commit $OI
		HUP_NEEDED=1
	fi
fi

if [ $HUP_NEEDED == 1 ]; then
	wifi
	HUP_NEEDED=0
	echo "HUP!"
fi
