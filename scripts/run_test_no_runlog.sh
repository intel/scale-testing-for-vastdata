#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Enable xtrace mode, which logs every command as it runs.
set -x
   
script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/common.conf"
source "$script_dir/error_code.conf"

network_speed="10"
step_size=""
cmdline_create_only=0
runtime=""
ramptime=""
cmdline_runtime=""
cmdline_ramptime=""
skip_mount=0
common_prefix="results_"$(date +%Y-%m-%d-%H.%M.%S)
schedule_file=""
test_type="fio"
REMOTE_PATH=""
fio_template="fio_template.ini"
extra_prefix=""
STEP_TYPE_INCREMENTAL=0
STEP_TYPE_CONSTANT=1
step_type=$STEP_TYPE_INCREMENTAL
dry_run=0
inject_error_num=0
skip_all_client_config_query=0
uid="$UID"

# Additional globals defined by run_test() function
# schedule_name schedule_name_ext hostname client_nodes client_nodes_array result_prefix run_dir

#=================================================================
# Print the help message.
#=================================================================
print_help () {
    echo " Usage: $0 [ options ]"
    echo " Valid options:"
    echo
    echo " -co|--create-only: when specified, create the FIO files only for read workload, no actual read access."  
    echo " -dr|--dryrun: do not run workload. Everything else will be executed the same as a normal run including nfs mounts and starting fio and Elbencho services on clients."             
    echo " -ns|--network-speed: GbE speed in [\"10\", \"100\"]. Default: 10"
    echo " -pf|--prefix: extra prefix to be added to the test name"  
    echo " -sf|--schedule-file: specify the schedule file to run." 
    echo " -sm|--skip-mount: specify this to skip the mount step. This can speed up the test if the mount is the same as the previous test."            
    echo " -sq|--skip-all-client-config-query: do not do query of all client configurations before the test. As query takes a few minutes, this allows the test to be started sooner for quicker benchmarking." 
    echo " -ss|--step-size: specify the number of clients to increase to run the test." 
    echo "    Default: max clients. Any value outside of [1..max client count] will have step size of max client count." 
    echo "    Examples:"
    echo "      when st==0:"
    echo "          if max clients = 100, then \"-ss 10\" will test clients in steps of 10, 20, 30...90, 100 clients"
    echo "          if max clients = 100, then \"-ss 15\" will test clients in steps of 15, 30, 45...75, 90, 100 clients"
    echo "          if max clients = 100, then \"-ss 0\" or \"-ss 100\" or omitting -ss option will test all 100 clients in 1 step"
    echo "      when st==1:"
    echo "          if max clients = 10,  then \"-ss 1 -st 1\" will test the 10 clients 1 at a time, in 10 steps"
    echo "          if max clients = 10,  then \"-ss 2 -st 1\" will test the 10 clients 2 at a time, in 5 steps"            
    echo " -st|--step-type: 0 - incremental (default), 1 - constant. Refer to -ss|--step-size examples to see the differences between the two types"           
    echo " --runtime:  FIO runtime. Default: as specified in template FIO job file"
    echo " --ramptime: FIO ramptime. Default: as specified in template FIO job file"
    echo " -h|--help: to print this help"  
    echo 
    echo " Examples:" 
    echo "     # Run FIO BW test on 100G"
    echo "     ./run_test.sh -ns 100 -sf ../workloads/fio/bw_test_100g.sch"
    echo "     # Create FIO BW short test files only on 100G"
    echo "     ./run_test.sh -ns 100 -sf ../workloads/fio/bw_test_short_100g.sch -co"
    echo "     # Run FIO BW short test with 120s of runtime and 0s of ramptime, instead of the values as specified in the schedule file"
    echo "     ./run_test.sh -ns 100 -sf ../workloads/fio/bw_test_short_100g.sch --runtime 120 --ramptime 0" 
    echo "     # Run constant type of stepping test, with step size of 1, meaning test each client 1 by 1" 
    echo "     ./run_test.sh -ns 100 -sf ../workloads/fio/bw_test_short_100g.sch -ss 1 -st 1" 
    echo "     # Run incremental stepping test, with step size of 2"
    echo "     ./run_test.sh -ns 100 -sf ../workloads/fio/bw_test_short_100g.sch -ss 2"                                                                                    
}

#=================================================================
# Parse the command line and set global variables accordingly.
#=================================================================
parse_command_line () {
    # Each client will add its own timestamp as suffix, which could be different from client to client
    
    # Supply a common timestamp as the prefix so that we can easily identify if the results are from 
    # the same run with the clush command

    while [ $# -gt 0 ]; do
      case "$1" in
        -co|--create_only)
            cmdline_create_only=1
            shift 1
        ;;
        -dr|--dryrun)
            dry_run=1
            shift 1
        ;; 
        -ei|--error-injection)
            inject_error_num="$2" # This shall be the error code for injection
            shift 2
        ;;               
        -ns|--network-speed)
            network_speed="$2"
            if [ "$network_speed" != "10" ] && [ "$network_speed" != "100" ]; then
                echo "Invalid value for network speed, must be in [10, 100]"
                exit "$ERROR_CODE_INVALID_NETWORK_SPEED"
            fi
            shift 2
        ;; 
        -pf|--prefix)
            extra_prefix="$2"
            shift 2
        ;;        
        -sf|--schedule-file)
            schedule_file_dir="$(cd "$(dirname "$2")" || exit; pwd)"
            schedule_file="$schedule_file_dir/$(basename "$2")" # Always convert to absolution path
            if [[ -L "$schedule_file" ]] || [ ! -f "$schedule_file" ]; then
                echo "$schedule_file not found or it's a symbolic link, or not in $WORKLOAD_DIR!"
                exit "$ERROR_CODE_INVALID_SCHEDULE_FILE"
            fi
            shift 2
        ;;
        -sq|--skip-all-client-config-query)
            skip_all_client_config_query=1
            shift 1
        ;;
        -sm|--skip-mount)
            skip_mount=1
            shift 1
        ;;        
        -ss|--step-size)
            step_size="$2"
            # Range bounded by env.conf
            shift 2
        ;;
        -st|--step-type)
            step_type="$2"
            if [ "$step_type" != "0" ] && [ "$step_type" != "1" ]; then
                echo "Invalid value for step type, must be in [0, 1]"
                exit "$ERROR_CODE_INVALID_STEPPING_TYPE"
            fi            
            shift 2
        ;;              
        --runtime)
            cmdline_runtime="$2"
            shift 2
        ;;    
        --ramptime)
            cmdline_ramptime="$2"
            shift 2
        ;;                  
        -h|--help)
            print_help "$0"
            echo " Usage: $0 [ options ]"
            exit
        ;;
        *)
          echo "Unrecongized option: $1!"
          print_help "$0"
          exit $ERROR_CODE_INVALID_OPTION
      esac
    done
}

#=================================================================
# Set additional globals based on the configuration file env.conf.
#=================================================================
parse_env_and_set_globals () {
  
    source "$SCRIPT_DIR/env.conf" "$network_speed" "$step_size"

    # Sanity check of the configurations
    
    if [ "$HOST_SUBNET" == "" ]; then
        echo "VIP Pool not defined"
        exit "$ERROR_CODE_VIP_POOL_NOT_DEFINED"
    fi
    
    if [ ${#CLIENT_NODES_ARRAY[@]} -eq 0 ]; then
        echo "Clients not defined"
        exit "$ERROR_CODE_CLIENTS_NOT_DEFINED"
    fi
    
    MOUNT="$MOUNT_MULTIPATH_ENABLED"
    if [ "$MULTIPATH_ENABLE" == "0" ]; then 
        MOUNT="$MOUNT_MULTIPATH_DISABLED"        
    fi    
    if [[ "$schedule_file" == *"elbencho/file"* ]]; then
        test_type="elbencho-file"
        REMOTE_PATH="$REMOTE_PATH_ELBENCHO_FILE"
    elif [[ "$schedule_file" == *"elbencho/s3"* ]]; then
        test_type="elbencho-s3" 
        REMOTE_PATH="$REMOTE_PATH_ELBENCHO_S3"
    else
        test_type="fio"
        REMOTE_PATH="$REMOTE_PATH_FIO"        
    fi
    
    echo "Test type: $test_type"
    
   
}

#=================================================================
# Enable/disable irqbalance
#=================================================================
function check_client_status_and_deploy_files () {

    echo "Sanity check of the client nodes' presence..."
    
    rm -rf "$RUN_ERROR_LOG_FILE"    
    clush -w "$CLIENT_NODES" "hostname -s" > /dev/null 2> "$RUN_ERROR_LOG_FILE"

    # This is the first clush, and currently the only place write to error log.
    if [[ ! -L "$RUN_ERROR_LOG_FILE" ]] && [ -s "$RUN_ERROR_LOG_FILE" ]; then 
        if grep -q 'exited with exit code\|timed out\|Failed\|failed' "$RUN_ERROR_LOG_FILE"; then
            cat "$RUN_ERROR_LOG_FILE"
            exit "$ERROR_CODE_CLIENT_NOT_REACHABLE" 
        fi; 
    fi 
    
    # Utility shall deploy them, but in case we forget to do that after changing these files.
    clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "mkdir -p $VAST_SCALE_TESTING_PATH"
    clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" -c "$SCRIPT_DIR/nfs_mount.sh" "$SCRIPT_DIR/general_info.sh" "$SCRIPT_DIR/error_code.conf" --dest "$VAST_SCALE_TESTING_PATH"
}
    
#=================================================================
# Enable/disable irqbalance
#=================================================================
function irqbalance_config() {

    if [ "$IRQBALANCE_ENABLE" == "1" ]; then
        clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "sudo systemctl enable irqbalance; sudo systemctl start irqbalance"
    else
        clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "sudo systemctl stop irqbalance; sudo systemctl disable irqbalance"
    fi    
}

#=================================================================
# Enable/disable Intel Turbo Boost
#=================================================================
function turbo_boost_config () {

    if [ "$TURBO_BOOST_ENABLE" == "1" ]; then
        clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo"
    else
        clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo"
    fi
}

#=================================================================
# Enable/disable Hyper Threading
#=================================================================
function hyper_threading_config() {

    if [ "$HYPER_THREADING_ENABLE" == "1" ]; then
        clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "echo on | sudo tee /sys/devices/system/cpu/smt/control"
    else
        clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "echo off | sudo tee /sys/devices/system/cpu/smt/control"
    fi    
}

#=================================================================
# Config irqbalance/turbo boost and hyper threading
#=================================================================
function set_irqb_tb_ht_controls() {
    irqbalance_config > /dev/null
    turbo_boost_config > /dev/null
    hyper_threading_config > /dev/null
}

#=================================================================
# Query irqbalance/turbo boost and hyper threading status
#=================================================================
function get_all_client_config() {
  
    # Todo: not optimized as it does dmidecode / lscpu etc multiple times
    
    echo "Kernel:"
    clush -w "$CLIENT_NODES" "uname -r" | sort  
    
    echo "OS:"    
    clush -w "$CLIENT_NODES" "cat /etc/centos-release" | sort  

    echo "Platform:"
    clush -w "$CLIENT_NODES"  "sudo dmidecode | grep -m 1 Product" | sort
    
    echo "BIOS:"
    clush -w "$CLIENT_NODES" "sudo dmidecode | grep -A 20 'BIOS Information' | grep Version" | sort      
    echo "BIOS grouped:"
    clush --diff -w "$CLIENT_NODES" "sudo dmidecode | grep -A 20 'BIOS Information' | grep Version" | sort      
  
    echo "CPU information:"
    clush -w "$CLIENT_NODES" "grep -m 3 'stepping\|model name\|microcode' /proc/cpuinfo" | sort
    echo "Cores per socket:"
    clush -w "$CLIENT_NODES" "lscpu | grep 'Core(s)'" | sort 
    echo "Total sockets"
    clush -w "$CLIENT_NODES" "lscpu | grep 'Socket(s)'" | sort
    echo "Threads per core"
    clush -w "$CLIENT_NODES" "lscpu | grep 'Thread(s)'" | sort 
    echo "Virtualization"
    clush -w "$CLIENT_NODES" "lscpu | grep 'VT-x'" | sort           
    echo "Total CPU(s):" # = Cores per socket x threads per core x sockets. Threads per core = 1 if Hyper Threading is disabled.
    clush -w "$CLIENT_NODES" "getconf _NPROCESSORS_ONLN" | sort     
    
    echo "Total memory:"
    clush -w "$CLIENT_NODES" "free -m | grep Mem:" | sort 
    echo "Memory speed:"    
    clush -w "$CLIENT_NODES" "sudo dmidecode | grep -C 20 DDR | grep  Speed: | tail -1" | sort  
    echo "Memory speed grouped:"    
    clush --diff -w "$CLIENT_NODES" "sudo dmidecode | grep -C 20 DDR | grep  Speed: | tail -1" | sort   
    
    echo "irqbalance status:"
    clush -w "$CLIENT_NODES" "echo irqb:     \$(systemctl status irqbalance | grep Active)" | sort
    echo "Turbo Boost status:"
    clush -w "$CLIENT_NODES" "echo no_turbo: \$(cat /sys/devices/system/cpu/intel_pstate/no_turbo)" | sort
    echo "Hyper Threading status"
    clush -w "$CLIENT_NODES" "echo ht:       \$(cat /sys/devices/system/cpu/smt/active)" | sort       
    
    echo "Power & Performance policy (core 0 only):"
    # Query CPU performance mode
    #
    # Quotes http://manpages.ubuntu.com/manpages/bionic/man8/x86_energy_perf_policy.8.html:
    #
    #   The following table shows the mapping from the value strings above to actual  MSR  values.
    #   This mapping is defined in the Linux-kernel header, msr-index.h.
    #
    #       VALUE STRING        EPB  EPP
    #       performance         0    0
    #       balance-performance 4    128
    #       normal, default     6    128
    #       balance-power       8    192
    #       power               15   255    
    clush -w "$CLIENT_NODES" "sudo x86_energy_perf_policy | grep -m 1 cpu" | sort  
    echo "Per CPU Power & Performance policy (core 0 only):"
    clush -w "$CLIENT_NODES" "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" | sort   # This is per CPU, usually they are the same
    
    echo "Network interface and MTU"    
    "$SCRIPT_DIR/nic_info.sh" "$network_speed"
}

#=================================================================
# Mount the VIPs individually
# NConnect is available is also available in CentOS Linux release 8.3.2011.
# Warning: this can be slow and the connection might be dropped if
#          the VIP NConnect sizes are big as:  
#          total tcp connection = VIP size x NConnect size
#=================================================================
mount_nfs_no_multipath () {

    if [ "$1" == "all" ]; then
        clients="$CLIENT_NODES"
        vips_to_mount=("${ALL_VIPS[@]}")
    else
        clients="$1"
        vips_to_mount=("$2")
    fi
    
    if [ "$NCONNECT_ENABLE" == "0" ]; then
        nconnect_num=0
    else
        nconnect_num="$NCONNECT_NUM"
    fi

    randomnize="no" 
    if [ "$1" == "all" ]; then
        clush -w "$clients" -f "$CLUSH_MAX_FAN_OUT" "sudo umount ${MOUNT}/${REMOTE_PATH}/\$(hostname -s)/* > /dev/null 2>/dev/null &" &
        
        wait
        if [ "$MOUNT_ALL" == "1" ] || [ "$test_type" == "elbencho-file" ];
        then 
            if [ "$test_type" == "elbencho-file" ]; then 
                randomnize="yes"
            fi
 
            if [ "$inject_error_num" == "$ERROR_CODE_NO_MULTIPATH_MOUNT_FAILURE_ALL" ]; then
                # Mess up randomnize to force the error
                randomnize="yesno"
            fi 
                       
            # Mount may fail, but clush return code is 0. So capture the stderr result to know the actual error instead.
            clush -w "$clients" -f "$CLUSH_MAX_FAN_OUT" "cd $VAST_SCALE_TESTING_PATH; ./nfs_mount.sh $MOUNT $REMOTE_PATH $HOST_SUBNET $nconnect_num $randomnize $NFS_MOUNT_LOG_FILE ${vips_to_mount[*]} &" &
            
            wait
            
            # If file is not empty, then something went wrong
            clush -S -w "$clients" -f "$CLUSH_MAX_FAN_OUT" "if [[ ! -L $NFS_MOUNT_LOG_FILE ]] && [ -s $NFS_MOUNT_LOG_FILE ]; then if grep -q 'exited with exit code\|timed out\|Failed\|failed' $NFS_MOUNT_LOG_FILE; then cat $NFS_MOUNT_LOG_FILE; exit $ERROR_CODE_NO_MULTIPATH_MOUNT_FAILURE_ALL; fi; fi"
            status=$?
            if [ "$status" -gt 0 ]; then
                echo "Mount failed, exiting..."     
                exit "$ERROR_CODE_NO_MULTIPATH_MOUNT_FAILURE_ALL"
            fi 
        fi
    else
        if [ "$inject_error_num" == "$ERROR_CODE_NO_MULTIPATH_MOUNT_FAILURE_PARTIAL" ]; then
            # Mess up randomnize to force the error
            randomnize="yesno"
        fi 
                
        # Mount may fail, but clush return code is 0. So capture the stderr result to know the actual error instead.
        clush -w "$clients" -f "$CLUSH_MAX_FAN_OUT" "cd $VAST_SCALE_TESTING_PATH; ./nfs_mount.sh $MOUNT $REMOTE_PATH $HOST_SUBNET $nconnect_num $randomnize $NFS_MOUNT_LOG_FILE ${vips_to_mount[*]} &" &
        # No wait to complete here for better performance, as check of error condition is also deferred
    fi
}

#=================================================================
# Mount the VIPs using multipath and nconnect
#=================================================================
mount_nfs_multipath () {

    # Create node index and vip mappings in round robin fashion
    #
    # Although each client will set remoteports to all VIPs,
    # each client is going to mount 1 VIP to the mountpoint,
    # and that VIP will be round robinned.
    
    i=0
    node_index=()
    node_vip=()    
    vip_last_field=$HOST_SUBNET_FIRST_VIP_LAST_FIELD

    for node in "${CLIENT_NODES_ARRAY[@]}"
    do
        node_index+=("${node}:${i}")
        node_vip+=("${node}:${vip_last_field}")
        i=$((i + 1))
        vip_last_field=$((vip_last_field + 1))
        if [ $vip_last_field -gt "$HOST_SUBNET_LAST_VIP_LAST_FIELD" ] 
        then
            vip_last_field="$HOST_SUBNET_FIRST_VIP_LAST_FIELD"
        fi    
    done 
  
    # Now mount it.
    # localports need to match the HOST_SUBNET
    # chown is necessary otherwise FIO cannot write to the folder.
   
    if [ "$inject_error_num" == "$ERROR_CODE_MULTIPATH_MOUNT_FAILURE" ]; then
        # Mess up HOST_SUBNET to force the error
        host_subnet_org="$HOST_SUBNET"
        HOST_SUBNET="A.B.C"
    fi
    
    if [[ ! -L "$NFS_MOUNT_LOG_FILE" ]] && [ -f "$NFS_MOUNT_LOG_FILE" ]; then
        rm -rf "$NFS_MOUNT_LOG_FILE"
    fi
    
    clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "sudo umount ${MOUNT} > /dev/null 2>/dev/null;
                                                      sudo mkdir -p ${MOUNT}; 
                                                      sudo mount -v -o vers=3,proto=tcp,nconnect=$NCONNECT_NUM,port=20048,localports=\$(ifconfig | grep inet | grep $HOST_SUBNET | xargs | awk '{print \$2}'),remoteports=$HOST_SUBNET_FIRST_VIP-$HOST_SUBNET_LAST_VIP $HOST_SUBNET.\$(echo ${node_vip[*]} | grep -o [^[:space:]]*\$(hostname -s):[^[:space:]]* | cut -d':' -f 2):/ ${MOUNT};
                                                      io_dir=${MOUNT}/${REMOTE_PATH}/\$(hostname -s);
                                                      sudo mkdir -p \${io_dir}; sudo chown $uid:$uid \${io_dir}" 2> "$NFS_MOUNT_LOG_FILE"                                                   

    if [ "$inject_error_num" == "$ERROR_CODE_MULTIPATH_MOUNT_FAILURE" ]; then
        # Mess up HOST_SUBNET to force the error
        HOST_SUBNET="$host_subnet_org"
    fi
                                                         
    # If file is not empty, then something went wrong
    if  [[ ! -L "$NFS_MOUNT_LOG_FILE" ]] && [ -s "$NFS_MOUNT_LOG_FILE" ]; then 
        if grep -q "exited with exit code\|timed out\|Failed\|failed" "$NFS_MOUNT_LOG_FILE"; then
            echo "Mount failed: exiting..."        
            exit "$ERROR_CODE_MULTIPATH_MOUNT_FAILURE"
        fi
    fi                                                       
}

#=================================================================
# Mount VIPs based on test type and multipath configuration
#=================================================================
mount_vips () {

    # Mount VIP pools
    # S3 is not using file system, so no NFS mount needed
    if [ "$skip_mount" == "0" ] && [ "$test_type" != "elbencho-s3" ]; then
        if [ "$MULTIPATH_ENABLE" == "1" ]; then
            mount_nfs_multipath           
       else
            mount_nfs_no_multipath "all"
        fi
    fi 
    
}

#=================================================================
# Start FIO server or elbencho server on clients
# Precondition: VIPs are mounted already
#=================================================================
start_services () {
            
    if [ "$test_type" == "fio" ]; then
        # Start fio on all clients
        if [ "$FIO_SERVER_CLIENT_MODE" == "1" ]; then
            clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "sudo pkill fio; sudo rm fiopid; ${FIO_PATH}/fio --server --daemonize=fiopid &" & 
        fi
    elif [ "$test_type" == "elbencho-file" ] || [ "$test_type" == "elbencho-s3" ]; then
        clush -w "$CLIENT_NODES" -f "$CLUSH_MAX_FAN_OUT" "docker container kill elbencho-server > /dev/null 2>/dev/null;
                                                          docker container rm elbencho-server > /dev/null 2>/dev/null;
                                                          docker run --rm --name elbencho-server -v ${MOUNT}/${REMOTE_PATH}/\$(hostname -s):/data/${REMOTE_PATH} --net=host -dt breuner/elbencho:$ELBENCHO_TAG --service --foreground --zones 0,1"
    fi 
    
    wait  
}

#=================================================================
# Split the FIO json summary files to per client record + All_Clients.
#
# For aggregated results such as total BW/IOPS/Latency, check All_Clients record.
#
# This is to make it easier for Elastic Search (out of scope of this harness), 
# otherwise the size could be to big when creating the index
#=================================================================
split_server_log_file () {
    for file in *_summary.log
    do
        "${SCRIPT_DIR}/split_json.sh" "$file"
    done
}

#=================================================================
# ZIP the logs to keep the size of result smaller
#=================================================================
zip_logs () {
    zip -r "$(basename "$run_dir")_Logs.zip" ./*summary.inf ./*summary.json ./redwood-* All_Clients
    rm -rf ./*summary.log ./*summary.inf ./*summary.json ./redwood-* All_Clients
    zip -r context.zip ./context
    zip -r "$schedule_name.zip" "$schedule_name" 
    rm -rf context "$schedule_name"    
}

#=================================================================
# Save the configurations for this test to result folder
# Todo: save the VAST Data Appliance version as well using public API?
#=================================================================
before_test () {
     
    # Set the xtrace prefix to show a timestamp and line number
    PS4="[$(date +%T)] $LINENO: "
   
    # Enable extended globbing
    shopt -s extglob
    
    # Save the general telemetry information
    mkdir -p "$run_dir/context"
    
    if [ "$skip_all_client_config_query" == "0" ]; then
        # Save irqbalance/turbo boost and hyper threading information
        get_all_client_config | tee "$run_dir/context/all_client_config.log"
    fi
    
    # Save the context and hardware telemetry of head node. 
    # It may not have 100G, but it does have 10G
    echo "$FIO_PATH/fio version: $($FIO_PATH/fio --version)" > "$run_dir/context/general_info.log"
    "${SCRIPT_DIR}/general_info.sh" "$_HOST_SUBNET_10G" "$run_dir/context" >> "$run_dir/context/general_info.log"   # Head node may not have 100G, but does have 10G, so use 10G subnet
    sudo dmidecode | tee "$run_dir/context/hardware_info.log" > /dev/null
           
    # Do the same for client nodes as well. 
    # For client nodes, every run will wipe out the context from previous runs
    local context_path="$VAST_SCALE_TESTING_PATH/context"
    clush -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" "mkdir -p $context_path;
                                                      echo $FIO_PATH/fio version: $($FIO_PATH/fio --version) > $context_path/general_info.log;
                                                      $VAST_SCALE_TESTING_PATH/general_info.sh $HOST_SUBNET $context_path >> $context_path/general_info.log;
                                                      sudo dmidecode | tee $context_path/hardware_info.log > /dev/null" &
    wait
    
    clush -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" --rcopy "$context_path/hardware_info.log" --dest "$run_dir/context" 
    clush -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" --rcopy "$context_path/general_info.log" --dest "$run_dir/context"
    clush -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" --rcopy "$context_path/numa.png" --dest "$run_dir/context"
   
    for file in "$run_dir"/context/numa.png.*
    do 
        local client_name
        client_name="$(basename "$file" | cut -d'.' -f 3)"
        mv "$run_dir/context/numa.png.$client_name" "$run_dir/context/numa.$client_name.png"
    done    
         
    # Save the configuration and schedule files
    cp "${SCRIPT_DIR}/env.conf" "$run_dir"
    if [ -f "${SCRIPT_DIR}/env.conf.override" ]; then
        cp "${SCRIPT_DIR}/env.conf.override" "$run_dir"
    fi
    cp "$schedule_file" "$run_dir"
    
    # Only FIO test needs to save the job files in the folder
    if [ "$test_type" == "fio" ]; then        
        mkdir "$schedule_name"
    fi
}

#=================================================================
# Automatically upload the results to NFS share after the test
# This can be enabled/disabled by RESULTS_UPLOAD_ENABLE.
#=================================================================
upload_results () {

    if [ "$RESULTS_UPLOAD_ENABLE" == "0" ]; then
        return
    fi

    local cluster_result_path
    cluster_result_path="$(basename "${run_dir}")"
    
    local retry=0
    while [[ $retry -eq 0 || ( "$(ls "${RESULTS_MNTPOINT}")" != "" && $retry -lt 3 ) ]]
    do    
        sudo umount -lf "${RESULTS_MNTPOINT}" >/dev/null 2>/dev/null
        sudo rm -rf "${RESULTS_MNTPOINT}/results*"  
        sudo mkdir -p "${RESULTS_MNTPOINT}"
        if [ "$RESULTS_UPLOAD_MOUNT_CMD" != "" ] && [[ "$RESULTS_UPLOAD_MOUNT_CMD" == "sudo mount"* ]]; then
            $RESULTS_UPLOAD_MOUNT_CMD
        else
            break
        fi
        sleep 1
        sudo mkdir -p "${RESULTS_MNTPOINT}/${test_type}/${cluster_result_path}"
        sudo cp -r "${run_dir}"/* "${RESULTS_MNTPOINT}/${test_type}/${cluster_result_path}"
        sleep 1
        sudo umount "${RESULTS_MNTPOINT}"
        sleep 1
        retry=$((retry+1))
    done
}

#=================================================================
# Post processing of logs and result upload
#=================================================================
after_test () { 

    # Save of the end of test dmesg for both head node and client nodes
    dmesg > "$run_dir/context/End_of_test_dmesg.log"
    local context_path="$VAST_SCALE_TESTING_PATH/context"
    clush -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" "mkdir -p $context_path;
                                                      dmesg > $context_path/End_of_test_dmesg.log &" &
    wait
    
    clush -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" --rcopy "$context_path/End_of_test_dmesg.log" --dest "$run_dir/context" &

    wait
    
    if [ "$test_type" == "fio" ] && [ "$FIO_SERVER_CLIENT_MODE" == "1" ]; then
        split_server_log_file
        zip_logs
    fi
    
    # Move normal log only. 
    # Error log shall cause the harness to exit immediately and won't be here.
    # Error log will be moved by the run_test.sh
    if [[ ! -L "$RUN_LOG_FILE" ]] && [ -f "$RUN_LOG_FILE" ]; then
        mv "$RUN_LOG_FILE" "$run_dir"
    fi
   
    upload_results
}

#=================================================================
# Run FIO workload
# Todo: so many passed in parameters, compact all to an array instead?
#=================================================================
run_fio_workload () {
    local wl_name=$1
    local wl_num=$2
    local jobname=$3
    local client_count=$4
    local rw=$5
    local numjobs=$6
    local iodepth=$7
    local bs=$8
    local size=$9 
    local read_perc=${10}
    local random_type=${11}
    local create_on_open=${12}
    local fallocate=${13} 
    local create_serialize=${14}  
    local fill_device=${15}
    local create_only=${16}
    
    echo "Running #$wl_num workload: $wl_name" 
    
    # Always generate the json+ output
    local fio_cmd="${FIO_PATH}/fio --output-format=json+ --output ${wl_name}_summary.log"
    
    if [ "$FIO_SERVER_CLIENT_MODE" == "0" ]; then    
        clush -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" "mkdir -p $VAST_SCALE_TESTING_PATH/${result_prefix}_${schedule_name}_${hostname}/${schedule_name}"
    fi

    local i jobfile fio_server
    i=0
    jobfile="$run_dir/$schedule_name/${wl_name}.ini"
    for fio_server in "${client_nodes_array[@]}"
    do
        i=$((i + 1))
        if [ $i -gt "$client_count" ]; then break; fi
        mkdir -p "$run_dir/$schedule_name/$fio_server"
                       
        # Generate the actual per client FIO job file based on template and the passed in parameters defined by schedule file
                       
        if [ "$create_only" == "1" ]; then
            sed "/^#create_only=/c create_only=$create_only" -i "$jobfile"
        fi
        
        if [ "$runtime" != "" ]; then
            sed "/^runtime=/c runtime=$runtime" -i "$jobfile"
        fi        
        
        if [ "$ramptime" != "" ]; then
            sed "/^ramp_time=/c ramp_time=$ramptime" -i "$jobfile"
        fi 
       
        if [ "$create_on_open" != "invalid" ]; then
            sed "/^#create_on_open=/c create_on_open=$create_on_open" -i "$jobfile"
        fi 
        
        if [ "$fallocate" != "invalid" ]; then        
            sed "/^#fallocate=/c fallocate=$fallocate" -i "$jobfile"
        fi
        
        if [ "$create_serialize" != "invalid" ]; then        
            sed "/^#create_serialize=/c create_serialize=$create_serialize" -i "$jobfile"
        fi        
               
        if [ "$fill_device" == "1" ]; then
            sed "/^#fill_device=/c fill_device=1" -i "$jobfile"
            sed '/^runtime=/d' -i "$jobfile"
            sed '/^ramp_time=/d' -i "$jobfile" 
            sed '/^time_based/d' -i "$jobfile"                       
        fi
                
        sed "/^rw=/c rw=$rw" -i "$jobfile"
        sed "/^numjobs=/c numjobs=$numjobs" -i "$jobfile"
        sed "/^iodepth=/c iodepth=$iodepth" -i "$jobfile"
        sed "/^bs=/c bs=$bs" -i "$jobfile"
        
        if [ "$size" != "invalid" ]; then          
            sed "/^size=/c size=$size" -i "$jobfile"
        fi 
        
        if [ "$jobname" != "invalid" ]; then        
            sed "/\[jobname]/c [$jobname]" -i "$jobfile"
        else
            sed "/\[jobname]/c [$wl_name]" -i "$jobfile"         
        fi 
        
        # Two different ways of running mixed workloads
        # 1. rwmixread:     mix workload on every client
        # 2. rwmixreadhost: read on some clients, but write on other clients
        if [ "$read_perc" != "invalid" ]; then
            # update rwmixread
            if [ "$random_type" == "rwmixread" ]; then                
                sed "/^#rwmixread=/c rwmixread=$read_perc" -i "$jobfile"
            elif [ "$random_type" == "rwmixreadhost" ]; then
                local random=$((1 + RANDOM % 100))
                if [ "$random" -gt "$read_perc" ]; then
                    if [[ "$wl_name" == *"_rnd_"* ]]; then
                        sed "/^rw=/c rw=randwrite" -i "$jobfile"
                    else
                        sed "/^rw=/c rw=write" -i "$jobfile"                   
                    fi
                else
                    if [[ "$wl_name" == *"_rnd_"* ]]; then
                        sed "/^rw=/c rw=randread" -i "$jobfile"
                    else
                        sed "/^rw=/c rw=read" -i "$jobfile"                  
                    fi
                fi 
            fi
        fi
                
        if [ "$MULTIPATH_ENABLE" == "1" ]; then
            sed "s/hostname/${fio_server}/g" "$jobfile"  > "$run_dir/$schedule_name/$fio_server/${wl_name}.ini"
        else
            local vip_list vips
            vip_list=$(shuf -e "${ALL_VIPS[@]}" | xargs)
            IFS=" " read -r -a vips <<< "$vip_list"
            
            local fio_directory="" 
            local vip_count=0
            local vips_to_mount=()
            for MOUNTVIP in "${vips[@]}"; do
                if [ "$vip_count" == "$numjobs" ] && [ "$MOUNT_ALL" == "0" ]; then 
                    # Number of vips to be mounted == number of jobs
                    break;
                fi
                            
                if [ "$fio_directory" != "" ]; then
                    fio_directory+=":"
                fi  
                fio_directory+="${MOUNT}/${REMOTE_PATH}/${fio_server}/${HOST_SUBNET}.${MOUNTVIP}"   # hostname is placeholder, and will be replaced later

                vips_to_mount+=("$MOUNTVIP")  
                vip_count=$((vip_count+1))
            done
            sed "/directory=/c directory=$fio_directory" "$jobfile" > "$run_dir/$schedule_name/$fio_server/${wl_name}.ini"   
        fi

        if [ "$FIO_SERVER_CLIENT_MODE" == "1" ]; then
            fio_cmd+=" --client $fio_server $run_dir/$schedule_name/$fio_server/${wl_name}.ini"
        else
            clush -w "$fio_server" -c "$run_dir/$schedule_name/$fio_server/$wl_name.ini" --dest "$VAST_SCALE_TESTING_PATH/${result_prefix}_${schedule_name}_${hostname}/${schedule_name}" &
        fi

        # Mount vips for this server if they haven't been mounted already
        # Applicable to individual mount only (multipath mount is always done upfront, and not affected by MOUNT_ALL flag)
        if [ "$MOUNT_ALL" == "0" ];
        then
            mount_nfs_no_multipath "$fio_server" "${vips_to_mount[@]}"
            
            # Ensure mount is done every a few servers. 
            # This is to avoid overwhelming clush            
            if [ $(( i % MOUNT_STAGGER )) -eq 0 ]; then
                wait
                
                # If file is not empty, then something went wrong
                clush -S -w "$fio_server" -f "$CLUSH_MAX_FAN_OUT" "if [[ ! -L $NFS_MOUNT_LOG_FILE ]] && [ -s $NFS_MOUNT_LOG_FILE ]; then if grep -q 'exited with exit code\|timed out\|Failed\|failed' $NFS_MOUNT_LOG_FILE; then cat $NFS_MOUNT_LOG_FILE; exit $ERROR_CODE_NO_MULTIPATH_MOUNT_FAILURE_PARTIAL; fi; fi"
                local status=$?
                if [ "$status" -gt 0 ]; then
                    echo "Mount failed, exiting..."     
                    exit "$ERROR_CODE_NO_MULTIPATH_MOUNT_FAILURE_PARTIAL"
                fi
            fi            
        fi        
    done

    if [ "$dry_run" == "0" ]; then
        # Run test
        echo "Run test..."    
        if [ "$FIO_SERVER_CLIENT_MODE" == "1" ]; then
            $fio_cmd
        else
            wait 
            
            # If file is not empty, then something went wrong
            clush -S -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" "if [[ ! -L $NFS_MOUNT_LOG_FILE ]] && [ -s $NFS_MOUNT_LOG_FILE ]; then if grep -q 'exited with exit code\|timed out\|Failed\|failed' $NFS_MOUNT_LOG_FILE; then cat $NFS_MOUNT_LOG_FILE; exit $ERROR_CODE_NO_MULTIPATH_MOUNT_FAILURE_PARTIAL; fi; fi"
            status=$?
            if [ "$status" -gt 0 ]; then
                echo "Mount failed, exiting..."     
                exit "$ERROR_CODE_NO_MULTIPATH_MOUNT_FAILURE_PARTIAL"
            fi  
                       
            clush -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" "cd $VAST_SCALE_TESTING_PATH/${result_prefix}_${schedule_name}_${hostname}; $fio_cmd $VAST_SCALE_TESTING_PATH/${result_prefix}_${schedule_name}_${hostname}/${schedule_name}/${wl_name}.ini"
            wait
        fi
    fi
}

#=================================================================
# Parse FIO workload arguments and run it
#=================================================================
run_test_fio() {
    local wl_num=$1
    local client_count=$2
    
    local fio_args_str fio_args
    fio_args_str=$(echo "$3" | xargs)
    IFS=" " read -r -a fio_args <<< "$fio_args_str"
       
    local rw="invalid"
    local numjobs="invalid"
    local iodepth="invalid"
    local bs="invalid"
    local jobname="invalid"
        
    local size="invalid"
    local read_perc="invalid"
    local random_type="invalid"
    local create_on_open="invalid"
    local fallocate="invalid"
    local create_serialize="invalid"
    local fill_device="invalid"
    local tag="invalid"
    local create_only="invalid"
    
    # All supported options in schedule file shall be added in this for loop
    
    for arg in "${fio_args[@]}"
    do    
       case "$arg" in
         --rw=*)
             rw="${arg#*=}"
         ;;
         --numjobs=*)
             numjobs="${arg#*=}"
         ;;
         --iodepth=*)
             iodepth="${arg#*=}"
         ;;
         --bs=*)
             bs="${arg#*=}"
         ;;
         --size=*)
             size="${arg#*=}"
         ;;
         --runtime=*)         
             if [ "$cmdline_runtime" == "" ]; then
                 runtime="${arg#*=}"
             else
                 runtime=$cmdline_runtime
             fi
         ;;
         --ramp_time=*)
             if [ "$cmdline_ramptime" == "" ]; then  
                  ramptime="${arg#*=}"
             else
                  ramptime=$cmdline_ramptime
             fi         
         ;;
         --name=*)
             jobname="${arg#*=}"
         ;;
         --fill_device=*)
             fill_device="${arg#*=}"
         ;;
         --rwmixread=*)
             random_type="rwmixread"
             read_perc="${arg#*=}"
         ;; 
         --rwmixhostread=*)
             random_type="rwmixhostread"
             read_perc="${arg#*=}"
         ;; 
         --fallocate=*)
             fallocate="${arg#*=}"
         ;; 
         --create_on_open=*)
             create_on_open="${arg#*=}"
         ;;  
         --create_serialize=*)
             create_serialize="${arg#*=}"
         ;; 
         --tag=*)
             tag="${arg#*=}"
         ;;
         --create_only)
             create_only=1
         ;;                                                              
        esac
    done

    if [ "$cmdline_create_only" == "1" ]; then
        create_only=1
    fi   
   
    # Generate the summary log file name for the workload
    local qd=$((numjobs * iodepth)) 
    
    case "$rw" in
  
        randread)
            op="rd_rnd"
        ;;
      
        randwrite)
            op="wr_rnd"
        ;;
          
        randrw)
            op="rw_rnd"
        ;;            
      
        read)
            op="rd"
        ;;
          
        write)
            op="wr"
        ;; 
          
        rw|readwrite)
            op="rw"
        ;; 
    esac
   
    # Sanity check of the mandatory options in schedule file
    if [ "$rw" == "invalid" ] || [ "$numjobs" == "invalid" ] || [ "$iodepth" == "invalid" ] || [ "$bs" == "invalid" ]; then
         echo "Please specify --rw/--numjobs/--iodepth/--bs in schedule file"
         exit "$ERROR_CODE_MISSING_FIO_WORKLOAD_OPTIONS"
    fi                 

    # Need to differentiate the 2 mix read types in naming
    if [ "$read_perc" != "invalid" ]; then
        if [ "$random_type" == "rwmixreadhost" ]; then
            wl_name="${op}_qd_${qd}_${bs}_${read_perc}hostrd_${numjobs}w"
        else              
            wl_name="${op}_qd_${qd}_${bs}_${read_perc}rd_${numjobs}w"
        fi        
    else                            
        wl_name="${op}_qd_${qd}_${bs}_${numjobs}w"
    fi
    
    # For workloads that cannot be differentiated by the mandatory options,
    # append workload number as the unique identifier for the log filename
    if [ "$tag" == "1" ]; then
        if [ "$jobname" == "invalid" ]; then
            jobname="$wl_name"
        fi    
        wl_name+="_${wl_num}tag"
    fi
       
    cp "$WORKLOAD_DIR/fio/$fio_template" "$schedule_name/${wl_name}.ini"
    if [ "$wl_num" -gt 1 ]; then 
        sleep "$INTER_WORKLOAD_WAIT_IN_SECONDS"
    fi
             
    # Run workload 
    echo -e "\nBegin #$wl_num workload: $wl_name"
    run_fio_workload "$wl_name" "$wl_num" "$jobname" "$client_count" "$rw" "$numjobs" "$iodepth" "$bs" "$size" "$read_perc" "$random_type" "$create_on_open" "$fallocate" "$create_serialize" "$fill_device" "$create_only"
    echo -e "End of #$wl_num workload: $wl_name\n"
}

#=================================================================
# Parse elbencho file workload arguments and run it
#=================================================================
run_test_elbencho_file() {
    local wl_num=$1
    local client_count=$2    
    local elbencho_args elbencho_args_array
    elbencho_args=$(echo "$3" | xargs)    
    IFS=" " read -r -a elbencho_args_array <<< "$elbencho_args"        
    
    local threads="invalid"
    local iodepth="invalid"
    local bs="invalid"
    local op="invalid" 
    local jobname="invalid"  
    local tag="invalid"         
    
    # Parse the options in schedule file for log file naming
    local arg
    for arg in "${elbencho_args_array[@]}"
    do    
       case "$arg" in
         --write)
             op="wr"
         ;;
         --read)
             op="rd"
         ;;         
         --iodepth=*)
             iodepth="${arg#*=}"
         ;;
         --threads=*)
             threads="${arg#*=}"
         ;;
         --block=*)
             bs="${arg#*=}"
         ;;
         --rand) # This is optional
             random=1
         ;;    
         --name=*) # This is not from Elbencho
             jobname="${arg#*=}"
         ;;
         --tag=*)
             tag="${arg#*=}"
         ;;                                                                      
       esac
    done  
    
    # Remove elbencho unsupported options
    local elbencho_args_stripped elbencho_args_stripped_array
    elbencho_args_stripped=$(echo "$elbencho_args" | sed -e 's/[^ ]*--name=[^ ]*//ig' | sed -e 's/[^ ]*--tag=[^ ]*//ig')
    IFS=" " read -r -a elbencho_args_stripped_array <<< "$elbencho_args_stripped" 
   
    # Sanity check of the mandatory options in schedule file
    if [ "$op" == "invalid" ] || [ "$threads" == "invalid" ] || [ "$iodepth" == "invalid" ] || [ "$bs" == "invalid" ]; then
         echo "Please specify --rw/--threads/--iodepth/--bs in schedule file"
         exit "$ERROR_CODE_MISSING_ELBENCHO_FILE_WORKLOAD_OPTIONS"
    fi 
        
    local ELBENCHO_FILE_RESULT_SUBDIR_ON_HOST="elbencho/file"
    local ELBENCHO_FILE_RESULT_DIR_ON_CONTAINER="/vast-scale-testing/file"
    local result_filename="${op}-${bs}bs-${threads}t-${iodepth}iodepth"
    if [ "$random" == "1" ]; then
        result_filename+="_rnd"
    fi    
 
    # For workloads that cannot be differentiated by the mandatory options,
    # append workload number as the unique identifier for the log filename
    if [ "$tag" == "1" ]; then
        result_filename+="_${wl_num}tag"
    fi
        
    wl_name="$result_filename"  
     
    if [ "$wl_num" -gt 1 ]; then 
        sleep "$INTER_WORKLOAD_WAIT_IN_SECONDS"
    fi    
              
    echo -e "\nBegin #$wl_num workload: $wl_name" 
    mkdir -p "$run_dir/$ELBENCHO_FILE_RESULT_SUBDIR_ON_HOST" 
    docker container kill elbencho-client > /dev/null 2>/dev/null;
    docker container rm elbencho-client > /dev/null 2>/dev/null; 
    
    local data_directory=()
    if [ "$MULTIPATH_ENABLE" == "1" ]; then
        if [ "$jobname" == "invalid" ]; then
            data_directory=("/data/${REMOTE_PATH}")
        else
            data_directory=("/data/${REMOTE_PATH}/$jobname")
            clush -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" "io_dir=${MOUNT}/${REMOTE_PATH}/\$(hostname -s)/$jobname;
                                                              sudo mkdir -p \${io_dir}; sudo chown $uid:$uid \${io_dir}"
        fi
    else 
        local vip_count=0
        local vips_to_mount=()  
         
        for MOUNTVIP in "${ALL_VIPS[@]}"; do
            if [ "$jobname" != "invalid" ]; then   
                data_directory+=("/data/${REMOTE_PATH}/${HOST_SUBNET}.${MOUNTVIP}/$jobname")
            else
                data_directory+=("/data/${REMOTE_PATH}/${HOST_SUBNET}.${MOUNTVIP}")
            fi
            
            vips_to_mount+=("$MOUNTVIP")  
            vip_count=$((vip_count+1))           
        done 
        
        # Mount vips for this server if they haven't been mounted already
        # Applicable to individual mount only (multipath mount is always done upfront, and not affected by MOUNT_ALL flag)
        if [ "$MOUNT_ALL" == "0" ];
        then
            echo "MOUNT_ALL==0 is not supported for elbencho file testing"
            exit 
        else
            # Need to create the folder if jobname is specified.
            # For no jobname scenario, the folder should have been created when mounting.
            if [ "$jobname" != "invalid" ]; then
                for MOUNTVIP in "${vips_to_mount[@]}"; do       
                    clush -w "$client_nodes" -f "$CLUSH_MAX_FAN_OUT" "io_dir=${MOUNT}/${REMOTE_PATH}/\$(hostname -s)/${HOST_SUBNET}.${MOUNTVIP}/$jobname;
                                                                      sudo mkdir -p \${io_dir}; sudo chown $uid:$uid \${io_dir}"
                done
            fi            
        fi         
    fi
    
    if [ "$dry_run" == "0" ]; then
        docker run --rm --name elbencho-client --net=host -v "$run_dir/$ELBENCHO_FILE_RESULT_SUBDIR_ON_HOST:$ELBENCHO_FILE_RESULT_DIR_ON_CONTAINER" "breuner/elbencho:$ELBENCHO_TAG" "${data_directory[@]}" "${elbencho_args_stripped_array[@]}" --hosts "$client_nodes" --csvfile "$ELBENCHO_FILE_RESULT_DIR_ON_CONTAINER/${result_filename}.csv"
    fi
    
    echo -e "End of #$wl_num workload: $wl_name\n"
}

#=================================================================
# Parse elbencho S3 workload arguments and run it
#=================================================================
run_test_elbencho_s3() {
    local wl_num=$1
    local client_count=$2  
      
    local elbencho_args elbencho_args_array
    elbencho_args=$(echo "$3" | xargs)
    IFS=" " read -r -a elbencho_args_array <<< "$elbencho_args"  
    
    # Parse the options in schedule file for log file naming
    local arg op threads bs random
    for arg in "${elbencho_args_array[@]}"
    do    
       case "$arg" in
         --write)
             op="wr"
         ;;
         --read)
             op="rd"
         ;;         
         --threads=*)
             threads="${arg#*=}"
         ;;
         --block=*)
             bs="${arg#*=}"
         ;;
         --rand)  # This is optional
             random=1
         ;;          
       esac
    done   
    
    # Sanity check of the mandatory options in schedule file
    if [ "$op" == "invalid" ] || [ "$threads" == "invalid" ] || [ "$iodepth" == "invalid" ] || [ "$bs" == "invalid" ]; then
         echo "Please specify --rw/--numjobs/--iodepth/--bs in schedule file"
         exit "$ERROR_CODE_MISSING_ELBENCHO_S3_WORKLOAD_OPTIONS"
    fi     

    local ELBENCHO_S3_RESULT_SUBDIR_ON_HOST="elbencho/s3"
    local ELBENCHO_S3_RESULT_DIR_ON_CONTAINER="/vast-scale-testing/s3"
    local result_filename="${op}-${bs}bs-${threads}t-${iodepth}iodepth"    
    if [ "$random" == "1" ]; then
        result_filename+="_rnd"
    fi
       
    local endpoints
    endpoints=$(eval echo "http://$HOST_SUBNET.{$HOST_SUBNET_FIRST_VIP_LAST_FIELD..$HOST_SUBNET_LAST_VIP_LAST_FIELD}")
    
    wl_name="$result_filename"       
    if [ "$wl_num" -gt 1 ]; then 
        sleep "$INTER_WORKLOAD_WAIT_IN_SECONDS"
    fi          
    echo -e "\nBegin #$wl_num workload: $wl_name"
    mkdir -p "$run_dir/$ELBENCHO_S3_RESULT_SUBDIR_ON_HOST"
    docker container kill elbencho-client > /dev/null 2>/dev/null;
    docker container rm elbencho-client > /dev/null 2>/dev/null;
    
    if [ "$dry_run" == "0" ]; then
        docker run --rm --name elbencho-client --net=host -v "$run_dir/$ELBENCHO_S3_RESULT_SUBDIR_ON_HOST:$ELBENCHO_S3_RESULT_DIR_ON_CONTAINER" "breuner/elbencho:$ELBENCHO_TAG" "${elbencho_args_array[@]}" --s3endpoints "$endpoints" --s3key "$ELBENCHO_S3KEY" --s3secret "$ELBENCHO_S3SECRET" --hosts "$client_nodes" --csvfile "$ELBENCHO_S3_RESULT_DIR_ON_CONTAINER/${result_filename}.csv"
    fi
    
    echo -e "End of #$wl_num workload: $wl_name\n"
}

#=================================================================
# Run test with the client count of current step.
# Each step will run all workloads in the schedule file. 
#=================================================================
run_step () {
    
    local client_count=$1
    
    before_test
    
    # Any abort after context is save will do normal shutdown handling
    #graceful_terminate_required=1    
    
    local wl_num=0    
    local workloads=()
    local line
    
    while read -r line
    do
        line=$(echo "$line" | xargs)
        
        # Skip the comment and empty lines
        if [ "$line" == "" ] || [[ "$line" == "#"* ]]; then continue; fi
        
        workloads+=("$line ")
        
    done < "$schedule_name.$schedule_name_ext"  # clush seems to screw up the read sometimes, so read lines to workloads variable first
        
    for line in  "${workloads[@]}"
    do
        line=$(echo "$line" | xargs)
        
        # There is still an empty line, so filter again
        if [ "$line" == "" ] || [[ "$line" == "#"* ]]; then continue; fi
                  
        echo "Parsing: $line" 
        
        local wl_num=$((wl_num + 1))      
                
        case "$test_type" in
    
          "fio")
            run_test_fio           "$wl_num" "$client_count" "$line"
            ;;
          "elbencho-file")
            run_test_elbencho_file "$wl_num" "$client_count" "$line"
            ;;
          "elbencho-s3")
            run_test_elbencho_s3   "$wl_num" "$client_count" "$line"
            ;;
        esac          
    done
    
    after_test   
}

#=================================================================
# Run test with specified network speed, schedule file and step size
#=================================================================
run_test () {
   
    schedule_name="$(basename "$schedule_file" | cut -d'.' -f 1)"
    schedule_name_ext="$(basename "$schedule_file" | cut -d'.' -f 2)" 
    hostname=$(hostname -s) 
       
    local count=$STEP_SIZE
    local previous_count=0
    
    local step
    for step in $(seq 1 $STEPS)
    do
        if [ "$step" -gt 1 ]; then 
            sleep "$INTER_STEP_WAIT_IN_SECONDS"
        fi     
        
        local actual_step_size=$((count - previous_count)) # for incremental type, previous_count is always 0
        local client_nodes_string
        client_nodes_string="${CLIENT_NODES_ARRAY[*]:$previous_count:$actual_step_size}"
        
        IFS=" " read -r -a client_nodes_array <<< "$client_nodes_string"         
        client_nodes=${client_nodes_string// /,}          
                
        echo -e "\nBegin the test of $count clients..."
        if [ "$step_type" == "$STEP_TYPE_CONSTANT" ]; then
            result_prefix="${common_prefix}_${actual_step_size}ClientsFrom${previous_count}"
        else        
            result_prefix="${common_prefix}_${count}Clients"
        fi
        run_dir="${RESULTS_DIR}/${result_prefix}_${schedule_name}_${hostname}"
        if [ "$extra_prefix" != "" ]; then
            run_dir="${run_dir}_${extra_prefix}"
        fi
        mkdir -p "$run_dir"
        
        echo "$run_dir" > "$RUN_DIR_TEMP_FILE"
         
        pushd "$run_dir" || exit "$ERROR_CODE_FAIL_TO_GOTO_DIR"

        run_step "$count"
        
        popd || exit "$ERROR_CODE_FAIL_TO_EXIT_DIR"
        
        if [ "$step_type" == "$STEP_TYPE_CONSTANT" ]; then
            previous_count="$count"
        fi
        count=$((count + STEP_SIZE))
        if [ $count -gt "$CLIENT_COUNT" ]; then
            count="$CLIENT_COUNT"
        fi
    done
}

#=================================================================
# Call functions defined above to kick off the test
#=================================================================
parse_command_line "$@"
parse_env_and_set_globals
check_client_status_and_deploy_files
set_irqb_tb_ht_controls
mount_vips
start_services
run_test
