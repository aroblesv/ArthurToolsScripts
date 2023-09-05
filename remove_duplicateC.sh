#!/bin/bash

NODE_ID=$1
ARGU=$2

duplicate=$(ssh root@${NODE_ID} 'efibootmgr| grep -i centos')
boots=$(ssh root@${NODE_ID} 'efibootmgr |grep -i boot[co]')


echo "Duplicates"
echo "$boots"
echo "$duplicate"
echo "Select and Write 4 digit to argument to remove"
if [ -z "$2" ]; then
exit 1
else
ssh root@${NODE_ID} "efibootmgr -b $2 -B"
./check_duplicate_centos.sh ${NODE_ID}
./set_bootorderwht.sh ${NODE_ID}
./check_1stbootorder.sh ${NODE_ID}
fi
