#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/error_code.conf" # This file shall be copied to all clients, in the same folder as nfs_mount.sh

MOUNT=$1
REMOTE_PATH=$2
HOST_SUBNET=$3
NCONNECT_NUM=$4
randomnize=$5
nfs_mount_log_file=$6
all_vips=("${@:7}")  # This is array
NCONNECT_NUM_MIN=0
NCONNECT_NUM_MAX=48
uid=$UID

# Validate the inputs
return_code=0
if [ "$#" -le 6 ]; then
    echo "NFS mount failure, invalid number of inputs. Valid parameters: [MOUNT REMOTE_PATH HOST_SUBNET NCONNECT_NUM RANDOMNIZATION VIPs]. Exiting..."
    return_code=$ERROR_CODE_NO_MULTIPATH_MOUNT_INVALID_NUMBER_OF_INPUTS
elif [[ "$MOUNT" != "/mnt/"* ]]; then
    echo "NFS mount failure, mount base not in /mnt/* format, exiting..."
    return_code=$ERROR_CODE_NO_MULTIPATH_MOUNT_INVALID_MOUNT_BASE
elif [[ "$HOST_SUBNET" != *"."*"."* ]]; then
    echo "NFS mount failure, invalid subnet, must be in format A.B.C, exiting..."
    return_code=$ERROR_CODE_NO_MULTIPATH_MOUNT_INVALID_SUBNET
elif [ "$NCONNECT_NUM" -lt $NCONNECT_NUM_MIN ] || [ "$NCONNECT_NUM" -gt $NCONNECT_NUM_MAX ]; then
    echo "NFS mount failure, invalid nconnect number, must be in range [$NCONNECT_NUM_MIN, $NCONNECT_NUM_MAX], exiting..."
    return_code=$ERROR_CODE_NO_MULTIPATH_MOUNT_INVALID_NCONNECT_NUM
elif [ "$randomnize" != "yes" ] && [ "$randomnize" != "no" ]; then
    echo "NFS mount failure, invalid randomnization, must be in [yes, no], exiting..."
    return_code=$ERROR_CODE_NO_MULTIPATH_MOUNT_INVALID_RANDOMNIZE
fi

if [ "$return_code" != "0" ]; then
    echo "Error code: $return_code" > "$nfs_mount_log_file"
    exit "$return_code"
fi

HN=$(hostname -s)
if [ "$randomnize" == "yes" ]; then
    vip_list=$(shuf -e "${all_vips[@]}" | xargs)
    IFS=" " read -r -a all_vips <<< "$vip_list"
fi

if [[ ! -L "$nfs_mount_log_file" ]] && [ -f "$nfs_mount_log_file" ]; then
    rm -rf "$nfs_mount_log_file"
fi

for MOUNTVIP in "${all_vips[@]}"
do
    remote_address="${HOST_SUBNET}.${MOUNTVIP}:/${REMOTE_PATH}"
    mountpoint_parent="${MOUNT}/${REMOTE_PATH}/${HN}"
    mountpoint="${mountpoint_parent}/${HOST_SUBNET}.${MOUNTVIP}"
    sudo mkdir -p "$mountpoint_parent"       
    sudo chown $uid:$uid "$mountpoint_parent"    
    sudo mkdir -p "$mountpoint"       
    sudo chown $uid:$uid "$mountpoint"
    
    if [ "$NCONNECT_NUM" == "0" ]; then        
        sudo mount -t nfs -o vers=3,tcp "$remote_address" "$mountpoint" 2> "$nfs_mount_log_file"
    else
        sudo mount -t nfs -o vers=3,tcp,nconnect="${NCONNECT_NUM}" "$remote_address" "$mountpoint" 2> "$nfs_mount_log_file"
    fi
        
    if [[ ! -L "./$nfs_mount_log_file" ]] && [ -s "./$nfs_mount_log_file" ]; then 
        if grep -q "exited with exit code\|timed out\|Failed\|failed" "./$nfs_mount_log_file"; then 
            echo "Mount of $remote_address to $mountpoint failed:"
            cat "$nfs_mount_log_file" # No cleanup of this file until the next run
            exit "$ERROR_CODE_NO_MULTIPATH_MOUNT_FAILURE" 
        fi
    fi     
done