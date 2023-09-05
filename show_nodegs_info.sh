#!/bin/bash

NODE_ID=$1
CURRENT=`pwd`
$CURRENT/clean_known_hosts.sh $NODE_ID

port=22
connect_timeout=5
timeout $connect_timeout bash -c "</dev/tcp/$NODE_ID/$port"
if [ $? == 0 ];then
    ssh_status="ssh_ok"
else
    ssh_status="ssh_fail"
fi

timeup=`ssh root@${NODE_ID} -n "uptime -p"`
Name_image=`ssh root@${NODE_ID} -n "cat /etc/motd |grep -i 'image version'|cut -d ' ' -f3"`
kernel="$(ssh root@${NODE_ID} 'uname -r')"
microcode="$(ssh root@${NODE_ID} 'grep microcode /proc/cpuinfo|tail -n 1 |cut -d ":" -f2')"
bios_ver="$(ssh root@${NODE_ID} 'dmidecode -s bios-version')"
BMC_VER="$(./get_bmc_info.py -M $NODE_ID |cut -d ',' -f2)"
CPLD_VER="$(./get_bmc_info.py -M ${NODE_ID}| cut -d ',' -f5)"
NIC_NAMEF=$(ssh root@${NODE_ID} "nmcli d |grep -v 'disconnected' |grep -E ^en.[[:digit:]]f0|grep -i connected|cut -d ' ' -f1")
NIC_NAMEC=$(ssh root@${NODE_ID} "nmcli d |grep -E ^ens4f0|cut -d ' ' -f1")

#NIC_NAME2=$(ssh root@${NODE_ID} "nmcli d |grep -v 'disconnected' |grep -E ^enp"

if [ -z "$NIC_NAMEF" ]; then
	NICDEVF=$(ssh root@${NODE_ID} "nmcli d|grep -v 'disconnected' |grep -E ^en.|grep -i connected|cut -d ' ' -f1")
	NICFWF=$(ssh root@${NODE_ID} "ethtool -i $NICDEVF|grep -i firmware|cut -d ' ' -f2")
else
	NICDEVF=$(ssh root@${NODE_ID} "nmcli d|grep -v 'disconnected' |grep -E ^en.|grep -i connected|cut -d ' ' -f1")
	NICFWF=$(ssh root@${NODE_ID} "ethtool -i $NICDEVF|grep -i firmware|cut -d ' ' -f2")
fi	

if [ -z "$NIC_NAMEC" ]; then
	NICDEVC=$(ssh root@${NODE_ID} "nmcli d|grep -E ^ens4f0|cut -d ' ' -f1")
	NICFWC=$(ssh root@${NODE_ID} "ethtool -i $NICDEVC|grep -i firmware|cut -d ' ' -f2")
else
	NICDEVC=$(ssh root@${NODE_ID} "nmcli d|grep -E ^ens4f0|cut -d ' ' -f1")
	NICFWC=$(ssh root@${NODE_ID} "ethtool -i $NICDEVC|grep -i firmware|cut -d ' ' -f2")
fi	
echo -e "\r$timeup|$NODE_ID|$ssh_status|$bios_ver|$microcode|$BMC_VER|$CPLD_VER|$NICFWF|$NICFWC|$Name_image|$kernel" 

#echo -e "\n\r\033[32mSystem:\033[0m $NODE_ID\n\033[33m$Name_image\033[0m\n\033[032mKernel:\033[0m $kernel\n\033[32mBios version:\033[0m $bios_ver\n\033[32mBMC version:\033[0m $BMC_VER\n\033[32mUcode:\033[0m $microcode"


