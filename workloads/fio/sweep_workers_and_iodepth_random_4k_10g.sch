# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 32 jobs x 3g x 100 clients = 9.6T. 
--rw=randread --numjobs=32 --iodepth=16 --bs=4k --size=3g
--rw=randread --numjobs=16 --iodepth=16 --bs=4k --size=6g
--rw=randread --numjobs=8  --iodepth=16 --bs=4k --size=12g 
--rw=randread --numjobs=4  --iodepth=16 --bs=4k --size=24g
--rw=randread --numjobs=1  --iodepth=16 --bs=4k --size=96g 
 
--rw=randread --numjobs=32 --iodepth=8  --bs=4k --size=3g
--rw=randread --numjobs=16 --iodepth=8  --bs=4k --size=6g
--rw=randread --numjobs=8  --iodepth=8  --bs=4k --size=12g 
--rw=randread --numjobs=4  --iodepth=8  --bs=4k --size=24g
--rw=randread --numjobs=1  --iodepth=8  --bs=4k --size=96g  
