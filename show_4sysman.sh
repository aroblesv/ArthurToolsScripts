#!/bin/bash
read -p "type your list: " list
tr '\n' ' ' < $list > sysman_show_list
sysman_show=$(cat sysman_show_list)
echo -e "\r\ncopy and paste\r\n"
echo -e "\r\n  $sysman_show \r\n"
echo -e "\r\ncopy and paste in sysman-command\r\n"
