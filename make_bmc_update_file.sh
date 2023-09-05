#!/bin/bash
#simple scripts to make file
#Parameters

#Local Variales
#FULL_LIST="full_list"
#BMC_OOB="OBMC-wht-1.01-75-g3685a0-31e5d79-pfr-oob.bin"

opc_yes=yes

echo -e "\r\nThese are the bmc versions available on your local system\r\n"
ls -l OBMC* |awk '{print $9}'
echo -e "\r\nComplete the following data\r\n" 
read -p "Type one BMC version: " BMC_OOB
echo -e "\r\nYou have chosen the following version: $BMC_OOB\r\n"
read -p "Type your list: " list
echo -e "\r\nContents of the list\r\n" 
cat -n $list
echo -e "\r\nIs your data correct?\r\n"
read -p "yes or no: " opc_typed
	if [ $opc_yes = $opc_typed ]; then
		sed -e 's:^:./node_update_bmc.py --send -M :g' "$list" > run_list_bmc_update.sh
		sed -i "s/$/\ -d gdc -f $BMC_OOB \&/" run_list_bmc_update.sh
		echo "The executable file was successfully created: run_list_bmc_update.sh"
		else
		exit 1
	fi
