# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size = 4 jobs x 1280m x 100 clients = 512G. 
# 2 x 512g write for randread iops. Total data for read and write < 4T, both data will be hold in Optane
# Create the files first, then read altogether.
--rw=randread   --numjobs=4  --iodepth=64  --bs=4k --size=1280m --runtime=300 --ramp_time=60 --create_only --name=iops-test-1-10g --tag=1
--rw=randread   --numjobs=4  --iodepth=64  --bs=4k --size=1280m --runtime=300 --ramp_time=60 --name=iops-test-1-10g --tag=1
--rw=randread   --numjobs=4  --iodepth=16  --bs=4k --size=1280m --runtime=300 --ramp_time=60 --create_only --name=iops-test-2-10g --tag=1
--rw=randread   --numjobs=4  --iodepth=16  --bs=4k --size=1280m --runtime=300 --ramp_time=60 --name=iops-test-2-10g --tag=1
# Another 2 x 512G write. This could be a partial write, as the runtime is too short. 
# Only use it for write statistics. For read statistics, need to regenerate the complete file.
--rw=randwrite  --numjobs=4  --iodepth=64  --bs=4k --size=1280m --runtime=300 --ramp_time=60
--rw=randwrite  --numjobs=4  --iodepth=16  --bs=4k --size=1280m --runtime=300 --ramp_time=60
# Write 9.6T (> 2 * 4T) of data to fully destage the previous data to QLC 
--rw=write      --numjobs=16 --iodepth=8   --bs=1024k --size=6g --fill_device
# Now re-read the data written before
--rw=randread   --numjobs=4  --iodepth=64  --bs=4k --size=1280m --runtime=300 --ramp_time=60 --name=iops-test-1-10g --tag=1
--rw=randread   --numjobs=4  --iodepth=16  --bs=4k --size=1280m --runtime=300 --ramp_time=60 --name=iops-test-2-10g --tag=1

