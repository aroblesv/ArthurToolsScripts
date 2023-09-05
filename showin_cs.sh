#!/bin/bash
read -p "type your list: " list
tr '\n' ',' < $list > cluster_show_list
cs_show=$(cat cluster_show_list)
echo -e "\r\ncopy and paste\r\n"
echo -e "\r\n  $cs_show \r\n"
echo -e "\r\ncopy and paste in: http://ive-infra04.deacluster.intel.com/clusterscope/\r\n"
