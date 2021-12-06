#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/common.conf"

"$SCRIPT_DIR"/purge_cluster.sh
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/elbencho/s3/sweep_threads_random_32m_100g.sch
"$SCRIPT_DIR"/purge_cluster.sh
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/elbencho/s3/sweep_iosizes_random_100g.sch
"$SCRIPT_DIR"/purge_cluster.sh
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/elbencho/s3/sweep_threads_random_4k_100g.sch

"$SCRIPT_DIR"/purge_cluster.sh
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/elbencho/s3/sweep_threads_random_32m_10g.sch
"$SCRIPT_DIR"/purge_cluster.sh
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/elbencho/s3/sweep_iosizes_random_10g.sch
"$SCRIPT_DIR"/purge_cluster.sh
sleep 300
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/elbencho/s3/sweep_threads_random_4k_10g.sch
