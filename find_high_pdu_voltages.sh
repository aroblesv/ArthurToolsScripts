#!/bin/bash

function highestload {

HVOLTAGE=($1);

grep -i ${HVOLTAGE[0]} -B5 temp_pdu_info >> report_hight_voltage
echo -e "\n" >> report_hight_voltage

#ddif [ $? == 0 ];then

}



echo -e "\n\033[034mFind outlets with hight temperature.\033[0m\n"
echo -e "********************************************************************************"
echo -e "\033[33mEnter the rack number with this format "XX" if the number is of 1 digit.\033[0m"
read -p "RACK: " nrack
echo -e "\033[33mEnter the PDU number with this formtat "" if the number is of 1 digit.\033[0m"
read -p "PDU: " npdu
echo -e "\n"


total_iterations=100
bar_length=20

for ((i = 0; i <= total_iterations; i++)); do
  progress=$((i * 100 / total_iterations))
  completed_length=$((progress * bar_length / 100))
  remaining_length=$((bar_length - completed_length))

  completed_bar=$(printf "%${completed_length}s" | tr ' ' '#')
  remaining_bar=$(printf "%${remaining_length}s" | tr ' ' '-')

  printf "\rProgress: [%s%s] %3d%%" "$completed_bar" "$remaining_bar" "$progress"
  sleep 0.001
done

echo ""
echo -e "\n"

pdu_name=$(echo -e "zp3110b001p$nrack$npdu")

ip_addrss=$(ping -c1 -n $pdu_name | head -n 1 | sed "s/.*(\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)).*/\1/g")

sshpduuser=$(cat sshpduuser.txt)
sshpdupass=$(cat sshpdupass.txt)

#sshpass -p $sshpdupass  scp -o StrictHostKeyChecking=no $sshpduuser@$ip_addrss:/diag-data.zip .

#sshpass -p $sshpdupass rsync -r -v --progress -e $sshpduuser@$ip_addrss:/diag-data.zip .
<< 'multi-line-comment'
sp="/-\|"
sc=0
spin() {
   printf "\b${sp:sc++:1}"
   ((sc==${#sp})) && sc=0
}
endspin() {
   printf "\r%s\n" "$@"
}
multi-line-comment

echo "Transferring pdu folder to the pdu info of $pdu_name"

sshpass -p $sshpdupass scp -o StrictHostKeyChecking=no $sshpduuser@$ip_addrss:/diag-data.zip . &

for i in $(seq 60 -1 1); do
  printf "Time remaining: %02d\r" "$i"
  sleep 1
done
echo -e "\nTime's up!\n"

#rsync -e "ssh -o StrictHostKeyChecking=no" -arvc --progress $sshpduuser@$ip_addrss:/diag-data.zip .
<< 'multi-line-comment'
cmd_status=$(jobs | awk '{print $2}')
until [ "$cmd_status" = "Done" ]; do
     spin
     cmd_status=$(jobs | awk '{print $2}')
done
endspin
multi-line-comment

unzip -qq diag-data.zip

cp ./diag-data/topo-data .

sed -e 's/ //g' ./topo-data > temp_pdu_info
sed -i '1,75d' temp_pdu_info

#grep -i "activepower:" ./temp_pdu_info |sort -t ":" -k2 -n

#grep 751.82W -B5 temp_pdu_info

#grep -E "^Current:[0-9]\.[0-9][0-9]"A|grep 9.50

#grep -i -E "[0-9]*\.[0-9]*w\(normal\)" temp_pdu_info

#grep -i -E "[0-9]*\.[0-9]*w\(normal\)" temp_pdu_info |sort -t":" -k2 -n

grep -i -E "[0-9]*\.[0-9]*w\(normal\)" temp_pdu_info |sort -t":" -k2 -n|tail -n 5|cut -c 13-19 > 5_HighestLoad

cat -n 5_HighestLoad

echo -e "\n"

HIGHEST=$(grep -i -E "[0-9]*\.[0-9]*w" 5_HighestLoad)

if [ -z "${HIGHEST}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${HIGHEST}; do
	highestload $n
done

cat report_hight_voltage

rm -rf diag-data.zip diag-data topo-data temp_pdu_info 5_HighestLoad report_hight_voltage
	

<< 'MULTILINE-COMMENT'
Outlet35:
Receptacle:IEC60320C13
State:on
Voltage:242.24V(normal)
Current:3.12A(normal)
ActivePower:751.82W(normal)
MULTILINE-COMMENT
