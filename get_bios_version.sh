#!/bin/bash

#Parameters
: "${1?Must provide node name}"

NODE_ID=$1

Bios_ver=`ssh $NODE_ID -n "dmidecode -s bios-version"` 

echo "bios version in node: ${NODE_ID} is: $Bios_ver"

