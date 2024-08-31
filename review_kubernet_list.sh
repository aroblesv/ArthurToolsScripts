#!/bin/bash

function review_kube {

NODE=($1);

 kubectl get nodes -A --kubeconfig=$HOME/.kube/config.ZP31 | grep "${NODE[0]}"

}

read -p "type the list: " list
echo -e "\nGenereting kube status.\n"
NODES=$(grep "zp31" ${list})

if [ -z "${NODES}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${NODES}; do
	review_kube $n
done	
