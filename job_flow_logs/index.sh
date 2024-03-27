#!/bin/bash

set -e

index_file_name="job_flow_logs"
source "$index_file_name/ce/index.sh"

index_file_name="job_flow_logs"
source "$index_file_name/worker/index.sh"

