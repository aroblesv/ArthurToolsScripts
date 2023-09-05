#!/bin/bash
#Parameters
: "${1?Must provide node name}"

NODE_ID=${1}
DUPLICATE="$(ssh root@${NODE_ID} 'efibootmgr| cut -d " " -f 2|sort|grep -ic centos')"

if [ "$DUPLICATE" -ge "2" ]; then
   echo -e "\r$NODE_ID Centos is duplicated in efibootmgr, please remove with efibootmgr -b XXXX -B command"
else
   echo -e "\r$NODE_ID Centos is not duplicated in efibootmgr, good you can send Os provision"
fi
