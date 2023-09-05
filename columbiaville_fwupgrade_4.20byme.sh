#!/bin/bash

: "${1?Must provide node name}"

NODE_ID="${1}"

scp E810_NVMUpdatePackage_v4_20_Linux.tar.gz root@${NODE_ID}:/root/

ssh root@${NODE_ID} "rm -rf E810; tar -xvf E810_NVMUpdatePackage_v4_20_Linux.tar.gz; cd E810/Linux_x64; chmod 777 nvmupdate64e; chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"

ssh root@${NODE_ID} "rm -rf E810; reboot 0"

