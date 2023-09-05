#!/bin/bash

PROJECT=$1
SYSMAN_CMD=$(/usr/bin/python3 -m Sysman.sysman --print-names -P $PROJECT)
echo "$SYSMAN_CMD" > full_list_temp
tr ' ' '\n' < full_list_temp > full_list_ord
sort full_list_ord > full_list 
echo -e "\r\nfull_list was created\033[33m\r\n"
cat -n full_list
echo -e "\033[0m\r\nEnd list"
