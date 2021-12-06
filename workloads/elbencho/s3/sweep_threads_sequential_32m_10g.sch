# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 32 jobs x 160m x 100 clients x 1 dirs x 20 files = 10T.
--write --blockvarpct=100 --threads=32 --block=32m --size=160m  --dirs=1 --files=20 --mkdirs elbencho-s3-bucket-sweep-threads-10g
# Sequential read
--read  --blockvarpct=100 --threads=32 --block=32m --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-10g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-10g
--read  --blockvarpct=100 --threads=8  --block=32m --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-10g
--read  --blockvarpct=100 --threads=4  --block=32m --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-10g
--read  --blockvarpct=100 --threads=2  --block=32m --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-10g
--read  --blockvarpct=100 --threads=1  --block=32m --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-10g
