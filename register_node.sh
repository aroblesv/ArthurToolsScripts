#!/bin/bash

#set -o xtrace

: "${1?Must provide node name}"

source ../functions

NODE=$1
DRIVER=${2:-redfish}
FILENAME=../data/nodes

realname=$(readlink -f ../data/nodes)
[[ "$realname" =~ "hbm_nodes_flex" ]] && source ~/openrc-egs
[[ "$realname" =~ "gnr_ap_nodes_flex" || "$realname" =~ "gnr_sp_nodes_flex" || "$realname" =~ "srf_sp_nodes_flex" ||  "$realname" =~ "srf_ap_nodes_flex" ]] && source ~/openrc-bhs

name=`grep $NODE $FILENAME | cut -d "," -f 1`
bmc_add=`grep $NODE $FILENAME | cut -d "," -f 2`
bmc_user=`grep $NODE $FILENAME | cut -d "," -f 3`
bmc_pass=`grep $NODE $FILENAME | cut -d "," -f 4`
pxe_mac=`grep $NODE $FILENAME | cut -d "," -f 5`

[[ -z "$name" ]] && echo "Unable to find node $NODE at $FILENAME" && exit 1

[[ "$DRIVER" == 'redfish' ]] && add_node_redfish  $name $bmc_add $bmc_user $bmc_pass $pxe_mac
#[[ "$DRIVER" == 'redfish' ]] && add_node_redfish  $name $bmc_add $bmc_user $bmc_pass $pxe_mac skip_validation

[[ "$DRIVER" == 'ipmi' ]]    && add_node_ipmi     $name $bmc_add $bmc_user $bmc_pass $pxe_mac
