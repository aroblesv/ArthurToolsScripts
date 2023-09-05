#!/bin/bash

#Parameters
: "${1?Must provide node name}"

NODE_ID=$1

echo -e "enable DAM_script on the node: $NODE_ID"
cd /var/local/cluster/
./set_DAM_production_BIOS_Knobs_2unlock.sh -M $NODE_ID
echo -e "\nThe system will be restarted 2 more times."
cd /var/local/cluster-tools/
./InventoryCollector_wrapper.sh -M $NODE_ID DAM
