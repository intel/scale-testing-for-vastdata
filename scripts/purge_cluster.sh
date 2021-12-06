#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/env.conf" 10 # Always run from 10g interface

sudo umount /mnt/all > /dev/null 2>/dev/null
sudo mount "$_HOST_SUBNET_FIRST_VIP_10G:"/ /mnt/all -t nfs
pushd /mnt/all || exit

file .vast_trash
if [ "$REMOTE_PATH_FIO" != "" ]; then
    if [ -d "/mnt/all/$REMOTE_PATH_FIO" ]; then
        sudo mv /mnt/all/"${REMOTE_PATH_FIO}"/* /mnt/all/.vast_trash                > /dev/null 2>/dev/null
    fi
    
    # Todo: MULTIPATH_ENABLE=0 currently requires remote path to exist first, 
    # so use this as the workaround to always ensure that's true.
    
    # Should consider mount differently and remove this requirement later
    sudo mkdir -p /mnt/all/$REMOTE_PATH_FIO  
fi 

if [ "$REMOTE_PATH_ELBENCHO_FILE" != "" ]; then
    if [ -d "/mnt/all/$REMOTE_PATH_ELBENCHO_FILE" ]; then
        sudo mv /mnt/all/"${REMOTE_PATH_ELBENCHO_FILE}"/* /mnt/all/.vast_trash      > /dev/null 2>/dev/null
    fi
    sudo mkdir -p /mnt/all/$REMOTE_PATH_ELBENCHO_FILE
fi

if [ "$REMOTE_PATH_ELBENCHO_S3" != "" ]; then
    if [ -d "/mnt/all/$REMOTE_PATH_ELBENCHO_S3" ]; then
        sudo mv /mnt/all/"${REMOTE_PATH_ELBENCHO_S3}"/* /mnt/all/.vast_trash        > /dev/null 2>/dev/null
    fi
    sudo mkdir -p /mnt/all/$REMOTE_PATH_ELBENCHO_S3 
fi

# For easier cleanup, it is recommended that schedule files in workloads/elbencho/s3 
# to create s3 bucket with elbencho-s3-bucket* naming convention.
sudo mv /mnt/all/elbencho-s3-bucket* /mnt/all/.vast_trash  > /dev/null 2>/dev/null

popd || exit
