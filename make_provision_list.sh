#!/bin/bash
opc_yes=yes
read -p "Type your list: " list
echo -e "\r\nContents of the list"
cat -n $list
echo -e "\r\nHow to work with this list?\r\n" 
read -p "Type yes to continue or no to exit: " opc_typed
	if [ $opc_yes = $opc_typed ]; then
		sed -e 's:^:yes | ./provision_node.sh :g' $list > send_provision_list.sh
		sed -i 's/$/\ \&/' send_provision_list.sh
		echo "Your run file has been successfully created: send_provision_list.sh"
	else
		exit 1
	fi
