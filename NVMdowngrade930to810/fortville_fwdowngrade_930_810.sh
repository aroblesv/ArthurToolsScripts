#!/bin/bash

: "${1?Must provide node name}"

NODE_ID="${1}"

scp 700Series_NVMDowngradePackage_v9_30_to_v8_10_Linux.tar.gz root@${NODE_ID}:/root/

ssh root@${NODE_ID} "rm -rf 700Series; tar -xvzf 700Series_NVMDowngradePackage_v9_30_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e;
                     chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"

