#!/bin/bash

function run_memories_list {

node=($1);

./memories_awk4.sh ${node[0]}

}

read -p "Typing your list: " list

nodes=$(grep "zp31" ${list})

if [ -z "${nodes}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${nodes}; do
	run_memories_list $n
done

