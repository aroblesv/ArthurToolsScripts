#!/bin/bash

: "${1?Must provide node name}"

NODE_ID="${1}"

s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"

ssh ${NODE_ID} "mkdir driver_fw"
ssh root@${NODE_ID} "cd /root/driver_fw; curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/iavf-4.7.zip"
ssh root@${NODE_ID} "cd /root/driver_fw; curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/ice-1.10.1.2.zip"
ssh root@${NODE_ID} "cd /root/driver_fw; curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/E810_NVMUpdatePackage_v4_30_Linux.tar.gz"

ssh ${NODE_ID} "cd /root/driver_fw; unzip iavf-4.7.zip; cd iavf-4.7.0/iavf-4.7.0/src; make install;cd /root/driver_fw; unzip ice-1.10.1.2.zip; cd ice-1.10.1.2.2/src/; make install; cd /root/driver_fw; tar -xvf E810_NVMUpdatePackage_v4_30_Linux.tar.gz; cd E810/Linux_x64; chmod 777 nvmupdate64e nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg;"

ssh ${NODE_ID} "rm -rf /root/driver_fw; reboot 0"
