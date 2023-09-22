import os
import re
import sys
import json
import logging
import time
import argparse
import urllib3
import requests
import threading
import subprocess
import base64
from datetime import datetime, timedelta
from remote_ssh import paramikoServer

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

RELEASE_VERSION         = "v2.02.1.0001"
SEAMLESS_UPDATER_SERVER = {
                             "GDC" : "http://10.219.26.235:9666",
                             "FLEX": "http://10.45.242.8:9666",
                             "TEST": "http://172.21.133.108:9666"
                          }

SEAMLESS_COLLECTOR_SERVER = {
                             "GDC" : "http://10.219.26.234:9666",
                             "FLEX": "http://10.45.242.20:9666",
                             "TEST": "http://172.21.133.108:9666"
                          }

	
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
	
	
class IFWI_Update:

    def __init__(self, inventory_file, capsule_file, bkc_version, site="", verbose=0):
        self.site = site
        self.inventory = inventory_file
        self.capsule = capsule_file
        self.bkc = bkc_version
        self.verbose = verbose
	
		
    def _decode_prometheus_entry(self, entry):
        entries = entry.split('--')
        if len(entries) == 5:
            entries.append('') # add missing redfish_endpoint
        return entries

    def _create_session_key(self, name, target, username, password, redfish_endpoint):
        return "{}--{}--{}--{}--{}".format(name, target, username, password, redfish_endpoint)

    def _split_session_key(self, session):
        return session.split("--")
		
    def _create_jsonfile(self, jsondata, filename):
        #jsonfile = json.dumps(jsondata, indent=4)
        f = open(filename, "w")
        f.write(jsondata)
        f.close()
		
    def read_inventory_file(self):
        nodes = []
        with open(self.inventory, 'r') as fin:
            pobj = json.load(fin)
            for promstring in pobj[0]['targets']:
                (ironic_instance, name, target, username, password, redfish_endpoint) = self._decode_prometheus_entry(promstring)
                nodes.append(self._create_session_key(name, target, username, password, redfish_endpoint))
        return nodes
		
    def get_cluster_site(self, host):
 
        location = ""
        site = ""
        status = 0
		
        try:
            loc = host.find('.')
            if loc != -1:
                location = host[loc+1:]
                #print("location: {}\n".format(location))
                site = location[0:2]
                #print("site: {}\n".format(site))
				
                if site == "zp":
                    site = "GDC"
                elif site == "op":
                    site = "OPUS2"
                elif site == "fl":
                    site = "FLEX"
                elif site == "sh":
                    site = "SHZ" 
                else:
                    site = "UNKNOWN"
                    status = -1
            else:
                site = host[0:2]
                if site == "zp":
                    site = "GDC"
                elif site == "op":
                    site = "OPUS2"
                elif site == "fl":
                    site = "FLEX"
                elif site == "sh":
                    site = "SHZ" 
                else:
                    site = "UNKNOWN" 
                    status = -1
			
            #print("site: {}\n".format(site))
			
        except Exception as e: 
            print("Get Cluster Site Exception: {}\n".format(e))
            site = "Get Cluster Site Exception: {}\n".format(e)
            status = -1
			
        return status, site

    # IFWI update
	
    def post_ifwi(self,configured_node):
 
        status = -1
        output = ""
        retval = 0
        site = ""

        try:
            (name, target, username, password, redfish_endpoint) = self._split_session_key(configured_node)
			
            if self.site == "":
                retval, site = self.get_cluster_site(name)
                if retval != 0:
                    output = "Invalid host name format '{}', site information not found.".format(name)
                    return status, output
            else:
                site = self.site
				
            if site not in list(SEAMLESS_UPDATER_SERVER.keys()):
                #print("\nInvalid Cluster site: {}.\n".format(site))
                output = "Invalid Cluster site: {}.".format(site)
                return status, output
            else:
                if self.verbose > 1:
                    print("\nCluster site: {} selected.\n".format(site))
				
            command = "curl --noproxy '*' -i -X POST -H 'Content-Type: multipart/form-data' -F 'capsulefile=@{}' --dump-header - '{}/update?node={}&host={}&bmcuser={}&bmcpass={}&ingredient=IFWI&expected_ver_bios={}'".format(self.capsule, SEAMLESS_UPDATER_SERVER[site], target, name, username, password, self.bkc)
			
            if self.verbose > 1:
                print("Command: {}\n".format(command))
				
            status, output = subprocess.getstatusoutput(command)
            #print(status)
            #if status == 0:
                #print("\noutput:\n{}\n".format(output))
                #if re.search("ReferenceId = ", output, re.IGNORECASE):
                    #loc = output.find("ReferenceId = ")
                    #uuid = output[loc + 14:].strip()
                    #print("UUID: {}\n".format(uuid))
                #else:
                    #errmsg = "Utilization data {} uploaded to iBI but \"ReferenceId\" not generated.\n".format(filename)
            #else:
                #errmsg = "Failed to upload {} to iBI, status: {}.\n{}\n".format(filename,status,output)
                #print("\noutput:\n{}\n".format(output))				
          
        except Exception as e: 
            #print("Post ifwi Exception: {}\n".format(e))
            output = "Post ifwi Exception: {}\n".format(e)

			
        return status, output
		
			
class BMC_access:

    def __init__(self, inventory_file, verbose=0):
        self.inventory = inventory_file
        self.verbose = verbose
		
    def _decode_prometheus_entry(self, entry):
        entries = entry.split('--')
        if len(entries) == 5:
            entries.append('') # add missing redfish_endpoint
        return entries

    def _create_session_key(self, name, target, username, password, redfish_endpoint):
        return "{}--{}--{}--{}--{}".format(name, target, username, password, redfish_endpoint)

    def _split_session_key(self, session):
        return session.split("--")
		
    def _create_jsonfile(self, jsondata, filename):
        #jsonfile = json.dumps(jsondata, indent=4)
        f = open(filename, "w")
        f.write(jsondata)
        f.close()
		
    def read_inventory_file(self):
        nodes = []
        with open(self.inventory, 'r') as fin:
            pobj = json.load(fin)
            for promstring in pobj[0]['targets']:
                (ironic_instance, name, target, username, password, redfish_endpoint) = self._decode_prometheus_entry(promstring)
                nodes.append(self._create_session_key(name, target, username, password, redfish_endpoint))
        return nodes
		
    def sys_power_off(self, configured_node):
  
        status = -1
        output = ""

        try:

            (name, target, username, password, redfish_endpoint) = self._split_session_key(configured_node)
            bmcuser = base64.b64decode(username.encode('utf-8')).decode()
            bmcpass = base64.b64decode(password.encode('utf-8')).decode()
			
            command = "curl --noproxy '*' -X POST https://{}/redfish/v1/Systems/system/Actions/ComputerSystem.Reset".format(target) + " -H 'Content-Type: application/json'" + " -d '{\"ResetType\": \"ForceOff\"}'" + " -u {}:{} -k -q".format(bmcuser, bmcpass)
			
            if int(self.verbose) > 1:
                print("Command: {}\n".format(command))
				
            status, output = subprocess.getstatusoutput(command)
            if status == 0:
                loc = output.find("{")
                if loc != -1:
                    output = output[loc:].strip()
            else:
                loc = output.find("curl")
                if loc != -1:
                    output = output[loc:].strip()
				 
        except Exception as e: 
            output = "System Power off Exception: {}\n".format(e)
		
        return status, output
		
    def sys_power_state(self, configured_node):
  
        status = -1
        output = ""

        try:

            (name, target, username, password, redfish_endpoint) = self._split_session_key(configured_node)
            bmcuser = base64.b64decode(username.encode('utf-8')).decode()
            bmcpass = base64.b64decode(password.encode('utf-8')).decode()
			
            command = "curl --noproxy '*' -X GET https://{}/redfish/v1/Systems/system".format(target) + " -u {}:{} -k -q".format(bmcuser, bmcpass) + " | grep \"PowerState\""
			
            if int(self.verbose) > 1:
                print("Command: {}\n".format(command))
				
            status, output = subprocess.getstatusoutput(command)
            if status == 0:
                loc = output.find("\"PowerState\"")
                if loc != -1:
                    output = "{" + output[loc:-1].strip() + "}"
                    print(output)
                else:
                    output = "{\"PowerState\": \"none\"}"
            else:
                loc = output.find("curl")
                if loc != -1:
                    output = output[loc:].strip()
				 
        except Exception as e: 
            output = "System command Exception: {}\n".format(e)

        return status, output
	
	
# Seamless updater & collector 

def health_check_upd(site, verbose):
 
    status = -1
    output = ""

    try:
        
        command = "curl --noproxy '*' -X GET {}/health".format(SEAMLESS_UPDATER_SERVER[site])
			
        if  int(verbose) > 1:
            print("Command: {}\n".format(command))
				
        status, output = subprocess.getstatusoutput(command)
        if status == 0:
            loc = output.find("seamless_")
            if loc != -1:
                output = output[loc:].strip()				
          
    except Exception as e: 
        output = "Get Health Exception: {}\n".format(e)

    return status, output
	

def health_check_col(site, verbose):

    status = -1
    output = ""
	
    try:
        
        command = "curl --noproxy '*' -X GET {}/health".format(SEAMLESS_COLLECTOR_SERVER[site])
			
        if int(verbose) > 1:
            print("Command: {}\n".format(command))
				
        status, output = subprocess.getstatusoutput(command)
        if status == 0:
            loc = output.find("seamless_")
            if loc != -1:
                output = output[loc:].strip()			
          
    except Exception as e: 
        output = "Get Health Exception: {}\n".format(e)

    return status, output

	
def clean_up(site, verbose):
 
    status = -1
    output = ""

    try:
        
        command = "curl --noproxy '*' -i -X POST {}/cleanup".format(SEAMLESS_UPDATER_SERVER[site])
			
        if int(verbose) > 1:
            print("Command: {}\n".format(command))
				
        status, output = subprocess.getstatusoutput(command)				
          
    except Exception as e: 
        output = "Clean up Exception: {}\n".format(e)

    return status, output
	
		
def check_ping(bmc_ip, verbose):
    
    command = "ping -c 1 -W 3 " + bmc_ip
    status, output = subprocess.getstatusoutput(command)
    if verbose > 1:
        print("\n{}\n".format(output))
    return status


def check_ssh(bmcip, verbose):

    userName = "root"
    passwrd  = "0penBmc1"
    command  = "pwd"
    stdout   = ""
    retval   = False
	
    try:  
        bmcserver = paramikoServer(bmcip,userName,passwrd)
        if verbose > 0:
            print("\nEstablish SSH session to {}.\n".format(bmcip))
			
        if bmcserver.connectSsh() != None:
            retval = True
            stdout = "SSH session is established successfully to {}.".format(bmcip)
			
            """if verbose > 0:
                print("Run command: {}.\n".format(command))
            stdout = bmcserver.runCommand(command)"""
        else:
            stdout = "Failed to establish SSH session to {}.".format(bmcip)
            retval = False		
    except Exception as e:
        retval = False	
        stdout = "SSH exception: {}.".format(e)
    finally:
	
        if verbose > 0:
            print("Closing SSH session from {}.\n".format(bmcip))
			
        bmcserver.closeSSH()
        return retval, stdout
	   
	   
def help():
    print(bcolors.OKCYAN + "\n\nUsage     : " + bcolors.ENDC + "python3 Remote_IFWI_Update.py --inventory 'inventory json' --capsule 'capsule' --bkc 'BKC version'") 
    print("            --site 'GDC|FLEX' --health --cleanup --syspwroff --verbose '1|2' --usage")
    print(bcolors.OKCYAN + "Version   : " + bcolors.WARNING + "{}\n".format(RELEASE_VERSION) + bcolors.ENDC)
    print(bcolors.BOLD   +  "\n***** Arguments *****\n" + bcolors.ENDC)
    print(bcolors.OKCYAN + "inventory : " + bcolors.ENDC + "Allow users to specify a list of SUTs for the IFWI update. The file format is leveraging Ironic inventory file.")
    print(bcolors.OKCYAN + "capsule   : " + bcolors.ENDC + "Allow users to specify the IFWI capsule for the update.")
    print(bcolors.OKCYAN + "bkc       : " + bcolors.ENDC + "Allow users to specify the BKC version for the update.")
    print(bcolors.OKCYAN + "site      : " + bcolors.ENDC + "[OPTIONAL] Allow users to select the updater service based on cluster site. Default is based on node's location.")
    print(bcolors.OKCYAN + "health    : " + bcolors.ENDC + "[OPTIONAL] Allow users to check the updater service status, must use with '--site' to get targeted cluster site.")
    print(bcolors.OKCYAN + "cleanup   : " + bcolors.ENDC + "[OPTIONAL] Allow users to clean up the capsule files, must use with '--site' to get targeted cluster site.")
    print(bcolors.OKCYAN + "syspwroff : " + bcolors.ENDC + "[OPTIONAL] Allow users to power off SUTs via BMC, must use with '--inventory' to get targeted SUTs' list.")
    print(bcolors.OKCYAN + "verbose   : " + bcolors.ENDC + "[OPTIONAL] Allow users to turn on debug messages.")
    print(bcolors.OKCYAN + "usage     : " + bcolors.ENDC + "[OPTIONAL] Allow users to print out help menu.\n\n")


if __name__ == "__main__":
	
    try:
	
        parser = argparse.ArgumentParser()
        parser.add_argument("--inventory",   default=argparse.SUPPRESS, help="List of SUTs to perform the FW update.")
        parser.add_argument("--capsule",     default=argparse.SUPPRESS, help="FW capsule files (seamless) for the update.")
        parser.add_argument("--ingredient",  help="FW update ingredient.")
        parser.add_argument("--bkc",         default=argparse.SUPPRESS, help="BKC Version.")
        parser.add_argument("--site",        help="Optional cluster sites.")
        parser.add_argument("--health",      nargs='?', const=1, type=int, help="Optional service health status.")
        parser.add_argument("--cleanup",     nargs='?', const=1, type=int, help="Optional clean up capsule files.")
        parser.add_argument("--syspwroff",   nargs='?', const=1, type=int, help="Optional power off system via BMC redfish.")
        parser.add_argument("--verbose",     nargs='?', const=1, type=int, help="Optional verbose level.")
        parser.add_argument("--usage",       nargs='?', const=1, type=int, help="Help menu.")
        parser.add_argument("--checkbmcssh", help="Optional check ssh connection.")
        args = parser.parse_args()

			
        # Dispay help menu
		
        if args.usage != None:
            help()
            sys.exit(1)
				
				
        # Dispay version
        print(bcolors.WARNING+ "\nVersion   : " + bcolors.WARNING + "{}\n".format(RELEASE_VERSION) + bcolors.ENDC)
	   
	   
        # Check BMC SSH connection
		
        if args.checkbmcssh != None:

            verbose = 0
            retval = False
            stdout = ""
			
            if args.verbose != None:
                verbose = int(args.verbose)
                print(bcolors.HEADER + "\nVERBOSE ON: {}\n".format(verbose) + bcolors.ENDC)
							
            retval, stdout = check_ssh(args.checkbmcssh, verbose)
            if retval == True:
                print(bcolors.OKGREEN + "\n{}\n".format(stdout) + bcolors.ENDC)
                sys.exit(0)
            else:
                print(bcolors.FAIL + "\nERROR: {}\n".format(stdout) + bcolors.ENDC)
                sys.exit(1)
				
				
       # Service health check
		
        if args.health != None:
		
            status = -1
            output = ""
            verbose = 0
			
            if args.verbose != None:
                verbose = int(args.verbose)
                print(bcolors.HEADER + "\nVERBOSE ON: {}\n".format(verbose) + bcolors.ENDC)
				
            if args.site != None:
			
                if args.site not in list(SEAMLESS_UPDATER_SERVER.keys()) or args.site not in list(SEAMLESS_COLLECTOR_SERVER.keys()):
                    print(bcolors.FAIL + "\nERROR: Invalid Cluster site: {}.\n".format(args.site) + bcolors.ENDC)
                    help()
                    sys.exit(1)
                else:
				
                    status, output = health_check_upd(args.site, verbose)
                    if status != 0:
                        print(bcolors.FAIL + "ERROR: Failed to get Seamless Updater Service health, status: {}.\n{}\n".format(status,output) + bcolors.ENDC)
                        sys.exit(1)
                    else:
                        print("\n{}\n".format(output))

                    status, output = health_check_col(args.site, verbose)
                    if status != 0:
                        print(bcolors.FAIL + "ERROR: Failed to get Seamless Collector Service health, status: {}.\n{}\n".format(status,output) + bcolors.ENDC)
                        sys.exit(1)
                    else:
                        print("{}".format(output))
                    
                    print(bcolors.OKGREEN + "\nSeamless Updater & Collector Services health check PASS.\n" + bcolors.ENDC)
                    sys.exit(0)
            else:
                print(bcolors.FAIL + "\nERROR: Invalid arguments! '--health' must use with '--site' option.\n" + bcolors.ENDC)
                sys.exit(1)
				

        # Cleanp up capsule files from service container
		
        if args.cleanup != None:
            if args.site != None:
                if args.site not in list(SEAMLESS_UPDATER_SERVER.keys()):
                    print(bcolors.FAIL + "\nERROR: Invalid Cluster site: {}.\n".format(args.site) + bcolors.ENDC)
                    help()
                    sys.exit(1)
                else:
                    status = -1
                    output = ""
                    if args.verbose != None:
                        status, output = clean_up(args.site, args.verbose)
                    else:
                        status, output = clean_up(args.site, 0)
                    print("\n{}\n".format(output))
                    sys.exit(0)
            else:
                print(bcolors.FAIL + "\nERROR: Invalid arguments! '--cleanup' must use with '--site' option.\n" + bcolors.ENDC)
                sys.exit(1)
				
				
        # Power off system via BMC
		
        if args.syspwroff != None:
		
            status = -1
            output = ""
            verbose = 0
            node_count = 0
            report = {}
            reportlist = []
			
            if args.verbose != None:
                verbose = int(args.verbose)
                print(bcolors.HEADER + "\nVERBOSE ON: {}\n".format(verbose) + bcolors.ENDC)
				
            if "inventory" in args:
			
                bmcaccess = BMC_access(args.inventory, verbose)
                configured_nodes = bmcaccess.read_inventory_file()
			
                if verbose > 0:
                    print("\nSending System Power Off command...\n")
			
                for node in configured_nodes:
			
                    if verbose > 1:
                        print("Node: {}\n".format(node))
					
                    (name, target, username, password, redfish_endpoint) = bmcaccess._split_session_key(node)
                    node_count += 1
					
                    if verbose > 0:
                        print("\nCheck BMC: {} status...\n".format(target))
						
                    if  check_ping(target, verbose) == 0:
					
                        if verbose > 1:
                            print("\nBMC: {} is active.\n".format(target))
						
                        status, output = bmcaccess.sys_power_off(node)
                        if status == 0:
						
                            if verbose > 1:
                                print("\n{}\n".format(output))
								
                            time.sleep(5)
							
                            status, output = bmcaccess.sys_power_state(node)
                            if status == 0:
                                jsondata = json.loads(output)
                                if verbose > 1:
                                    print("\nSystem Power State: {}\n".format(jsondata["PowerState"]))
								
                                if re.search("off", jsondata["PowerState"], re.IGNORECASE):
                                    if verbose > 0:
                                        print(bcolors.OKGREEN + "\nSystem {} is power off successfully.\n".format(name) + bcolors.ENDC)
                                    report = {"host": name, "result": "PASS - Power " + jsondata["PowerState"]}
                                else:
                                    if verbose > 0:
                                        print(bcolors.FAIL + "\nERROR: Fail to power off system {}.\n".format(name) + bcolors.ENDC)
                                    report = {"host": name, "result": "FAIL - Power " + jsondata["PowerState"]}

                                #sys.exit(0)
                            else:
                                if verbose > 0:
                                    print(bcolors.FAIL + "\nERROR: Fail to send System state command for {}. {}\n".format(name, output) + bcolors.ENDC)
                        else:
                            if verbose > 0:
                                print(bcolors.FAIL + "\nERROR: Fail to send System power off command for {}. {}\n".format(name, output) + bcolors.ENDC)

                            report = {"host": name, "result": "FAIL - " + output}
                    else:
                        if verbose > 0:
                            print(bcolors.FAIL + "\nERROR: BMC: {} is not active.\n".format(target) + bcolors.ENDC)
                        report = {"host": name, "result": "FAIL - BMC not active."}
                        #sys.exit(1)
						
                    reportlist.append(report)
					
                print("\n*************** Summary ***************\n")
                print("Total Nodes: {}\n".format(node_count))
                print("{:<30}{:<30}".format("Host", "Status"))
                print("{:<30}{:<30}".format("****", "******"))
                for i in range(node_count):
                    if re.search("PASS", reportlist[i]["result"], re.IGNORECASE):
                        print("{:<30}".format(reportlist[i]["host"]) + bcolors.OKGREEN + "{:<100}".format(reportlist[i]["result"]) + bcolors.ENDC)
                    else:
                        print("{:<30}".format(reportlist[i]["host"]) + bcolors.FAIL + "{:<100}".format(reportlist[i]["result"]) + bcolors.ENDC)
                print("\n")
                sys.exit(0)
				
            else:
                print(bcolors.FAIL + "\nERROR: Invalid arguments! '--syspwroff' must use with '--inventory' option.\n" + bcolors.ENDC)
                sys.exit(1)
			
			
        # Update IFWI
		
        if "inventory" not in args or "capsule" not in args or "bkc" not in args:
            print(bcolors.FAIL + "\nERROR: Invalid arguments! '--inventory', '--capsule' and '--bkc' are mandatory arguments.\n" + bcolors.ENDC)
            help()
            sys.exit(1)
        else:
            if args.ingredient == None:
                args.ingredient = "IFWI"
				
            inventory_file = args.inventory
            ifwi_capsule = args.capsule
            bkc_version = args.bkc
            site = ""
            verbose = 0
            status = -1
            output = ""
            node_count = 0
            report = {}
            reportlist = []


            if args.verbose != None:
                verbose = int(args.verbose)
                print(bcolors.HEADER + "\nVERBOSE ON: {}\n".format(verbose) + bcolors.ENDC)
				
            if args.site != None:
                site = args.site
                if site not in list(SEAMLESS_UPDATER_SERVER.keys()):
                    print(bcolors.FAIL + "\nERROR: Invalid Cluster site: {}.\n".format(site) + bcolors.ENDC)
                    help()
                    sys.exit(1)
                else:
                    if verbose > 1:
                        print("\nCluster site: {} selected.\n".format(site))		
				
            ifwiupdate = IFWI_Update(inventory_file, ifwi_capsule, bkc_version, site, verbose)
            configured_nodes = ifwiupdate.read_inventory_file()
			
            if verbose > 1:
                print("\nSending {} Update command...\n".format(args.ingredient))
			
            for node in configured_nodes:
			
                if verbose > 1:
                    print("Node: {}\n".format(node))
					
                (name, target, username, password, redfish_endpoint) = ifwiupdate._split_session_key(node)
                node_count += 1
					
                status, output = ifwiupdate.post_ifwi(node)
                if status == 0:
                    if verbose > 0:
                        print(bcolors.OKGREEN + "\n{} update command is sent successfully for {}.\n".format(args.ingredient,name) + bcolors.ENDC)
                    report = {"host": name, "result": "STARTED"}
                else:
                    if verbose > 0:
                        print(bcolors.FAIL + "\nERROR: Fail to send {} update command for {}. {}\n".format(args.ingredient, name, output) + bcolors.ENDC)
                    report = {"host": name, "result": "FAIL - " + output}
					
                reportlist.append(report)
                time.sleep(1)
					
            print("\n*************** Summary ***************\n")
            print("Total Nodes: {}\n".format(node_count))
            print("{:<30}{:<30}".format("Host", "Status"))
            print("{:<30}{:<30}".format("****", "******"))
            for i in range(node_count):
                if reportlist[i]["result"] == "STARTED":
                    print("{:<30}".format(reportlist[i]["host"]) + bcolors.OKGREEN + "{:<100}".format(reportlist[i]["result"]) + bcolors.ENDC)
                else:
                    print("{:<30}".format(reportlist[i]["host"]) + bcolors.FAIL + "{:<100}".format(reportlist[i]["result"]) + bcolors.ENDC)
            print("\n")
			
            sys.exit(0)
			
			
    except Exception as e: 
        print(bcolors.FAIL + "\nException: {}\n".format(e) + bcolors.ENDC)
        sys.exit(1)
		


		


