#!/bin/bash

#export http_proxy=http://proxy-us.intel.com:911
#export https_proxy=http://proxy-us.intel.com:911
export https_proxy=http://proxy-dmz.intel.com:912
env | grep -i proxy

