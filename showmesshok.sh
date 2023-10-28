#!/bin/bash
cut -d ' ' -f 1-6 sshstatusconn |grep ok |awk '{print $4}' > full_list2
cat full_list2
./list_get_Bios_And_Kernel_info.sh full_list2 > report_get_Bios_and_kernel
sleep 45
cat report_get_Bios_and_kernel
echo "**********************************************************************************************************"
grep -v 5.15.0-spr.bkc.pc.2.10.0.x86_64 report_get_Bios_and_kernel
exit 1
