#!/bin/bash

NODE_ID=$1

kernel="$(ssh root@${NODE_ID} 'uname -r')"
#microcode="$(ssh root@${NODE_ID} 'dmesg | grep microcode | grep revision= | tail -c11')"
microcode="$(ssh root@${NODE_ID} 'grep microcode /proc/cpuinfo |tail -n 1 |cut -d ":" -f2')"
bios_ver="$(ssh root@${NODE_ID} 'dmidecode -s bios-version')"
bmc_ver="$(./get_bmc_info.py -M $NODE_ID |cut -d ',' -f2)"
timeup=`ssh root@${NODE_ID} -n "uptime -p"`
echo -e "\rOs_info_Centos: $NODE_ID | $kernel | $bios_ver | $microcode | $bmc_ver |$timeup"
