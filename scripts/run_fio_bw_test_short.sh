#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/common.conf"

"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/bw_test_short_100g.sch -co

# Run it 3 times
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/bw_test_short_100g.sch -ss 2 -pf run1
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/bw_test_short_100g.sch -ss 2 -pf run2
"$SCRIPT_DIR"/run_test.sh -ns 100 -sf "$WORKLOAD_DIR"/fio/bw_test_short_100g.sch -ss 2 -pf run3
"$SCRIPT_DIR"/purge_cluster.sh
