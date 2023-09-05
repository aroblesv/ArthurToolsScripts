#!/bin/bash
NODE_ID=$1
echo " ********************************************"
echo "cleanning known hosts"
echo " ********************************************"
./clean_known_hosts.sh $NODE_ID
echo "*********************************************"
echo "show image installed"
echo "**************************************************"
ssh $NODE_ID  -n "cat /etc/motd |grep -i 'image version'"
echo "**************************************************"
echo "running boot override"
echo "**************************************************"
./node_boot_override.sh $NODE_ID
echo "**************************************************"
echo "running postinstall"
echo "**************************************************"
./node_postinstall.sh $NODE_ID
echo "**************************************************"
echo "show resize info"
echo "***************************************************"
./check_rpart_size.sh $NODE_ID
echo "***************************************************"
