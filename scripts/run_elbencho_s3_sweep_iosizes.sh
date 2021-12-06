#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/common.conf"

iterations=3
sleep_in_seconds=600

purge_and_wait() {
    "$SCRIPT_DIR"/purge_cluster.sh
    sleep "$sleep_in_seconds"
}

purge_only() {
    "$SCRIPT_DIR"/purge_cluster.sh
}

for i in $(seq 1 $iterations)
do

    "$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/elbencho/s3/sweep_iosizes_random_100g.sch -pf "run$i"
    purge_and_wait
    
    if [ "$i" == "$iterations" ]; then
        purge_only
    else
        purge_and_wait
    fi
    
done
