#!/bin/bash
NODE_ID=$1

./clean_known_hosts.sh $NODE_ID
sshpass -p c1oudc0w -v ssh root@${NODE_ID} -n "journalctl -f -u ironic-python-agent"
