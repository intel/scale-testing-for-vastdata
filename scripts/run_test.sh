#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

# Any inputs will be passed to run_test_no_runlog.sh transparently hence validated there
echo "$0" "$@"

script_dir="$(cd "$(dirname "$0")" || exit; pwd)"
source "$script_dir/common.conf"

# script_dir and SCRIPT_DIR are the same, but SCRIPT_DIR is preferred after sourcing common.conf
runner="$SCRIPT_DIR/run_test_no_runlog.sh"

# Ctrl + C abort handler
function abort_handler() {
    echo "Test aborted with CTRL C, cleaning up..."
    end_of_test
}

# Abort takes the same steps to end the test as normal execution
function end_of_test() {

    if [[ ! -L "$RUN_DIR_TEMP_FILE" ]] && [ -f "$RUN_DIR_TEMP_FILE" ]; then
    
        while IFS= read -r run_dir
        do
            if [ -d "$run_dir" ]
            then
                if [[ ! -L "$RUN_LOG_FILE" ]] && [ -f "$RUN_LOG_FILE" ]; then
                    # Abort case will leave run log in staging folder, move it to the result folder
                    mv "$RUN_LOG_FILE" "$run_dir"
                fi
                if [[ ! -L "$RUN_ERROR_LOG_FILE" ]] && [ -f "$RUN_ERROR_LOG_FILE" ]; then
                    # Abort case will leave run error log in staging folder, move it to the result folder
                    mv "$RUN_ERROR_LOG_FILE" "$run_dir"
                fi
            fi
        done < "$RUN_DIR_TEMP_FILE"
        
        rm -rf "$RUN_DIR_TEMP_FILE"
    fi
    
    [ -n "$return_code" ] && [ "$return_code" -eq "$return_code" ] 2>/dev/null
    status="$?"
    if [ "$status" -eq 0 ]; then
       # return_code is a number
       exit "$return_code"
    fi
}

# Trap ctrl-c to cleanup before exit
trap abort_handler INT

# Remove the temporary file first
if [[ ! -L "$RUN_DIR_TEMP_FILE" ]] && [ -f "$RUN_DIR_TEMP_FILE" ]; then
    rm -rf "$RUN_DIR_TEMP_FILE"
fi

# Execute the runner only if it's not a symbolic link and if it exists
if [[ ! -L "$runner" ]] && [ -f "$runner" ]; then
    # Error code from runner not handled other than being provided as the return code, 
    # this is because we always exit if anything goes wrong.
    set -o pipefail
    $runner "$@" 2>&1 | tee -a "$RUN_LOG_FILE"
    return_code=$?
fi

# Disable ctrl + c, so that we always do proper cleanup
trap '' INT
end_of_test


 