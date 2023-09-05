#!/bin/bash

NODE_ID=$1

echo "executing node_power_on  in: $NODE_ID"

./redfish_power_on.sh ${NODE_ID}
