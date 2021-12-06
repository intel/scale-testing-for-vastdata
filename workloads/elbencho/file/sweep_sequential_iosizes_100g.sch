# Data size per workload = 16 jobs x 6g x 20 clients x 1 dirs x 5 files = 9.6T.
--write --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=6g --nosvcshare --dirs=1 --files=5 --mkdirs 
# Sequential read
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=6g --nosvcshare --dirs=1 --files=5 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=512k  --direct --size=6g --nosvcshare --dirs=1 --files=5 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=256k  --direct --size=6g --nosvcshare --dirs=1 --files=5 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=128k  --direct --size=6g --nosvcshare --dirs=1 --files=5 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=64k   --direct --size=6g --nosvcshare --dirs=1 --files=5 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=32k   --direct --size=6g --nosvcshare --dirs=1 --files=5 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=16k   --direct --size=6g --nosvcshare --dirs=1 --files=5 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=8k    --direct --size=6g --nosvcshare --dirs=1 --files=5 --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=4k    --direct --size=6g --nosvcshare --dirs=1 --files=5 --timelimit=300 --infloop
