#!/bin/bash

#sudo apt get install curl jq

DEVICE=$1
ACTION=$2

if [ "$DEVICE" == "autoconfig" ] || [ "$DEVICE" == "lights" ]
  then
    ACTION=$DEVICE
fi
source hue.config

test_hue_ip(){
  # Test IP address to determine if this is a Philips Hue Bridge
  TEST_IP=$1
  if [ -z "$TEST_IP" ]
    then
      return 0;
  else
        curl -m 2 -s -X HEAD http://$TEST_IP | grep hue  >> /dev/null 2>&1 &&
                return 1  ||
                return 0

  fi
}

find_hue_ip(){
 # find the IP address of the hue bridge on the network
for adapter in $(ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d'); do
        # get Netmask

        IP_ADDR=`ifconfig $adapter | grep "inet " | cut -d ':' -f 2 | cut -d ' ' -f 1`
        NET_ADDR=`ifconfig $adapter | grep "inet " | rev | cut -d ':' -f 1 | rev`

        IFS=. read -r i1 i2 i3 i4 <<< $IP_ADDR
        IFS=. read -r m1 m2 m3 m4 <<< $NET_ADDR
        NET_START=`printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))"`
        if [ "$NET_START" == "0.0.0.0" ]
                then
                        continue
        fi

        HUE_IP=
        RETVAL=0
        for ip in $(nmap -n -p80 $NET_START/24 -oG - | grep "80/open" | awk '{print $2}'); do
                test_hue_ip $ip
                if [ $? == 1 ]
                  then
                    HUE_IP=$ip
                    RETVAL=1
                    break
                else
                        continue
                fi
        done
done
return $RETVAL
}
show-lights(){
  # get lights from HUE bridge and display them with respective ID values
  curl http://$BRIDGE/api/$USER/lights
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
    curl -s -X PUT -d '{"on":true}'  http://$BRIDGE/api/$USER/lights/$DEVICE/state
}

light_off(){
    curl -s -X PUT -d '{"on":false}'  http://$BRIDGE/api/$USER/lights/$DEVICE/state
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
    STATUS=$(curl -s http://$BRIDGE/api/$USER/lights/$DEVICE | jq '.|.state.on')
}


case "$ACTION" in
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
    echo "Usage: $0 # {on|off|toggle|status|autoconfig|lights}"
esac
