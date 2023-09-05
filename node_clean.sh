NODE_ID=${1}


openstack baremetal node maintenance set $NODE_ID

openstack baremetal node delete $NODE_ID

./register_node.sh $NODE_ID

