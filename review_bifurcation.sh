#!/bin/bash

#Parameters
: "${1?Must provide node name}"
NODE=${1}
bifurcation="$(ssh root@${NODE} 'efibootmgr | grep INTEL | head -n1 | cut -d " " -f4')" 
verify="SSDPFCKE064T9"
if [ "$bifurcation" == "$verify" ]; then
   echo "bifurcation is enabled in node: $NODE | bifurcation: $bifurcation | status: bifurcation_ok"
else
   echo "bifurcation is not enabled in node: $NODE | bifurcation: not found | status: bifurcation_fail"
fi
