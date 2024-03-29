# Intel Copyright � 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 32 jobs x 160m x 100 clients x 1 dirs x 20 files = 10T.
# s3 protocol defines that:
#    (1) an upload object cannot consist of more than 10000 parts
#    (2) an upload object cannot be less than 5MiB
# VAST doesn't have limitation of (2), but does also have (1).
# Workaround: use 5MiB for write, but read with 4KiB.
--write --blockvarpct=100 --threads=32 --block=5m --size=160m  --dirs=1 --files=20 --mkdirs elbencho-s3-bucket-sweep-threads-10g
# Random read
--read  --blockvarpct=100 --threads=32 --block=4k --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop --randamount=1p --s3randobj elbencho-s3-bucket-sweep-threads-10g
--read  --blockvarpct=100 --threads=16 --block=4k --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop --randamount=1p --s3randobj elbencho-s3-bucket-sweep-threads-10g
--read  --blockvarpct=100 --threads=8  --block=4k --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop --randamount=1p --s3randobj elbencho-s3-bucket-sweep-threads-10g
--read  --blockvarpct=100 --threads=4  --block=4k --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop --randamount=1p --s3randobj elbencho-s3-bucket-sweep-threads-10g
--read  --blockvarpct=100 --threads=2  --block=4k --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop --randamount=1p --s3randobj elbencho-s3-bucket-sweep-threads-10g
--read  --blockvarpct=100 --threads=1  --block=4k --size=160m  --dirs=1 --files=20 --timelimit=300 --infloop --randamount=1p --s3randobj elbencho-s3-bucket-sweep-threads-10g
