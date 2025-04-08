#!/bin/bash

sed -i d outlet_data_info_pdu1_temp
sed -i d outlet_data_info_pdu2_temp

function outletreportpdu1 {

OUTLET1=($1);

grep -wi ${OUTLET1[0]} -A13 temp_pdu1_info |awk '/State|Current|ActivePower|ApparentPower|PowerFactor/' >> outlet_data_info_pdu1_temp

} 

function outletreportpdu2 {

OUTLET2=($1);

grep -wi ${OUTLET2[0]} -A13 temp_pdu2_info |awk '/State|Current|ActivePower|ApparentPower|PowerFactor/' >> outlet_data_info_pdu2_temp

}

echo -e "\033[33mEnter the row number with this format "X"\033[0m"
read -p "ROW: " nrow
echo -e "\033[33mEnter the rack number with this format "XX" if the number is of 1 digit.\033[0m"
read -p "RACK: " nrack

if [[ "$nrow" = "1" ]];then
        nrow="zp3110b001p"

elif [[ "$nrow" = "2" ]];then
        nrow="zp3110b002p"
else
echo "this number not is vaild"
fi

echo -e "\noutlets connected in pdu01\n"
grep ${nrow}${nrack}01 /var/local/Sysman/cluster_nodes.py |sed -e 's/ //g' |tr '"' '|' | awk -F '|' '{print "system: "$2 " " "pdu: "$12 " " "outlet"$14}' > pdu1info
cat pdu1info
cat pdu1info| awk '{print $5}' > outletconnectedpdu1_list
echo -e "\noutlets connected in pdu02\n"
grep ${nrow}${nrack}02 /var/local/Sysman/cluster_nodes.py |sed -e 's/ //g' |tr '"' '|' | awk -F '|' '{print "system: "$2 " " "pdu: "$12 " " "outlet"$14}' > pdu2info
cat pdu2info
cat pdu2info| awk '{print $5}' > outletconnectedpdu2_list

pdu1_name=`echo "${nrow}${nrack}01"`

ip_addrss1=$(ping -c1 -n $pdu1_name | head -n 1 | sed "s/.*(\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)).*/\1/g")

sshpduuser=$(cat sshpduuser.txt)
sshpdupass=$(cat sshpdupass.txt)

echo "Transferring pdu folder to the pdu info of $pdu1_name"

sshpass -p $sshpdupass scp -o StrictHostKeyChecking=no $sshpduuser@$ip_addrss1:/diag-data.zip . &

<< 'multiline-comment'
for i in $(seq 60 -1 1); do
  printf "Time remaining: %02d\r" "$i"
  sleep 1
done
echo -e "\nTime's up!\n"
multiline-comment
echo -e "\nPlease wait 1 minute, it's downloading pdu1 info"

total_seconds=60
bar_length=20

for (( i = 0; i <= bar_length; i++ )); do
  progress=$((i * 100 / bar_length))
  filled_length=$((i * bar_length / bar_length))
  empty_length=$((bar_length - filled_length))
  filled_bar=$(printf "%${filled_length}s" | tr " " "#")
  empty_bar=$(printf "%${empty_length}s" | tr " " "-")

  printf "\rProgress: [%s%s] %d%%" "$filled_bar" "$empty_bar" "$progress"
  sleep $((total_seconds / bar_length))
done

echo "" # Move to the next line after completion

unzip -qq diag-data.zip -d ./pdu1-diag-data/

rm -rf diag-data.zip

cp ./pdu1-diag-data/diag-data/topo-data .

mv topo-data pdu1-topo-data

crow1_temp=$(grep -n -m1 "Outlet 1" pdu1-topo-data |head -n 1|cut -d ":" -f 1)
y=1
crow1=$(echo "$(($crow1_temp - $y))")
sed -e 's/ //g' ./pdu1-topo-data > temp_pdu1_info
sed -i "1,${crow1}d" temp_pdu1_info

pdu2_name=`echo "${nrow}${nrack}02"`

ip_addrss2=$(ping -c1 -n $pdu2_name | head -n 1 | sed "s/.*(\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)).*/\1/g")

sshpduuser=$(cat sshpduuser.txt)
sshpdupass=$(cat sshpdupass.txt)

echo "Transferring pdu folder to the pdu info of $pdu2_name"

sshpass -p $sshpdupass scp -o StrictHostKeyChecking=no $sshpduuser@$ip_addrss2:/diag-data.zip . &

echo -e "\nPlease wait 1 minute, it's downloading pdu2 info"

total_seconds=60
bar_length=20

for (( i = 0; i <= bar_length; i++ )); do
  progress=$((i * 100 / bar_length))
  filled_length=$((i * bar_length / bar_length))
  empty_length=$((bar_length - filled_length))
  filled_bar=$(printf "%${filled_length}s" | tr " " "#")
  empty_bar=$(printf "%${empty_length}s" | tr " " "-")

  printf "\rProgress: [%s%s] %d%%" "$filled_bar" "$empty_bar" "$progress"
  sleep $((total_seconds / bar_length))
done

echo "" # Move to the next line after completion

echo -e "Information is being generated"

unzip -qq diag-data.zip -d ./pdu2-diag-data/

rm -rf diag-data.zip

cp ./pdu2-diag-data/diag-data/topo-data .

mv topo-data pdu2-topo-data

crow2_temp=$(grep -n -m1 "Outlet 1" pdu2-topo-data |head -n 1|cut -d ":" -f 1)
x=1
crow2=$(echo "$(($crow2_temp - $x))")

sed -e 's/ //g' ./pdu2-topo-data > temp_pdu2_info
sed -i "1,${crow2}d" temp_pdu2_info

OUTLETS1=$(grep -i outlet outletconnectedpdu1_list)

if [ -z "${OUTLETS1}" ]; then
	echo "empty list"
	exit 1
fi

for n in ${OUTLETS1}; do
	outletreportpdu1 $n
done

OUTLETS2=$(grep -i outlet outletconnectedpdu2_list)

if [ -z "${OUTLETS2}" ]; then
	echo "empty list"
	exit 1
fi

for m in ${OUTLETS2}; do
	outletreportpdu2 $m
done

cat outlet_data_info_pdu1_temp outlet_data_info_pdu2_temp > outlet_data_info_pdu_all_temp

tr ':' ' ' < outlet_data_info_pdu_all_temp > outlet_data_info_pdu_all

awk '
BEGING{ FS="i " }
/^State/{
  if(++count1==1){ header=$1 }
  stateArr[++count]=$NF
  next
}
/^Current/{
  if(++count2==1){ header=header OFS $1 }
  currentArr[count]=$NF
  next
}
/^ActivePower/{
  if(++count3==1){ header=header OFS $1 }
  activepowArr[count]=$NF
  next
}
/^ApparentPower/{
  if(++count4==1){ header=header OFS $1 }
  apparentpowArr[count]=$NF
  next
}
/^PowerFactor/{
  if(++count5==1){ header=header OFS $1 }
  powerfactorArr[count]=$NF
  next
}

END{
  print header
  for(i=1;i<=count;i++){
   printf("%s %s %s %s %s\n",stateArr[i],currentArr[i],activepowArr[i],apparentpowArr[i],powerfactorArr[i])
  }
}
' outlet_data_info_pdu_all | column -t > outlet_report_h


cat pdu1info pdu2info > allpdusinfo_temp

input_file="allpdusinfo_temp"
output_file="allpdusinfo_temp_wtimestamp"

while IFS= read -r line; do
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$line $timestamp"
done < "$input_file" > "$output_file"

#echo "Timestamp column added to $output_file"


awk 'BEGIN {print "\tSystem\t\t\t\tPDU\t\t\tOutlet"} {print $0}' allpdusinfo_temp_wtimestamp > allpdusinfo

paste allpdusinfo outlet_report_h > report_pdu_information
./find_highvalues.sh report_pdu_information
#cat report_pdu_information

rm -rf pdu1info pdu2info outletconnectedpdu1_list outletconnectedpdu2_list temp_pdu1_info temp_pdu2_info outlet_data_info_pdu_all_temp outlet_data_info_pdu_all allpdusinfo_temp pdu1-topo-data pdu2-topo-data outlet_data_info_pdu1_temp outlet_data_info_pdu2_temp outlet_report_h allpdusinfo allpdusinfo_temp_wtimestamp

rm -rf ./pdu1-diag-data/diag-data/
rm -rf ./pdu2-diag-data/diag-data/

