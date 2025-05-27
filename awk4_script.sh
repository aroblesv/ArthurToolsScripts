#!/bin/bash
node=$1

BMC_ID=$(echo $node |sed '0,/s/s//b/')
echo -e "\n"
echo -e "\n"
echo "executing clean known hosts in: $node"
echo "executing clean known hosts in: $BMC_ID"
sed -i "/${node}/d" ~/.ssh/known_hosts
sed -i "/${BMC_ID}/d" ~/.ssh/known_hosts

ssh root@${node} -n "dmidecode -t 17" > memories.csv
echo -e "\nInstalled memories information $node"

#cat memories.csv |tr -d '\t'|grep -i ^size:[[:space:]][[:digit:]]| cut -d ' ' -f 2 > size_mem.info
cat memories.csv |tr -d '\t'|grep -i ^size:[[:space:]][[:digit:]]|grep -i gb| cut -d ' ' -f 2 > size_mem_gb.info
cat memories.csv |tr -d '\t'|grep -i ^size:[[:space:]][[:digit:]]|grep -i mb| cut -d ' ' -f 2 > size_mem_mb.info
tmeminstalled_ddr=$(cat size_mem_gb.info |wc -l)
tmeminstalled_optane=$(cat size_mem_mb.info|wc -l)
result=$(($tmeminstalled_ddr+$tmeminstalled_optane)) 
while read -r num1; do ((sum1 += num1)); done < size_mem_gb.info; echo -e "\nTotal DDR: $sum1 Gb and memories Installed: $tmeminstalled_ddr"
while read -r num2; do ((sum2 += num2)); done < size_mem_mb.info; echo -e "\nTotal Optane: $sum2 Mb or $((sum2/1000)) Gb and memories Installed: $tmeminstalled_optane\n"
echo -e "Memories sum: $result\n"
echo -e "Total DRR + Optane: $((sum1+((sum2/1000)))) Gb\n"
cat memories.csv |tr -d '\t'|grep -A11 -i ^size:[[:space:]][[:digit:]]|awk '/Size|Locator: CPU|Speed|Manufacturer|Serial|Part/' > mem_data_info

#find2point=`cat mem_serial_list |head -n 1 |grep -i :` 
#findmdash=`cat mem_serial_list| head -n 1 |grep -i -`
#if [ -z "$find2point" ]; then
   # cat memories.csv |tr -d '\t'|grep -A11 -i ^size:[[:space:]][[:digit:]]|awk '/Serial/'|cut -d ':' -f 2 > mem_serial_list
   # cat memories.csv |tr -d '\t'|grep -A11 -i ^size:[[:space:]][[:digit:]]|awk '/Serial/'|rev|cut -c 1-7|rev  > mem_serial_list
cat memories.csv |tr -d '\t'|grep -A11 -i ^size:[[:space:]][[:digit:]]|awk '/Serial/'|awk '{print $3}' > mem_serial_list

#	sed -i 's/[[:blank:]]//g' mem_serial_list
#	sed -i 's/[[:blank:]]//g' mem_data_info
#	sed -i 's/\:/ /g' mem_data_info
#else
#    cat memories.csv |tr -d '\t'|grep -A11 -i ^size:[[:space:]][[:digit:]]|awk '/Serial/'|cut -d ':' -f 2 > mem_serial_list 
#	sed -i 's/[[:blank:]]//g' mem_serial_list
#	sed -i 's/[[:blank:]]//g' mem_data_info
#	sed -i 's/\:/ /g' mem_data_info
#fi    
sed -i 's/[[:blank:]]//g' mem_serial_list
#sed -i 's/\-//g' mem_serial_list
sed -i 's/[[:blank:]]//g' mem_data_info
sed -i 's/\:/ /g' mem_data_info
#sed -i 's/\-//g' mem_data_info

awk '
BEGING{ FS="i " }
/^Size/{
  if(++count1==1){ header=$1 }
  sizeArr[++count]=$NF
  next
}
/^Locator/{
  if(++count2==1){ header=header OFS $1 }
  locatorArr[count]=$NF
  next
}
/^Speed/{
  if(++count3==1){ header=header OFS $1 }
  speedArr[count]=$NF
  next
}
/^Manufacturer/{
  if(++count4==1){ header=header OFS $1 }
  manufacturerArr[count]=$NF
  next
}
/^Serial/{
  if(++count5==1){ header=header OFS $1 }
  serialArr[count]=$NF
  next
}
/^Part/{
  if(++count6==1){ header=header OFS $1 }
  partArr[count]=$NF
  next
}
END{
  print header
  for(i=1;i<=count;i++){
   printf("%s %s %s %s %s %s\n",sizeArr[i],locatorArr[i],speedArr[i],manufacturerArr[i],serialArr[i],partArr[i])
  }
}
' mem_data_info | column -t
echo -e "\nGenerating Gcode"
echo -e "\n*****************************************************************************"

while read p; do
  grep -i $p mem_inventory.csv|tail -1 >> gcode.file
done < mem_serial_list

sed -i 's/"//g' gcode.file
cut -d ',' -f 1,2,3,4 gcode.file |tr ',' '\t'
echo -e "GDC INFO" > gcode.file
#echo -e "\nBuild table copy and pate memlocation meminventor"
#echo -e "then execute make_mem_info.sh"
