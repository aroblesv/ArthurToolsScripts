#!/bin/bash
NODE_ID=$1

F_BOOTORD=`ssh $NODE_ID -n "efibootmgr" |grep -i bootorder |cut -c11-15`
NAMEF_BOOTORD=`ssh $NODE_ID -n "efibootmgr" |grep $F_BOOTORD| tail -n1`  
echo -e "\rNode $NODE_ID set $NAMEF_BOOTORD as first boot order"
