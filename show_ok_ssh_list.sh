#!/bin/bash
CURRENT=`pwd`
LIST="full_list"
echo -e "\033[0mGenerating information...wait 10 sec"
$CURRENT/list_ssh_revision.sh $LIST > report_ssh_conn.csv 
sleep 10
grep ok report_ssh_conn.csv | cut -d ' ' -f 4 > full_listok
echo -e "full_listok was created\033[32m"
cat -n full_listok
echo -e "\033[0mEnd ok_ssh_list"
