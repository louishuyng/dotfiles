#!/bin/sh

export BLUE=#62A2D5
export CYAN=#90C6B2
export WHITE=#B1B1B2

IP_ADDRESS=$(scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1)
IS_VPN=$(scutil --nwi | grep -m1 'utun' | awk '{ print $1 }')

if [[ $IS_VPN != "" ]]; then
	COLOR=$CYAN
	ICON=
	LABEL="VPN"
elif [[ $IP_ADDRESS != "" ]]; then
	COLOR=$BLUE
	ICON=
	LABEL=$IP_ADDRESS
else
	COLOR=$WHITE
	ICON=
	LABEL="Not Connected"
fi

echo $IP_ADDRESS
echo $IP_VPN

sketchybar --set $NAME background.color=$COLOR \
	icon=$ICON \
	label="$LABEL"
