#!/bin/bash

function ssh_status {
node=($1);
port=22
connect_timeout=5

timeout $connect_timeout bash -c "</dev/tcp/${node[0]}/$port"

if [ $? == 0 ];then
      echo -e "\033[0mSSH Connection to ${node[0]} | \033[32mssh_ok\033[0m" >> sshconn
else
      echo -e "\033[0mSSH Connection to ${node[0]} | \033[33mssh_fail\033[0m" >> sshconn
fi
}

#read -p "type the list: " list
list=racksequence
echo -e "\nGenerating ssh connection information for the network and for the BMC, wait a moment, please.\n"
nodes=$(grep "zp31" ${list})

if [ -z "${nodes}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${nodes}; do
	ssh_status $n
done

tr 's' 'b' < $list > ${list}bmc
sed -e 's/$/\.deacluster.intel.com/' ${list}bmc > webviewss
sed -i 's/^/https:\/\//g' webviewss

function ssh_bmc_status {
node=($1);
port=22
connect_timeout=5

timeout $connect_timeout bash -c "</dev/tcp/${node[0]}/$port"

if [ $? == 0 ]; then
      echo -e "\033[0mSSH BMC Connection to ${node[0]} | \033[32mssh_ok\033[0m" >> sshbmcconn
else
      echo -e "\033[0mSSH BMC Connection to ${node[0]} | \033[33mssh_fail\033[0m" >> sshbmcconn
fi
}

listb=${list}bmc

nodes=$(grep "zp31" $listb)

if [ -z "${nodes}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${nodes}; do
	ssh_bmc_status $n
done

tr 's' 'b' < $list > ${list}bmc
sed -e 's/$/\.deacluster.intel.com/' ${list}bmc > webviewss
sed -i 's/^/https:\/\//g' webviewss

paste sshconn sshbmcconn > sshstatusconn
cat sshstatusconn
echo -e "\n********************************************************************************************************"
echo -e "copy and paste into an excel sheet to be able to enter the nodes with which you want to work.\n"
cat webviewss
rm sshbmcconn sshconn
