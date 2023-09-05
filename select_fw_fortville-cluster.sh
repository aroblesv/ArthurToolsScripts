#!/bin/bash
echo -e "check what fw you have\r\n"
read -p "write your system: " node
NICNAME=$(ssh root@${node} "nmcli d|grep -v 'disconnected' |grep -E ^ens[[:digit:]]f0|grep -i connected| cut -d ' ' -f1")

if [ -z "$NICNAME" ]; then
	NICDEV=$(ssh root@${node} "nmcli d| grep -v 'disconnected'| grep -E ^ens[[:digit:]][[:digit:]]f0|grep -i connected| cut -d ' ' -f1")	
	echo -e "\nWired connection device: $NICDEV\r\n"
else
	NICDEV=$(ssh root@${node} "nmcli d| grep -v 'disconnected'| grep -E ^ens[[:digit:]]f0|grep -i connected| cut -d ' ' -f1")
	echo -e "\nWired connection device: $NICDEV\r\n"
fi	

NICFW=$(ssh root@${node} "ethtool -i ${NICDEV} |grep -i firmware|cut -d ' ' -f2")
echo -e "\nThe system $node have this FW: $NICFW\r\n"

echo -e "\nTo downgrade is available: a)8.60 to 8.10 b)8.50 to 8.10 c)8.40 to 8.10 d)8.30 to 8.10\r\n"
echo -e "\nTo upgrade is available: a)upgrade fw to 8.60\r\n"
echo -e "\nDo you need to downgrade or update?\n\rSelect an option\n\r"
echo -e "\n1) for downgrade or 2) for update\r\n"
read -p "write your option: " option
echo "your selection is: $option"

	case $option in
		1) echo "you selected to downgrade"
			echo "Select one firmware a)8.60 to 8.10 b)8.50 to 8.10 c)8.40 to 8.10 d)8.30 to 8.10"
			read -p "write a letter: " fwdwn
			echo "your selection is: $fwdwn"
				case $fwdwn in 
					a) echo "downgrade 8.60 to 8.10";
						s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')";
						ssh root@${node} "curl -LO http://${s3web_url}/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v8_60_to_v8_10_Linux.tar.gz";
						ssh root@${node} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v8_60_to_v8_10_Linux.tar.gz; 
						cd 700Series/Linux_x64; chmod 777 nvmupdate64e; chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg";
 						ssh root@${node} "rm -rf 700Series; rm -f 700Series_NVMDowngradePackage_v8_60_to_v8_10_Linux.tar.gz; reboot 0";;
					b) echo "downgrade 8.50 to 8.10";
						s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')";
						ssh root@${node} "curl -LO http://${s3web_url}/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v8_50_to_v8_10_Linux.tar.gz";
						ssh root@${node} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v8_50_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64;
									chmod 777 nvmupdate64e; chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg";
						ssh root@${node} "rm -rf 700Series; rm -f 700Series_NVMDowngradePackage_v8_50_to_v8_10_Linux.tar.gz; reboot 0";;
					c) echo "downgrade 8.40 to 8.10";
						s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')";
						ssh root@${node} "curl -LO http://${s3web_url}/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v8_40_to_v8_10_Linux.tar.gz";
						ssh ${node} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v8_40_to_v8_10_Linux.tar.gz; cd 700Series/Linux_x64;
								chmod 777 nvmupdate64e; chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg";
						ssh root@${node} "rm -rf 700Series; rm -f 700Series_NVMDowngradePackage_v8_40_to_v8_10_Linux.tar.gz; reboot 0";;
					d) echo "downgrade 8.30 to 8.10";;
						s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')";
						ssh root@${node} "curl -LO http://${s3web_url}/bkc-mirror/wilson_city/network_fw/700Series_NVMDowngradePackage_v8_10_Linux.tar.gz";
						ssh ${node} "rm -rf 700Series; tar -xvf 700Series_NVMDowngradePackage_v8_10_Linux.tar.gz; cd 700Series/Linux_x64; 
						chmod 777 nvmupdate64e; chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg";
						ssh ${node} "rm -rf 700Series; rm -f 700Series_NVMDowngradePackage_v8_10_Linux.tar.gz; reboot 0";;
					*) echo "not a valid letter";;
				esac;;
	  
		2) echo "you selected to upgrade"
			echo "Select one firmware a)upgrade fw to 8.60"
			read -p "write a letter: " fwuwn
			echo "your selection is: $fwuwn"
				case $fwuwn in 
					a) echo "upgrade 8.10,8,30,8.40,8.50 to 8.60";
						s3web_url="$(ping -c2 s3web | grep statistics | sed 's/.*s3web/s3web/g' | awk '{ printf $1 }')";
						ssh root@${node} "curl -LO http://${s3web_url}/bkc-mirror/wilson_city/network_fw/700Series_NVMUpdatePackage_v8_60_Linux.tar.gz";
						#scp 700Series_NVMUpdatePackage_v8_60_Linux.tar.gz root@${node}:/root/; 
						ssh root@${node} "rm -rf 700Series; tar -xvf 700Series_NVMUpdatePackage_v8_60_Linux.tar.gz; 
						cd 700Series/Linux_x64; chmod 777 nvmupdate64e; chmod 777 nvmupdate.cfg; ./nvmupdate64e -u -l -o update.xml -c nvmupdate.cfg;";
						ssh root@${node} "rm -rf 700Series; rm -f 700Series_NVMUpdatePackage_v8_60_Linux.tar.gz; reboot 0";;
					#b) echo "udpgrade 8.10 to 8.50";;
					#c) echo "upgrade 8.10 to 8.40";;
					*) echo "not a valid letter";;
				esac;;
		*) echo "not a valid letter";; 
	esac

