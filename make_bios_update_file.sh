#!/bin/bash
#simple scripts to make file
#Parameters

#Local Variales
echo "work current capsule me: CAPSULE_BOOT_PRODUCTION_30_P26_Signed_12745.cap"
echo "work current capsule bios: CAPSULE_ME_SPS_30_P26_signed_12745.cap"
S3WEB_URL="$(ping -c2 s3web.l10b2 |grep statistics |sed 's/.*s3web/s3web/g' |awk '{ printf $1 }')"
opc_yes=yes
read -p "Type your list: " list
read -p "Type Me_Capsule Name: " ME_CAPSULE
read -p "type Bios Capsule Name: " BIOS_CAPSULE

#FULL_LIST="full_list2"
echo -e "\r\nContents of the list"
cat -n $list
echo "Is your data correct? $ME_CAPSULE and $BIOS_CAPSULE"
read -p "yes or no: " opc_typed
	if [ $opc_typed = $opc_yes ]; then
				sed -e 's:^:./node_update_bios.sh :g' "$list" > send_bios_update_list.sh
				sed -i "s|$|\ http://${S3WEB_URL}/bkc-mirror/wilson_city/bios_capsules/$ME_CAPSULE http://${S3WEB_URL}/bkc-mirror/wilson_city/bios_capsules/$BIOS_CAPSULE \&|" send_bios_update_list.sh
				echo "Your run files has been successfully created: send_bios_update_list.sh"
			else
				exit 1
	fi
