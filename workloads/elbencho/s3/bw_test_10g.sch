# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 16 jobs x 160m x 100 clients x 1 dirs x 6 files = 1.5T.
--write --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=6 --mkdirs elbencho-s3-bucket1-10g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=6 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket1-10g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=6 --timelimit=300 --infloop elbencho-s3-bucket1-10g

# Data size per workload = 16 jobs x 160m x 100 clients x 1 dirs x 40 files = 10T.
--write --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=40 --mkdirs elbencho-s3-bucket1-10g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=40 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket1-10g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=40 --timelimit=300 --infloop elbencho-s3-bucket1-10g

# Data size per workload = 16 jobs x 160m x 100 clients x 1 dirs x 96 files = 24T.
--write --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=96 --mkdirs elbencho-s3-bucket1-10g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=96 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket1-10g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=96 --timelimit=300 --infloop elbencho-s3-bucket1-10g
