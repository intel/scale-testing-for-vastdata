#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# If the interface is not eth0, specify it in command line argument
#**************
# Important   *
#**************
#  (1)	Please adapt to the proper interfaces if they are different
#  (2)	Ensure switch side connected to this interface supports 9000 too, 
#       otherwise the system may not be reachable after this update

network_interface=${1,-"eth0"}

if [ ! -f /etc/sysconfig/network-scripts/ifcfg-"$network_interface" ]; then
    echo "/etc/sysconfig/network-scripts/ifcfg-$network_interface not found!"
    exit 22 # Standard EINVAL for Invalid Argument
fi

echo "MTU=9000" | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-"$network_interface"
sudo systemctl restart NetworkManager

# Commented out as connection could be broken for clush when NetworkManager restarts
#cat /etc/sysconfig/network-scripts/ifcfg-"$network_interface"
