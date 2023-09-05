#!/bin/bash
#Parameters

#Local Variables
opc_yes=yes
read -p "type your list: " list
echo -e "\r\nbmc list\r\n"
tr 's' 'b' < $list > full_listbmc
cat -n full_listbmc
read -p "your list is correct type yes or no to continue: " opc_typed
if [ $opc_typed = $opc_yes ]; then
	FULL_LIST="full_listbmc"
	sed -e 's:^:ipmitool -I lanplus -H :g' "$FULL_LIST" > turnon_light_list.sh 
	sed -i "s/$/ -C 17 -U debuguser -P 0penBmc1 chassis identify force \&/" turnon_light_list.sh
	echo "file turnon_light_list.sh was successfully created"
	else
	exit 1
fi
