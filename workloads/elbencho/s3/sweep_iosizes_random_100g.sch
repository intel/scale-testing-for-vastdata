# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 16 jobs x 160m x 20 clients x 1 dirs x 200 files = 10T.
--write --blockvarpct=100 --threads=16 --block=32m --size=160m  --dirs=1 --files=200 --mkdirs elbencho-s3-bucket-sweep-iosizes-100g
# Random read
--read  --blockvarpct=100 --threads=16  --block=32m  --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=16m  --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=8m   --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=5m   --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=4m   --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=2m   --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=1m   --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=512k --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=256k --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=128k --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=64k  --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=32k  --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=16k  --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=8k   --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
--read  --blockvarpct=100 --threads=16  --block=4k   --size=160m  --dirs=1 --files=200 --timelimit=300 --infloop --s3randobj elbencho-s3-bucket-sweep-iosizes-100g
