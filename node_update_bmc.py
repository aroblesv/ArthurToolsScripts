#!/usr/bin/python3
# Script formerly bmc_support.py
import requests
import argparse
import os
from urllib3.exceptions import InsecureRequestWarning
import time
import sys

requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

RETRY_COUNT = 10
RETRY_WAIT = 5

# Arguments
def get_args():
    parser = argparse.ArgumentParser(description='Redfish get FW verson')
    # Create argument parser and mutually exclusive group.
    mutexArgs = parser.add_mutually_exclusive_group(required=True)
    mutexArgs.add_argument("--version", "-V", action='store_true', help="Get BMC FW version")
    mutexArgs.add_argument("--busy", action='store_true', help="Check if PFR is busy")
    mutexArgs.add_argument("--bios", action='store_true', help="Reserve PFR for BIOS update")
    mutexArgs.add_argument("--bmc", action='store_true', help="Reserve PFR for BMC update")
    mutexArgs.add_argument("--cpld", action='store_true', help="Reserve PFR for CPLD update")
    mutexArgs.add_argument("--send", action='store_true', help="Send binary file to PFR")

    # New group and argument added.
    parser.add_argument('-M', '--MachineId', help='Node ID', required=True)
    parser.add_argument('-d', '--domain', help='Domain ID', default='gdc')
    parser.add_argument('-f', '--file', help='PFR package file')
    return parser.parse_args()

# BMC Basics
myArgs = get_args()
username = "debuguser"
password = "0penBmc1"
bmcVersion = "N/A"

# Processing BMC ID 
index = myArgs.MachineId.rindex("s")
bmcId = myArgs.MachineId[:index] + "b" + myArgs.MachineId[index+1:]

if myArgs.domain == 'gdc':
   domain = ".deacluster.intel.com"
elif myArgs.domain == 'flex':
   domain = '.deacluster.intel.com'
else:
   print("%s: ERROR: Invalid domain: %s, valid domains: gdc and opus" % (bmcId, myArgs.domain))
   sys.exit()
#print (bmcId)
#print (domain)

s = requests.Session()
# Readiing /Managers/bmc to get BMC Firmware Version
if myArgs.version:
   retry = RETRY_COUNT
   while True:
         try:
             #print("Sending Get Version...")
             resp = s.get('https://{}{}/redfish/v1/Managers/bmc'.format(bmcId, domain),
                          verify = False,
                          timeout = 5,
                          auth = (username, password))
             status = resp.status_code
             if status == 200:
                break
             else:
                #print ("StatusCode = %d"  % status)
                retry -= 1
         except Exception as e:
                #print (e)
                retry -= 1
         if not retry:
            #print ("ERROR: Reached maximum retries, nothing was sent!")
            sys.exit()
         else:
            print ("%s: WARNING: Issuing retry %d" % (bmcId, (RETRY_COUNT - retry)))
            time.sleep(1)
   myResponse = resp.json()
   if "FirmwareVersion" in myResponse:
      bmcVersion = myResponse["FirmwareVersion"] 
      print("%s: %s" % (bmcId, bmcVersion))

# Checking if PFR is BUSY
elif myArgs.busy:
     try:
         resp = s.get('https://{}{}/redfish/v1/UpdateService'.format(bmcId, domain),
                verify=False,
                timeout=5,
                auth=(username, password))
     except requests.exceptions.RequestException as e:
         print ( "%s - unable to reach bmc" % myArgs.MachineId )
         sys.exit()
     status = resp.status_code
     if status != 200:
        print("RETURN_ERROR(%s)" % (status))
     myResponse = resp.json()
     if "HttpPushUriTargetsBusy" in myResponse:
        bmcBusy = myResponse["HttpPushUriTargetsBusy"] 
        print("%s" % (bmcBusy))

# Reserve PFR for BIOS update
elif myArgs.bios:
     try:
         body = '{"HttpPushUriTargets": ["bios_recovery"], "HttpPushUriTargetsBusy": true }'
         resp = s.patch('https://{}{}/redfish/v1/UpdateService'.format(bmcId, domain),
                verify=False,
                timeout=5,
                auth= (username, password),
                data = body)
     except requests.exceptions.RequestException as e:
         print ( "%s - unable to reach bmc" % myArgs.MachineId )
         sys.exit()
     status = resp.status_code
     if status != 200:
        print("RETURN_ERROR(%s)" % (status))

# Send binary file to PFR
elif myArgs.send:
   outband = myArgs.file
   with open(outband, 'rb') as file:
        retry = RETRY_COUNT
        while True:
              try:
                  print("%s: Sending binary to BMC" % bmcId)
                  resp = s.post('https://{}{}/redfish/v1/UpdateService'.format(bmcId, domain),
                         verify=False,
                         auth= (username, password),
                         data = file.read())
                  status = resp.status_code
                  if status == 200 or status == 202:
                     break
                  else:
                     print ("%s: StatusCode = %d"  % (bmcId, status))
                     retry -= 1
              except Exception as e:
                  print ("%s: " % bmcId, e)
                  retry -= 1
              if not retry:
                 print ("%s: ERROR: Reached maximum retries, nothing was sent!" % bmcId )
                 sys.exit()
              else:
                 print ("%s: WARNING: Issuing retry %d" % (bmcId, 5-retry))
                 time.sleep(RETRY_WAIT)
        print("%s: Please wait 15-30 minutes to see changes." % bmcId)
else:
    print("unsupported option")

