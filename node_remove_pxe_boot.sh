#!/bin/bash

# uncomment next line to troubleshoot
# set -o xtrace

shopt -s expand_aliases
alias ssh='ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR'

# Sample file
# BootCurrent: 0003
# Timeout: 2 seconds
# BootOrder: 0003,0002,0000,0004,0005,0006,0007,0008,0009,000A,000B,000C,000D,000E,000F,0001
# Boot0000* Enter Setup
# Boot0001* UEFI Internal Shell
# Boot0002* Boot Device List
# Boot0003* UEFI Misc Device
# Boot0004* UEFI PXEv4 (MAC:A4BF0170DF4D)
# Boot0005* UEFI PXEv6 (MAC:A4BF0170DF4D)
# Boot0006* UEFI HTTPv4 (MAC:A4BF0170DF4D)
# Boot0007* UEFI HTTPv6 (MAC:A4BF0170DF4D)
# Boot0008* UEFI PXEv4 (MAC:3CFDFEED1924)
# Boot0009* UEFI PXEv6 (MAC:3CFDFEED1924)
# Boot000A* UEFI HTTPv4 (MAC:3CFDFEED1924)
# Boot000B* UEFI HTTPv6 (MAC:3CFDFEED1924)
# Boot000C* UEFI PXEv4 (MAC:3CFDFEED1925)
# Boot000D* UEFI PXEv6 (MAC:3CFDFEED1925)
# Boot000E* UEFI HTTPv4 (MAC:3CFDFEED1925)
# Boot000F* UEFI HTTPv6 (MAC:3CFDFEED1925)
# MirroredPercentageAbove4G: 0.00
# MirrorMemoryBelow4GB: false

############### FUNCTIONS ####################
function _print_error {
  echo -e "\033[0;31m ERROR: $@ \033[0m"
  exit 1
}
function _get_option {
  echo "${BOOTMGR}" | grep -i "${1}" | head -1 | cut -c 5-8
}
function _set_boot_order {
  local opt=$(echo $@ | sed 's/ /|Boot/g')
  local tmp=$(echo "$BOOTMGR" | grep -E "Boot"$opt | sed 's/^/    /g')
  local opt=$(echo $@ | tr -s ' ' ',')
  echo -e "Setting New BootOrder: $opt\n$tmp"

  ssh root@$NODE "efibootmgr -o $opt > /dev/null"
  [[ $? -eq 0 ]] && echo -e "\033[0;32mOK - Boot Order Fixed\n\033[0m" || _print_error "$NODE - Failed setting boot order"
}
function _one_centos_menu {
  [[ $(echo "$BOOTMGR" | grep -i "centos" -c) -eq 1 ]] && return

  # if there is more than one centos menu entry 
  # delete all centos entries
  # create single centos entry
  ssh root@$NODE '
    for x in  `efibootmgr | grep -i "centos" | cut -c 5-8`
    do
        efibootmgr -b $x -B > /dev/null
    done

    ln=`lsblk -l -o MAJ:MIN,NAME,MOUNTPOINT | grep efi`
    pn=`echo $ln | cut -d" " -f1 | cut -d":" -f2` 
    dn=`echo $ln | cut -d" " -f1 | cut -d":" -f1`
    dk="/dev/"`lsblk | grep "${dn}:0"|cut -d" " -f1`
    efibootmgr -c -d $dk -p $pn -L centos -l "\EFI\centos\shimx64.efi" > /dev/null
  '
  BOOTMGR=`ssh root@$NODE "efibootmgr"`
}

############### VARS #########################
: "${1?Must provide node name}"
NODE=${1}
pfl=`grep $NODE ../data/ --exclude nodes -ri | head -1 | cut -d ":" -f1`
[[ -n "$pfl" ]] && PLATFORM=`readlink -f $pfl | rev | cut -d "/" -f 1 | rev`
BOOTMGR=`ssh root@$NODE "efibootmgr"`
[[ -z "$BOOTMGR" ]] && _print_error "Unable to ssh and get initial boot menu"

############### MAIN SCRIPT ##################
echo -e "\nSetting BIOS boot order."

_one_centos_menu

# get options
centos=`_get_option "centos"`
misc=`_get_option "Misc Device"`
if [[ -z "${misc}" ]]; then
  st=`echo "${BOOTMGR}" | grep UEFI | grep -vEi 'mac|internal.shell' | awk '{print $2" "$3}'`
  misc=`_get_option "$st"`
fi
internal_shell=`echo "${BOOTMGR}" | grep -E 'Internal Shell|Internal UEFI Shell' | head -1 | cut -c 5-8`
enter_setup=`_get_option "Enter Setup"`
device_list=`_get_option "Device List"`

# set options
# TODO: Test booting always from centos

if [[ "$PLATFORM" =~ 'whitley' ]]; then
    echo 'ICX System...'
    [[ -z "$misc" ]] && _print_error "No Misc Device menu"
    _set_boot_order $misc $internal_shell $enter_setup $device_list
elif [[ "$PLATFORM" =~ 'catlow' ]]; then
    echo "CATLOW System..."
    [[ -z "$centos" ]] && _print_error "No centos menu"
    _set_boot_order $centos $internal_shell $enter_setup $device_list
elif [[ "$PLATFORM" =~ 'spr' || "$PLATFORM" =~ 'hbm' || "$PLATFORM" =~ 'flex_uservices' ]]; then
    echo "EGS System..."
    [[ -z "$centos" ]] && _print_error "No centos menu"
    _set_boot_order $centos $misc $internal_shell $device_list
elif [[ "$PLATFORM" =~ 'bhs' || "$PLATFORM" =~ 'gnr' || "$PLATFORM" =~ 'srf' ]];then
    echo "BHS System..."
    [[ -z "$centos" ]] && _print_error "No centos menu"
    _set_boot_order $centos $misc $internal_shell $device_list
else
  #_print_error "ADD SYSTEM TO ../data/XXXX FOLDER\nUnable to determine Platform $PLATFORM"
  echo -e "\033[0;33mWARN: ADD SYSTEM TO ../data/XXXX FOLDER\nWARN:Unable to determine Platform $PLATFORM\033[0m"
  _set_boot_order $centos $misc $internal_shell $device_list $enter_setup
fi
