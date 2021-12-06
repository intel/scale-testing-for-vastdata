# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 4 threads x 1280m x 100 clients x 1 dirs x 1 files = 512G.
# Total data for read and write < 4T, both data will be held in Optane
# Create the files first, then read altogether.
--write --blockvarpct=100 --iodepth=64 --threads=4 --block=4k --direct --size=1280m --nosvcshare --dirs=1 --files=1 --mkdirs --name=iops-test-10g-job1
--read  --blockvarpct=100 --iodepth=64 --threads=4 --block=4k --direct --size=1280m --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop --name=iops-test-10g-job1

--write --blockvarpct=100 --iodepth=16 --threads=4 --block=4k --direct --size=1280m --nosvcshare --dirs=1 --files=1 --mkdirs --name=iops-test-10g-job2
--read  --blockvarpct=100 --iodepth=16 --threads=4 --block=4k --direct --size=1280m --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop --name=iops-test-10g-job2
# For random write statistics only.
--write --blockvarpct=100 --iodepth=64 --threads=4 --block=4k --direct --size=1280m --nosvcshare --dirs=1 --files=1 --mkdirs --rand --timelimit=300 --name=iops-test-10g-job3
--write --blockvarpct=100 --iodepth=16 --threads=4 --block=4k --direct --size=1280m --nosvcshare --dirs=1 --files=1 --mkdirs --rand --timelimit=300 --name=iops-test-10g-job4

# Write 9.6T (> 2 * 4T) of data to fully destage the previous data to QLC 
--write --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=6g --nosvcshare --dirs=1 --files=1 --mkdirs --name=iops-test-10g-job5
# Now re-read the data written before
--read  --blockvarpct=100 --iodepth=64 --threads=4 --block=4k --direct --size=1280m --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop --name=iops-test-10g-job1
--read  --blockvarpct=100 --iodepth=16 --threads=4 --block=4k --direct --size=1280m --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop --name=iops-test-10g-job2
