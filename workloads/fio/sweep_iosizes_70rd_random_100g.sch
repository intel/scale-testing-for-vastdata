# Intel Copyright � 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 16 jobs x 30g x 20 clients = 9.6T.
# Workload on each client is 70 read, 30 write
--rw=randrw --numjobs=16 --iodepth=8 --bs=1024k --size=30g --rwmixread=70
--rw=randrw --numjobs=16 --iodepth=8 --bs=512k  --size=30g --rwmixread=70
--rw=randrw --numjobs=16 --iodepth=8 --bs=256k  --size=30g --rwmixread=70
--rw=randrw --numjobs=16 --iodepth=8 --bs=128k  --size=30g --rwmixread=70
--rw=randrw --numjobs=16 --iodepth=8 --bs=64k   --size=30g --rwmixread=70
--rw=randrw --numjobs=16 --iodepth=8 --bs=32k   --size=30g --rwmixread=70
--rw=randrw --numjobs=16 --iodepth=8 --bs=16k   --size=30g --rwmixread=70
--rw=randrw --numjobs=16 --iodepth=8 --bs=8k    --size=30g --rwmixread=70
--rw=randrw --numjobs=16 --iodepth=8 --bs=4k    --size=30g --rwmixread=70
