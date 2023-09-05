#!/bin/bash

function turnon_bluelight {
	
	read -p "Write an option: 1) for turn on lights or 2) for turn off lights" option
	
	case $option in

	1) 	NODE=($1);
		BMC_ID=$(echo $NODE | sed '0,/s/s//b/');
		echo -e "\n";
		echo "**turn on blue light in: $node **";
		TURNON_BLIGHT=`ipmitool -I lanplus -H $BMC_ID -C 17 -U debuguser -P 0penBmc1 chassis identify 1`;
		echo -e "NODE | $TURNON_BLIGHT";;

	2) 	NODE=($1);
		BMC_ID=$(echo $NODE | sed '0,/s/s//b/');
		echo -e "\n";
		echo "**turn off blue light in: $node **";
		TURNOFF_BLIGHT=`ipmitool -I lanplus -H $BMC_ID -C 17 -U debuguser -P 0penBmc1 chassis identify 0`;
		echo -e "NODE | $TURNOFF_BLIGHT";;
	*)	echo "not is a valid option";;
	esac;;
}


CURRENT=`pwd`
OPC_YES=yes
OPC_NO=no
nodes=$(grep r..s $LIST)


read -p "type your list: " LIST
echo -e "\r\nIs this your list?\r\n"
read -p "if your list is correct type yes to continueor or no to exit: " OPC_TYPED
if [ $OPC_TYPED = $OPC_YES ]; then
	cat -n $LIST

elif [$OPC_TYPED = $OPC_NO ]; then
	exit 1
else


for n in $nodes; do
	turnon_bluelight $n
done
