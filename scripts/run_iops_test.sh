#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Ensure the cluster is 99% free and Auxiliary is o or close to 0 before start ( < 4T perferred)
# The test will write ~12TB of data, and it takes 5~10 minutes to be truely purged
# Sleep after the purge to ensure all tests start with the same condition

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
    prefix="run$i"
    
    "$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/iops_test_100g.sch -pf "$prefix"
    purge_and_wait
    "$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/elbencho/file/iops_test_100g.sch -pf "$prefix"
    purge_and_wait
    "$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/elbencho/s3/iops_test_100g.sch -pf "$prefix"
    purge_and_wait
    "$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/fio/iops_test_10g.sch -pf "$prefix"
    purge_and_wait
    "$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/elbencho/file/iops_test_10g.sch -pf "$prefix"
    purge_and_wait
    "$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/elbencho/s3/iops_test_10g.sch -pf "$prefix"
    
    if [ "$i" == "$iterations" ]; then
        purge_only
    else
        purge_and_wait
    fi
done
