#!/bin/bash
echo -e "\033[32mcheck memories locator\033[0m\r\n"
#read -p "write your system: " node
node=$1
ssh root@${node} -n "dmidecode -t 17" > memories.csv

echo -e "\nCan you check memories installed info or empty dimm slot location?\n\rSelect an option\n\r"
echo -e "\033[33m\n1) installed memories info 2) empty slot_dimm location 3) General Info\033[0m\r\n"
read -p "write your option: " option
echo "your selection is: $option"

	case $option in
		1) echo "installed memory information";
			cat memories.csv |tr -d '\t'|grep -A3 -i ^size:[[:space:]][[:digit:]]| awk '/Size|Locator/';
			cat memories.csv |tr -d '\t'|grep -i ^size:[[:space:]][[:digit:]]| cut -d ' ' -f2 > size_mem.info;
			tmeminstalled=$(cat size_mem.info |wc -l);
			while read -r num; do ((sum += num)); done < size_mem.info; echo -e "\033[34mTotal: $sum GB and Memories Installed: $tmeminstalled\033[0m";;
		2) echo "empty slots_dimm information";
			cat memories.csv |tr -d '\t'|grep -A3 -i ^size:[[:space:]][[:alpha:]]| awk '/Size|Locator/';
			cat memories.csv |tr -d '\t'|grep -i ^size:[[:space:]][[:alpha:]] > mems_not_installed.info;
			tmem_not_installed=$(cat mems_not_installed.info | wc -l);
			echo -e "\033[34mTotal memories not installed: $tmem_not_installed\033[0m";;
		3) echo -e "\033[36mGeneral memories installed Info";
			ssh ${node} -n "dmidecode -t17| tr -d '\t'|grep -A11 -i ^size:[[:space:]][[:digit:]];" > general_mem.info; 
			#awk '/--|^Locator|Speed|Manufacturer|Serial|Part/' general_mem.info;; 
			awk '/--|^Locator|Speed|Manufacturer|Serial|Part/' general_mem.info; 
			echo -e "\033[0m";;
		*) echo -e "\033[31mnot a valid option\033[0m";; 
	esac

