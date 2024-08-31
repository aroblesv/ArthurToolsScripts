#!/bin/bash
# simple script to run BKC checker for all nodes in a list

#Parameters
CURRENT=`pwd`
LIST_FILE=${1}
BKC_ID=${2}
while read node
      do
        [[ "${node:0:1}" == "#" ]] && continue
        NODE_ID=`grep $node $LIST_FILE | cut -d"," -f 1`
        $CURRENT/ctl_bat.sh $NODE_ID ${BKC_ID} 
      done < $LIST_FILE

