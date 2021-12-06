#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

network_speed=${1:-"10"}

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/env.conf" "$network_speed"

clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "docker logs elbencho-server" 
