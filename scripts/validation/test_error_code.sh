#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

validation_dir="$(cd "$(dirname "$0")" || exit; pwd)"
script_dir=${validation_dir/%\/validation/}

source "$script_dir/error_code.conf"

# Todo: not all error codes are tested, as some require more work, 
#       i.e to change the configuration with custom env.conf.override.
#       However, the framework is surficient to test all.

# Use a normal command line for this, but do not provide valid client names in env.conf.override for force the error
test_cmd_index_for_ERROR_CODE_CLIENT_NOT_REACHABLE=4  

test_cmds=("../run_test.sh -ns 20"
           "../run_test.sh -ns 100 -sf foo.sch"
           "../run_test.sh -ns 100 -st 3" 
           "../run_test.sh -ns 100 -crazyoption 1 > /dev/null"
           "../run_test.sh -ns 100 -sf ../../workloads/fio/bw_test_short_100g.sch"       
           # This following test assumes env.conf.override doesn't change MULTIPATH_ENABLE to 0, 
           # otherwise this will be a normal run and the test will fail
           "../run_test.sh -ns 100 -sf ../../workloads/fio/bw_test_short_100g.sch -ei $ERROR_CODE_MULTIPATH_MOUNT_FAILURE"                      
           "../nfs_mount.sh /mnt/test fio 1.2.3 2 yes"           
           "../nfs_mount.sh / fio 1.2.3 2 yes 1 2 3"
           "../nfs_mount.sh /mnt/test fio subnet 2 yes 1 2 3"
           "../nfs_mount.sh /mnt/test fio 1.2.3 -1 yes 1 2 3"
           "../nfs_mount.sh /mnt/test fio 1.2.3 2 random 1 2 3"
           "../nfs_mount.sh /mnt/test fio 1.2.3 2 yes 1 2 3"                                                       
           )
           
expected_errcode=("$ERROR_CODE_INVALID_NETWORK_SPEED" 
                  "$ERROR_CODE_INVALID_SCHEDULE_FILE"
                  "$ERROR_CODE_INVALID_STEPPING_TYPE"
                  "$ERROR_CODE_INVALID_OPTION"
                  "$ERROR_CODE_CLIENT_NOT_REACHABLE"
                  "$ERROR_CODE_MULTIPATH_MOUNT_FAILURE"
                  "$ERROR_CODE_NO_MULTIPATH_MOUNT_INVALID_NUMBER_OF_INPUTS"
                  "$ERROR_CODE_NO_MULTIPATH_MOUNT_INVALID_MOUNT_BASE"                  
                  "$ERROR_CODE_NO_MULTIPATH_MOUNT_INVALID_SUBNET"
                  "$ERROR_CODE_NO_MULTIPATH_MOUNT_INVALID_NCONNECT_NUM"
                  "$ERROR_CODE_NO_MULTIPATH_MOUNT_INVALID_RANDOMNIZE"
                  "$ERROR_CODE_NO_MULTIPATH_MOUNT_FAILURE"
                  )

index=0
passed=0
failed=0
for cmd in "${test_cmds[@]}"
do
    echo "=================="
    echo "Testing command: $cmd"
    
    if [ "$index" == "$test_cmd_index_for_ERROR_CODE_CLIENT_NOT_REACHABLE" ]; then
        # Save env.conf.override to backup
        # Assumption is that env.conf only contains the dummy clients and VIPs
        if [[ ! -L $script_dir/env.conf.override ]] && [ -s $script_dir/env.conf.override ]; then
            mv $script_dir/env.conf.override $script_dir/env.conf.override.bak
        fi
    fi
    
    $cmd
    if [ "$?" == "${expected_errcode[index]}" ];
    then
        passed=$((passed + 1))
        echo -e "Result: pass" 
    else
        failed=$((failed + 1))
        echo -e "Result: fail" 
    fi
    
    if [ "$index" == "$test_cmd_index_for_ERROR_CODE_CLIENT_NOT_REACHABLE" ]; then
        # Restore env.conf.override
        if [[ ! -L $script_dir/env.conf.override.bak ]] && [ -s $script_dir/env.conf.override.bak ]; then
            mv $script_dir/env.conf.override.bak $script_dir/env.conf.override
        fi
    fi
        
    index=$((index + 1))
   
done

echo "=================="
echo "Total tests: $index"
echo "Passed:      $passed"
echo "Failed:      $failed"
echo "=================="

if [ "$failed" -ne 0 ];
then
    exit 1 # Catch all shell failure code
fi