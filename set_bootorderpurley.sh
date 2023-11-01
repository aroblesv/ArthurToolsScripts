#!/bin/bash
NODE_ID=$1

echo "executing node_pxe_boot in: $NODE_ID"

centos1st=`ssh ${NODE_ID} -n "efibootmgr" |grep -i centos|cut -c 5-8`

MISC_ID=`ssh ${NODE_ID} -n "efibootmgr" | grep 'UEFI Misc Device' | cut -c 5-8`

THIRD_ID=`ssh ${NODE_ID} -n "efibootmgr" | grep 'Launch EFI Shell' | cut -c 5-8`

FOURTH_ID=`ssh ${NODE_ID} -n "efibootmgr" | grep 'Enter Setup' | cut -c 5-8`


ssh ${NODE_ID} -n "efibootmgr -o $centos1st,$THIRD_ID,$FOURTH_ID,$MISC_ID"
