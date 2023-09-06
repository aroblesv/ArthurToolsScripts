#!/bin/bash
#Parameters
: "${1?Must provide node name}"
NODE_ID="$1"
RPART_SIZE="$(ssh ${NODE_ID} -n 'df -Th / | grep \/| awk " {print \$3,\$4,\$5,\$6 } " ')"
KERNEL_INFO="$(ssh ${NODE_ID} -n 'uname -r')"

echo -e "\r$NODE_ID       |        $KERNEL_INFO        |       $RPART_SIZE"
