#!/bin/bash
# Add keys, isdct tool & efibootmgr to SVOS nodes
NODE_ID=${1}
echo -e "\rexecute bootdev none"
ssh ${NODE_ID} -n "ipmitool chassis bootdev none"   
