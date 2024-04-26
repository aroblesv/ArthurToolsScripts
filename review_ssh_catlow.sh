#!/bin/bash

function review_ssh {

NODE=($1);
port=22
connect_timeout=5

timeout ${connect_timeout} bash -c "</dev/tcp/${NODE[0]}/${port}" 2> /dev/null

if [ $? == 0 ];then
   echo -e "${NODE[0]} \033[32mssh_live\033[0m" >> report_ssh
else
   echo -e "${NODE[0]} \033[33mssh_dead\033[0m" >> report_ssh
fi
}

read -p "type the list: " list
echo -e "\nGenerating ssh connection information for the network and for the BMC, wait a moment, please. \n"
NODES=$(grep "zp31" ${list})

if [ -z "${NODES}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${NODES}; do
	review_ssh $n
done

bmcname=`grep -E ^zp31l0233ms[[:digit:]]*$ ${list}`

if [ "$?" == 0 ]; then
	tr 's' 'b' < ${list} > ${list}bmc
	sed -e 's/$/\.deacluster.intel.com/' ${list}bmc > webviewss
	sed -i 's/^/https:\/\//g' webviewss
else
	sed 's/s/b/2g' ${list} > ${list}bmc
	sed -e 's/$/\.deacluster.intel.com/' ${list}bmc > webviewss
	sed -i 's/^/https:\/\//g' webviewss
fi

function review_ssh_bmc {
NODE=($1);
port=22
connect_timeout=5

#timeout $connect_timeout bash -c "</dev/tcp/${NODE[0]}/${port}"
ping -c1 ${NODE[0]} &> /dev/null

if [ $? == 0 ]; then
   echo -e "${NODE[0]} \033[32mssh-bmc_live\033[0m" >> report_sshbmc
else
   echo -e "${NODE[0]} \033[33mssh-bmc_dead\033[0m" >> report_sshbmc
fi
}

listb=${list}bmc

NODES=$(grep "zp31" $listb)

if [ -z "${NODES}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${NODES}; do
	review_ssh_bmc $n
done

bmcname=`grep -E ^zp31l0233ms[[:digit:]]*$ ${list}`

if [ "$?" == 0 ]; then
	tr 's' 'b' < ${list} > ${list}bmc
	sed -e 's/$/\.deacluster.intel.com/' ${list}bmc > webviewss
	sed -i 's/^/https:\/\//g' webviewss
else
	sed 's/s/b/2g' ${list} > ${list}bmc
	sed -e 's/$/\.deacluster.intel.com/' ${list}bmc > webviewss
	sed -i 's/^/https:\/\//g' webviewss
fi

#tr 's' 'b' < ${list} > ${list}bmc
#sed -e 's/$/\.deacluster.intel.com/' ${list}bmc > webviewss
#sed -i 's/^/https:\/\//g' webviewss

paste report_ssh report_sshbmc > ssh_status_report
cat ssh_status_report
echo -e "\n*******************************************************************************************************"
echo -e "copy and pastate into an excel sheet to be able to enter the nodes with which you want to work\n"
cat webviewss
rm report_ssh report_sshbmc 

#unset list
#unset listb
#unset listbmc
