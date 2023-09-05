#!/bin/bash

#Parameters

: "${1?Must provide node name}"

NODE=${1}

#PXE_MAC=`openstack baremetal port list --node $NODE -c Address -f value| tr -d ":" > temp_pxe_mac` 
#PXE_MAC_UPPER=`tr [:lower:] [:upper:] < temp_pxe_mac` 
PXE_MAC=`openstack baremetal port list --node $NODE -c Address -f value| tr -d ":" |tr [:lower:] [:upper:]` 
PXE_ID=`ssh ${NODE} -n "efibootmgr | grep -i 'PXEv4' |grep -i $PXE_MAC |tail -c15 |cut -c 2-13 "`

if [ $PXE_MAC == $PXE_ID ]; then
   echo -e "Network is enabled in node: $NODE | Addrs: $PXE_MAC | status: Boot _Network_ok"
else
   echo -e "Network is not enabled in node: $NODE | Addrs not found | status: Boot_Network_fail"
fi

bifurcation="$(ssh root@${NODE} 'efibootmgr | grep INTEL | head -n1 | cut -d " " -f4')"

verify="SSDPFCKE064T9"

if [ "$bifurcation" == "$verify" ]; then
   echo -e "bifurcation is enabled in node: $NODE | bifurcation: $bifurcation | status: bifurcation_ok"
else
   echo -e "bifurcation is not enabled in node: $NODE | bifurcation: not found or not needed | status: bifurcation_fail"
fi
