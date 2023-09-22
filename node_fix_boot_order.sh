#!/bin/bash
# uncomment next line to troubleshoot
#set -o xtrace

: "${1?Must provide node name}"
NODE_ID=$1

shopt -s expand_aliases
alias ssh='ssh -T -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR  -i ~/.ssh/test_rsa'

function _print_error { echo -e "\033[0;31m ERROR: $@ \033[0m"; exit 1; }
function _get_option { echo "${BOOTMGR}" | grep -i "${1}"|head -1|cut -c 5-8; }

PXE_MAC=`openstack baremetal port list --node $NODE_ID -c Address -f value | sed 's/://g'`
[[ -z "$PXE_MAC" ]] && _print_error "Unable to find node expected boot mac address"

BOOTMGR=`ssh root@${NODE_ID} "efibootmgr"`
[[ -z "$BOOTMGR" ]] && _print_error "Unable to ssh and get initial boot menu"

PXE_ID=`echo "${BOOTMGR}" | grep -i "$PXE_MAC" | grep 'PXEv4' | cut -c 5-8`
[[ -z "$PXE_ID" ]] && _print_error "PXEv4 MAC $PXE_MAC not on the menu\n\n$BOOTMGR"

MISC_ID=`echo "${BOOTMGR}" | grep 'UEFI Misc Device' | cut -c 5-8`
[[ -z "${MISC_ID}" ]] && MISC_ID=`echo "${BOOTMGR}" | grep UEFI | grep -vEi 'mac|internal.shell' | head -1 | cut -c 5-8`

ARBOR_ID=`echo "${BOOTMGR}" | grep 'CGN-1' | cut -c 5-8`

HDD_ID=`echo "${BOOTMGR}" | grep 'ST500D' | cut -c 5-8`

THIRD_ID=`echo "${BOOTMGR}" | grep -E 'UEFI Internal Shell|Internal UEFI Shell' | head -1 | cut -c 5-8`

FOURTH_ID=`echo "${BOOTMGR}" | grep 'Enter Setup' | cut -c 5-8`

if [[ "${NODE_ID}" =~ .*"b001".* ]] || [[ "${NODE_ID}" =~ .*"zp31l10c01".* ]]; then
   echo "EGS NODE FIX BOOT ORDER"
   ssh root@${NODE_ID} "efibootmgr -o $PXE_ID,$ARBOR_ID,$THIRD_ID,$FOURTH_ID"
elif [[ "${NODE_ID}" =~ .*"b002".* ]]; then
   echo "ICX NODE FIX BOOT ORDER"
   ssh root@${NODE_ID} "efibootmgr -o $PXE_ID,$MISC_ID,$THIRD_ID,$FOURTH_ID"
elif [[ "${NODE_ID}" =~ .*"fl30lne001".*  || "$NODE_ID}" =~ "fl31ca" || "$NODE_ID}" =~ "fl41ca" ]]; then
   echo "FLEX NODE FIX BOOT ORDER"
   ssh root@${NODE_ID} "efibootmgr -o $PXE_ID,$MISC_ID,$THIRD_ID,$FOURTH_ID"
elif [[ "${NODE_ID}" =~ .*"l0233m".* ]] || [[ "${NODE_ID}" =~ .*"a001".* ]]; then
   echo "CATLOW NODE FIX BOOT ORDER"
   ssh root@${NODE_ID} "efibootmgr -o $PXE_ID,$HDD_ID,$THIRD_ID,$FOURTH_ID"
else
   _print_error "Unable to change boot order via OS. Unknown node lab - $NODE_ID"
fi

