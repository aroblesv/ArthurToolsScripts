#!/bin/bash

#set -o xtrace

: "${1?Must provide node name}"

source ../openstack-scripts/functions

NODE=$1
FILENAME=../openstack-scripts/data/nodes
#CSV_ADDR=`readlink -f ${FILENAME}`
name=`grep $NODE $FILENAME | cut -d "," -f 1`
bmc_add=`grep $NODE $FILENAME | cut -d "," -f 2`
bmc_user=`grep $NODE $FILENAME | cut -d "," -f 3`
bmc_pass=`grep $NODE $FILENAME | cut -d "," -f 4`

[[ -z "$name" ]] && echo 'Invalid name - check data/nodes link to correct file' && exit 1

ping $NODE -c 1 2>&1 1>/dev/null
if [ "$?" == "0" ]; then
   echo "Setting boot order to provision ${NODE}"
   node_fix_boot_order.sh ${NODE}
   sleep 1 
   # Force turning off system through Redfish
   echo "Turning off system through redfish"
   redfish_power_off.sh ${NODE}
   sleep 10
   provision_node $name
else
   echo "System ${NODE} is not reachable, are you sure you want to attempt to provision it? (y/n)"
   read ANS
   if [[ "${ANS}" =~ .*"y".* || "${ANS}" =~ .*"Y".* ]]; then
      provision_node $name
   else   
      echo "${NODE} will not be provisioned."
   fi   
fi

