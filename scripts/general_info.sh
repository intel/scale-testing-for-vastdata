#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

HOST_SUBNET=$1   # eg: 192.168.B
NUMA_TOPO_OUTPUT_DIR=$2

if [ "$(ifconfig | grep "$HOST_SUBNET")" == "" ]; then
    echo "Invalid host subnet: $HOST_SUBNET"
    exit 22 # Standard EINVAL for Invalid Argument
fi

if [ ! -d "$NUMA_TOPO_OUTPUT_DIR" ]; then
    echo "$NUMA_TOPO_OUTPUT_DIR not found!"
    exit 22 # Standard EINVAL for Invalid Argument
fi

date
hostname
uname -r
cat /etc/centos-release

# Query memory information
echo "Memory information:"
cat /proc/meminfo  
   
# Query CPU information
echo "CPU information by lscpu:"
lscpu

echo "CPU information by /proc/cpuinfo:"
cat /proc/cpuinfo

# More detailed turbo boost information
cpupower frequency-info
   
# Query NIC card info
echo "Network information:"
sudo lshw -class network
 
# Query the networking configuration
echo "ifconfig information:"
ifconfig

# Query the NIC FW version information, i.e. driver and FW version
# Strip off the color control charactors at the beginning with sed
echo "NIC information:"
network_interface=$(sed -r "s:\x1B\[[0-9;]*[mK]::g" <<< "$(sudo ip -br -c addr show | grep --color=never "$HOST_SUBNET" | cut -d' ' -f 1)")
ethtool -i "$network_interface"

# Query Numa topology 
echo "Numa topology:"
lstopo -l

if [ "$NUMA_TOPO_OUTPUT_DIR" != "" ]; then
    lstopo --logical --output-format png > "$NUMA_TOPO_OUTPUT_DIR/numa.png"
fi

# Query Numa statistics
echo "Numa stats:"
numastat -c -z -m -n


   
