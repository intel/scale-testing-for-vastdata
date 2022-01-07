#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/common.conf"

# Ensure it starts cleanly
"$SCRIPT_DIR"/purge_cluster.sh

# Create the files on 100GbE and run it 3 times, cleanup afterwards
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/bw_test_short_100g.sch -co
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/bw_test_short_100g.sch -ss 2 -pf run1
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/bw_test_short_100g.sch -ss 2 -pf run2
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/bw_test_short_100g.sch -ss 2 -pf run3
"$SCRIPT_DIR"/purge_cluster.sh

# Create the files on 10GbE and run it 3 times, cleanup afterwards
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/fio/bw_test_short_10g.sch -co
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/fio/bw_test_short_10g.sch -ss 10 -pf run1
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/fio/bw_test_short_10g.sch -ss 10 -pf run2
"$SCRIPT_DIR"/run_test.sh -ns 10 -sf "$WORKLOAD_DIR"/fio/bw_test_short_10g.sch -ss 10 -pf run3
"$SCRIPT_DIR"/purge_cluster.sh
