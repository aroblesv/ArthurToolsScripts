#!/bin/bash

# Uncomment next line to debug
# set -o xtrace

#Parameters
: "${1?Must provide node name}"
NODE=${1}

shopt -s expand_aliases
alias ssh='ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR'

ping -c1 $NODE >/dev/null
[[ $? -ne 0 ]] && echo "ERROR: Node must be Power ON" && exit 1

./node_hostname.sh $NODE

./node_remove_pxe_boot.sh $NODE

echo "Fixing root partition"

ssh root@$NODE '
    part="/dev/"`lsblk -l -o NAME,MOUNTPOINT | grep -w "/" | awk '{print $1}'`
    disk="/dev/"`lsblk -ndo pkname $part`
    partN=`cat /sys/block/${disk:5}/${part:5}/partition`
    fstype=`lsblk -ndo FSTYPE $part`

    echo "    Growing partition"
    rst=`growpart $disk $partN`
    if [[ $? -eq 0 ]]; then echo -e "\033[0;32m    OK: grown \033[0m";
    else echo -e "\033[0;33m    WARN:$rst \033[0m"; fi
    partprobe $disk

    echo "    Growing filesystem"
    [[ "$fstype" == "xfs" ]] && `xfs_growfs $part` || `resize2fs $part 2>&1 | cat > /tmp/aux`
    [[ $? -ne 0 ]] && echo -e "\033[0;31m    ERROR: $(cat /tmp/aux)\033[0m\n"
    aux="$(grep Nothing.to.do /tmp/aux)"
    if [[ -z "$aux" ]]; then echo -e "\033[0;32m    OK: grown \n \033[0m";
    else echo -e "\033[0;33m    WARN: $aux \n \033[0m"; fi
  '

echo "Setting bmc boot override option to None - change boot order"
ssh root@$NODE '
  ipmitool chassis bootdev none options=persistent'
  [[ $? -eq 0 ]] && echo -e "\033[0;32mOK - option changed\n\033[0m" || echo -e "\033[0;31mERROR: Unable to change bmc boot order\033[0m\n"

echo "Enabling IT lab scan account"
ssh root@$NODE '
  wget -4 -e use_proxy=no -q -O - http://isscorp.intel.com/IntelSM_BigFix/33570/package/scan/labscanaccount.sh | bash -s --  2>&1 | cat > /tmp/aux
  aux="$(grep Lab.*.setup.successfully /tmp/aux)"
  if [[ -n "$aux" ]]; then echo -e "\033[0;32mOK - $aux \n \033[0m";
  else echo -e "\033[0;31mERROR: $(cat /tmp/aux ) \n \033[0m";
  fi
'

