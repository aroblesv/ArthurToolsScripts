cat memories.csv|tr -d '\t'|grep -A11 -i ^size:[[:space:]][[:digit:]]| awk '/Size|Locator: CPU|Speed|Manufacturer|Serial|Part/' > mem_data_info
