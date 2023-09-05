#!/bin/bash
NODE_ID=$1
Name_image=`ssh $NODE_ID -n "cat /etc/motd |grep -i 'image version'"`
kernel="$(ssh root@${NODE_ID} 'uname -r')"
microcode="$(ssh root@${NODE_ID} 'dmesg | grep microcode | grep revision= |tail -c11')"
bios_ver="$(ssh root@${NODE_ID} 'dmidecode -s bios-version')"
BMC_VER="$(./get_bmc_info.py -M $NODE_ID |cut -d ',' -f2)"
echo -e "\n\r\033[32mSystem:\033[0m $NODE_ID\n\033[33m$Name_image\033[0m\n\033[032mKernel:\033[0m $kernel\n\033[32mBios version:\033[0m $bios_ver\n\033[32mBMC version:\033[0m $BMC_VER\n\033[32mUcode:\033[0m $microcode"

./check_fwnic_fortville_cluster.sh $NODE_ID
