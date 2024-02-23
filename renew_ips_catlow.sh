#!/bin/bash

node=$1

ip_catlow=$(grep $node ips_catlow_list|awk '{print $2}')
echo clean ip $ip_catlow 
sshpass -p 'c1oudc0w' ssh root@${ip_catlow} -n 'rm -rf /etc/hostname'
echo hostname deleted
echo Ac cycle in $node wait few minutes..
SYSMAN_CMD=$(/usr/bin/python3 -m Sysman.sysman -aA -M ${node})
echo $SYSMAN_CMD
