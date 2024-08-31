#!/bin/bash
NODE_ID=${1}
BMC_ID=$(echo ${NODE_ID} | sed '0,/s/s//b/')
echo -e "\n"
echo "executing ipmi set none in: ${NODE_ID}"
SET_NONE=`ipmitool -I lanplus -H ${BMC_ID} -C 17 -U debuguser -P 0penBmc1 chassis bootdev none options=persistent`
echo -e "${NODE_ID} | $SET_NONE"
