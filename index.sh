#!/bin/bash

source func/messages.sh
source func/conversions.sh
source .env

id=0
critical_count=0
warning_count=0
minor_count=0
critical_fail=0
warning_fail=0
minor_fail=0

print_test_header

source common/index.sh
source central/index.sh
source schedd/index.sh
source se/index.sh
source ce/index.sh
source worker/index.sh
source job_flow/index.sh

critical_success=$((critical_count - critical_fail))
warning_success=$((warning_count - warning_fail))
minor_success=$((minor_count - minor_fail))

print_test_summary
