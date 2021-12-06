# Data size per workload = 32 jobs x 3g x 100 clients x 1 dirs x 1 files = 9.6T.
# Generate all data first
--write --blockvarpct=100 --iodepth=8 --threads=32 --block=4k --direct --size=3g   --nosvcshare --dirs=1 --files=1 --mkdirs  
--write --blockvarpct=100 --iodepth=8 --threads=16 --block=4k --direct --size=6g   --nosvcshare --dirs=1 --files=1 --mkdirs
--write --blockvarpct=100 --iodepth=8 --threads=8  --block=4k --direct --size=12g  --nosvcshare --dirs=1 --files=1 --mkdirs
--write --blockvarpct=100 --iodepth=8 --threads=4  --block=4k --direct --size=24g  --nosvcshare --dirs=1 --files=1 --mkdirs
--write --blockvarpct=100 --iodepth=8 --threads=1  --block=4k --direct --size=96g  --nosvcshare --dirs=1 --files=1 --mkdirs
# Sequential read, iodepth 8
--read  --blockvarpct=100 --iodepth=8 --threads=32 --block=4k --direct --size=3g   --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=4k --direct --size=6g   --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=8  --block=4k --direct --size=12g  --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=4  --block=4k --direct --size=24g  --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=1  --block=4k --direct --size=96g  --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
# Sequential read, iodepth 16
--read  --blockvarpct=100 --iodepth=16 --threads=32 --block=4k --direct --size=3g  --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=16 --threads=16 --block=4k --direct --size=6g  --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=16 --threads=8  --block=4k --direct --size=12g --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=16 --threads=4  --block=4k --direct --size=24g --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=16 --threads=1  --block=4k --direct --size=96g --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
# Sequential read, iodepth 32
--read  --blockvarpct=100 --iodepth=16 --threads=32 --block=4k --direct --size=3g  --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=16 --threads=16 --block=4k --direct --size=6g  --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=16 --threads=8  --block=4k --direct --size=12g --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=16 --threads=4  --block=4k --direct --size=24g --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=16 --threads=1  --block=4k --direct --size=96g --nosvcshare --dirs=1 --files=1 --timelimit=300 --infloop
