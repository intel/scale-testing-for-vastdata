# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 16 jobs x 1g x 100 clients x 1 dirs x 1 file = 1.6T.
--write --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=1g --nosvcshare --dirs=1 --files=1 --mkdirs --name=bw-test-10g-job1
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=1g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop --name=bw-test-10g-job1
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=1g --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop --name=bw-test-10g-job1
# Short random write for statistics
--write --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=1g --nosvcshare --dirs=1 --files=1 --mkdirs --rand --timelimit=300 --name=bw-test-10g-job2

# Data size per workload = 16 jobs x 6g x 100 clients x 1 dirs x 1 file = 9.6T.
--write --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=6g --nosvcshare --dirs=1 --files=1 --mkdirs --name=bw-test-10g-job3
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=6g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop --name=bw-test-10g-job3
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=6g --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop --name=bw-test-10g-job3
# Short random write for statistics
--write --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=6g --nosvcshare --dirs=1 --files=1 --mkdirs --rand --timelimit=300 --name=bw-test-10g-job4

# Data size per workload = 16 jobs x 15g x 100 clients x 1 dirs x 1 file = 24T.
--write --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=15g --nosvcshare --dirs=1 --files=1 --mkdirs --name=bw-test-10g-job5
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=15g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop --name=bw-test-10g-job5
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=15g --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop --name=bw-test-10g-job5
# Short random write for statistics
--write --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=15g --nosvcshare --dirs=1 --files=1 --mkdirs --rand --timelimit=300 --name=bw-test-10g-job6
