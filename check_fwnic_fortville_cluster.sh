#!/bin/bash
#Parameters
: "${1?Must provide node name}"

NODE_ID=${1}
NIC_NAME=$(ssh root@${NODE_ID} "nmcli d | grep -v 'disconnected' | grep -E ^ens[[:digit:]]f0 | grep -i connected | cut -d ' ' -f1")

if [ -z "$NIC_NAME" ]; then 
	echo -e "\033[32m the name of the interface is not the standard one in $NODE_ID"
		NICDEV=$(ssh root@${NODE_ID} "nmcli d| grep -v 'disconnected'| grep -E ^ens[[:digit:]][[:digit:]]f0|grep -i connected| cut -d ' ' -f1")
		NICFW=$(ssh root@${NODE_ID} "ethtool -i $NICDEV| grep -i firmware| cut -d ' ' -f2")
		echo -e "\033[0m \\r$NODE_ID | $NICDEV  | \033[33m $NICFW \033[0m"
else	
	echo -e "\033[32m the name of the interface is the stadard one in $NODE_ID"
	NICDEV=$(ssh root@${NODE_ID} "nmcli d| grep -v 'disconnected'| grep -E ^ens[[:digit:]]f0|grep -i connected| cut -d ' ' -f1")
	NICFW=$(ssh root@${NODE_ID} "ethtool -i $NICDEV| grep -i firmware| cut -d ' ' -f2")
      	echo -e "\033[0m \\r$NODE_ID | $NIC_NAME   | \033[33m $NICFW \033[0m" 
fi

