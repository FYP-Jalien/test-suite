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
source job_flow_logs/index.sh
source advanced_logs/index.sh

print_test_summary
