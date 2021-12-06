# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 32 jobs x 3g x 100 clients = 9.6T.
--rw=randread --numjobs=32 --iodepth=32 --bs=1024k --size=3g  --name=sweep-workers-32 --create_only --tag=1
--rw=randread --numjobs=32 --iodepth=32 --bs=1024k --size=3g  --name=sweep-workers-32 --tag=1
--rw=randread --numjobs=32 --iodepth=16 --bs=1024k --size=3g  --name=sweep-workers-32 --tag=1
--rw=randread --numjobs=32 --iodepth=8  --bs=1024k --size=3g  --name=sweep-workers-32 --tag=1
--rw=randread --numjobs=16 --iodepth=32 --bs=1024k --size=6g  --name=sweep-workers-16 --create_only --tag=1
--rw=randread --numjobs=16 --iodepth=32 --bs=1024k --size=6g  --name=sweep-workers-16 --tag=1
--rw=randread --numjobs=16 --iodepth=16 --bs=1024k --size=6g  --name=sweep-workers-16 --tag=1
--rw=randread --numjobs=16 --iodepth=8  --bs=1024k --size=6g  --name=sweep-workers-16 --tag=1
--rw=randread --numjobs=8  --iodepth=32 --bs=1024k --size=12g --name=sweep-workers-8  --create_only --tag=1
--rw=randread --numjobs=8  --iodepth=32 --bs=1024k --size=12g --name=sweep-workers-8  --tag=1
--rw=randread --numjobs=8  --iodepth=16 --bs=1024k --size=12g --name=sweep-workers-8  --tag=1
--rw=randread --numjobs=8  --iodepth=8  --bs=1024k --size=12g --name=sweep-workers-8  --tag=1
--rw=randread --numjobs=4  --iodepth=32 --bs=1024k --size=24g --name=sweep-workers-4  --create_only --tag=1
--rw=randread --numjobs=4  --iodepth=32 --bs=1024k --size=24g --name=sweep-workers-4  --tag=1
--rw=randread --numjobs=4  --iodepth=16 --bs=1024k --size=24g --name=sweep-workers-4  --tag=1
--rw=randread --numjobs=4  --iodepth=8  --bs=1024k --size=24g --name=sweep-workers-4  --tag=1
--rw=randread --numjobs=1  --iodepth=32 --bs=1024k --size=96g --name=sweep-workers-1  --create_only --tag=1
--rw=randread --numjobs=1  --iodepth=32 --bs=1024k --size=96g --name=sweep-workers-1  --tag=1
--rw=randread --numjobs=1  --iodepth=16 --bs=1024k --size=96g --name=sweep-workers-1  --tag=1
--rw=randread --numjobs=1  --iodepth=8  --bs=1024k --size=96g --name=sweep-workers-1  --tag=1
