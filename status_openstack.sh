
NODE_ID=${1}
echo -e "\r"&openstack baremetal node list |grep $NODE_ID

