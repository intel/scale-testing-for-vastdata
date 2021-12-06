#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# How to use the script
# Precondition: iperf3 installed on both client and VAST Data side
# Steps to test 10G performance:
#   Step 1: log onto VAST VMS node, note down one of the VIP on the VMS node, eg 10.A.B.E
#   Step 2: start iperf as the service on the VMS node
#      iperf3 -s -p5900
#   Step 3: run iperf test script on the client:
#      ./run_iperf_test.sh 10 10.A.B.E

# Steps to test 100G performance:
#   Step 1: log onto VAST VMS node, note down one of the VIP on the VMS node, eg 192.168.B.F
#   Step 2: start iperf as the service on the VMS node, but bind iperf3 to the 100GbE interface IP
#      iperf3 -s -p5900 -B 192.168.B.F
#   Step 3: on client 101, run iperf test script:
#      ./run_iperf_test.sh 100 192.168.B.F

network_speed=${1:-"10"}

# Replace the IP accordingly or provide it in command line
vip=${2:-"10.A.B.E"}  

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/env.conf" "$network_speed"

echo "$HOST_SUBNET"

for i in "${CLIENT_NODES_ARRAY[@]}"; do clush -w "$i" "iperf3 -c $vip -B \$(ifconfig | grep inet | grep $HOST_SUBNET | xargs | awk '{print \$2}') -p5900 -t 5"; done
