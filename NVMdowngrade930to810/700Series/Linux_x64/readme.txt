NVM Update Package
==================
July 1, 2021

Contents
========
Overview
Limitations and Prerequisites
Updating Your NVM Using Interactive Mode
Updating Using a Script
Results
Legal / Disclaimers


OVERVIEW
========
This package contains all the required files to update the NVM on the Intel(R)
Ethernet adapters in your system. It contains the NVMUpdate utility,
configuration file, updated NVM binaries, and required driver files.

Note: Some Intel(R) Ethernet Converged Network Adapter X710-T4 adapters may
display the message "Image differences found at offset 0x7..." when performing
an update using the 700 Series NVM Update Package. This behavior is expected.
Updating the Option ROM on a device with Device ID 1586 is a two step process.
The first update will change the Device ID to 1589. Reboot your system and run
the update tool a second time to update the Option ROM for the new Device ID.

Adapters based on the Intel(R) Ethernet 800 Series
--------------------------------------------------
NVM binaries in the NVM Update Package are in the Platform Level Data Model
(PLDM) format defined by the DMTF in DSP0240. Refer to your vendor's platform
documentation for instructions on how to update your device NVM using the
baseboard management controller (BMC) or UEFI.


Limitations and Prerequisites
=============================
This package is intended to be used on Intel branded adapters. Please contact
your OEM vendor for an appropriate package. In some cases this package may
update an OEM device. This package only updates the NVM image for the device
family listed on the package. Each Intel Ethernet product family has its own
NVM Update Package.

DO NOT
- Power down your system during the NVM Update.
- Remove the NIC before the NVM Update completes.
- Interrupt the NVM Update in any other way.
Doing so may make your device unusable.

Link Loss during and after NVM update
-------------------------------------
When you update a device based on the Intel(R) Ethernet Controller X710 and
Intel(R) Ethernet Controller XL710, the device may lose link during and after
the update. Power cycle your system after the NVM update completes to resolve
the issue.

Linux, FreeBSD, and ESX Requirements
------------------------------------
The base driver for your NIC must already be installed.

UEFI Requirements
-----------------
Create a bootable disk or other media and extract the update package onto the
media.
Boot your system from the media and run the tool from there.

Firmware Recovery Mode
----------------------
When a device is in Firmware Recovery mode it will not pass traffic or allow
any configuration; you can only attempt to recover the device's firmware. A
device will enter Firmware Recovery mode if it detects a problem that requires
the firmware to be reprogrammed.

NOTE: Before starting the recovery process, make sure that your operating
system, drivers, and tools have been installed properly. You must use the
out-of-tree driver. Using the in-box or kernel driver may result in a "Cannot
initialize port" warning.

NOTE: You must power cycle your system after using Recovery Mode to completely
reset the firmware and hardware.


Updating Your NVM Using Interactive Mode
========================================
1. Extract the update package into a temporary folder.
2. Start the NVMUpdate utility by running the executable. For example, on an
   x64 Microsoft* Windows* system, type:

  nvmupdatew64e

On an x64 Linux* system, type:

  nvmupdate64e

3. Follow the prompts to update the NVM image on the desired device.


Using a Script
==============
You can use a script to perform an inventory of all the Intel Ethernet devices
in the system or update the Intel Ethernet devices in the system.
Update script example:

  nvmupdate64e -u -l -o results.xml -b -c nvmupdate.cfg

This causes the NVMUpdate utility to check the installed Intel Ethernet devices
against those contained in nvmupdate.cfg. If a device contains an NVM version
older than that specified in the config file, the utility will update the
device's NVM. It will create an xml file containing the results of the update.
Note that -b is optional. Specifying -b will create a backup of the current NVM
image(s). This may add about 30% to the tools execution time.
Inventory script example:

  nvmupdate64e -i -l -o inventory.xml

This causes the NVMUpdate utility to perform an inventory of all the Intel
Ethernet devices in the system and creates an output file (called
inventory.xml) of the results of the inventory.


Results
=======
The NVMUpdate utility will return an exit code of zero if the update completed
successfully.


LEGAL / DISCLAIMERS
===================
Copyright (C) 2018 - 2021, Intel Corporation. All rights reserved.

This software and the related documents are Intel copyrighted materials, and
your use of them is governed by the express license under which they were
provided to you ("License"). Unless the License provides otherwise, you may not
use, modify, copy, publish, distribute, disclose or transmit this software or
the related documents without Intel's prior written permission.

This software and the related documents are provided as is, with no express or
implied warranties, other than those that are expressly stated in the License.

Intel technologies may require enabled hardware, software or service activation.

No product or component can be absolutely secure.

Your costs and results may vary.

Intel, the Intel logo, and other Intel marks are trademarks of Intel
Corporation or its subsidiaries.

*Other names and brands may be claimed as the property of others.


