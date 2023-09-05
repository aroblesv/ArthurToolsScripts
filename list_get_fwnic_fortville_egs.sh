#!/bin/bash
CURRENT=`pwd`
filename='full_list2'
n=1
while read line; do
#reading each line

$CURRENT/check_fwnic_fortville_egs.sh $line &
n=$((n+1))
done < $filename
