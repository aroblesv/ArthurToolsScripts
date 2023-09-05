#!/bin/bash
#Parameters
: "${1?Must provide node name}"
NODE_ID=$1
CPLD_VER="$(./get_bmc_info.py -M $NODE_ID | cut -d ',' -f5)"
echo -e "\r$NODE_ID | CPLD_VERSION: $CPLD_VER"
