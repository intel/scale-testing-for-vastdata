#!/bin/bash

# Intel Copyright © 2021, Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

IN_FILE="$1"

if [ ! -f "$IN_FILE" ] || [[ -L "$IN_FILE" ]] ; then
    echo "File $IN_FILE not found or is symbolic link!"
    exit 2 # Standard error code ENOENT: No such file or directory
fi

WL=${IN_FILE//_summary.log/}
echo "$WL"
OUT_FILE="${WL}_summary.json"
ALL_CLIENTS_OUT_DIR="All_Clients"

echo -e "Start splitting ${IN_FILE}: $(date)"

sed '/{/,$d' < "$IN_FILE" > "${WL}_summary.inf"
sed '/{/,$!d' < "$IN_FILE" > "${WL}_summary.json"

mkdir -p "${ALL_CLIENTS_OUT_DIR}"

touch "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}"
{
    echo "{"
    echo "  \"fio_version\" : $(jq '."fio version"' < "${OUT_FILE}"),"
    echo "  \"timestamp\" : $(jq '."timestamp"' < "${OUT_FILE}"),"
    echo "  \"time\" : $(jq '."time"' < "${OUT_FILE}"),"
} >> "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.common"

echo '  "global options" : {' > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options.tmp1"
jq '."global options"' < "${OUT_FILE}" | sed 's/}/},/g' > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options.tmp2"
sed 's/^/    /' "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options.tmp2" >  "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options.tmp3"
sed '1d' "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options.tmp3" > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options.tmp4"
cat "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options.tmp1" "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options.tmp4" > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options"

# extract summry which is the last item in array (-1 index)
echo '  "client_stats" : [' > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.stats.tmp1"
jq '."client_stats"[-1]' < "${OUT_FILE}" > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.stats.tmp2"
sed 's/^/    /' "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.stats.tmp2" > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.stats.tmp3"
cat "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.stats.tmp1" "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.stats.tmp3" > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.stats"
echo '  ],' >> "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.stats"

echo '  "disk_util" : [' > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.util.tmp1"
jq '."disk_util"[-1]' < "${OUT_FILE}" > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.util.tmp2"
sed 's/^/    /' "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.util.tmp2" > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.util.tmp3"
cat "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.util.tmp1" "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.util.tmp3" > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.util"
echo '  ]' >> "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.util"


cat "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.common" "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options" "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.stats" "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.util" > "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}"
echo '}' >> "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}"

client_num=$(jq '."client_stats" | length' < "${OUT_FILE}")
for i in $(seq 0 $((client_num - 2))); do
    jq ".\"client_stats\"[${i}]" < "${OUT_FILE}" > "client-${i}.tmp1"    
    sed 's/^/    /' "client-${i}.tmp1" > "client-${i}.tmp2"
    echo '  ]' >> "client-${i}.tmp2"        
    cat "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.common" "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.options" "${ALL_CLIENTS_OUT_DIR}/${OUT_FILE}.stats.tmp1" "client-${i}.tmp2" > "client-${i}.json"
    echo '}' >> "client-${i}.json"
    hostname=$(grep "hostname" "client-${i}.json" | cut -d'"' -f 4)
    mkdir -p "$hostname"
    mv "client-${i}.json" "$hostname/${WL}_summary.json"
done

rm -rf ./*.tmp* ./${ALL_CLIENTS_OUT_DIR}/*.tmp* ./${ALL_CLIENTS_OUT_DIR}/*.common ./${ALL_CLIENTS_OUT_DIR}/*.options ./${ALL_CLIENTS_OUT_DIR}/*.stats ./${ALL_CLIENTS_OUT_DIR}/*.util

echo -e "Done:  $(date)"