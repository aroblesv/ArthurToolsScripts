#!/bin/bash
opc_yes=yes
read -p "Type the file list name: " list
echo -e "\r\nContents of the list"
cat -n $list
echo -e "\r\nHow to work with this list?\r\n"
read -p "Type yes to continue or no to exit: " opc_typed
	if [ $opc_yes = $opc_typed ]; then
		tr 's' 'b' < $list > full_listbmc
		sed -e 's/$/\.deacluster.intel.com/' full_listbmc > webviewss
		sed -i 's/^/https:\/\//g' webviewss
		cat webviewss
	else
		exit 1
	fi
