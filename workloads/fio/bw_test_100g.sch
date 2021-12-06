# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size = 16 jobs x 5g x 20 clients = 1.6T.
--rw=write      --numjobs=16 --iodepth=8  --bs=1024k --size=5g  --fill_device=1  --name=bw-test-job1-100g --tag=1
--rw=randread   --numjobs=16 --iodepth=8  --bs=1024k --size=5g  --runtime=300    --ramp_time=60 --name=bw-test-job1-100g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=read       --numjobs=16 --iodepth=8  --bs=1024k --size=5g  --runtime=300    --ramp_time=60 --name=bw-test-job1-100g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=randwrite  --numjobs=16 --iodepth=8  --bs=1024k --size=5g  --runtime=300    --ramp_time=60 --name=bw-test-rnd-job1-100g --tag=1

# Data size = 16 jobs x 30g x 20 clients = 9.6T.
--rw=write      --numjobs=16 --iodepth=8  --bs=1024k --size=30g  --fill_device=1  --name=bw-test-job2-100g --tag=1
--rw=randread   --numjobs=16 --iodepth=8  --bs=1024k --size=30g  --runtime=300    --ramp_time=60 --name=bw-test-job2-100g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=read       --numjobs=16 --iodepth=8  --bs=1024k --size=30g  --runtime=300    --ramp_time=60 --name=bw-test-job2-100g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=randwrite  --numjobs=16 --iodepth=8  --bs=1024k --size=30g  --runtime=300    --ramp_time=60 --name=bw-test-rnd-job2-100g --tag=1

# Data size = 16 jobs x 75g x 20 clients = 24T.
--rw=write      --numjobs=16 --iodepth=8  --bs=1024k --size=75g  --fill_device=1  --name=bw-test-job3-100g --tag=1
--rw=randread   --numjobs=16 --iodepth=8  --bs=1024k --size=75g  --runtime=300    --ramp_time=60 --name=bw-test-job3-100g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=read       --numjobs=16 --iodepth=8  --bs=1024k --size=75g  --runtime=300    --ramp_time=60 --name=bw-test-job3-100g --fallocate=none --create_on_open=1 --create_serialize=0 --tag=1
--rw=randwrite  --numjobs=16 --iodepth=8  --bs=1024k --size=75g  --runtime=300    --ramp_time=60 --name=bw-test-rnd-job3-100g --tag=1
