# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 16 jobs x 160m x 20 clients x 1 dirs x 32 files = 1.6T.
--write --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=32 --mkdirs elbencho-s3-bucket1-100g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=32 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket1-100g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=32 --timelimit=300 --infloop elbencho-s3-bucket1-100g

# Data size per workload = 16 jobs x 160m x 20 clients x 1 dirs x 200 files = 10T.
--write --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=200 --mkdirs elbencho-s3-bucket1-100g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket1-100g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=200 --timelimit=300 --infloop elbencho-s3-bucket1-100g

# Data size per workload = 16 jobs x 160m x 20 clients x 1 dirs x 400 files = 24T.
--write --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=480 --mkdirs elbencho-s3-bucket1-100g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=480 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket1-100g
--read  --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=1 --files=480 --timelimit=300 --infloop elbencho-s3-bucket1-100g
