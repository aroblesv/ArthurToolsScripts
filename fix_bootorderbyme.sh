#!/bin/bash
NODE_ID=${1}

FIRST=$(ssh ${NODE_ID} -n 'efibootmgr |cut -d " " -f1,2 |rev|sort|rev|grep -i centos|tail -n1|cut -c5-8')
SECOND=$(ssh ${NODE_ID} -n 'efibootmgr |grep -i misc | cut -c5-8')
THIRD=$(ssh ${NODE_ID} -n 'efibootmgr |grep -i shell | cut -c5-8')
FOURTH=$(ssh ${NODE_ID} -n 'efibootmgr |grep -i setup | cut -c5-8')
FIFTH=$(ssh ${NODE_ID} -n 'efibootmgr |grep -i "boot device" | cut -c5-8')

echo "New BootOrder: ${SECOND},${THIRD},${FOURTH},${FIFTH}"
echo "------------------------------------------------------------------------"
ssh ${NODE_ID} -n "efibootmgr -o ${FIRST},${SECOND},${THIRD},${FOURTH},${FIFTH}"

