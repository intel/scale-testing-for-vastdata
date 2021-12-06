#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

network_speed=${1:-"10"}

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/env.conf" "$network_speed"

MOUNT="$MOUNT_MULTIPATH_ENABLED"
clush -w "$CLIENT_NODES" "for i in \$(seq 1 \$(mount | grep multipath-tcp | wc -l | cut -d' ' -f 2)); do sudo umount $MOUNT > /dev/null 2>/dev/null; done"

MOUNT="$MOUNT_MULTIPATH_DISABLED"
remote_path_all=("$REMOTE_PATH_FIO" "$REMOTE_PATH_ELBENCHO_FILE" "$REMOTE_PATH_ELBENCHO_S3")

for REMOTE_PATH in "${remote_path_all[@]}"
do
    clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "sudo umount ${MOUNT}/${REMOTE_PATH}/\$(hostname -s)/* > /dev/null 2>/dev/null &" &
done
wait
