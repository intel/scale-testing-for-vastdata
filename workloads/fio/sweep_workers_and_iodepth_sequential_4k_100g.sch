# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 32 jobs x 15g x 20 clients = 9.6T. 
--rw=read --numjobs=32 --iodepth=16 --bs=4k --size=15g
--rw=read --numjobs=16 --iodepth=16 --bs=4k --size=30g
--rw=read --numjobs=8  --iodepth=16 --bs=4k --size=60g 
--rw=read --numjobs=4  --iodepth=16 --bs=4k --size=120g
--rw=read --numjobs=1  --iodepth=16 --bs=4k --size=480g 
 
--rw=read --numjobs=32 --iodepth=8  --bs=4k --size=15g
--rw=read --numjobs=16 --iodepth=8  --bs=4k --size=30g
--rw=read --numjobs=8  --iodepth=8  --bs=4k --size=60g 
--rw=read --numjobs=4  --iodepth=8  --bs=4k --size=120g
--rw=read --numjobs=1  --iodepth=8  --bs=4k --size=480g  
