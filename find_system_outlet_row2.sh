#!/bin/bash
echo -e "\n\033[34mFind node name script.\033[0m\n"
echo -e "***********************************************************************************"
echo -e "\033[33mEnter the RACK number with this format "XX" if the number is of 1 digit.\033[0m"
read -p "RACK: " nrack
echo -e "\033[33mEnter the PDU number with this format "XX" if the number is of 1 digit.\033[0m"
read -p "PDU: " npdu
echo -e "\033[33mEnter the OUTLET number with this format "X" if the number is of 1 digit.\033[0m"
read -p "OUTLET: " noutlet

nodename=$(grep zp3110b002s$nrack /var/local/Sysman/cluster_nodes.py |grep p$nrack$npdu|grep \"$noutlet\"\)\,$ |tr ',' ' '|awk '{print "system: "$1 "\turl-check-pdu: "$7 "\toutlet: "$8 "\tsystemoff_command: sysman --pdu_off -M "$1}')
echo -e "***********************************************************************************"
echo -e "$nodename" > nodename_temp2
nodename2=$(awk '{gsub(/"/,"")}1' nodename_temp2)
echo -e "$nodename2" > nodename_temp3
nodename3=$(awk '{gsub(/)/,"")}1' nodename_temp3)
echo -e "\n\033[32m$nodename3\033[0m\n"
