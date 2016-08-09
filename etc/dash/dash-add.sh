#!/bin/bash

# This script will add a config folder for new Dash buttons

MAC=$( echo $1 | sed 's/[:-]//g' | tr '[:upper:]' '[:lower:]')

echo Adding configuration for $MAC ...

cp -r mac-00112233445566.d mac-$MAC.d

echo Configuration folder added at `pwd`/mac-$MAC.d
