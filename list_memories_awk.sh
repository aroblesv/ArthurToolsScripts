#!/bin/bash
#simple script to get memories size and location
#Parameters
CURRENT=`pwd`
LIST_FILE=$1
#LIST_FILE=$CURRENT/$1

#Local Variables


while read node
	do
	  [[ "${node:0:1}" == "#" ]] && continue
	  NODE_ID=`grep $node $LIST_FILE | cut -d "," -f 1`
	$CURRENT/memories_awk4.sh $NODE_ID &
	done < $LIST_FILE

