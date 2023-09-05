#!/bin/bash

node_id=$1
macos=`ssh $node_id -n "efibootmgr"|grep -i pxev4|grep -i 40 |head -n 1|cut -d ':' -f2|cut -c 1-12`
macopenstack=`openstack baremetal port list --node $node_id -c Address -f value|sed -e 's/://g'|tr [:lower:] [:upper:]`
echo -e "\n\033[0mMAC_OperativeSystem :\t\033[32m$macos\033[0m\r"
echo -e "\033[0mMAC_OpenStack :\t\t\033[32m$macopenstack\033[0m"

