#!/bin/bash

#sudo apt get install curl jq

DEVICE=$1
ACTION=$2
# Replace with the IP address of your Hue bridge
BRIDGE=<IP_ADDRESS>
# get Username (http://www.developers.meethue.com/documentation/getting-started)
# curl -s -X POST -d '{"devicetype":"hue_script"}'  http://$BRIDGE/api/ '.[0] | .error.description + .success.username'
USER=<USER_ID>


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
  *)
    echo "Usage: $0 # {on|off|toggle|status}"
esac

