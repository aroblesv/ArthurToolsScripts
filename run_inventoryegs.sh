#!/bin/bash
NODE_ID=$1
source /var/local/cluster-tools/inventory_collector/inventory_collector.sh -M $NODE_ID\.EMR
source ~/.bashrc
