# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size = 16 jobs x 1g x 100 clients = 1.6T.
--rw=write      --numjobs=16 --iodepth=8  --bs=1024k --size=1g  --fill_device=1  --name=bw-test-job1-10g --tag=1
--rw=randread   --numjobs=16 --iodepth=8  --bs=1024k --size=1g  --runtime=300    --ramp_time=60 --name=bw-test-job1-10g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=read       --numjobs=16 --iodepth=8  --bs=1024k --size=1g  --runtime=300    --ramp_time=60 --name=bw-test-job1-10g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=randwrite  --numjobs=16 --iodepth=8  --bs=1024k --size=1g  --runtime=300    --ramp_time=60 --name=bw-test-rnd-job1-10g --tag=1

# Data size = 16 jobs x 6g x 100 clients = 9.6T.
--rw=write      --numjobs=16 --iodepth=8  --bs=1024k --size=6g  --fill_device=1  --name=bw-test-job2-10g --tag=1
--rw=randread   --numjobs=16 --iodepth=8  --bs=1024k --size=6g  --runtime=300    --ramp_time=60 --name=bw-test-job2-10g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=read       --numjobs=16 --iodepth=8  --bs=1024k --size=6g  --runtime=300    --ramp_time=60 --name=bw-test-job2-10g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=randwrite  --numjobs=16 --iodepth=8  --bs=1024k --size=6g  --runtime=300    --ramp_time=60 --name=bw-test-rnd-job2-10g --tag=1

# Data size = 16 jobs x 15g x 100 clients = 24T.
--rw=write      --numjobs=16 --iodepth=8  --bs=1024k --size=15g  --fill_device=1  --name=bw-test-job3-10g --tag=1
--rw=randread   --numjobs=16 --iodepth=8  --bs=1024k --size=15g  --runtime=300    --ramp_time=60 --name=bw-test-job3-10g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=read       --numjobs=16 --iodepth=8  --bs=1024k --size=15g  --runtime=300    --ramp_time=60 --name=bw-test-job3-10g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=randwrite  --numjobs=16 --iodepth=8  --bs=1024k --size=15g  --runtime=300    --ramp_time=60 --name=bw-test-rnd-job3-10g --tag=1
