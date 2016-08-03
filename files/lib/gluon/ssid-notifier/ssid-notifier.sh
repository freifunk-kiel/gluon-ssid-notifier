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

if [ ! $GATEWAY_TQ ]; # if there is no gateway there will be errors in the following if clauses
then
	GATEWAY_TQ=0 # just an easy way to get a valid value if there is no gateway
fi

if [ $GATEWAY_TQ -gt $UPPER_LIMIT ];
then
	logger -s -t "gluon-offline-notifier" -p 5 "Gateway TQ is $GATEWAY_TQ node is online"
	uci set wireless.client_radio0_offline=wifi-iface
	uci set wireless.client_radio0_offline.network='client'
	uci set wireless.client_radio0_offline.device='radio0'
	uci set wireless.client_radio0_offline.mode='ap'
	uci set wireless.client_radio0_offline.ssid="${OFFLINE_SSID}"
	uci set wireless.client_radio0_offline.disabled='1'
	uci commit wireless.client_radio0_offline
	wifi
fi

if [ $GATEWAY_TQ -lt $LOWER_LIMIT ];
then
	logger -s -t "gluon-offline-notifier" -p 5  "Gateway TQ is $GATEWAY_TQ node is considered offline"
	uci set wireless.client_radio0_offline=wifi-iface
	uci set wireless.client_radio0_offline.network='client'
	uci set wireless.client_radio0_offline.device='radio0'
	uci set wireless.client_radio0_offline.mode='ap'
	uci set wireless.client_radio0_offline.ssid="${OFFLINE_SSID}"
	uci set wireless.client_radio0_offline.disabled='0'
	uci commit wireless.client_radio0_offline
	wifi
fi

if [ $GATEWAY_TQ -ge $LOWER_LIMIT -a $GATEWAY_TQ -le $UPPER_LIMIT ]; # this is just get a clean run if we are in-between the grace periode
then
	echo "TQ is $GATEWAY_TQ, do nothing"
	HUP_NEEDED=0
fi

if [ $HUP_NEEDED == 1 ]; then
	killall -HUP hostapd # send HUP to all hostapd to load the new SSID
	HUP_NEEDED=0
	echo "HUP!"
fi
