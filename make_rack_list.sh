#!/bin/bash

read -p "Write number rack sequence: " racknumb

if [[ $racknumb =~ ^[0-9]+$ ]]; then

	for n in {1..20}; do echo "zp3110a001s$racknumb"; done > racksequence1

	seq -w 1 20 > racksequence2

	paste racksequence1 racksequence2 > racksequence

	sed -i 's/[[:blank:]]//g' racksequence

	cat racksequence

	./review_ssh_rack_status.sh

else
	rm -rf *racksequence*

	for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15

	do
		for n in {1..20}; do echo "zp3110b001s$i"; done >> racksequence1

		seq -w 1 20 >> racksequence2
		
		paste racksequence1 racksequence2 >> temp_racksequence

		sed -i 's/[[:blank:]]//g' temp_racksequence
		

		sort temp_racksequence | uniq > racksequence
		cat racksequence
		#./review_ssh_rack_status.sh
	done

fi
