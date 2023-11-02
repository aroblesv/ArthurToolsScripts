#!/bin/bash

function checkservicedns {

node=($1);

ping -c1 ${node[0]}

}

nodes=$(grep "zp31" racksequence)

if [ -z "${nodes}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${nodes}; do
	checkservicedns $n
done

nodesbmc=$(grep "zp31" racksequencebmc)

if [ -z "${nodesbmc}" ]; then
	echo "empty list"
	exit 1
fi

for b in ${nodesbmc}; do
	checkservicedns $b
done
