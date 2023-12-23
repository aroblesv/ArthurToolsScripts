#!/bin/bash

#Parameters
: "${Must provide node name}"
NODE=$1{1}

ssh $NODE 'yum-config-manager --disable intel-embargo; TOKEN=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 ./setup_sut_zp31.sh'
