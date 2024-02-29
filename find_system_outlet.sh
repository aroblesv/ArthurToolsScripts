#!/bin/bash

read -p "Write rack with 2 digits: " nrack
read -p "Now Write pdu nomber 2 digits: " npdu
read -p "Write outlet number: " noutlet

grep zp3110b001s$nrack /var/local/Sysman/cluster_nodes.py |grep p$nrack$npdu|grep $noutlet\"\)\,$ |awk '{print $5}'
