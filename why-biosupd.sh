#!/bin/bash
: "${1?Must provide node name}"

NODE_ID=$1

scp ofu_BiosUpdate16928.tar.gz ${NODE_ID}:/home/
ssh ${NODE_ID} -n "cd /home/; tar -xvf ofu_BiosUpdate16928.tar.gz;cd /home/ofu_BiosUpdate16928/OFU/Linux_x64/RHEL/RHEL8/; rpm -ivh flashupdt-V14.1-B31.x86_64.rpm;cd /home/ofu_BiosUpdate16928/;
		   echo -e '1\\n3\\' | ./startup.sh"
