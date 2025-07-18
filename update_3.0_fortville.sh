#!/bin/bash
NODE_ID=$1
EXPECTED_FW=$2
NICNAME=$(ssh root@$NODE_ID "nmcli d|grep -v 'disconnected' |grep -E ^ens[[:digit:]]f0|grep -i connected| cut -d ' ' -f1")

if [ -z "$NICNAME" ]; then
	NICDEV=$(ssh root@$NODE_ID "nmcli d| grep -v 'disconnected'| grep -E ^ens[[:digit:]][[:digit:]]f0|grep -i connected| cut -d ' ' -f1")	
	echo -e "\nWired connection device: $NICDEV\r\n"
else
	NICDEV=$(ssh root@$NODE_ID "nmcli d| grep -v 'disconnected'| grep -E ^ens[[:digit:]]f0|grep -i connected| cut -d ' ' -f1")
	echo -e "\nWired connection device: $NICDEV\r\n"
fi	

CURRENT_FW=$(ssh root@$NODE_ID "ethtool -i $NICDEV |grep -i firmware|cut -d ' ' -f2")

echo -e "\nThe system $NODE_ID have this CURRENT FW $CURRENT_FW and your EXPECTED FW is $EXPECTED_FW\r\n"

<< 'MULTILINE-COMMENT'
if  [[ "$EXPECTED_FW" > "$CURRENT_FW" ]]; then 
	echo "you need to update your firmware"
	
elif [[ "$EXPECTED_FW" < "$CURRENT_FW" ]]; then
	echo "you need to downgrade your firmware"
else
	echo "you don't need update"
fi
MULTILINE-COMMENT

if [[ "$EXPECTED_FW" > "$CURRENT_FW" ]]; then
	echo "need to update"
	if [[ "$EXPECTED_FW" = "8.10" ]]; then
		echo "updating to $EXPECTED_FW version"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v8_10_Linux.tar.gz"
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"

	elif [[ "$EXPECTED_FW" = "8.60" ]]; then
		echo "updating to $EXPECTED_FW version"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v8_60_Linux.tar.gz"
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v8_60_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	
	elif [[ "$EXPECTED_FW" = "8.70" ]]; then
		echo "updating to $EXPECTED_FW version"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v8_70_Linux.tar.gz"
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v8_70_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	
	elif [[ "$EXPECTED_FW" = "9.00" ]]; then
		echo "updating to $EXPECTED_FW version"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v9_00_Linux.tar.gz"
		#scp 700Series_NVMUpdatePackage_v9_00_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v9_00_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	
        elif [[ "$EXPECTED_FW" = "9.20" ]]; then
		echo "updating to $EXPECTED_FW version"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v9_20_Linux.tar.gz"
		#scp 700Series_NVMUpdatePackage_v9_00_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v9_20_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"

        elif [[ "$EXPECTED_FW" = "9.30" ]]; then
		echo "updating to $EXPECTED_FW version"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v9_30_Linux.tar.gz"
		#scp 700Series_NVMUpdatePackage_v9_00_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v9_30_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"

        elif [[ "$EXPECTED_FW" = "9.40" ]]; then
		echo "updating to $EXPECTED_FW version"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v9_40_Linux.tar.gz"
		#scp 700Series_NVMUpdatePackage_v9_00_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v9_40_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"

        elif [[ "$EXPECTED_FW" = "9.50" ]]; then
		echo "updating to $EXPECTED_FW version"
		#s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		#ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v9_40_Linux.tar.gz"
		scp 700Series_NVMUpdatePackage_v9_52_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v9_52_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"

        elif [[ "$EXPECTED_FW" = "9.52" ]]; then
		echo "updating to $EXPECTED_FW version"
		#s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		#ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v9_40_Linux.tar.gz"
		scp 700Series_NVMUpdatePackage_v9_52_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v9_52_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"

        elif [[ "$EXPECTED_FW" = "9.53" ]]; then
		echo "updating to $EXPECTED_FW version"
		#s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		#ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v9_40_Linux.tar.gz"
		scp 700Series_NVMUpdatePackage_v9_53_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v9_53_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"

        elif [[ "$EXPECTED_FW" = "9.54" ]]; then
		echo "updating to $EXPECTED_FW version"
		#s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
		#ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v9_40_Linux.tar.gz"
		scp 700Series_NVMUpdatePackage_v9_54_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v9_54_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	fi
fi

if [[ "$EXPECTED_FW" < "$CURRENT_FW" ]]; then
	echo "need to downgrade"
	if [[ "$CURRENT_FW" = "8.30" ]]; then
		echo "downloading system firmware to $EXPECTED_FW"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
                ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v8_10_Linux.tar.gz"
                ssh ${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
                chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
                ssh ${NODE_ID} "rm -rf 700Series; reboot 0"	
	elif [[ "$CURRENT_FW" = "8.60" ]]; then
		echo "downloading system firmware to $EXPECTED_FW"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
  		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v8_60_to_v8_10_Linux.tar.gz"
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v8_60_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	elif [[ "$CURRENT_FW" = "8.70" ]]; then
		echo "downloading system firmware to $EXPECTED_FW"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
  		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v8_70_to_v8_10_Linux.tar.gz"
		#scp 700Series_NVMDowngradePackage_v8_10_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v8_70_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	elif [[ "$CURRENT_FW" = "9.00" ]]; then
		echo "downloading system firmware to $EXPECTED_FW"
		#s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
  		#ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v8_70_to_v8_10_Linux.tar.gz"
		scp 700Series_NVMDowngradePackage_v9.00_to_v8_10_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v9.00_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	elif [[ "$CURRENT_FW" = "9.20" ]]; then
		echo "downloading system firmware to $EXPECTED_FW"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
  		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v9_20_to_v8_10_Linux.tar.gz"
		#scp 700Series_NVMUpdatePackage_v9_20_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v9_20_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	elif [[ "$CURRENT_FW" = "9.30" ]]; then
		echo "downloading system firmware to $EXPECTED_FW"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
  		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v9_30_to_v8_10_Linux.tar.gz"
		#scp 700Series_NVMUpdatePackage_v9_20_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v9_30_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	
	elif [[ "$CURRENT_FW" = "9.40" ]]; then
		echo "downloading system firmware to $EXPECTED_FW"
		s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
  		ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v9_40_to_v8_10_Linux.tar.gz"
		#scp 700Series_NVMUpdatePackage_v9_20_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v9_40_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	
	elif [[ "$CURRENT_FW" = "9.50" ]]; then
		echo "downloading system firmware to $EXPECTED_FW"
		#s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
  		#ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v9_40_to_v8_10_Linux.tar.gz"
		scp 700Series_NVMDowngradePackage_v9_50_to_v8_10_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v9_50_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"

	elif [[ "$CURRENT_FW" = "9.53" ]]; then
		echo "downloading system firmware to $EXPECTED_FW"
		#s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
  		#ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v9_40_to_v8_10_Linux.tar.gz"
		scp 700Series_NVMDowngradePackage_v9_53_to_v8_10_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v9_53_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"

	elif [[ "$CURRENT_FW" = "9.54" ]]; then
		echo "downloading system firmware to $EXPECTED_FW"
		#s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')"
  		#ssh root@${NODE_ID} "curl -LO --noproxy '*' http://${s3web_url}/download/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v9_40_to_v8_10_Linux.tar.gz"
		scp 700Series_NVMDowngradePackage_v9_54_to_v8_10_Linux.tar.gz root@${NODE_ID}:/root/
		ssh root@${NODE_ID} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v9_54_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; chmod 777 nvmupdate64e; 
		chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg"
		ssh root@${NODE_ID} "rm -rf 700Series; reboot 0"
	fi

else
echo the system has the same firmware, nothing to do!!!
fi
