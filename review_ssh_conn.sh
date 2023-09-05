#!/bin/bash

#Parameters
: "${1?Must provide node name}"
NODE=${1}
port=22
connect_timeout=5

timeout $connect_timeout bash -c "</dev/tcp/$NODE/$port"

if [ $? == 0 ];then
   echo -e "\r\033[0mSSH Connection to $NODE | \033[32mssh_ok\033[0m\r"
else
   echo -e "\r\033[0mSSH connection to $NODE | \033[33mssh_fail\033[0m\r"
fi
