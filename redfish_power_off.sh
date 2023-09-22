#!/bin/bash
# Script to Force Restart system through Redfish

NODE=${1}
LIST_FILE=../data/nodes
BMC_FQDN=`grep $NODE $LIST_FILE | cut -d"," -f2`
echo "Turning system off through BMC: ${BMC_FQDN}"
RESET=`timeout 5 curl -k -s -X POST https://${BMC_FQDN}/redfish/v1/Systems/system/Actions/ComputerSystem.Reset -H 'Content-Type: application/json' -H 'Authorization: Basic ZGVidWd1c2VyOjBwZW5CbWMx' -H 'Cache-Control: no-cache' -d '{"ResetType": "ForceOff"}' | grep MessageId | cut -d "\"" -f 4`
echo "${NODE}, Request status: ${RESET}" 
