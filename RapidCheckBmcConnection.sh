#!/bin/bash


function rapidcheckbmc {

node=($1);

echo -e "\n"
echo -e "###########################################################"
sshpass -p 0penBmc1 ssh root@${node[0]} -n "cat /etc/hostname"
echo -e "###########################################################"

ping -c 4 ${node[0]} &> /dev/null && echo "bmc connection it's OK"

}

read -p "Typing your list: " list

tr 's' 'b' < $list > ${list}bmc

bmclist=`ls -ltr| tail -n 1| awk '{print $9}'`

nodes=$(grep "zp31" ${bmclist})

if [ -z "${nodes}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${nodes}; do
	rapidcheckbmc $n
done

