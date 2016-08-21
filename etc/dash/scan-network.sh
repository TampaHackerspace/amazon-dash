#!/bin/bash

# Scan the current network for IP addresses with a specific port open. This port defaults to 80
# to scan for port 22 then pass 80

PORT=$1


find_all_ip(){
 # find the IP address that have port $PORT open on the local network
 # scan all network adapters and get IP/Netmask for each
for adapter in $(ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d'); do

        # get Netmask and IP
        IP_ADDR=`ifconfig $adapter | grep "inet " | cut -d ':' -f 2 | cut -d ' ' -f 1`
        NET_ADDR=`ifconfig $adapter | grep "inet " | rev | cut -d ':' -f 1 | rev`

        # Generate "start" address.
        IFS=. read -r i1 i2 i3 i4 <<< $IP_ADDR
        IFS=. read -r m1 m2 m3 m4 <<< $NET_ADDR
        NET_START=`printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))"`
        if [ "$NET_START" == "0.0.0.0" ]
                then
                  # Skip start address of 0.0.0.0
                  continue
        fi

        # Show all IP addresses with $PORT open
        nmap -n -p$PORT $NET_START/24 -oG - | grep "$PORT/open" | awk '{print $2}'
done
return $RETVAL
}


if [ -z $PORT ]
  then
    echo "Usage: $0 port# "
  else
    find_all_ip
fi
