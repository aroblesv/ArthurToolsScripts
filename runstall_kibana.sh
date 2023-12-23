#!/bin/bash

#Parameters
: "${1?Must provide node name}"
NODE=${1}

echo "Download script to sut"
ssh $NODE 'curl -LO http://s3web.l10b2.deacluster.intel.com/download/bkc-mirror/wilson_city/setup_sut_zp31.sh; chmod 777 setup_sut_zp31.sh; TOKEN=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 ./setup_sut_zp31.sh'
