#!/bin/bash

read -p "Copy and paste 1 project ( EMR WHITLEY PURLEY1 PURLEY2 CATLOW10a CATLOWROW33): " project

if [[ "$project" = "EMR" ]]; then
	newproject=zp3110b001s
	echo "Generating EMR status ssh connection"
	elif [[ "$project" = "WHITLEY" ]]; then
	newproject=zp3110a001s
	echo "Generating WHITLEY status ssh connection"
	elif [[ "$project" = "PURLEY1" ]]; then
	newproject=zp31sra001s
	echo "Generating PURLEY1 status ssh connection"
	elif [[ "$project" = "PURLEY2" ]]; then
	newproject=zp31sra002s
	echo "Generating PURLEY2 status ssh connection"
	elif [[ "$project" = "CATLOW10a" ]]; then
	newproject=zp3110a001s
	echo "Generating CATLOW10A status ssh connection"
	elif [[ "$project" = "CATLOWROW33" ]]; then
	newproject=zp31l0233ms
	echo "Generating CATLOWROW33 status ssh connection"
else

echo "Not is a valid project"

fi

read -p "Write number rack sequence: " racknumb

if [[ $racknumb =~ ^[0-9]+$ ]]; then

	for n in {1..20}; do echo "${newproject}${racknumb}"; done > racksequence1

	seq -w 1 20 > racksequence2

	paste racksequence1 racksequence2 > racksequence

	sed -i 's/[[:blank:]]//g' racksequence

	cat racksequence

	./review_ssh_rack_status.sh

else
	rm -rf *racksequence*

	for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20

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

