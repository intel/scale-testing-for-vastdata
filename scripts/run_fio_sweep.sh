#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/common.conf"

"$SCRIPT_DIR"/purge_cluster.sh
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/sweep_workers_and_iodepth_random_1024k_100g.sch -co
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/sweep_workers_and_iodepth_random_1024k_100g.sch
"$SCRIPT_DIR"/purge_cluster.sh
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/sweep_iosizes_100rd_random_100g.sch -co
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/sweep_iosizes_100rd_random_100g.sch

"$SCRIPT_DIR"/purge_cluster.sh
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/fio/sweep_workers_and_iodepth_random_1024k_10g.sch -co
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/fio/sweep_workers_and_iodepth_random_1024k_10g.sch
"$SCRIPT_DIR"/purge_cluster.sh
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/fio/sweep_iosizes_100rd_random_10g.sch -co
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/fio/sweep_iosizes_100rd_random_10g.sch