#!/bin/bash
NODE_ID=$1
ARGU=$2
ssh root@${NODE_ID} "efibootmgr -n $2"
./ipmi_reset.sh ${NODE_ID}
