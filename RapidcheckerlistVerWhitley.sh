#!/bin/bash

function Checker {

node=($1);

#ping -c1 ${node[0]} &> /dev/null || exit 1

#echo "ssh connection successful ${node[0]} obtaining information from the node"

echo -e "\t${node[0]} \t$BKC" >> header_RChecker

CbmcBios=$(ssh ${node[0]} 'dmidecode -s bios-version')
CbmcCpld=$(./get_bmc_info.py -M ${node[0]}| cut -d ',' -f5)
CbmcVer=$(./get_bmc_info.py -M ${node[0]} |cut -d ',' -f2)
CosKernel=$(ssh ${node[0]} 'uname -r')
CUcode=$(ssh ${node[0]} 'grep microcode /proc/cpuinfo |tail -n1'| cut -d ":" -f2|cut -d " " -f2)
#CosCLV1=$(ssh ${node[0]} 'ethtool -i ens2f0np0'| grep -i firmware| awk '{print $2}')
#CosCLV2=$(ssh ${node[0]} 'ethtool -i ens4f0np0'| grep -i firmware| awk '{print $2}')
CNET_INTERFACE=$(ssh ${node[0]} 'ip -brief a'|grep 10.219*|awk '{print $1}'|head -n1)
CosFTVFw=$(ssh ${node[0]} "ethtool -i ${CNET_INTERFACE}"| grep -i firmware|cut -d " " -f2)
CosM2Version=$(ssh ${node[0]} 'intelmas show -intelssd 0'| grep -i firmware|awk '{print $3}' |head -n1)
#CosArbFw=$(ssh ${node[0]} 'intelmas show -intelssd 1'| grep -i firmware|awk '{print $3}') 


if [[ "$EbmcBios" = "$CbmcBios" ]]; then
	echo "Bios Done" >> CheckerStatus
else
	echo "Bios Fail" >> CheckerStatus
fi

if [[ "$CbmcCpld" = "$EbmcCpld" ]]; then
	echo "CPLD Done" >> CheckerStatus
else
	echo "CPLD Fail" >> CheckerStatus
fi

if [[ "$CbmcVer" = "$EbmcVer" ]]; then
	echo "BMC Done" >> CheckerStatus
else
	echo "BMC Fail" >> CheckerStatus
fi

if [[ "$CosKernel" = "$EosKernel" ]]; then
	echo "Kernel Done" >> CheckerStatus
else
	echo "Kernel Fail" >> CheckerStatus
fi

if [[ "$CUcode" = "$EUcode" ]]; then
	echo "uCode Done" >> CheckerStatus
else
	echo "uCode Fail" >> CheckerStatus
fi

if [[ "$CosFTVFw" = "$EosFTVFw" ]]; then
	echo "Fortville Done" >> CheckerStatus
else
	echo "Fortville Fail" >> CheckerStatus
fi

if [[ "$CosM2Version" = "$EosM2Version" ]]; then
	echo "M2 Done" >> CheckerStatus
else
	echo "M2 Fail" >> CheckerStatus
fi

#echo -e "$CbmcBios\n$CbmcCpld\n$CbmcVer\n$CosKernel\n$CUcode\n$CosCLV1\n$CosCLV2\n$CNET_INTERFACE\n$CosFTVFw\n$Cm2Version\n$CosArbFw"

}





echo "Copy one project of these : GDC_EMR / GDC_ICX / GDC_EGS / GDC_CTL"
read -p "Typing Project code: " Pcode

python ~/openstack-scripts/verification_tools/bkc_checker/bkcManager.py -l | grep $Pcode > Checkerinfo.csv

cat Checkerinfo.csv

echo "Now Select a specific BKC"

read -p "Typing Specific BKC: " BKC

python ~/openstack-scripts/verification_tools/bkc_checker/bkcManager.py -b $BKC -s > CheckerDetail.csv

#cat CheckerDetail.csv

EbmcBios=`grep bmcBiosVersion CheckerDetail.csv |cut -d ' ' -f2`
EbmcCpld=`grep bmcCpldVersion CheckerDetail.csv |cut -d ' ' -f2`
EbmcVer=`grep bmcVersion CheckerDetail.csv |cut -d ' ' -f2`
EosKernel=`grep osKernelVersion CheckerDetail.csv |cut -d ' ' -f2`
EUcode=`grep osUcode CheckerDetail.csv |cut -d ' ' -f2`
#EosCLV1=`grep osCLV1FwVersion CheckerDetail.csv |cut -d ' ' -f2`
#EosCLV2=`grep osCLV2FwVersion CheckerDetail.csv |cut -d ' ' -f2`
EosFTVFw=`grep osFTVFwVersion CheckerDetail.csv |cut -d ' ' -f2`
EosM2Version=`grep osM2FwVersion CheckerDetail.csv |cut -d ' ' -f2`

read -p "Typing your list: " list

echo -e "\nGenerating info..wait 1 minute aprox"
echo "########################################################################################################################"
echo "Verifying Bios: $EbmcBios"
echo "Verifying CPLD: $EbmcCpld"
echo "Verifying BMC: $EbmcVer"
echo "Verifying Kernel: $EosKernel"
echo "Verifying uCode: $EUcode"
#echo "Verifying Columbia1: $EosCLV1"
#echo "Verifying Columbia2: $EosCLV1"
echo "Verifying Fortvile: $EosFTVFw"
echo "Verifying M2: $EosM2Version"
echo "########################################################################################################################"

nodes=$(grep "zp31" ${list})

if [ -z "${nodes}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${nodes}; do
	Checker $n
done

#cat CheckerStatus
cp CheckerStatus regCheckerStatus
#sed -i 's/\:/ /g' regCheckerStatus
awk '
BEGING{ FS="i " }
/^Bios/{
  if(++count1==1){ header=$1 }
  biosArr[++count]=$NF
  next
}
/^CPLD/{
  if(++count2==1){ header=header OFS $1 }
  cpldArr[count]=$NF
  next
}
/^BMC/{
  if(++count3==1){ header=header OFS $1 }
  bmcArr[count]=$NF
  next
}
/^Kernel/{
  if(++count4==1){ header=header OFS $1 }
  kernelArr[count]=$NF
  next
}
/^uCode/{
  if(++count5==1){ header=header OFS $1 }
  ucodeArr[count]=$NF
  next
}
/^Fortville/{
  if(++count8==1){ header=header OFS $1 }
  fortvilleArr[count]=$NF
  next
}
/^M2/{
  if(++count9==1){ header=header OFS $1 }
  M2Arr[count]=$NF
  next
}
END{
  print header
  for(i=1;i<=count;i++){
  printf("%s %s %s %s %s %s %s\n",biosArr[i],cpldArr[i],bmcArr[i],kernelArr[i],ucodeArr[i],fortvilleArr[i],M2Arr[i])
  }
}
' regCheckerStatus | column -t > CheckerColumns
#cat CheckerColumns

sed -i '1i\\t\tSystem_ID\t\t\tChecker' header_RChecker

cp header_RChecker regheader_RChecker

paste CheckerColumns regheader_RChecker > CheckerListInfo

cp CheckerListInfo regCheckerListInfo

rm -rf CheckerListInfo

grep --color -E '^|Fail|' regCheckerListInfo

#cat CheckerListInfo

rm -rf CheckerStatus

rm -rf header_RChecker

grep -i fail ./regCheckerListInfo |awk '{print $8}' > full_list2

echo "Showing BKC failures"

./RapidcheckerlistWhitley.sh

