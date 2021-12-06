#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Anonymous and authenticated docker users may run into docker pull limit quickly.
# This script provide a workaround to manually pull once and deploy the elbencho
# docker image to all systems.

# How to use it:
#
# Step 1: pull once
#     docker pull breuner/elbencho
# Step 2: note down "IMAGE ID" of the pulled image
#     docker image ls
# Example response:
#     REPOSITORY                  TAG          IMAGE ID      CREATED      SIZE
#     docker.io/breuner/elbencho  latest       d379a16a2453  4 days ago   136 MB
# Step 3: update ELBENCHO_ID and ELBENCHO_TAG accordingly in env.conf.
#         Tag is user defined string to help identify the version in a more convenient way.
# Step 4: run this script to deploy accordingly

# For more information of how to use elbencho, please refer to:
#     https://github.com/breuner/elbencho
#     https://hub.docker.com/r/breuner/elbencho
#
# To see the help of elbencho:
#     docker run --net=host -it breuner/elbencho --help-all

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/env.conf" 10 # 10 used here because all 100G nodes are 10 nodes as well. This may not be general enough. To be improved.

clush -w "$HEAD_NODE","$CLIENT_NODES" "sudo systemctl start docker"
clush -w "$HEAD_NODE","$CLIENT_NODES" "sudo chmod 666 /var/run/docker.sock"

mkdir -p "$ELBENCHO_IMAGE_FOLDER"
if [ ! -f "$ELBENCHO_IMAGE_FOLDER"/"$ELBENCHO_IMG" ]; then
    docker image tag "$ELBENCHO_ID" breuner/elbencho:$ELBENCHO_TAG
    docker image save -o "$ELBENCHO_IMAGE_FOLDER"/"$ELBENCHO_IMG" "$ELBENCHO_ID"
fi

clush -w "$CLIENT_NODES" "mkdir -p $ELBENCHO_IMAGE_FOLDER"
clush -w "$CLIENT_NODES" -c "$ELBENCHO_IMAGE_FOLDER/$ELBENCHO_IMG"
clush -w "$CLIENT_NODES" "docker image load -i $ELBENCHO_IMAGE_FOLDER/$ELBENCHO_IMG"
clush -w "$CLIENT_NODES" "docker image tag $ELBENCHO_ID breuner/elbencho:$ELBENCHO_TAG"



