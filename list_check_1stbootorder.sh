#!/bin/bash
#simple script to get microcode revision
#Parameters
CURRENT=`pwd`
LIST_FILE=$1
#LIST_FILE=$CURRENT/$1

#Local Variables

echo -e "\nScript to find the 1st boot order"
echo "***************************************"
while read node
	do
	  [[ "${node:0:1}" == "#" ]] && continue
	  NODE_ID=`grep $node $LIST_FILE | cut -d "," -f 1`
	$CURRENT/check_1stbootorder.sh $NODE_ID &
	done < $LIST_FILE

