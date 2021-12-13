# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Data size per workload = 4 jobs x 1280m x 100 clients x 1 dirs x 1 file = 512G.
# Total data for read and write < 4T, both data will be held in Optane
# Create the files first, then read altogether.
#
# s3 protocol defines that:
#    (1) an upload object cannot consist of more than 10000 parts
#    (2) an upload object cannot be less than 5MiB
# VAST doesn't have limitation of (2), but does also have (1).
# Workaround: use 5MiB for write, but read with 4KiB.
--write --blockvarpct=100 --threads=4 --block=5m --size=1280m --dirs=1 --files=1 --mkdirs elbencho-s3-bucket1-10g
--read  --blockvarpct=100 --threads=4 --block=4k --size=1280m --dirs=1 --files=1 --s3randobj --timelimit=300 --infloop elbencho-s3-bucket1-10g
# Write 10T (> 2 * 4T) of data to fully destage the previous data to QLC 
--write --blockvarpct=100 --threads=16 --block=32m --size=160m --dirs=40 --files=1 --mkdirs elbencho-s3-bucket2-10g
# Now re-read the data written before
--read  --blockvarpct=100 --threads=4 --block=4k --size=1280m --dirs=1 --files=1 --s3randobj --timelimit=300 --infloop elbencho-s3-bucket1-10g

