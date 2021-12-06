# Data size per workload = 16 jobs x 6g x 100 clients x 1 dirs x 1 files = 9.6T.
--write --blockvarpct=100 --iodepth=16 --threads=16 --block=1024k --direct --size=6g --nosvcshare --dirs=1 --files=1 --mkdirs 
# Random read 
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=6g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=512k  --direct --size=6g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=256k  --direct --size=6g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=128k  --direct --size=6g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=64k   --direct --size=6g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=32k   --direct --size=6g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=16k   --direct --size=6g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=8k    --direct --size=6g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop
--read  --blockvarpct=100 --iodepth=8 --threads=16 --block=4k    --direct --size=6g --nosvcshare --dirs=1 --files=1 --rand --timelimit=300 --infloop
