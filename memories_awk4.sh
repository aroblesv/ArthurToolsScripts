#!/bin/bash
node_id=$1

./awk4_script.sh ${node_id} > mem_inventory_report
./make_mem_info.sh
