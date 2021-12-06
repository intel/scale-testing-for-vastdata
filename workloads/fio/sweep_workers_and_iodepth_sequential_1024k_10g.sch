# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 32 jobs x 3g x 100 clients = 9.6T. 
--rw=read --numjobs=32 --iodepth=16 --bs=1024k --size=3g
--rw=read --numjobs=16 --iodepth=16 --bs=1024k --size=6g
--rw=read --numjobs=8  --iodepth=16 --bs=1024k --size=12g 
--rw=read --numjobs=4  --iodepth=16 --bs=1024k --size=24g
--rw=read --numjobs=1  --iodepth=16 --bs=1024k --size=96g
  
--rw=read --numjobs=32 --iodepth=8  --bs=1024k --size=3g
--rw=read --numjobs=16 --iodepth=8  --bs=1024k --size=6g
--rw=read --numjobs=8  --iodepth=8  --bs=1024k --size=12g 
--rw=read --numjobs=4  --iodepth=8  --bs=1024k --size=24g
--rw=read --numjobs=1  --iodepth=8  --bs=1024k --size=96g  
