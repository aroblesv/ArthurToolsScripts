#!/bin/bash
#simple script to reviwe ssh connection
#Parameters
CURRENT=`pwd`
LIST_FILE=$1
#LIST_FILE=$CURRENT/$1

#Local Variables


CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"

echo -e "\n\e[4mGetting fw fortiville info\e[0m"
echo -n "Obtainnig info 1..."
sleep 1
echo -e "\\r${CHECK_MARK} List fw fortville info done"

while read node
	do
	  [[ "${node:0:1}" == "#" ]] && continue
	  NODE_ID=`grep $node $LIST_FILE | cut -d "," -f 1`
	$CURRENT/check_fwnic_fortville_cluster.sh $NODE_ID &
	done < $LIST_FILE

