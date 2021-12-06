#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

network_speed=${1:-"10"}

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/env.conf" "$network_speed"

# Install clustershell on current node.
sudo install clustershell -y

# Install clustershell on all nodes.
# clustershell and jq installation are only required by harness on the FIO client node,
# However, installation on all nodes allows any node to be used as FIO client node.
clush -w "$CLIENT_NODES" "sudo yum install clustershell"

# Install other tools needed by the harness.
# lm_sersors not used by harness yet, for further enhancements, it can be used to query temperature during test with "sensors" command.
clush -w "$HEAD_NODE,$CLIENT_NODES" "sudo yum install fio iperf3 jq nfs-utils hwloc-libs hwloc-gui lshw ethtool lm_sensors irqbalance -y"

# Pull from head node only and use elbencho_deploy.sh to deploy instead.
# For users with unlimited docker pull, direct pull from all nodes can be used.

# clush -w $HEAD_NODE,$CLIENT_NODES "docker pull breuner/elbencho"
docker pull breuner/elbencho

# Copy nfs_mount.sh to all clients. 
# This is required for nfs mount with "MULTIPATH_ENABLED=0" in env.conf.

clush -w "$CLIENT_NODES" -c nfs_mount.sh --dest "$VAST_SCALE_TESTING_PATH/nfs_mount.sh"
clush -w "$CLIENT_NODES" -c error_code.conf --dest "$VAST_SCALE_TESTING_PATH/error_code.conf"

# Copy mtu_update.sh to all clients. 

clush -w "$CLIENT_NODES" -c mtu_update.sh --dest "$VAST_SCALE_TESTING_PATH/mtu_update.sh"

# Copy general_info.sh to head_node and all clients. 

clush -w "$CLIENT_NODES" -c general_info.sh --dest "$VAST_SCALE_TESTING_PATH/general_info.sh"

# Install the multipath driver.
# This is required for nfs mount with "MULTIPATH_ENABLED=1" in env.conf.
#
# Preconditions:
#    1. The driver is kernel version dependent. 
#       Obertain the version matching your kernel version from customer.support@vastdata.com if needed.
#    2. "mkdir ../drivers" and place the driver in the folder
#    3. Update MULTIPATH_DRIVER below with the driver name
# 
MULTIPATH_DRIVER="mlnx-nfsrdma-vast_3.9.3.for.4.18.0.240.x.centos-kernel_4.18.0_240.22.1.el8_3.x86_64.rpm"

if [ -f "../drivers/$MULTIPATH_DRIVER" ]; then

    clush -w "$HEAD_NODE,$CLIENT_NODES" "mkdir -p $VAST_SCALE_TESTING_PATH/drivers"
    clush -w "$HEAD_NODE,$CLIENT_NODES" -c "../drivers/$MULTIPATH_DRIVER" --dest "$VAST_SCALE_TESTING_PATH/drivers"
    clush -w "$HEAD_NODE,$CLIENT_NODES" "sudo rpm -i $VAST_SCALE_TESTING_PATH/drivers/$MULTIPATH_DRIVER; sudo dracut -f"
    
    # The new driver will only take effect after the reboot
    # The reboot is commented out in case another convenient time if preferred for reboot.
    
    # clush -w $CLIENT_NODES "sudo reboot"
    # sudo reboot
fi
