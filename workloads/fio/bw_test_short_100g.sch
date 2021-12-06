# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size = 16 jobs x 30g x 20 clients = 9.6T.
--rw=randread   --numjobs=16 --iodepth=8  --bs=1024k --size=30g  --runtime=300 --ramp_time=60

