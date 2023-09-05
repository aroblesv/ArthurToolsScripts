#!/bin/bash
# Script to run OS updates with ironic for a list of nodes

#echo "Please make sure you are not trying to provision more than 10 systems at a time."
#sleep 2s
#echo "Please."
#sleep 5s 
#Parameters
CURRENT=`pwd`
LIST_FILE=$CURRENT/$1
IMAGE=$2

echo "Exporting QCOW2_IMGNAME='$IMAGE'"
export QCOW2_IMGNAME="$IMAGE"

while read node
      do
        [[ "${node:0:1}" == "#" ]] && continue
        NODE_ID=`grep $node $LIST_FILE | cut -d"," -f 1`
	echo "-------------------------------------------------------------------------------"
        echo "Attempting to provision ${NODE_ID}..."
        $CURRENT/provision_node.sh ${NODE_ID} 
      done < $LIST_FILE

