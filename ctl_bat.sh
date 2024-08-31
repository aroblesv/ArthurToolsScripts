#!/bin/bash
# simple script to get kernel information from a nodes

# Parameters
# node_name as r01s01.zp31l10b02
# bkc_version as

# Uncomment line below to print verbose output
# set -o xtrace

#: "${1?Must provide node_name e.g. r01s01.zp31l10b02 or r01s01.op11l01c01}"

NODE_ID=${1}
BKC_ID=${2}
PROG_ID=$(echo $BKC_ID | cut -c1-7)
CURRENT="$(dirname $(readlink -f $0))"
TIMESTAMP=`date +%s`
STRAPS_INFO="N/A"
COLLECT_INVENTORY="N/A"
NODE_BMC=$(echo $NODE_ID | sed '0,/s/s//b/')
HEADER=$(cat header_ctl)
# Gathering node info
echo "*****     Gathering system information     *****"
./catlow_node_get_info.sh ${NODE_ID} > temp_${NODE_ID}_${TIMESTAMP}.info
sed -i "1 i ${HEADER}" temp_${NODE_ID}_${TIMESTAMP}.info
cat temp_${NODE_ID}_${TIMESTAMP}.info
echo "*****     Running BKC Checker     *****"
# Running BKC Checker
FILE_NAME=`ls -tu | grep ".info" | grep temp_${NODE_ID} | head -1`
if [[ "${FILE_NAME}" =~ .*".info".* ]]; then
   ./bkc_checker/bkcChecker.py -p ${PROG_ID} -b ${BKC_ID} -f ${FILE_NAME} -t
   ./bkc_checker/bkcChecker.py -p ${PROG_ID} -b ${BKC_ID} -f ${FILE_NAME} -i
fi
# Checking Node Straps
#echo "*****     Checking Straps     *****"
#ping $NODE_BMC -c 1 2>&1 1>/dev/null
#if [ "$?" == "0" ]; then
#   bash ${CURRENT}/get_straps.sh ${NODE_ID}
#else
#   echo "BMC not reachable..."
#fi
#echo "${STRAPS_INFO}"
# Collect Inventory
#echo "*****     Collecting inventory     *****"
#ping $NODE_BMC -c 1 2>&1 1>/dev/null
#if [ "$?" == "0" ]; then
#   source /var/local/cluster-tools/inventory_collector/inventory_collector.sh -M ${NODE_ID}
#else
#   echo "Cannot connect to BMC..."
#fi
echo "* ***************************************************************************************************"
echo "*                      All data collection and verifications have been executed.                    *"
echo "*                     Please wait for InventoryCollector wrapper to finish running.                 *"
echo "*                                    Make sure all verifications pass.                              *"
echo "*                    If you see any error in one of the steps, please review system.                *"
echo "* ***************************************************************************************************"
