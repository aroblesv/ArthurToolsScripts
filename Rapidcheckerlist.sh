#!/bin/bash

function Checker {
node=($1);

echo "##############################################################################################################"
echo -e "\033[34m${node[0]} Showing BKC failures\033[0m"
echo "##############################################################################################################"

CbmcBios=$(ssh ${node[0]} 'dmidecode -s bios-version')
CbmcCpld=$(./get_bmc_info.py -M ${node[0]}| cut -d ',' -f5)
CbmcVer=$(./get_bmc_info.py -M ${node[0]} |cut -d ',' -f2)
CosKernel=$(ssh ${node[0]} 'uname -r')
CUcode=$(ssh ${node[0]} 'grep microcode /proc/cpuinfo |tail -n1'| cut -d ":" -f2|cut -d " " -f2)
CosCLV1=$(ssh ${node[0]} 'ethtool -i ens2f0np0'| grep -i firmware| awk '{print $2}')
CosCLV2=$(ssh ${node[0]} 'ethtool -i ens4f0np0'| grep -i firmware| awk '{print $2}')
CNET_INTERFACE=$(ssh ${node[0]} 'ip -brief a'|grep 10.219*|awk '{print $1}')
CosFTVFw=$(ssh ${node[0]} "ethtool -i ${CNET_INTERFACE}"| grep -i firmware|cut -d " " -f2)
#Cm2Version=$(ssh ${node[0]} 'intelmas show -intelssd 0'| grep -i firmware|awk '{print $3}')
CosArbFw=$(ssh ${node[0]} 'intelmas show -intelssd 1'| grep -i firmware|awk '{print $3}') 


if [[ "$EbmcBios" = "$CbmcBios" ]]; then
	echo -e "\033[0mBios: \033[32mDone\033[0m"
else
	echo -e "\033[0mBios: \033[33m\"Need update\"\033[0m | Current Bios: \033[31m$CbmcBios\033[0m | Bios Requested: \033[33m$EbmcBios\033[0m"
fi

if [[ "$CbmcCpld" = "$EbmcCpld" ]]; then
	echo -e "\033[0mCPLD: \033[32mDone\033[0m"
else
	echo -e "\033[0mCPLD: \033[33m\"Need update\"\033[0m | Current CPLD: \033[31m$CbmcCpld\033[0m | CPLD Requested: \033[33m$EbmcCpld\033[0m"
fi

if [[ "$CbmcVer" = "$EbmcVer" ]]; then
	echo -e "\033[0mBMC: \033[32mDone\033[0m"
else
	echo -e "\033[0mBMC: \033[33m\"Need update\"\033[0m | Current BMC: \033[31m$CbmcVer\033[0m | BMC Requested: \033[33m$EbmcVer\033[0m"
fi

if [[ "$CosKernel" = "$EosKernel" ]]; then
	echo -e "\033[0mKernel: \033[32mDone\033[0m"
else
	echo -e "\033[0mKernel: \033[33m\"Need update\"\033[0m | Current Kernel: \033[31m$CosKernel\033[0m | Kernel Requested: \033[33m$EosKernel\033[0m"
fi

if [[ "$CUcode" = "$EUcode" ]]; then
	echo -e "\033[0muCode: \033[32mDone\033[0m"
else
	echo -e "\033[0muCode: \033[33m\"Need update\"\033[0m | Current uCode: \033[31m$CUcode\033[0m | uCode Requested: \033[33m$EUcode\033[0m"
fi

if [[ "$CosCLV1" = "$EosCLV1" ]]; then
	echo -e "\033[0mColumbia1: \033[32mDone\033[0m"
else
	echo -e "\033[0mColumbia1: \033[33m\"Need update\"\033[0m | Current Columbia1: \033[31m$CosCLV1\033[0m | Columbia1 Requested: \033[33m$EosCLV1\033[0m"
fi

if [[ "$CosCLV2" = "$EosCLV2" ]]; then
	echo -e "\033[0mColumbia2: \033[32mDone\033[0m"
else
	echo -e "\033[0mColumbia2: \033[33m\"Need update\"\033[0m | Current Columbia2: \033[31m$CosCLV2\033[0m | Columbia2 Requested: \033[33m$EosCLV2\033[0m"
fi

if [[ "$CosFTVFw" = "$EosFTVFw" ]]; then
	echo -e "\033[0mFortville: \033[32mDone\033[0m"
else
	echo -e "\033[0mFortville: \033[33m\"Need update\"\033[0m | Current Fortville: \033[31m$CosFTVFw\033[0m | Fortville Requested: \033[33m$EosFTVFw\033[0m"
fi

if [[ "$CosArbFw" = "$EosArbFw" ]]; then
	echo -e "\033[0mArbord: \033[32mDone\033[0m"
else
	echo -e "\033[0mArbord: \033[33m\"Need update\"\033[0m | Current Arbord: \033[31m$CosArbFw\033[0m | Arbord Requested: \033[33m$EosArbFw\033[0m"
fi


}

#./memories_awk4.sh ${node[0]}

#echo -e "$CbmcBios\n$CbmcCpld\n$CbmcVer\n$CosKernel\n$CUcode\n$CosCLV1\n$CosCLV2\n$CNET_INTERFACE\n$CosFTVFw\n$Cm2Version\n$CosArbFw"



#echo "Copy one project of these : GDC_EMR / GDC_ICX / GDC_EGS / GDC_CTL"
#read -p "Typing Project code: " Pcode

#python ~/openstack-scripts/verification_tools/bkc_checker/bkcManager.py -l | grep $Pcode > Checkerinfo.csv

#cat Checkerinfo.csv

#echo "Now Select a specific BKC"

#read -p "Typing Specific BKC: " BKC

#python ~/openstack-scripts/verification_tools/bkc_checker/bkcManager.py -b $BKC -s > CheckerDetail.csv

#cat CheckerDetail.csv

EbmcBios=`grep bmcBiosVersion CheckerDetail.csv |cut -d ' ' -f2`
EbmcCpld=`grep bmcCpldVersion CheckerDetail.csv |cut -d ' ' -f2`
EbmcVer=`grep bmcVersion CheckerDetail.csv |cut -d ' ' -f2`
EosKernel=`grep osKernelVersion CheckerDetail.csv |cut -d ' ' -f2`
EUcode=`grep osUcode CheckerDetail.csv |cut -d ' ' -f2`
EosCLV1=`grep osCLV1FwVersion CheckerDetail.csv |cut -d ' ' -f2`
EosCLV2=`grep osCLV2FwVersion CheckerDetail.csv |cut -d ' ' -f2`
EosFTVFw=`grep osFTVFwVersion CheckerDetail.csv |cut -d ' ' -f2`
EosArbFw=`grep osArbFwVersion CheckerDetail.csv |cut -d ' ' -f2`

#read -p "Typing your list: " list

list=full_list2

nodes=$(grep "zp31" ${list})

if [ -z "${nodes}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${nodes}; do
	Checker $n
done
