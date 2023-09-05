#!/bin/bash
echo -e "\r\nBuild file Progress\r\n"
file=$(ls -ltr |awk '{print $9}'|tail -n1)
watch -n5 "cat -n $file"
echo "To close or exit prss ctrl + c"
