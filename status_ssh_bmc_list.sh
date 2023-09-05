#!/bin/bash

function ssh_status {
node=($1);
port=22
connect_timeout=5

timeout $connect_timeout bash -c "</dev/tcp/${node[0]}/$port"

if [ $? == 0 ];then
      echo -e "\033[0mSSH Connection to ${node[0]} | \033[32mssh_ok\033[0m"
else
      echo -e "\033[0mSSH Connection to ${node[0]} | \033[33mssh_fail\033[0m"
fi
}

listb=`ls -ltr |tail -n2|head -n 1|cut -d ' ' -f 14`
nodes=$(grep "zp3110" ${listb})

if [ -z "${nodes}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${nodes}; do
	ssh_status $n
done
