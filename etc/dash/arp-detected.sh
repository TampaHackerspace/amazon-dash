#!/bin/bash
# This script will acccept the MAC address as the first item on the command line.
# If there is a configuration directory for the MAC address then each of the
# executable scripts are executed in the mac-<ADDRESS>.d directory

# Get the MAC address from the command line
MAC_ADDRESS=$1
# pid file will prevent multiple silmutaneous executions
PIDFILE=/var/run/dash-button-$MAC_ADDRESS.pid
# Directory that contains executavle scripts for this MAC address
PROCESS_DIRECTORY=/etc/dash/mac-$1.d

if [ ! -e $PIDFILE ]
  then
    if [ -d $PROCESS_DIRECTORY ]
    	then
        touch $PIDFILE
        echo "`date +%Y%m%d_%H24%M%S` Processing click for $MAC_ADDRESS"
        for i in $(find $PROCESS_DIRECTORY -executable -type f | sort); do
          echo "`date +%Y%m%d_%H24%M%S` Executing $i for $MAC_ADDRESS"
          sh $i $MAC_ADDRESS
        done
        # This delay will prevent closely spaced button clicks or ARP requests (ringing)
        sleep 3
        rm $PIDFILE
    fi
fi
