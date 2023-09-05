#!/bin/bash

cmem=$(grep -i sum mem_inventory_report |cut -d ' ' -f3) 

cat mem_inventory_report |grep -A$cmem -i ^Size > memlocation
cat mem_inventory_report |grep -A$cmem -i ^GDC > meminventory
cat mem_inventory_report |grep -A6 -i ^Installed > memsizeawk.info
paste memlocation meminventory > memgdcinfo
echo -e "\n**************************************************************"
cat memsizeawk.info
echo -e "\n**********************************************************************************************************************************************************"
cat memgdcinfo
