#!/bin/bash
while getopts "F:P" variable; do
case "$variable" in
F)
#parameters=($@)
echo "checking node(s)................."
echo "[" > seamless-inventory-gdc.json
echo "	{" >> seamless-inventory-gdc.json
echo "	\"targets\": [" >> seamless-inventory-gdc.json
readarray -t nodes < $2
size=${#nodes[@]}
if [ $size == 1 ]
then
	bmc=$( echo $nodes | sed 's/s/b/' )
	echo "		\"ironic--$nodes--$bmc.deacluster.intel.com--ZGVidWd1c2Vy--MHBlbkJtYzE=\"" >> seamless-inventory-gdc.json
else
for element in "${nodes[@]:0:($size-1)}";do
	bmc=$( echo $element | sed 's/s/b/' )
	echo "		\"ironic--$element--$bmc.deacluster.intel.com--ZGVidWd1c2Vy--MHBlbkJtYzE=\"," >> seamless-inventory-gdc.json
done
bmc=$( echo ${nodes[-1]}| sed 's/s/b/' )
echo "		\"ironic--${nodes[-1]}--$bmc.deacluster.intel.com--ZGVidWd1c2Vy--MHBlbkJtYzE=\"" >> seamless-inventory-gdc.json
fi
echo "	]" >> seamless-inventory-gdc.json
echo "	}" >> seamless-inventory-gdc.json
echo "]" >> seamless-inventory-gdc.json
read -p "Please enter SU_CAP name: " cap
read -p "Please enter BKC name: " bkc
python3 remote_ifwi_update.py --inventory seamless-inventory-gdc.json --capsule $cap --bkc $bkc
;;
esac
done
