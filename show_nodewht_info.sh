#!/bin/bash
NODE_ID=$1

port=22
connect_timeout=5
timeout $connect_timeout bash -c "</dev/tcp/$NODE_ID/$port"
if [ $? == 0 ];then
    ssh_status="ssh_ok"
else
    ssh_status="ssh_fail"
fi

Name_image=`ssh root@${NODE_ID} -n "cat /etc/motd |grep -i 'image version'|cut -d ' ' -f3"`
kernel="$(ssh root@${NODE_ID} 'uname -r')"
microcode="$(ssh root@${NODE_ID} 'dmesg | grep microcode | grep revision= |tail -c11|cut -d '=' -f2')"
bios_ver="$(ssh root@${NODE_ID} 'dmidecode -s bios-version')"
BMC_VER="$(./get_bmc_info.py -M $NODE_ID |cut -d ',' -f2)"

NIC_NAME=$(ssh root@${NODE_ID} "nmcli d |grep -v 'disconnected' |grep -E ^ens[[:digit:]]f0|grep -i connected|cut -d ' ' -f1")


if [ -z "$NIC_NAME" ]; then
	NICDEV=$(ssh root@${NODE_ID} "nmcli d|grep -v 'disconnected' |grep -E ^ens|grep -i connected|cut -d ' ' -f1")
	NICFW=$(ssh root@${NODE_ID} "ethtool -i $NICDEV|grep -i firmware|cut -d ' ' -f2")
else
	NICDEV=$(ssh root@${NODE_ID} "nmcli d|grep -v 'disconnected' |grep -E ^ens|grep -i connected|cut -d ' ' -f1")
	NICFW=$(ssh root@${NODE_ID} "ethtool -i $NICDEV|grep -i firmware|cut -d ' ' -f2")
fi	

echo -e "\r$NODE_ID|$ssh_status|$bios_ver|$microcode|$BMC_VER|$NICFW|$Name_image|$kernel" 

#echo -e "\n\r\033[32mSystem:\033[0m $NODE_ID\n\033[33m$Name_image\033[0m\n\033[032mKernel:\033[0m $kernel\n\033[32mBios version:\033[0m $bios_ver\n\033[32mBMC version:\033[0m $BMC_VER\n\033[32mUcode:\033[0m $microcode"


