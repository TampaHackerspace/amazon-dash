#!/bin/bash
# prerequisites
#sudo apt get install curl jq

# This script is

#ACTION=$1
#DEVICE=$2

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/hue.config"

COLOR_GREEN="\"hue\":85,\"sat\":255,\"bri\":128"
COLOR_RED="\"hue\":0,\"sat\":255,\"bri\":255"
COLOR_WHITE="\"hue\":0,\"sat\":0,\"bri\":255"
COLOR_YELLOW="\"hue\":43,\"sat\":255,\"bri\":128"
COLOR_BLUE="\"hue\":170,\"sat\":255,\"bri\":128"
COLOR_PINK="\"hue\":213,\"sat\":255,\"bri\":128"

COLOR_GREEN="\"xy\":[0.17,0.7]"
COLOR_RED="\"xy\":[0.6705,0.3204]"
COLOR_WHITE="\"xy\":[0.4255,0.3998]"
COLOR_YELLOW="\"xy\":[0.428,0.5024]"
COLOR_BLUE="\"xy\":[0.168.0.041]"
COLOR_PINK="\"xy\":[0.3824,0.1601]"


test_hue_ip(){
  # Test IP address to determine if this is a Philips Hue Bridge
  TEST_IP=$1
  if [ -z "$TEST_IP" ]
    then
      return 0;
  else
      TEST_IP_RESULT=$(curl -m 2 -s -X HEAD http://$TEST_IP | grep -o "$HUE_SEARCH_STRING")
      if [ "$TEST_IP_RESULT" == "$HUE_SEARCH_STRING" ]
       then
         # This contains " hue " in the HEAD request output
         echo " IP Address $TEST_IP is likely a Hue Bridge. Probing for Hue API"
         HUE_PROBE_RESPONSE=$(curl -s -X POST -d '{"devicetype":"hue_script"}'  http://$TEST_IP/api/ | jq -r '.[0] | .error.description + .success.username')
         if [ "$HUE_PROBE_RESPONSE" == "$HUE_BUTTON_SEARCH_STRING" ]
           then
             echo " IP Address $TEST_IP is a Hue Bridge"
             return 1
         fi
      else
         return 0
      fi
  fi
}

find_hue_ip(){
 # find the IP address of the hue bridge on the network
  HUE_IP=
  RETVAL=0
  for ip in `./scan-network.sh 80`; do
    echo "Probing $ip"
    test_hue_ip $ip
    if [ $? == 1 ]
      then
        HUE_IP=$ip
        return 1
        break
    else
        continue
    fi
  done
return $RETVAL
}
show-lights(){
  # get lights from HUE bridge and display them with respective ID values
  curl -s http://$BRIDGE/api/$USER/lights | jq -r 'keys[] as $k | "\($k)=\(.[$k] | .name) (\(.[$k] | if (.state.on == "true") then "On" else "Off" end))"'
}

configure_hue(){
  # find HUE Bridge

HUE_IP=$3

if  [ -n "$BRIDGE" ]
  then
    test_hue_ip $BRIDGE
    if [ $? == 1 ]
      then
        echo "Bridge IP already configured"
        HUE_IP=$BRIDGE
    fi
fi

if [ -z "$HUE_IP" ]
  then
    echo "trying to locate HUE"
  find_hue_ip
  if [ "$?" == "0" ]
    then
      echo "Unable to locate bridge from automatic scan of network"
  else
      echo "Hue device found @ $HUE_IP. writing hue.config..."
      sed -i 's,^\(BRIDGE=\).*,\1'$HUE_IP',' hue.config
      BRIDGE=$HUE_IP
  fi
else
  echo "testing for Hue @ $HUE_IP"
  test_hue_ip $HUE_IP
  if [ $? == 0 ]
    then
      echo "Unable to validate provided IP address as a Hue Bridge: $HUE_IP"
  else
    echo "Hue device found @ $HUE_IP. writing hue.config..."
    sed -i 's,^\(BRIDGE=\).*,\1'$HUE_IP',' hue.config
    BRIDGE=$HUE_IP
  fi

fi

if [ -z "$USER" ]
  then
    # Ask user to press button
    USER=$(curl -s -X POST -d '{"devicetype":"hue_script"}'  http://$BRIDGE/api/ | jq -r '.[0] | .error.description + .success.username')
    while [ "$USER" == 'link button not pressed' ]; do
      # Ask user to press button
      read -s -n1 -r -p "Press button on Hue Bridge and then press space to continue..." key
      echo ""
      USER=$(curl -s -X POST -d '{"devicetype":"hue_script"}'  http://$BRIDGE/api/ | jq -r '.[0] | .error.description + .success.username')
    done
    echo "Hue device token fetched ($USER). writing hue.config..."
    sed -i 's,^\(USER=\).*,\1'$USER',' hue.config
fi
  # fetch API token
  # configure config file with HUE config values
}

light_on(){
    curl -w "\n" -s -X PUT -d '{"on":true$BRI}'  http://$BRIDGE/api/$USER/lights/$DEVICE/state
}

light_off(){
    curl -w "\n" -s -X PUT -d '{"on":false}'  http://$BRIDGE/api/$USER/lights/$DEVICE/state
}

light_toggle(){
    light_status
    if [ "$STATUS" == "true" ]
        then
            light_off
        else
            light_on
    fi

}

light_status(){
    STATUS=$(curl -w "\n" -s http://$BRIDGE/api/$USER/lights/$DEVICE | jq '.|.state.on')
}

light_color_get(){

  COLOR=$(curl -w "\n" -s http://$BRIDGE/api/$USER/lights/$DEVICE | jq '.|.state.xy' | sed ':a;N;$!ba;s/[\n \t]//g')
  if [[ "\"xy\":$COLOR" == "$COLOR_GREEN" ]]; then
    COLOR="green"
  elif [[ "\"xy\":$COLOR" == *"$COLOR_RED"* ]]; then
    COLOR="red"
  elif [[ "\"xy\":$COLOR" == *"$COLOR_BLUE"* ]]; then
    COLOR="blue"
  elif [[ "\"xy\":$COLOR" == *"$COLOR_PINK"* ]]; then
    COLOR="pink"
  elif [[ "\"xy\":$COLOR" == *"$COLOR_WHITE"* ]]; then
    COLOR="white"
  elif [[ "\"xy\":$COLOR" == *"$COLOR_YELLOW"* ]]; then
    COLOR="yellow"
  fi
  echo $COLOR
}

light_color_set(){
    curl -w "\n" -s -X PUT -d "{$COLOR$BRI}"  http://$BRIDGE/api/$USER/lights/$DEVICE/state
}

while [ "$1" != "" ]; do
  case $1 in
    -d | --device )           shift
                              DEVICE=$1
                              ;;
      -a | --action )         shift
		              ACTION=$1
                              ;;
      -c | --color )          shift
                              COLOR=$1
                              ;;
      -b | --brightness )     shift
			      BRIGHT=$1
			      ;;
      * )                     usage
                              exit 1
  esac
  shift
done


if [ "${ACTION,,}" = "color" ]; then
  case ${COLOR,,} in
    red | r ) 
      COLOR=$COLOR_RED
      ;;
    yellow | y )
      COLOR=$COLOR_YELLOW
      ;;
    green | g )
      COLOR=$COLOR_GREEN
      ;;
    white | w )
      COLOR=$COLOR_WHITE
      ;;
    blue | b )
      COLOR=$COLOR_BLUE
      ;;
    pink | p )
      COLOR=$COLOR_PINK
      ;;
  esac
fi

BRI=
if [[ "$BRIGHT" != "" ]]; then
 BRI=",\"bri\":$BRIGHT"
fi


case "$ACTION" in
  color)
    if [ "$COLOR" = "" ]; then
      light_color_get
    else
      light_color_set
    fi
    ;;

  on)
    light_on
    ;;
  off)
    light_off
    ;;
  toggle)
    light_toggle
    ;;
  status)
    light_status
    ;;
  autoconfig)
    configure_hue
    ;;
  lights)
    show-lights
    ;;
  *)
    echo "Usage: $0 {-d|--device} # {-a|--action} {on|off|toggle|status|autoconfig|lights|color} [-b|--brightness 0-255] [-c|--color [red|yellow|white|green|blue|pink]]"
esac
