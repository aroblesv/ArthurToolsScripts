#!/bin/bash
NODE_ID=$1

echo "executing node_pxe_boot in: $NODE_ID"

PXE_ID=`ssh ${NODE_ID} -n "efibootmgr" | grep -i pxev4 |grep -i '40a' |head -n1|cut -c 5-8`

SSD_ID=`ssh ${NODE_ID} -n "efibootmgr" | grep -i 'intel' | head -n1 |  cut -c 5-8`

THIRD_ID=`ssh ${NODE_ID} -n "efibootmgr" | grep 'UEFI Internal Shell' | cut -c 5-8`

FOURTH_ID=`ssh ${NODE_ID} -n "efibootmgr" | grep 'Enter Setup' | cut -c 5-8`


ssh ${NODE_ID} -n "efibootmgr -o $PXE_ID,$SSD_ID,$THIRD_ID,$FOURTH_ID"
