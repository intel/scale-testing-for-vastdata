#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

network_speed=${1:-"10"}

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/env.conf" "$network_speed"

clush -w "$HEAD_NODE","$CLIENT_NODES" "sudo systemctl start docker"
clush -w "$HEAD_NODE","$CLIENT_NODES" "sudo chmod 666 /var/run/docker.sock"

# Direct docker pull is disabled for Anonymous and authenticated docker users
# to use elbencho_deploy.sh as the workaround instead.
#clush -w "$HEAD_NODE","$CLIENT_NODES" "docker pull breuner/elbencho"

