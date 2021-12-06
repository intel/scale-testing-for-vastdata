# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

#========================================================================================================
# Elbencho options supported by the Elbencho File testing schedule file:
# 
#     Mandatory: rw/numjobs/iodepth/bs
#                They will be used to generate the result filename
#     Optional:  all valid Elbencho options for file testing are supported in schedule file. Common ones to be used are:
#                rand/blockvarpct/direct/size/nosvcshare/dirs/files/mkdirs/timelimit/infloop
#                
# 
# Non-Elbencho options supported by the schedule file:
#     --name: This is added for workload to create the files under the specified folder, instead of the default.
#             The difference is whether the file will be reused or new files will be generated.
#             For example, following 2 lines will write to the same file
#                 --write --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=1g --nosvcshare --dirs=1 --files=1 --mkdirs
#                 --write --blockvarpct=100 --iodepth=8 --threads=8  --block=1024k --direct --size=1g --nosvcshare --dirs=1 --files=1 --mkdirs
#             While the lines below will write to different files:
#                 --write --blockvarpct=100 --iodepth=8 --threads=16 --block=1024k --direct --size=1g --nosvcshare --dirs=1 --files=1 --mkdirs --name=bw-test-100g-job1
#                 --write --blockvarpct=100 --iodepth=8 --threads=8  --block=1024k --direct --size=1g --nosvcshare --dirs=1 --files=1 --mkdirs --name=bw-test-100g-job2
#     --tag: set the flag to 1 to append workload number to the generated .csv filename, 
#             
#            This can be used for workloads that can not be differentiated by the mandatory options,
#            to generate a unique summary .csv filename. 
#             
#            Note that:
#                 - this doesn't affect the jobname, 
#                 - elbencho will append the subsequent results to .csv even for workloads that have the same mandatory options. 
#                   So for the 2 examples above, it's perfectly fine not to use --tag at all, although using tag would make it easier to identify each workload's result .csv.
#                   