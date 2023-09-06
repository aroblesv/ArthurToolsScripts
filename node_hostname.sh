#!/bin/bash

# set -o xtrace

# Parameters
: "${1?Must provide node name}"
NODE_ID="$1"

shopt -s expand_aliases
alias ssh='ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR'

echo -e "\nChanging hostname"
# ensure full node name on prompt msg (naming convention rev2.0)
ssh root@${NODE_ID} -n "sed -i 's/\\\\u@\\\\h/\\\\u@\\\\H/g' /etc/bashrc"
ssh root@${NODE_ID} -n "hostnamectl set-hostname $NODE_ID"
rc=$?
[[ $rc -ne 0 ]] && ssh root@${NODE_ID} -n "echo ${NODE_ID} > /etc/hostname" && rc=$?
[[ $rc -eq 0 ]] && echo -e "\033[0;32mHostname changed \033[0m" || echo -e "\033[0;31mERROR: Failed to change hostname $NODE_ID \033[0m"

