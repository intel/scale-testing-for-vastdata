# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

#========================================================================================================
# FIO options (refer to FIO man page for their definitions) supported by the fio schedule file:
# 
#     Mandatory: rw/numjobs/iodepth/bs
#                They will be used to generate the fio summary log filename, and jobname when --name is not specified.
#     Optional:  size/runtime/ramp_time/name/fallocate/create_on_open/fill_device/create_serialize
#                Default values of these are as specified in fio_template.ini, or disabled if commented out in fio_template.ini.
# 
# Non-FIO options supported by the schedule file: 
#     --tag: set the flag to 1 to append workload number to the generated summary log filename, 
#            and jobname but only when --name is not specified.
#             
#            This can be used for workloads that cannot be differentiated by the mandatory options,
#            to generate unique summary log filename. 
#             
#            Note that this doesn't affect the jobname if --name is specified.
#     --rwmixreadhost: set this option to run client based mixed workload, eg:
#                          --rw=randrw --rwmixreadhost=70: 70% of clients do random read, 30% of clients do random write
#                          --rw=rw     --rwmixreadhost=70: 70% of clients do sequential read, 30% of clients do sequential write
#                      In comparison, --rwmixread is the native fio option, which specifies the mixed workload per client ratio, eg:
#                          --rw=randrw --rwmixread=70: every client does 70% random read, 30% random write
#                          --rw=rw     --rwmixread=70: every client does 70% sequential read, 30% sequential write
# 
# Two ways to support additional options:
# 1) Enhance run_test_fio() function of run_test_no_runlog.sh
# 2) modify fio_template.ini
#


