#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

network_speed=${1:-"10"}

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/env.conf" "$network_speed"

clush -w "$HEAD_NODE","$CLIENT_NODES" "sudo pkill -9 fio"
sudo pkill -9 fio
sudo pkill -9 run_test_no_runlog.sh
sudo pkill -9 run_test.sh

docker container kill elbencho-client > /dev/null 2>/dev/null
docker container rm elbencho-client > /dev/null 2>/dev/null
clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "docker container kill elbencho-server > /dev/null 2>/dev/null; 
                                                  docker container rm elbencho-server > /dev/null 2>/dev/null;
					                                        sudo pkill -9 nfs_mount.sh"
