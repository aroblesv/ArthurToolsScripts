#!/bin/bash

#ping -c 4 ${node[0]}

function bmcremovehostname {

node=($1);

sshpass -p 0penBmc1 -v ssh root@${node[0]} -n "echo ${node[0]} |tee /etc/hostname"
sshpass -p 0penBmc1 -v ssh root@${node[0]} -n "/sbin/reboot"

}

read -p "Typing your list: " list

tr 's' 'b' < $list > ${list}bmc

nodes=$(grep "zp31" listbmc)

if [ -z "${nodes}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${nodes}; do
	bmcremovehostname $n
done

