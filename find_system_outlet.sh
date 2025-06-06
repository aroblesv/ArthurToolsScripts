#!/bin/bash
echo -e "\n\033[34mFind node name script.\033[0m\n"
echo -e "***********************************************************************************"
echo -e "\033[33mEnter the ROW number with this format "X"\033[0m"
read -p "ROW: " nrow
echo -e "\033[33mEnter the RACK number with this format "XX" if the number is of 1 digit.\033[0m"
read -p "RACK: " nrack
echo -e "\033[33mEnter the PDU number with this format "XX" if the number is of 1 digit.\033[0m"
read -p "PDU: " npdu
echo -e "\033[33mEnter the OUTLET number with this format "X" if the number is of 1 digit.\033[0m"
read -p "OUTLET: " noutlet

#<< 'multi-line-comment'
if [[ "$nrow" = "1" ]];then
        nrow="zp3110b001p"

elif [[ "$nrow" = "2" ]];then
        nrow="zp3110b002p"
else
echo "this number not is vaild"
fi

#multi-line-comment

nodename=$(grep $nrow$nrack /var/local/Sysman/cluster_nodes.py |grep p$nrack$npdu|grep \"$noutlet\"\)\,$ |tr ',' ' '|awk '{print "system: "$1 "\turl-check-pdu: "$7 "\toutlet: "$8 "\tsystemoff-command: sysman --pdu_off -M "$1}')


echo -e "***********************************************************************************"


echo -e "$nodename" > nodename_temp2

nodename2=$(awk '{gsub(/"/,"")}1' nodename_temp2)

echo -e "$nodename2" > nodename_temp3

nodename3=$(awk '{gsub(/)/,"")}1' nodename_temp3)

echo -e "\n\033[32m$nodename3\033[0m\n"

echo -e "\033[1;33m"
read -p "Are you need download outlet - $noutlet of pdu:  ${nrow}${nrack}${npdu}  voltate information? (y/n): " answer
echo -e "\033[0m"

case $answer in
  [yY]*)
    echo -e "\033[0;32mdownloading...\033[0m"
    # Place your code to execute if yes here
	echo -e "\n\033[1;33mplease wait for voltage info outlet: $noutlet - The information of the pdu is being generated.\033[1;36m\n"

	pdu_name=$(echo -e "$nodename3"|awk '{print $4}')

	#noutlet2=$(echo -e "nodename3"|awk '{print $6}')

	ip_addrs=$(ping -c1 -n $pdu_name | head -n1 | sed "s/.*(\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)).*/\1/g")

	sshpduuser=$(cat sshpduuser.txt)
	sshpdupass=$(cat sshpdupass.txt)

	sshpass -p $sshpdupass scp -o StrictHostKeyChecking=no $sshpduuser@$ip_addrs:/diag-data.zip .

	unzip -qq diag-data.zip

	grep -i -A13 "outlet $noutlet" ./diag-data/topo-data #|grep -i current:

	rm -rf diag-data diag-data.zip nodename_temp2 nodename_temp3

	echo -e "\n\033[1;33mcomplete\033[0m"

	#echo -e "\n\033[1;33mif fail run manualy thiw command: scp admin@$ip_addrs:/diag-data.zip .\033[0m"
	#echo -e "\n\033[1;33mwhen finish run again the script\033[0m"
    exit 0 # Exit with success code if yes
    ;;
  [nN]*)
    echo "Exiting..."
    exit 1 # Exit with error code if no
    ;;
  *)
    echo "Invalid input. Please answer y or n."
    exit 2 # Exit with error code for invalid input
    ;;
esac

