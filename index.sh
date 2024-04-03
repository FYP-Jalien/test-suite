#!/bin/bash

source .env
source func/messages.sh
source func/conversions.sh

args=("$@")

executeCommon=true
executeContainer=true
executeJobFlow=true
executeAdvancedLogs=true

for arg in "${args[@]}"; do
    if [ "$arg" = "--host-only" ]; then
        executeContainer=false
        executeJobFlow=false
        executeAdvancedLogs=false
    elif [ "$arg" = "--container-only" ]; then
        executeJobFlow=false
        executeAdvancedLogs=false
    elif [ "$arg" = "--flow-only" ]; then
        executeAdvancedLogs=false
    fi
    if [ "$arg" = "--csv" ]; then
        add_to_csv=true
        rm -f "$OUT_CSV_PATH"
        rm -f "$SUMMARY_CSV_PATH"
    fi
done

id=0
critical_count=0
warning_count=0
minor_count=0
critical_fail=0
warning_fail=0
minor_fail=0

print_test_header

if [ $executeCommon = true ]; then
    source common/index.sh
fi

if [ $executeContainer = true ]; then
    source central/index.sh
    source schedd/index.sh
    source se/index.sh
    source ce/index.sh
    source worker/index.sh
fi

if [ $executeJobFlow = true ]; then
    source job_flow/index.sh
    source job_flow_logs/index.sh
fi

if [ $executeAdvancedLogs = true ]; then
    source advanced_logs/index.sh
fi

print_test_summary
