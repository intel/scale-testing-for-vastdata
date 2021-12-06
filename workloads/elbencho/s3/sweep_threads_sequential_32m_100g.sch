# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 32 jobs x 160m x 20 clients x 1 dirs x 100 files = 10T.
--write --blockvarpct=100 --threads=32 --block=32m --size=160m  --dirs=1 --files=100 --mkdirs elbencho-s3-bucket-sweep-threads-100g
# Sequential read
--read  --blockvarpct=100 --threads=32 --block=32m --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
--read  --blockvarpct=100 --threads=8  --block=32m --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
--read  --blockvarpct=100 --threads=4  --block=32m --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
--read  --blockvarpct=100 --threads=2  --block=32m --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
--read  --blockvarpct=100 --threads=1  --block=32m --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
