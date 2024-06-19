#!/bin/bash
# Program name: pingall.sh
date

function ip_ping {

IPLIST=($1)

ping -c1 -w1 ${IPLIST[0]} &> /dev/null

if [ $? -eq 0 ]; then
    echo -e "node ${IPLIST[0]} is \033[32mup\033[0m" >> report_ip_ping
    else
    echo -e "node ${IPLIST[0]} is \033[31mdown\033[0m" >> report_ip_ping
fi
}

read -p "type the ip list: " iplist
echo -e "\nGenerating ping to ip node, wait a moment, please. \n"
IPSS=$(grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' $iplist)

if [ -z "{IPSS}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${IPSS}; do
	ip_ping $n
done

cat report_ip_ping
rm report_ip_ping
