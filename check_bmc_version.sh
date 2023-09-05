#!/bin/bash
#Parameters
: "${1?Must provide node name}"
NODE_ID=$1
BMC_VER="$(./get_bmc_info.py -M $NODE_ID | cut -d ',' -f2)"
echo -e "\r$NODE_ID | BMC_VERSION: $BMC_VER"
