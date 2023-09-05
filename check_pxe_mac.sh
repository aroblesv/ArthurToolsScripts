#!/bin/bash
NODE_ID=$1
MAC_NODE=`openstack baremetal port list --node $NODE_ID -c Address -f value`
echo -e "\r$NODE_ID | $MAC_NODE| SET IN PXE"
