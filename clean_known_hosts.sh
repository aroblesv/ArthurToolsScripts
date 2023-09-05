#!/bin/bash

NODE_ID=$1
BMC_ID=$(echo $NODE_ID | sed '0,/s/s//b/')
echo -e "\n"
echo "executing clean_known_hosts in: $NODE_ID"
echo "executing clean_known_hosts in: $BMC_ID"
sed -i "/${NODE_ID}/d" ~/.ssh/known_hosts
sed -i "/${BMC_ID}/d" ~/.ssh/known_hosts
