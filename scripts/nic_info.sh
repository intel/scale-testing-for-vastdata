#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

network_speed=${1:-"10"}

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/env.conf" "$network_speed"

query_network_interface_cmd="sed -r 's:\x1B\[[0-9;]*[mK]::g' <<< \$(sudo ip -br -c addr show | grep --color=never $HOST_SUBNET | cut -d' ' -f 1)"

echo "Querying NIC type:"
clush -w "$CLIENT_NODES" "network_interface=\$($query_network_interface_cmd); sudo lshw -class network | grep -B 10 \$network_interface | grep product" | sort
echo "Querying NIC Firmware Version"
clush -w "$CLIENT_NODES" "network_interface=\$($query_network_interface_cmd); ethtool -i \$network_interface | grep firmware-version" | sort
echo "Querying MTU:"
clush -w "$CLIENT_NODES" "network_interface=\$($query_network_interface_cmd); ifconfig | grep \$network_interface" | sort
echo "NUMA binding:"  # BIOS determines if enabled or not, -1 means disabled. Installation determines which NUMA is at, if enabled in BIOS.
clush -w "$CLIENT_NODES" "network_interface=\$($query_network_interface_cmd); cat /sys/class/net/\$network_interface/device/numa_node" | sort