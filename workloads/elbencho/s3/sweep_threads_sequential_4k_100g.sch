# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 32 jobs x 160m x 20 clients x 1 dirs x 100 files = 10T.
# s3 protocol defines that:
#    (1) an upload object cannot consist of more than 10000 parts
#    (2) an upload object can not be less than 5MiB
# VAST doesn't have limitation of (2), but does also have (1).
# Workaround: use 5MiB for write, but read with 4KiB.
--write --blockvarpct=100 --threads=32 --block=5m --size=160m  --dirs=1 --files=100 --mkdirs elbencho-s3-bucket-sweep-threads-100g
# Sequential read
--read  --blockvarpct=100 --threads=32 --block=4k --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
--read  --blockvarpct=100 --threads=16 --block=4k --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
--read  --blockvarpct=100 --threads=8  --block=4k --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
--read  --blockvarpct=100 --threads=4  --block=4k --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
--read  --blockvarpct=100 --threads=2  --block=4k --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
--read  --blockvarpct=100 --threads=1  --block=4k --size=160m  --dirs=1 --files=100 --timelimit=300 --infloop elbencho-s3-bucket-sweep-threads-100g
