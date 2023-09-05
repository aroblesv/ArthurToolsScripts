#!/bin/bash
NODE_ID=$1

launch_ipc2="/var/local/cluster-tools/remote_openipc/remote_openipc_main.sh"

unlock_script="/var/local/cluster-tools/remote_openipc/ipc_scripts/ipc_unlocker.py"

${launch_ipc2} ${NODE_ID} ${unlock_script}

#echo ${var} > launch_process
#tail -f launch_process
source ~/.bashrc
