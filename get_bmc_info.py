#!/usr/bin/python3

import argparse
import logging
import os
import re
import requests
import sys
import time

from urllib3.exceptions import InsecureRequestWarning
from requests.auth import HTTPBasicAuth

# Setup login
logger = logging.getLogger("get_bmc_info")
console_log_handle = logging.StreamHandler()
_format = "%(asctime)s %(name)s:%(lineno)d %(levelname)s %(message)s"
console_log_handle.setFormatter(logging.Formatter(_format))
logger.addHandler(console_log_handle)
logger.setLevel(logging.ERROR)

# Parser
requests.packages.urllib3.disable_warnings()
parser = argparse.ArgumentParser(description='Redfish fw update script')
parser.add_argument('-M', '--MachineId', help='Node ID', required=True)
parser.add_argument('-U', '--bmcUsr', help='BMC user', default='debuguser')
parser.add_argument('-P', '--bmcPass', help='BMC password', default='0penBmc1')
args = parser.parse_args()

logger.info("Init %s" % args.MachineId)

username = args.bmcUsr
password = args.bmcPass
bmcId = args.MachineId.replace("s","b", 1)
# Get domain from ping
domain = os.popen("ping -c1 %s | grep statistics | sed 's/.*%s//g' | awk '{printf $1}'" % (bmcId, bmcId)).read()

logger.info("Data - node: %s, domain: %s, bmc: %s, bmc_user: %s, bmc_pass: %s"
             % (args.MachineId, domain, bmcId, username, password))

bmcVersion = "N/A"
model = "N/A" 
biosVersion = "N/A"
powerState = "N/A"
cpuCount = "N/A"
totalMemory = "N/A"


def get_info(key, jsonobj, verbose=False):
    if verbose:
        logger.debug(jsonobj)

    if jsonobj and key and jsonobj.get(key):
        logger.debug('Key {} found: {}'.format(key, jsonobj[key]))
        return jsonobj[key]
    else:
        logger.debug('Key %s NOT FOUND - Processing' % key)
        return False


try:
    url = 'https://{}{}/redfish/v1'.format(bmcId, domain)
    #s.mount('https://', HTTPAdapter(max_retries=3))
    _auth = HTTPBasicAuth(username, password)

    logger.info("Reading /Managers/bmc to get BMC Firmware Version")
    resp = requests.get('{}/Managers/bmc'.format(url), auth=_auth, verify=False)
    bmcVersion = get_info('FirmwareVersion', resp.json(), True)

    logger.info("Reading /UpdateService/FirmwareInventory to get ME Version")
    resp = requests.get('{}/UpdateService/FirmwareInventory/me'.format(url), auth=_auth, verify=False)
    meVersion = get_info('Version', resp.json(), True)


    logger.info("Reading /UpdateService/FirmwareInventory to get CPLD Version")
    resp = requests.get('{}/UpdateService/FirmwareInventory/cpld_active'.format(url), auth=_auth, verify=False)
    cpldVersion = get_info('Version', resp.json(), True)


    logger.info("Reading Systems/system get PowerState,CPUCount,TotalMem")
    resp = requests.get('{}/Systems/system'.format(url), auth=_auth, verify=False)
    myResponse = resp.json()
    model = get_info('Model', myResponse, True)
    biosVersion = get_info('BiosVersion', myResponse)
#    aux = get_info('BiosVersion', myResponse)
#    if aux:
#        aux = re.compile('\.').split(aux)
#        if len(aux) >= 4:
#            biosVersion = "%s.%s.%s" % (aux[1], aux[2], aux[3])
    powerState = get_info('PowerState', myResponse)
    cpuCount = get_info('Count', get_info('ProcessorSummary', myResponse))
    totalMemory = get_info('TotalSystemMemoryGiB', get_info('MemorySummary', myResponse))

    logger.info("Reading /Systems/system/Memory to get DIMM Count")
    resp = requests.get('{}/Systems/system/Memory'.format(url), auth=_auth, verify=False)
    dimmCount = get_info('Members@odata.count', resp.json(), True)
except Exception as e:
    logger.error("%s - unable to reach bmc: %s" % (args.MachineId, e))
    sys.exit()
    #raise SystemExit(e)

print("%s,%s,%s,%s,%s,%s,%s,%s,%s" % (model, bmcVersion, biosVersion, meVersion, cpldVersion,powerState, cpuCount, dimmCount, totalMemory))

