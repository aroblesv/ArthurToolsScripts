#!/bin/bash
NODE_ID=${1}
BMC_ID=$(echo ${NODE_ID} | sed '0,/s/s//b/')
echo -e "\n"
echo "executing power reset with ipmitool in: $NODE_ID"
SEND_RESET=`ipmitool -I lanplus -H $BMC_ID -C 17 -U debuguser -P 0penBmc1 chassis power reset`
echo -e "$NODE_ID | $SEND_RESET"
